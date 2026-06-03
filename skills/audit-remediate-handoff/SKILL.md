---
name: audit-remediate-handoff
description: When the dispatcher has audit findings filed as GitHub issues and needs to decide how to fire per-finding runners -- use this to read the labeled finding-issues, apply the in-progress label before dispatch, and choose parallel vs sequential runner execution.
---

# Audit-remediate handoff

The audit + remediate shape has two phases: a read-only auditor that files
findings as GitHub issues, and a dispatcher-driven remediation phase that fires
runners per finding. This skill covers the handoff between those two phases --
how the dispatcher reads what the auditor produced and decides what to run.

## When to apply

Apply this skill after an auditor run has filed findings as GitHub issues, before
the dispatcher fires per-finding runners. The auditor's output is complete; the
remediation phase has not started. The dispatcher reads labeled finding-issues and
decides the execution shape (parallel or sequential) per finding.

## State transition

The handoff is a durable-state handoff, not an in-memory one:

1. **Auditor writes** -- findings are filed as GitHub issues with a label
   (e.g. `audit-finding`). Each issue is self-contained: a runner can pick it
   up without re-reading the audit context.

2. **Dispatcher reads** -- list finding-issues:

   ```bash
   gh issue list --label audit-finding --state open --repo <owner/repo>
   ```

   Filter out any issues already labeled `in-progress` (already dispatched in a
   prior session or parallel run):

   ```bash
   gh issue list --label audit-finding --state open --repo <owner/repo> \
     --json number,title,labels \
     --jq '[.[] | select(.labels[].name != "in-progress")]'
   ```

3. **Dispatcher labels before firing** -- apply `in-progress` to a finding-issue
   before dispatching its runner. See the avoid-double-dispatch section below.

4. **Runner reads the issue** -- the runner's prompt references `gh issue view N`
   as its authoritative context. The runner does not re-read audit reports or
   audit output files.

5. **Issue closes on PR merge** -- the runner's PR body uses `closes #N`. The
   finding-issue is closed when the PR merges, not before.

## Recommended finding-issue format

The auditor's "File" phase (see
[`agents/auditor/AGENT.md`](../../agents/auditor/AGENT.md)) writes finding-issues
with the following body shape. Runners must be able to consume the issue directly
without additional context:

```markdown
## Current state
<What the code actually does today -- specific, citable>

## Desired state
<What it should do per the rubric or standard>

## Files to touch
<Explicit paths or globs the runner should read first>

## Implementation notes
<Approach, gotchas, relevant cross-references>

## Audit context
Audit run: <date>
Auditor parameters: <domain, rubric reference, repo>
```

The "Audit context" section is why the runner does not need to re-read audit
output -- it has the parameters embedded. The dispatcher verifies this format
is present before firing; a sparse issue body is a signal to file a follow-up
or flesh out the issue rather than dispatch a runner blindly.

## Parallel vs sequential dispatch

Most finding-issues are independent. Default to parallel dispatch unless there
is an explicit ordering dependency.

**When to use parallel runners:**

- Findings touch different files with no shared state
- No finding's desired state depends on another finding's implementation
- The issue bodies do not reference each other as prerequisites

**When to use sequential runners:**

- Finding A introduces a type, interface, or schema that finding B uses
- Finding B's implementation notes say "depends on #N" or "after #N merges"
- Two findings modify the same file in ways that will conflict

**Heuristic -- check files before deciding:**

```bash
# Extract file paths from finding-issue bodies and look for overlaps
gh issue view <N> --json body --jq '.body' | grep -E '^- |`[^`]+`'
```

If two findings list the same file, treat them as sequential unless the changes
are clearly additive (e.g. two unrelated functions in the same module). When in
doubt, sequential is safer than a merge conflict.

For the fan-out mechanics of parallel dispatch, see
[`orchestrator-parallelization`](../orchestrator-parallelization/SKILL.md).

## Avoid-double-dispatch discipline

Two sessions or a re-dispatch scenario can pick up the same finding-issue if
it is not marked before the runner starts. The sequence to prevent this:

1. **Label the issue `in-progress` before firing the runner:**

   ```bash
   gh issue edit <N> --add-label in-progress --repo <owner/repo>
   ```

2. **Optionally assign or comment** to make dispatch visible:

   ```bash
   gh issue comment <N> --body "Dispatched to runner -- PR incoming." \
     --repo <owner/repo>
   ```

3. **Check the label before each dispatch** -- skip any issue already labeled
   `in-progress`:

   ```bash
   gh issue view <N> --json labels --jq '.labels[].name' | grep in-progress
   ```

   If the grep returns `in-progress`, skip the issue in this session.

The in-progress label is an idempotency guard. It does not need to be removed
after the runner completes -- the runner's PR close will change the issue state
to `closed`, which removes it from the open findings queue.

## Anti-patterns

**Firing runners before labeling findings in-progress.** A parallel session or
re-dispatch will pick up the same finding. Two runners addressing the same issue
produce conflicting PRs. Label first, fire second -- always.

**Using audit report text as runner context.** Audit reports are written for
human review, not machine consumption. They are lossy (summarized), may be
stale (the auditor ran yesterday), and are not the authoritative record (the
issue is). Pass the runner the issue number; let the runner call `gh issue view`.

**Dispatching all findings as sequential when they are independent.** Sequential
dispatch serializes work that could run in parallel. A 10-issue backlog dispatched
sequentially takes 10 runner cycles; dispatched in parallel (assuming independent
files) it takes 1. Check file overlap first; default to parallel.

**Closing finding-issues before the runner's PR merges.** Issue close is the
merge signal. Closing early breaks the traceability link between the finding and
the fix. Use `closes #N` in the PR body; let merge close the issue.

**Re-running the auditor to get finding context.** The finding-issue is the
durable record. Re-running the auditor is expensive and may produce different
findings if the codebase changed. Read the issue; do not re-audit.

## Related

- [`orchestration-patterns`](../orchestration-patterns/SKILL.md) -- the
  audit + remediate shape in the broader execution shape table
- [`agents/auditor/AGENT.md`](../../agents/auditor/AGENT.md) -- the agent that
  files findings; its "File" phase defines the issue body format this skill
  consumes
- [`non-pr-output-conventions`](../non-pr-output-conventions/SKILL.md) -- output
  destination conventions for audit findings (where the auditor writes before
  the handoff)
- [`orchestrator-parallelization`](../orchestrator-parallelization/SKILL.md) --
  fan-out heuristics for parallel runner dispatch
