---
name: runner-synchronous-lifecycle
description: The runner's invocation must hold open until the full lifecycle is done. Fire the dispatch SYNCHRONOUSLY (no `run_in_background`); your return-to-dispatcher signals "PR merged (or exception hit), lifecycle complete." Returning earlier orphans the work.
---

# Runner synchronous discipline

Your (the runner's) invocation must hold open until the full
lifecycle is done. **Returning to the dispatcher signals "task
complete: PR is merged (or an exception was hit -- see exception
cases in runner AGENT.md)."** Returning earlier orphans the work.

## The anti-pattern this prevents

Original failure mode observed on the work machine (roba #104):

1. Runner fires roba with `run_in_background=true`
2. Runner reports a summary and returns
3. Dispatcher gets a "completed" notification for the runner
4. roba is still running locally; the commit never gets pushed; CI
   never starts; the dispatcher thinks the task is done when it
   isn't.

## Discipline that prevents it

- **The dispatch is fired synchronously** (no `run_in_background`).
  Your session blocks until the dispatch exits.

  ```bash
  # Mechanism per dispatch-options:
  #   Task tool:    Task(subagent_type: "runner", prompt: <prompt>)
  #   Bash + roba:  roba --fresh --full-auto -C <repo-path> -f /tmp/task-<N>.md
  #   Bash + claude -p: claude -p --agent runner "$(cat /tmp/task-<N>.md)"
  ```

  For Bash-based dispatch, set a generous timeout (harness max is
  600000 ms / 10 min; pick what fits the task size).

- **CI watch CAN use `run_in_background=true`** because the watch is
  part of your runner's lifecycle and YOU wait for the notification
  yourself before returning. The
  [`dispatch-wait-react`](../dispatch-wait-react/SKILL.md) skill is
  the operational guide for that wait.

- **Push, mark ready, merge are all within your session.** Don't
  hand them off to "the dispatcher will pick this up." The
  dispatcher's expectation is that when your invocation returns,
  the lifecycle is done.

## What return-to-dispatcher means

When you DO return to the dispatcher:

- **Success case (default):** report PR number, merge commit hash,
  any caller-actionable notes (live-test follow-up, surfaced gaps
  in the issue spec, etc.). The PR is merged.
- **Exception case:** report PR number, why the exception applies
  (no CI configured, `needs-review` or `no-auto-merge` label on the PR,
  review:manual constraint, critical/delicate label), and "PR #N ready;
  awaiting manual merge."
- **Failure case:** report what failed, where (dispatch run? CI?
  push conflict?), the failing job's URL if applicable, and your
  read on whether this is refireable vs needs human decision.

The dispatcher's contract: "the runner returned" → "the lifecycle
is complete." If you return earlier than that, you've broken the
contract and the dispatcher will trust the wrong state.

## Label-based exception cases

Two PR labels signal the runner to skip auto-merge and return "awaiting manual
merge" instead:

- **`needs-review`** -- set by the dispatcher or issue author to require human
  sign-off before merging.
- **`no-auto-merge`** -- set by the runner (copied from the issue) or manually,
  to signal that automated merging should be skipped regardless of CI status.

Check for these before calling `gh pr merge`:

```bash
LABELS=$(gh pr view $PR --json labels --jq '[.labels[].name] | join(",")' 2>/dev/null || echo "")
if echo "$LABELS" | grep -qE "needs-review|no-auto-merge"; then
  echo "PR #$PR ready; awaiting manual merge (label: needs-review or no-auto-merge)"
  # Do NOT merge
fi
```

## Related

- [`dispatch-wait-react`](../dispatch-wait-react/SKILL.md) -- the
  background + notification pattern for the CI-watch half of your
  lifecycle.
- [`draft-pr-first`](../draft-pr-first/SKILL.md) -- the full
  lifecycle your invocation must hold open through.
- [`runner-issue-authority`](../runner-issue-authority/SKILL.md) --
  the first step of that lifecycle (fetch the issue body).
