---
name: orchestration-prompt-template
description: When the dispatcher is about to fire a runner -- use this template to write the prompt and wrap the PR lifecycle. Apply before every dispatch: the prompt section covers setup, context, task, tool-call discipline, and steps; the PR-lifecycle pattern covers draft-PR-first through CI-watch and merge.
---

# Orchestration prompt template

When the dispatcher dispatches a runner, it writes a tight,
well-formed prompt and wraps the PR lifecycle around the
dispatch. Don't just pass the human's words through.

This is a stacked-reliability contract:

- **Bottom:** explicit, well-formed prompt
- **Middle:** the dispatch substrate's predictable surface (typed
  exit codes, JSON envelope, sandbox preflight)
- **Top:** dispatcher that writes the prompt + wraps the PR
  lifecycle around the dispatch

The dispatch substrate (Task tool / Bash + claude -p) is
interchangeable per
[`dispatch-options`](../dispatch-options/SKILL.md). The
dispatcher's value-add is the prompt-writing layer plus the
gh-CLI wrapping. Pick the dispatch mechanism after the prompt is
written, not before.

## Prompt template

For dispatches that will use build tools, `gh`, `git`, or other
Bash commands, include the pre-flight check pattern from
[`sandbox-preflight`](../sandbox-preflight/SKILL.md) near the top
of the steps list. A blocked tool should fail loud, not silently
degrade into a "run this yourself" artifact.

For tasks involving "release readiness" / "release audit" / version
analysis, include
[`release-audit-anchoring`](../release-audit-anchoring/SKILL.md)
in the prompt's discipline section -- anchor the analysis on
`origin/main`, not the working branch tip, or the audit can report
false blocking findings on a stale branch.

```
## Setup

cwd: <absolute path>

Steps 1-3 MUST run sequentially, one tool call at a time. Do NOT
parallel-batch them with each other or with any exploration step.

1. git checkout main
2. git pull --ff-only origin main
3. git checkout -b <type>/<short-description>

Verify with a single Bash call:
   git branch --show-current
Output must be `<branch-name>`. Do NOT re-run steps 1-3.

## Context

<2-4 sentences on what the task is, why it matters, and any
constraints that aren't obvious from the issue.>

## Task

<Mechanical specifics: file paths, function names, surrounding
patterns to mirror. If the change touches a known-tricky area,
spell out the seam.>

## Tool-call discipline

(Include the spiral-diagnosis discipline -- see companion skill
`spiral-diagnosis`. Without it, parallel-batch cancellation
cascades have a real chance of derailing the run.)

## Steps

1. ...
2. ...
N. <language-appropriate format check>
N+1. <language-appropriate lint check>
N+2. <language-appropriate test invocation>
N+3. If the work produced anything worth capturing in project
     context (a new decision, a dogfood-worthy outcome, a brainstorm-
     worthy design idea), update CLAUDE.md with the appropriate
     entry. See "Read first, update last" below.
N+4. If all green: git add, commit
       <type>: <short description> (closes #<issue>)
N+5. Print git log --oneline -1, git diff HEAD^ --stat, and the
     branch name.

## Read first, update last

The full read-CLAUDE.md-first / update-CLAUDE.md-last discipline:

- **Read first.** Claude Code auto-loads CLAUDE.md when cwd matches
  the project; this happens transparently as the dispatched
  session boots. No explicit step needed.
- **Update last.** Before the final commit, ask: did this run
  produce something that belongs in CLAUDE.md? Three categories
  worth capturing:
  - **Decisions log entry** -- a settled choice (e.g. "we
    decided X because Y; tracked in #N / PR #M"). One terse line
    under the right date.
  - **Dogfood log entry** -- this run itself, if your project
    tracks dispatch outcomes. New lessons bubble up to the "Key
    lessons so far" list.
  - **Brainstorm-sketches addition** -- a design idea that
    surfaced mid-work and is worth capturing for later.
- **Don't update for nothing.** A small refactor that just
  executes the plan doesn't need a CLAUDE.md update. The bar is
  "would future-me want to find this when grepping the durable
  design home?"
- CLAUDE.md is typically untracked and out of scope for the PR
  diff, but edits to it persist locally and inform the next run.

## Constraints

- Do NOT push.
- Do NOT amend existing commits.
- Do NOT touch main after step 1.
- Do NOT run gh pr create.
- <task-specific do-nots>
```

