---
name: triage
description: When the issue queue has open unlabeled issues -- run a read-only triage pass that labels each issue by component, category, and priority, flags duplicates, closes noise, and reports the p1 queue before runners are dispatched.
---

# triage

The issue queue is the dispatcher's input. When issues land
unlabeled, the dispatcher can't scope or prioritize without first
reading every body -- which defeats the point of durable state.
Triage fixes that: a read-only pass that reads each open issue and
writes back labels, so the queue becomes self-describing. Triage
labels, comments, and closes noise; it does NOT implement fixes.

## When to apply

- At the **start of a work session** when open unlabeled issues
  exist -- before scoping any runner.
- When the dispatcher (or human) explicitly asks to **"triage open
  issues"**.

If every open issue is already labeled, skip triage and go straight
to scoping.

## The triage workflow

Run the pass one issue at a time. It is entirely read-plus-label;
no code changes.

1. **List all open issues** with their current labels and bodies:

   ```bash
   gh issue list --state open --json number,title,labels,body
   ```

2. **For each unlabeled issue**, read the full body and determine
   three labels:
   - **Component** -- `skills` / `agents` / `ci` / `docs`
   - **Category** -- `bug` / `feat` / `field-feedback` / `research` /
     `chore`
   - **Priority** -- `p1` / `p2` / `p3` (see heuristics below)

3. **Apply the labels** in one edit:

   ```bash
   gh issue edit N --add-label "skills,feat,p2"
   ```

4. **Check for duplicates.** If a near-duplicate open issue exists,
   comment linking them rather than silently relabeling:

   ```bash
   gh issue comment N --body "Possible duplicate of #M"
   ```

   Leave both open; the human decides which to close.

5. **Close obvious noise** -- test issues, empty bodies, or clearly
   non-actionable items:

   ```bash
   gh issue close N --comment "Closing: empty body, not actionable. Reopen with detail if needed."
   ```

6. **Emit a brief triage report**: N issues processed, breakdown by
   priority, any duplicates flagged, any issues closed. Keep it
   terse -- the labels are the durable output; the report is a
   summary for the human.

## Priority heuristics

| priority | meaning | examples |
|---|---|---|
| **p1** | Blocking or high-impact | runtime failures, broken CI, missing core behavior an agent depends on |
| **p2** | Standard queue | improvements, new skills, documentation gaps |
| **p3** | Nice-to-have | minor wording, future shapes, brainstorm ideas |

Most issues are p2. p1 is reserved for things that block work or
break the substrate; if everything is p1, nothing is. p3 is for work
worth recording but not worth scheduling yet.

## Label selection guidance

**Component** -- where the change lands:

- `skills` -- a skill file under `skills/`
- `agents` -- an agent definition under `agents/`
- `ci` -- workflows, gates, repo automation
- `docs` -- README or other documentation

**Category** -- what kind of change:

- `bug` -- documented behavior diverges from actual behavior
- `feat` -- new capability (new skill, new agent, new section)
- `field-feedback` -- surfaced from a dispatch-time observation
- `research` -- open question or investigation, not yet a fix
- `chore` -- maintenance, housekeeping, no behavior change

When an issue spans components, pick the primary one and note the
secondary in a comment. Don't stack every plausible label.

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
