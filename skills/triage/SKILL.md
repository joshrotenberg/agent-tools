---
name: triage
description: When the issue or PR queue has open unlabeled items -- run a read-only triage pass that labels each one by component, category, priority, and size, flags duplicates, closes noise, and reports the p1 queue before runners are dispatched.
allowed-tools: Bash(gh:*)
---

# triage

Current open issues: !`gh issue list --state open --json number,title,labels --jq 'map({number,title,labels:(.labels|map(.name))})'`

Current open PRs: !`gh pr list --state open --json number,title,labels --jq 'map({number,title,labels:(.labels|map(.name))})'`

The issue and PR queues are the dispatcher's input. When items land
unlabeled, the dispatcher can't scope or prioritize without first
reading every body -- which defeats the point of durable state.
Triage fixes that: a read-only pass that reads each open issue and
PR and writes back labels, so the queue becomes self-describing.
Triage labels, comments, and closes noise; it does NOT implement
fixes.

## When to apply

- At the **start of a work session** when open unlabeled issues or
  PRs exist -- before scoping any runner.
- When the dispatcher (or human) explicitly asks to **"triage open
  issues"** or **"triage open PRs"**.

If every open item is already labeled, skip triage and go straight
to scoping.

## The triage workflow

Run the pass one item at a time. It is entirely read-plus-label;
no code changes. The same pass covers both issues and PRs; the
`gh issue` commands below have `gh pr` equivalents
(`gh pr list`, `gh pr edit`, `gh pr comment`).

1. **List all open issues and PRs** with their current labels and
   bodies:

   ```bash
   gh issue list --state open --json number,title,labels,body
   gh pr list --state open --json number,title,labels,body,files
   ```

2. **For each unlabeled item**, read the full body and determine
   its labels from the taxonomy below:
   - **Component** -- where the change lands
   - **Category** -- what kind of change
   - **Priority** -- `p1` / `p2` / `p3` (see heuristics below)
   - **Size** (PRs) -- `size/small` / `size/medium` / `size/large`,
     from the file count

3. **Apply the labels** in one edit:

   ```bash
   gh issue edit N --add-label "skills,feat,p2"
   gh pr edit N --add-label "skills,feat,p2,size/small"
   ```

   A PR's component and category should match the issue it closes;
   add the size label from its changed-file count.

4. **Normalize the title.** Check whether the title has a conventional
   commit prefix (`feat:`, `fix:`, `docs:`, `chore:`, `ci:`, `perf:`,
   `refactor:`, `test:`). If not -- or if it uses a non-canonical prefix
   like `research:` or `brainstorm:` -- determine the correct type from
   the body and labels, then rename:

   ```bash
   gh issue edit N --title "type: normalized title"
   gh pr edit N --title "type: normalized title"
   ```

   The same prefix scheme applies to PR titles.

   Mapping rules for non-canonical prefixes:

   - `research:` → `docs:` (if the issue documents findings or a
     known gap) or `chore:` (if it's internal housekeeping)
   - `brainstorm:` → `docs:` (design sketches and deferred ideas)

   If the correct prefix is ambiguous, do NOT rename. Leave a comment
   instead:

   ```bash
   gh issue comment N --body \
     "Title is missing a conventional commit prefix. Candidates: feat / docs / chore. Please rename when the type is clear."
   ```

5. **Check for duplicates.** If a near-duplicate open issue exists,
   comment linking them rather than silently relabeling:

   ```bash
   gh issue comment N --body "Possible duplicate of #M"
   ```

   Leave both open; the human decides which to close.

6. **Close obvious noise** -- test issues, empty bodies, or clearly
   non-actionable items:

   ```bash
   gh issue close N --comment "Closing: empty body, not actionable. Reopen with detail if needed."
   ```

7. **Emit a brief triage report**: N issues and PRs processed,
   breakdown by priority, any duplicates flagged, any issues
   closed. Keep it terse -- the labels are the durable output; the
   report is a summary for the human.

## The label taxonomy

Every issue and PR draws from four axes. This is the single
source of truth for which labels exist and what they mean.

**Component** -- where the change lands:

- `skills` -- a skill file under `skills/`
- `agents` -- an agent definition under `agents/`
- `ci` -- workflows, gates, repo automation
- `docs` -- README or other documentation

**Category** -- what kind of change. These mirror the
conventional-commit prefixes used on commits, branches, PR titles,
and issue titles:

- `feat` -- new capability (new skill, new agent, new section)
- `fix` -- a correction; documented behavior diverges from actual
- `docs` -- documentation only
- `chore` -- maintenance, housekeeping, no behavior change
- `ci` -- workflows, gates, release process
- `test` -- tests only

Two non-prefix category labels are also in use and do not map to a
commit type: `field-feedback` (surfaced from a dispatch-time
observation) and `research` (open question or investigation, not
yet a fix). The `bug` label is the GitHub default; prefer `fix`
for the category axis.

**Priority** -- `p1` / `p2` / `p3` (see heuristics below).

**Size** (PRs only) -- from the changed-file count:

- `size/small` -- 1-3 files changed
- `size/medium` -- 4-10 files changed
- `size/large` -- 10+ files changed

When an item spans components, pick the primary one and note the
secondary in a comment. Don't stack every plausible label.

### Priority heuristics

| priority | meaning | examples |
|---|---|---|
| **p1** | Blocking or high-impact | runtime failures, broken CI, missing core behavior an agent depends on |
| **p2** | Standard queue | improvements, new skills, documentation gaps |
| **p3** | Nice-to-have | minor wording, future shapes, brainstorm ideas |

Most issues are p2. p1 is reserved for things that block work or
break the substrate; if everything is p1, nothing is. p3 is for work
worth recording but not worth scheduling yet.

## After triage

**Surface the p1 queue to the human before dispatching runners.**
Triage produces a prioritized queue, not a dispatch plan. The human
reviews the p1 items first; only then does the dispatcher begin
scoping and firing runners against the labeled queue.

## Anti-patterns

- **Labeling everything p1.** Priority inflation makes the queue
  useless. Reserve p1 for genuinely blocking work.
- **Skipping the duplicate check.** Relabeling a duplicate without
  flagging it buries the relationship and invites parallel runners
  on the same work.
- **Implementing fixes during triage.** Triage is read-only by
  design: it reads, labels, comments, and closes noise. The moment
  you edit project code, you've stopped triaging and started a
  runner's job -- dispatch one instead.
- **Closing issues that are merely vague.** Close noise (empty,
  test, non-actionable); for a thin-but-real issue, label it and
  let the runner ask for detail.

## Related skills

- [`orchestration-patterns`](../orchestration-patterns/SKILL.md) --
  triage-then-dispatch is a variant of audit + remediate: a
  read-only pass that writes findings (here, labels) to durable
  state before the runner phase.
- [`dispatch-options`](../dispatch-options/SKILL.md) -- triage is
  best dispatched read-only (`subagent_type: "explore"` / no
  worktree); pick the mechanism here.
- [`agent-feedback`](../agent-feedback/SKILL.md) -- if triage reveals
  a skill or agent gap, file it rather than working around it.
- [`field-feedback`](../field-feedback/SKILL.md) -- issues labeled
  `field-feedback` originate from dispatch-time observations filed
  via this skill.
