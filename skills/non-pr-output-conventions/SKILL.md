---
name: non-pr-output-conventions
description: When a dispatched run produces text or findings rather than a PR -- use this to pick the right output destination (stdout, CLAUDE.md entry, issue comment, findings file), apply the spawn-issue handback pattern, and hold the synchronous discipline for non-PR runs.
---

# Non-PR output conventions

Not every dispatch ends with a merged PR. Research, audits, Q&A,
diagnosis, and status reports produce text or structured findings.
This skill defines where that output goes and how the lifecycle
differs from the PR-centric path.

## Output destination decision tree

| who needs it | duration | destination |
|---|---|---|
| Human reading now | ephemeral | stdout / return text |
| Human + future agents, this project | durable, project-scoped | CLAUDE.md entry (brainstorm-sketches or decisions log) |
| Visible to others, indexed by GitHub | durable, public | issue comment (`gh issue comment N --body "..."`) |
| Cross-session, shareable artifact | durable, file | markdown file in repo or `/tmp/<task-id>-findings.md` |
| Spawns further work | structured input | issue body / issue comment as findings list |

Pick the most durable destination that the consumer actually needs.
A quick Q&A answer belongs in stdout. An audit summary that a
runner will act on belongs in an issue comment or findings file.
Don't write to CLAUDE.md for answers a human won't search for later.

## Mechanics per destination

**stdout / return text**

Just return it in the response. No file, no issue, no branch.
Right for ephemeral answers: "explain how --fresh works," "what
shipped this week?"

**CLAUDE.md entry**

Use the existing brainstorm-sketches or decisions-log pattern from
`orchestration-prompt-template`. Append to the relevant section;
no commit needed (CLAUDE.md is typically untracked).

**Issue comment**

```bash
gh issue comment N --body "$(cat /tmp/<task-id>-findings.md)"
```

Right for audit findings, diagnosis results, research summaries
that belong to a tracking issue. Visible to all; searchable.

**Findings file**

Write to `/tmp/<task-id>-findings.md`. Return the path in the
response so the dispatcher can reference it in a follow-on prompt.
Use when a subsequent runner dispatch will consume the findings.

## Spawn-issue handback pattern

When a non-PR run surfaces an actionable finding (e.g. an audit
finds an exploitable bug), file a new issue and return its number:

```bash
gh issue create \
  --title "fix: <short description of finding>" \
  --body "$(cat /tmp/<task-id>-findings.md)" \
  --label "fix,p1"
```

If priority warrants immediate action, the dispatcher can dispatch
a runner on the new issue directly. The auditor does NOT dispatch
the runner itself -- that decision belongs to the dispatcher.

## Synchronous discipline

Non-PR runs carry the same hold-open contract as PR runs. The
dispatched session must complete and deliver to the durable
destination before returning. A non-PR session that fires
`run_in_background=true` and returns has orphaned the output --
same failure mode as an unmerged PR.

No branch, no empty commit, no CI watch. These are not needed and
add overhead. Everything else from `runner-synchronous-lifecycle`
applies.

## Token budget hints by shape

| shape | model | effort | rationale |
|---|---|---|---|
| Q&A / explainer | haiku | low | Shallow read, short answer |
| Status / report | haiku | low | Structured retrieval, brief synthesis |
| Research | sonnet | high | Multi-source reasoning, cited output |
| Audit | sonnet | high | Deep scan, structured findings |
| Diagnosis | sonnet | medium | Focused analysis, RCA output |

These are defaults. The dispatcher overrides per the specific task.

## Related

- [`runner-synchronous-lifecycle`](../runner-synchronous-lifecycle/SKILL.md)
  -- the hold-open contract this skill extends to non-PR runs
- [`orchestration-patterns`](../orchestration-patterns/SKILL.md)
  -- researcher and auditor execution shapes
- [`dispatch-options`](../dispatch-options/SKILL.md)
  -- `model:` and `effort:` hints for non-PR dispatches