## PR-lifecycle pattern (draft-PR-first, sync-watch-then-merge)

The lifecycle is **draft-PR-first** (see
[`draft-pr-first`](../draft-pr-first/SKILL.md)) -- open the PR
before the work so the plan is visible and the work is observable
from minute zero. Then a sync watch + manual merge on green.

Don't rely on `gh pr merge --auto`. Its behavior depends on repo
settings (`allow_auto_merge`) and can silently no-op or fire
unexpectedly. The sync pattern is portable across repo configs
and leaves a hook for reacting to CI failures.

The full loop (the dispatcher runs this, NOT the dispatched
session):

```bash
# 1. Branch + empty initial commit (so a PR can exist)
git checkout main && git pull --ff-only origin main
git checkout -b <type>/<short-description>
git commit --allow-empty -m "chore: start work on #<N>"

# 2. Push and open the draft PR with the plan as the body
git push -u origin <branch>
gh pr create --draft \
    --title "<conventional commit subject> (closes #<N>)" \
    --body "$(cat /tmp/task-<N>.md)"
# (or compose a separate human-facing plan body if the prompt
# isn't shaped right for human reading)

# 3. Fire the dispatch (mechanism per dispatch-options).
#    For same-repo work, use isolation: "worktree" so the runner
#    gets its own checkout and the dispatcher's tree stays clean.
#
#    Task tool (same-repo, default):
#      Task(subagent_type: "runner", isolation: "worktree", prompt: ...)
#      # => returns {path: "/tmp/wt-xxx", branch: "<branch>"} if changes made
#
#    Bash + claude -p:
#      claude -p --agent runner --add-dir <path> "$(cat /tmp/task-<N>.md)"

# 4. When the dispatch returns: push the commits it made.
#    For worktree-isolated Task dispatches, push from the returned path:
git -C <returned-path> push -u origin <returned-branch>
git worktree remove <returned-path>
#    For non-isolated dispatches (same-checkout):
#      git push        # auto-extends the open draft PR

# 5. Mark PR ready
gh pr ready <pr-number>

# 6. CI watch + merge on green (default: merge immediately on exit 0)
sleep 15        # let GitHub register the checks (dodges the race)
gh pr checks <pr-number> --watch --interval 15
# On exit 0: merge immediately -- this is the default.
gh pr merge <pr-number> --squash --delete-branch
# Exception cases -- skip the merge and return "PR #N ready; awaiting
# manual merge" instead:
#   - No CI checks configured ("no checks" response from gh pr checks)
#   - Issue has a needs-review label
#   - Dispatcher passed review:manual in constraints
#   - Change described as "critical" or "delicate" in the issue body
# On exit non-zero: read the watch output for failing job names,
#   surface failures, optionally fire the dispatch again with
#   failure context ("fix the CI failures in PR #X; checkout the
#   branch first")
```

The empty initial commit gets squashed away on merge. The plan
lives in the PR body permanently and is observable from anywhere
via `gh pr view <N>`. See
[`draft-pr-first`](../draft-pr-first/SKILL.md) for the full
rationale.

All orchestrator-side -- pure gh-CLI + dispatch wrapping. No
substrate-specific verbs.

## `--auto` quirk worth remembering

`gh pr merge --auto` silently exits 0 even when
`allow_auto_merge: false` is set on the repo. The PR may or may
not actually queue for auto-merge. Don't rely on it; use the
sync pattern above.

## Related

- [`draft-pr-first`](../draft-pr-first/SKILL.md) -- the "open the
  PR before the work" pattern this skill's PR-lifecycle assumes.
- [`spiral-diagnosis`](../spiral-diagnosis/SKILL.md) -- what to do
  when the dispatched session hangs.
- [`dispatch-options`](../dispatch-options/SKILL.md) -- pick the
  dispatch mechanism for the lifecycle's "fire" step.
- [`git-branch-pr-workflow`](../git-branch-pr-workflow/SKILL.md) --
  the "branch off main + PR" discipline the prompt template
  assumes.
- [`heredoc-backticks`](../heredoc-backticks/SKILL.md) -- how to
  format the PR body in a `gh pr create --body "$(cat <<'EOF' ...
  EOF)"` call without breaking the markdown.
