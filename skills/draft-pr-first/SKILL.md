---
name: draft-pr-first
description: Before starting any dispatched or non-trivial work that will become a PR -- open the draft PR first, with the plan as the body. The PR body is the plan, the commit stream is the work, and the PR exists as a visible, resumable work unit from minute zero. Use this whenever the work crosses the "deserve a PR" threshold.
allowed-tools: Bash(git *) Bash(gh *)
---

# Draft PR first

When starting work that's substantial enough to deserve a PR --
dispatched or hand-edited -- **open the draft PR before the
work, not after.** The PR body holds the plan; the commit stream
holds the execution; together they are the work itself, not
artifacts produced at the end.

## When to apply

- Any dispatched work that will become a PR
- Any non-trivial hand-edit that will become a PR
- Multi-step refactors where intermediate state matters
- Anything you want a second party (human or another agent) to be
  able to see in flight

## Why

- **Visible from minute zero.** `gh pr list --draft` from any
  shell shows the work-in-flight, with its plan. The user, another
  agent, or a future you can see what's going on without finding the
  prompt file.
- **Resumable.** If the session dies, the PR is still there with
  the plan, and the branch carries whatever progress made it to
  commit. Nothing important lives only in conversation context.
- **Cross-session continuity.** A different agent picking up the
  work doesn't need handoff -- the PR body IS the handoff.
- **The substrate for multi-repo orchestration.** A single parent
  agent can fan tasks out across N repos and see the global state
  by listing draft PRs across each one. Each repo carries its own
  `CLAUDE.md`, `skills/`, `.claude/agents/`, so the
  spawned work inherits full project context without the
  dispatcher having to know specifics.

## The dispatch flow

For a dispatcher firing on the user's behalf:

```bash
# 1. Branch + empty initial commit so a PR can exist
git checkout main && git pull --ff-only origin main
git checkout -b <type>/<short-description>
git commit --allow-empty -m "chore: start work on #<N>"

# 2. Push and open the draft PR with the plan body
git push -u origin <branch>
gh pr create --draft \
    --title "<conventional commit subject> (closes #<N>)" \
    --body "$(cat /tmp/task-<N>.md)"
# (or pass a separately-composed plan body if the prompt body
# isn't shaped right for the PR.)

# 3. Fire the dispatch against the same branch (the dispatcher owns
#    the branch lifecycle). Mechanism per dispatch-options:
#
#    Task tool:      Task(subagent_type: "runner", prompt: <full prompt>)
#    Bash + claude -p: claude -p --agent runner "$(cat /tmp/task-<N>.md)"

# 4. When the dispatch returns: push the commits it made
git push        # auto-extends the draft PR

# 5. (optional) Verify the diff is sane before marking ready
# 6. Mark ready
gh pr ready <pr-number>

# 7. CI watch + merge on green (merge-on-green is the default)
sleep 15        # let GitHub register the checks
gh pr checks <pr-number> --watch --interval 15
# On exit 0: merge immediately -- this is the default.
gh pr merge <pr-number> --squash --delete-branch
# Exception cases -- skip the merge and return "PR #N ready; awaiting
# manual merge" instead:
#   - No CI checks configured ("no checks" from gh pr checks)
#   - Issue has a needs-review label
#   - Dispatcher passed review:manual in constraints
#   - Change described as "critical" or "delicate" in the issue body
```

The empty initial commit gets squashed away on merge. The plan
lives in the PR body permanently, which is what makes the work
observable from anywhere even after the merge.

## Plan as PR body, not as `.tasks/<N>.md`

Why not commit the plan into the repo as a file?

- The plan is meta-work, not a deliverable. Committing it pollutes
  the source tree.
- Squash-merge would eat the file commit anyway, but then the plan
  is gone from history.
- PR body is the natural home: GitHub renders it, search-engines
  index it, `gh pr view <N>` retrieves it.

If the plan needs to evolve mid-flight (a clarification, a
constraint change), edit the PR body via `gh pr edit <N> --body
"$(...)"`. The commit stream is for code; the PR body is for the
plan.

## Empty initial commit: cost vs benefit

The `git commit --allow-empty` step is the one rough edge -- the
intermediate state has a no-op commit. Acceptable because:

- Squash-merge collapses everything into one final commit; the
  empty commit doesn't reach main.
- The alternative (open PR after first real commit) means the work
  starts invisible -- the dispatcher can't reference the PR
  number when firing the dispatch, and there's a window where the
  work is in flight but unobservable.

If the project's merge strategy is *not* squash-merge, the empty
commit is more visible. Adjust to "small trivial change as initial
commit" (e.g. touch CHANGELOG.md or add a placeholder comment) in
that case.

## Plan body shape

A good plan body for a draft PR mirrors the orchestration prompt
template:

- **Setup** -- branch, cwd, pre-conditions
- **Context** -- 2-4 sentences on why this matters
- **Task / Decision** -- what specifically to change
- **Steps** -- numbered, with verification gates (fmt, clippy, test)
- **Constraints** -- explicit do-nots
- **Acceptance** -- what the final state should look like

This is the same shape as the prompt at
[`orchestration-prompt-template`](../orchestration-prompt-template/SKILL.md);
the body and the prompt can often be the same text. Where they
differ: the PR body is human-facing (the user reads it to
understand the work); the prompt is agent-facing (the spawned
claude executes it). Sometimes you want both, slightly different.

## When NOT to apply

- Trivial typo fixes that won't see a PR
- Local experiments / spikes you don't intend to land
- Pre-0.1 throwaway code where the overhead exceeds the visibility
  benefit

For any work that crosses the "deserve a PR" threshold, draft-PR-
first is the default.

## Anti-patterns

- Opening the PR after the work is done -- the plan is no longer visible in flight and unobservable during execution.
- Writing the plan into task files instead of the PR body -- the plan pollutes the source tree and gets squash-merged away.
- Leaving a draft PR in draft state indefinitely -- it never gets marked ready and stays invisible to CI and merge gates.

## Related

- [`orchestration-prompt-template`](../orchestration-prompt-template/SKILL.md)
  -- the prompt template the plan body is built from.
- [`git-branch-pr-workflow`](../git-branch-pr-workflow/SKILL.md) --
  the broader branch + PR discipline this fits into.
- [`heredoc-backticks`](../heredoc-backticks/SKILL.md) -- formatting
  the PR body's markdown without breaking it.
