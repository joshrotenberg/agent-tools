---
name: work-reports
description: >-
  The two report shapes for a unit of work: the plan report written before the
  work starts (the draft PR body) and the completion report written when it
  ends (the return summary and the ready PR). Both are mechanical -- a verdict
  line, a labeled block of one-fact bullets, an explicit gate roll-call naming
  each gate, and a statement of what was left undone. Load before writing a
  draft PR body or reporting a finished dispatch.
---

# work-reports

Two reports per unit of work, and no third. Before: what is
planned. After: what was done. Both are mechanical, which is the
point. A reader scanning ten of these should find the same fact in
the same place every time.

This defines the **shape**.
[`github-authoring`](../github-authoring/SKILL.md) governs the voice
inside it, and
[`non-pr-output-conventions`](../non-pr-output-conventions/SKILL.md)
decides where a report goes when the work produces no PR.

## When to apply

- Writing the draft PR body when claiming an issue (the plan report)
- Reporting a finished dispatch to a human or a dispatcher (the
  completion report)
- Reporting on a set of work rather than one issue: same two
  shapes, the unit is the set

## The plan report

Goes in the draft PR body, per the claim protocol in
[`issue-pr-conventions`](../issue-pr-conventions/SKILL.md). It
answers one question: can another agent read this and tell whether
its own task overlaps?

```markdown
Closes #<N>.

## Plan

<One or two sentences: what changes and why. No restating the issue.>

### <New | Changes>

- <verb-first, one fact per bullet>
- <name files or areas, not adjectives>

### Verification

<The gates that will run, named individually.>

### Out of scope

<What this deliberately does not do, and where it is recorded.>
```

`Out of scope` is not optional padding. It is what stops the next
agent from assuming the unit covers more than it does.

## The completion report

Four parts, in order. Every one of them earns its place.

### 1. Verdict line

One sentence, state first, no preamble. The reader should be able
to stop here.

```text
Opened draft PR #537: docs: align config help and guides.
PR #536 is green across Ubuntu stable/beta, macOS, Windows, Clippy, docs, and release checks.
Completed both issues and stopped.
Backlog is handoff-ready.
```

Not: "I've gone ahead and finished up the work on the config
alignment, and I'm happy to report that everything looks good."

### 2. The labeled block

A short label (`This batch:`, `Changes:`, `Suggested order:`) then
bullets. One fact per bullet, verb first, no adjectives, no
justification.

```text
Changes:

- Stabilized the Codex fail-closed test around semantic behavior.
- Merged current main.
- Integrated session policy with the config-proposal host path.
- Added a compact host-options boundary to stay Clippy-clean.
```

Bullets are parallel: same tense, same grammatical shape, roughly
the same length. A bullet that needs a sentence of explanation is
either two bullets or belongs in the prose paragraph below the
block.

### 3. The gate roll-call

Name every gate and state the result. `Tests pass` is not a gate
roll-call, because it does not say which gates ran or which were
skipped.

```text
All formatting, lint, test, Clippy, rustdoc, and release-build gates pass.
Working tree is clean.
```

For a set of gates with mixed results, use a table:

| gate | result |
|---|---|
| `cargo fmt --all -- --check` | pass |
| `cargo clippy --all-targets -- -D warnings` | pass |
| `cargo test` | 152 pass, 0 fail |

A gate that did not run is reported as not run, never omitted.
Omission reads as pass.

### 4. The negative-space line

State what is not true, or what was left undone. This is the part
a reader cannot ask for, because they do not know to ask.

```text
No open issue was left unlabeled.
Working tree is clean.
No repo was migrated; labels are unchanged everywhere.
Two of the six findings are deferred and recorded in CLAUDE.md.
```

If nothing was left undone and nothing is outstanding, say that in
one line. Silence here reads as completeness and is the most
expensive thing to get wrong.

## Reporting on a set

Same shape, with the unit being the set rather than one issue. When
the output is a queue the reader will act on, add an explicit
ordering block, one line per item, no per-item justification:

```text
Suggested order:

1. #525 managed-session triggers and rollover
2. #520 shared authenticated MCP binding
3. #512 supervised Roba-to-Roba
```

Justification for the ordering, if any, goes in one sentence above
the list, not distributed across the items.

## Asking a question mid-work

Compress the evidence into one or two sentences, then ask one
specific question. Do not present the reasoning as a narrative and
leave the reader to infer what is being asked.

```text
#536 has one failed Ubuntu beta check in an unchanged Codex adapter test.
The exact test passes locally on beta, suggesting transient flakiness.
Per the CI-fix workflow, shall I rerun that failed job once?
```

The question is the last sentence, it is answerable yes or no, and
the evidence needed to answer it is directly above.

## The STATUS block is separate

Agent-to-dispatcher returns end with the machine-readable
`STATUS:` block defined in `agents/runner.md` and
`agents/worker.md`. That block is for parsing; this report is for
reading. The report goes above it, and neither replaces the other.

## Anti-patterns

- **Narrating the work instead of reporting it.** "First I looked
  at the config, then I noticed..." The reader wants the end state.
- **A verdict line that defers.** "Here's a summary of what I
  found" is not a verdict; it is a promise of one.
- **`Tests pass` as the gate roll-call.** Name the gates.
- **Omitting a gate that did not run.** Report it as not run.
- **No negative-space line.** A report with no statement of what
  was left undone claims completeness by silence.
- **Bullets that are sentences.** If a bullet needs a because-clause,
  split it or move it to prose.
- **A plan report with no `Out of scope`.** The next agent then has
  to guess the boundary.
- **Restating the issue body in the plan.** The issue is one click
  away; the plan is what the issue does not already say.
- **Closing offers.** "Let me know if you'd like me to..." Ask a
  specific question or stop.

## Related skills

- [`issue-pr-conventions`](../issue-pr-conventions/SKILL.md) -- the
  claim protocol the plan report is half of.
- [`draft-pr-first`](../draft-pr-first/SKILL.md) -- the lifecycle
  the plan report opens and the completion report closes.
- [`non-pr-output-conventions`](../non-pr-output-conventions/SKILL.md)
  -- where a report goes when the work produces no PR.
- [`github-authoring`](../github-authoring/SKILL.md) -- structure
  and voice inside an issue or PR body.
