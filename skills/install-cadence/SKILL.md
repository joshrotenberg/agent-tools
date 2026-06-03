---
name: install-cadence
description: Before dispatching any agent after a batch of merged PRs, verify that ~/.claude/agents/ and ~/.claude/skills/ are in sync with the repo. Stale installed definitions cause dispatched agents to reintroduce behaviors explicitly removed in recent PRs.
---

# Install cadence

The installed copies of skills and agents in `~/.claude/agents/` and
`~/.claude/skills/` are what Claude Code and dispatched sessions actually
load. Merged changes in the repo do **not** auto-propagate there. If you
merge a batch of PRs and dispatch without re-installing, the dispatched
agent runs against the old definitions -- and may reintroduce behaviors
you just removed.

## When to apply

- **After merging any batch of PRs** that modify skill or agent bodies.
- **Before dispatching** any agent (runner or worker) when you have
  recently merged agent-tools PRs.
- **On a fresh machine** -- the first `./install.sh` bootstraps the
  install; subsequent runs after PR merges keep it current.

A safe rule: if you merged PRs, run install before dispatching.

## The rule

After each batch of merged PRs, run from the repo root:

```bash
./install.sh --force
```

The `--force` flag overwrites existing files without prompting.
`install.sh` is idempotent -- running it when nothing changed is harmless.

## Verify sync before dispatching

If you are unsure whether your install is current, check from the repo
root:

```bash
diff -r ~/.claude/skills/ skills/
diff -r ~/.claude/agents/ agents/
```

No output means the installed copies match the repo. Any diff output
identifies which files are out of sync. Run `./install.sh --force` to
resolve.

## Failure signature

The most common symptom of a stale install: a dispatched agent
**re-adds a behavior you explicitly removed in a recent PR**. If you
see that, the agent loaded the old definition. Re-install and re-dispatch.

Other signs:

- A dispatched session references a skill name that was renamed or removed.
- The dispatched agent follows an old lifecycle step you replaced.
- Worker output matches the behavior described in a closed issue you thought
  was fixed.

## Anti-patterns

- **Merging PRs and dispatching immediately without re-installing.** The most
  common way to end up running stale definitions.
- **Relying on the repo being the install.** `~/.claude/` is the install
  location, not the repo directory. They diverge on every merged PR.
- **Installing once and forgetting.** Install cadence is per-PR-batch, not
  once at project setup.

## Related

- [`sandbox-preflight`](../sandbox-preflight/SKILL.md) -- the analogous
  pre-dispatch check for tool allowlist readiness. Run both: verify install
  sync AND tool allowlist before firing a runner.
- [`durable-context`](../durable-context/SKILL.md) -- the persistence model
  that explains what survives compaction and what must be externalized. Install
  sync is a separate concern (filesystem, not context), but both are
  pre-dispatch hygiene.
