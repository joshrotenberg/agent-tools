---
name: runner-vs-worker
description: >-
  Use when deciding whether to dispatch a runner or a worker for a subtask.
  Describes the decision boundary, the failure mode when runner is used where
  worker is intended, and the safe composition pattern.
---

# Runner vs worker

The runner and worker are two distinct agents with non-overlapping scopes.
Confusing them causes a specific, loud failure: the runner will open an
unsolicited draft PR, run CI, and attempt a merge when all you wanted was a
file edit.

## When to apply

Consult this skill before dispatching any subagent that will edit files:

- You have a GitHub issue and want the full lifecycle handled end-to-end:
  use **runner**.
- You have an already-open branch + draft PR and want a bounded set of file
  edits committed: use **worker**.
- You are the runner and need code-change execution on your branch: dispatch
  **worker**.
- You are the dispatcher with a simple "edit these files" task inside a
  running lifecycle: dispatch **worker**, not runner.

## Decision boundary

| Use runner when | Use worker when |
|---|---|
| Starting from a GitHub issue number | Branch + draft PR already exist |
| You need the full issue->branch->PR->CI->merge lifecycle | You need file edits + commit only |
| The task is a top-level unit of work | The task is a subtask within a running lifecycle |
| No PR exists yet for this work | The caller owns the PR and lifecycle |

**Runner scope:** reads the issue, creates a branch, opens a draft PR,
dispatches a worker for file changes, pushes, watches CI, merges. The runner
IS the lifecycle.

**Worker scope:** reads context, edits files, validates, commits, stops.
The worker does NOT read GitHub issues, create branches, open PRs, push,
watch CI, or merge.

## Failure mode: dispatching runner when you want worker

If a dispatcher or runner dispatches a runner subagent for a bounded
file-edit task, the runner will:

1. Fetch a GitHub issue (or fail loudly if no issue number was passed)
2. Create a new branch and empty commit
3. Open an **unsolicited draft PR** (duplicating the outer lifecycle's PR)
4. Dispatch another worker inside itself
5. Push, watch CI, and attempt a merge

The result: a spurious open PR, extra CI runs, and potential merge conflicts
if both the outer and inner lifecycles push to the same repo concurrently.
This is loud and recoverable, but wasteful and confusing.

The reverse failure (dispatching worker when you want runner) is quieter:
the worker will edit files and commit but leave no PR, no CI, no merge. The
work is stranded on a local branch.

## Safe composition

The standard safe pattern:

```
dispatcher or human
  --> runner (for issue #N)
        creates branch + draft PR
        --> worker (for file edits on that branch)
              edits files, validates, commits
        <-- worker done (commit on branch)
        runner pushes, watches CI, merges
```

Rules:

- **Runner dispatches worker.** The runner owns the lifecycle; it delegates
  only the file-editing step to a worker.
- **Dispatcher dispatches runner.** If the dispatcher needs a full lifecycle,
  it dispatches runner (not worker) and passes an issue number.
- **Dispatcher dispatches worker directly only for simple subtasks** within
  an already-open branch + PR lifecycle that the dispatcher itself is
  managing. This is rare -- the dispatcher usually fires runner and lets it
  handle everything.
- **Never dispatch runner as a "just make these edits" worker.** Pass no
  issue number to a runner and it will either fail loudly or invent one.

## Anti-patterns

- **Dispatching runner with a file-edit-only prompt and no issue number.**
  The runner requires an issue number. Without one, it will fail at the
  `gh issue view` step.
- **Dispatching runner instead of worker inside a running lifecycle.** The
  runner opens its own PR and lifecycle. Two concurrent lifecycles on the
  same branch cause conflicts.
- **Dispatching worker to do lifecycle operations.** The worker explicitly
  blocks `git push`, `gh pr create`, and other lifecycle commands. A prompt
  that asks the worker to do those will be ignored or fail.
- **Using runner as a "smart worker" because it has more skills loaded.**
  The runner's skills are lifecycle skills. The worker's scope is correct
  for file-edit tasks regardless of which agent has more context loaded.

## Related

- [`../../agents/runner/AGENT.md`](../../agents/runner/AGENT.md) -- the
  full-lifecycle agent: reads issues, creates PRs, dispatches worker,
  watches CI, merges.
- [`../../agents/worker/AGENT.md`](../../agents/worker/AGENT.md) -- the
  file-change agent: edits files, validates, commits, stops.
- [`../dispatch-options/SKILL.md`](../dispatch-options/SKILL.md) -- choosing
  the dispatch mechanism (Task tool vs Bash + claude -p) after you have
  decided which agent to dispatch.
