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
   - **Priority** -- `p1` / `p2` / `p3` (see heuristics below)
   - **Area** -- `area/*`, where the change lands, if the repo
     defines any
   - **Size** (PRs) -- `size/small` / `size/medium` / `size/large`,
     from the file count

   Leave the `status/*` axis alone. The runner and dispatcher set it
   during execution, and overwriting it during a triage pass drops a
   claim on work already underway.

3. **Apply the labels** in one edit:

   ```bash
   gh issue edit N --add-label "p2,area/skills"
   gh pr edit N --add-label "p2,area/skills,size/small"
   ```

   A PR's priority and area should match the issue it closes; add
   the size label from its changed-file count.

   **Never apply `good first issue` or `help wanted`.** These labels
   feed GitHub's global beginner-issue firehose, which PR-farming
   bots scrape and pounce on within minutes. They are not part of
   the taxonomy above; if a human added one, leave it, but triage
   never adds them.

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

   With no type axis in the taxonomy, the prefix is the only thing
   that makes an item findable by type
   (`gh issue list --search "fix: in:title"`). An unprefixed title
   is a gap in the queue, not a cosmetic one.

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

Defined in
[`issue-pr-conventions`](../issue-pr-conventions/SKILL.md), which is
the source of truth for which labels exist. Triage applies them; it
does not define them. The short form:

| axis | labels | applied by triage |
|---|---|---|
| priority | `p1`, `p2`, `p3` | yes |
| area | `area/*`, repo-defined, cap 6 | yes |
| status | `status/in-progress`, `status/blocked`, `status/needs-review` | no, the runner and dispatcher own these |
| size (PRs only) | `size/small`, `size/medium`, `size/large` | yes |

**There is no type axis.** The conventional-commit prefix in the
title carries the type, so a `feat` or `bug` label would store the
same fact twice. If a repo still has those labels, triage does not
apply them; retiring them is the adoption pass described in the
conventions skill, not a triage job.

`field-feedback` is the one label outside the axes. It records that
an agent filed the item from a dispatch-time observation, which the
title prefix cannot express.

### Applying the axes

The priority heuristics table and the area cap live in
[`issue-pr-conventions`](../issue-pr-conventions/SKILL.md). What
that means at the point of labeling:

- **Most items are p2.** Reserve p1 for work that blocks or breaks
  the substrate; if everything is p1, nothing is.
- **Pick one area.** When an item spans two, label the primary and
  note the secondary in a comment. If the repo defines no `area/*`
  labels, skip the axis rather than inventing one per item.
- **Leave `status/*` alone.** It reflects execution state the
  runner and dispatcher own.

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
- [`issue-pr-conventions`](../issue-pr-conventions/SKILL.md) -- the
  source of truth for the labels this pass applies and the naming
  this pass normalizes to.
- [`agent-feedback`](../agent-feedback/SKILL.md) -- if triage reveals
  a skill or agent gap, file it rather than working around it.
- [`field-feedback`](../field-feedback/SKILL.md) -- issues labeled
  `field-feedback` originate from dispatch-time observations filed
  via this skill.
