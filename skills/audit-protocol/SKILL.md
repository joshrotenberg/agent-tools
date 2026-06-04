---
name: audit-protocol
description: >-
  Use when dispatching an auditor or implementing an audit pass: defines the
  rubric format the auditor expects and the five-phase execution contract
  (Orient, Evaluate, Triage, File, Report) the auditor follows.
---

# audit-protocol

The audit-protocol skill defines two interrelated contracts: (1) the rubric
format that a well-formed auditor dispatch must supply, and (2) the five-phase
execution contract the auditor follows. Both are load-bearing -- a vague rubric
produces vague issues; an auditor that skips phases (especially duplicate-check
before filing) produces noise.

## When to apply

- When **dispatching an auditor**: use this skill to verify your rubric is
  well-formed before firing. A missing priority heuristics section or a missing
  "what to skip" boundary guarantees low-value output.
- When **implementing an audit pass**: follow the five-phase contract
  sequentially. Do not collapse Orient + Evaluate into a single pass; read all
  sources before drawing conclusions.
- When **reviewing audit output**: use the rubric format and report shape to
  verify the auditor returned a complete, structured result.

## Rubric format

Agents dispatching auditors must provide a structured rubric. A vague rubric
produces vague, low-value issues. A well-formed rubric has four required
sections:

```markdown
## Rubric

### What "complete" looks like
<Description of the fully-realized end state for this domain>

### Priority heuristics
- `priority: high`: <conditions -- e.g. "gaps that cause silent data loss or cascading failures">
- `priority: medium`: <conditions>
- `priority: low`: <conditions>

### What to skip
<Explicit out-of-scope items for this audit domain>

### Cross-cutting question
Are there concerns that span multiple areas and would be missed by a narrower checklist?
```

Priority heuristics belong in the rubric, not in agent judgment. When the rubric
says "`priority: high` for gaps that can cause silent data loss," the auditor
applies that rule; without it, priority becomes a guess.

## Execution contract

Five phases, in order:

### 1. Orient

Read all files listed in `files_to_read` before drawing any conclusions. If
`external_refs` are provided, fetch them now. External references make coverage
audits dramatically more accurate -- an external commands reference reveals gaps
that first-principles reasoning misses entirely. Always fetch when provided.

### 2. Evaluate

Compare actual state against the rubric. Identify both:

- **Gaps** -- things the rubric requires that are absent or incomplete
- **Confirmations** -- things the rubric requires that are genuinely present

Both matter. Confirmed-good findings prevent re-auditing. Pose the
cross-cutting question: are there issues that span areas and would be missed
by a narrower checklist?

### 3. Triage

Decide issue grouping and priority. Grouping calibration:

- Too granular (1 issue per missing command): noise, hard to prioritize
- Too coarse (1 issue per domain): loses actionability; runners can't pick up
- Right level: 1 issue per logical work unit a runner can implement in one PR

Apply priority from the rubric's heuristics, not judgment.

### 4. File

For each finding, run a pre-flight duplicate check first:

```bash
gh issue list --search "<keywords from the finding title>" --repo <repo>
```

If a matching issue exists, note it as "already tracked" and skip. If no
match, file with a structured body:

- **Current state** -- what the code actually does today
- **Desired state** -- what it should do per the rubric
- **Code example** -- concrete example showing the improvement (where applicable)
- **Implementation notes** -- files to touch, approach

The pre-flight check is essential when running parallel auditors on the same
repo -- it prevents noise without requiring a post-reconciliation pass.

In `dry_run` mode: print the issue draft (title, labels, body) but do NOT
call `gh issue create`.

### 5. Report

Return a structured report with three sections:

1. **Filed issues** -- table: `#N | title | priority | one-line rationale`.
   The table format is non-negotiable. Prose summaries lose signal; the table
   is immediately scannable by the dispatcher reviewing audit output.
2. **Confirmed good** -- brief list of things evaluated and found complete.
   Required, not optional -- prevents future re-auditing of covered areas.
3. **Out of scope / skipped** -- anything noticed but not filed: scope
   boundaries, out-of-domain findings, items already tracked.

## Anti-patterns

- **Vague rubric, vague output.** A rubric that says "check for quality" without
  a "what complete looks like" section or priority heuristics will produce issues
  that are hard to prioritize and easy to argue about. Reject vague rubrics at
  dispatch time; ask for the four required sections.
- **Skipping Orient.** Reading some files and evaluating in the same pass risks
  premature conclusions. Complete the file read before comparing against the rubric.
- **Filing without duplicate check.** The pre-flight `gh issue list --search`
  in phase 4 is not optional. Parallel auditors on the same repo converge on the
  same gaps; skipping the check creates duplicate issues that clutter the backlog.
- **Priority from judgment, not rubric.** If the rubric defines priority heuristics,
  apply them. Substituting personal judgment inverts the rubric's purpose.
- **Omitting confirmed-good.** A report without a confirmed-good section is
  incomplete. Future dispatchers need to know what areas are already covered.
- **Filing out-of-scope findings.** Note them in the "Out of scope / skipped"
  section; do NOT file them as issues. The domain owner files their own issues.

## Related

- [`agents/auditor.md`](../../agents/auditor.md) -- the agent that
  executes this protocol; the audit-protocol skill is a required preload for it
- [`skills/triage/SKILL.md`](../triage/SKILL.md) -- triage labels and prioritizes
  existing issues; audit-protocol produces new ones
- [`skills/orchestration-patterns/SKILL.md`](../orchestration-patterns/SKILL.md)
  -- "audit + remediate" is the execution shape that uses the auditor
- [`agents/runner.md`](../../agents/runner.md) -- the natural next step
  after an audit produces a backlog; implements the filed issues
