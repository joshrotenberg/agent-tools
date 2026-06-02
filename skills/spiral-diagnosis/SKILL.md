---
name: spiral-diagnosis
description: When a dispatched session hangs, produces no output, or seems stuck. Read the dispatched session's transcript directly -- it's the source of truth. Echo-flush spirals usually trace to one failed parallel tool call cascading cancellation errors to siblings.
---

# Spiral diagnosis

When a dispatched session hangs, its own transcript is the ground
truth. The dispatch wrapper's stdout/stderr capture is often
unreliable as a debug signal -- the dispatched Claude session
writes a JSONL transcript that is authoritative.

## When to apply

- A dispatched session has been quiet for an unusual length of
  time relative to the task size
- The wrapper's stdout capture is 0 bytes or empty
- You want to confirm what the dispatched session is actually
  doing *while* it runs

## Best practice: fire with an explicit trace handle

If your dispatch mechanism supports a trace flag (e.g. roba's
`--trace PATH`), use it. The wrapper mirrors the dispatched
session's streaming events to PATH as JSONL, in arrival order,
as they arrive. You read PATH directly -- no project-dir ls-sort,
no guessing which session id belongs to this run.

Tail it live (`tail -f /tmp/<task-id>.jsonl`) while the run is in
flight, or read it after.

The ls-sort approach below is the fallback for diagnosing a run
that *wasn't* fired with a trace handle.

## How to find the dispatched session (fallback)

The dispatched claude session writes to the same project directory
as the parent (the dispatch wrapper typically inherits cwd via
`-C` or `cd`; claude-code keys session storage by cwd):

```
~/.claude/projects/<encoded-project-path>/<uuid>.jsonl
```

Find the latest non-this-session entry:

```bash
ls -lt ~/.claude/projects/<this-project-dir>/*.jsonl | head -3
```

The biggest recent file that *isn't* the current Claude Code
session is the dispatched session.

For dispatches via the Task tool (same process, no separate
session id): the Task tool's output stream IS the transcript;
read what's been emitted so far.

## What to look for

Parse `type == 'assistant'` entries, then `content[].type ==
'tool_use'` for what the agent has been doing:

```python
import json
fn = '~/.claude/projects/<dir>/<uuid>.jsonl'
for line in open(fn):
    r = json.loads(line)
    if r.get('type') != 'assistant':
        continue
    c = r.get('message', {}).get('content', [])
    if not isinstance(c, list):
        continue
    for b in c:
        if isinstance(b, dict) and b.get('type') == 'tool_use':
            ts = r.get('timestamp', '')[:19]
            print(f"{ts} {b.get('name')}: "
                  f"{json.dumps(b.get('input', {}))[:120]}")
```

## Spiral signatures (kill the run early)

These patterns indicate the agent has lost the thread:

1. **Echo-flush spam.** Many consecutive `echo flush` or `echo
   fb1 / fb2 / fb3...` Bash tool calls. The agent thinks tool
   output is missing and is trying to "flush" something.
2. **Cancellation cascade.** Repeated `<tool_use_error>Cancelled:
   parallel tool call ...</tool_use_error>` tool_result entries.
   One sibling parallel call errored; the framework cancelled all
   the others.
3. **Parallel-batch timestamp collisions.** Many tool calls in a
   single assistant turn all sharing the same wall-clock
   timestamp. The agent is batching aggressively, which is
   exactly what triggers (2).

Kill the dispatched process (for Bash-based dispatch:
`ps aux | grep <wrapper>` to find the pids).

## Root cause (almost always)

Echo-flush spirals are NOT a dispatch-wrapper bug. The wrapper is
a thin process: compose prompt, spawn claude, capture result.
The cause is inside the dispatched claude session:

1. Agent batches a parallel turn that re-runs a setup command
   (commonly `git checkout -b <branch>` it already created in an
   earlier turn).
2. The duplicate fails (e.g. exit 128 `branch already exists`).
3. Claude's tool framework cancels every other call in that
   parallel batch, returning `<tool_use_error>Cancelled: parallel
   tool call Bash(...) errored</tool_use_error>` to all of them.
4. Agent sees a wall of cancellations and misreads it as "tool
   output is missing," goes into flush-spiral mode.

## Prevention (in the prompt)

The orchestration prompt should include this `## Tool-call
discipline` section verbatim (or by reference -- see
[`orchestration-prompt-template`](../orchestration-prompt-template/SKILL.md)):

```
- Setup steps (git checkout, pull, branch) must run sequentially,
  NOT in a parallel batch with exploration.
- Before re-running any setup command, verify state first
  (`git branch --show-current`, `git status`).
- If tool calls return `<tool_use_error>Cancelled: parallel tool
  call Bash(...) errored</tool_use_error>` errors, do NOT retry
  blindly. Do NOT issue "flush" echo commands. Read the actual
  failing call, decide if it matters, fix or continue. Almost
  always: the failure is a duplicate setup command, and the cure
  is to STOP issuing the duplicate, not to flush.
```

Also: dispatch with a "fresh session" flag if your wrapper
supports one (e.g. roba's `--fresh`), so the dispatched session
starts clean rather than inheriting any prior session state.

## Worktree isolation as an alternative

Some dispatch wrappers offer worktree isolation (e.g. roba's
`-w` / `--worktree`), which creates a new git worktree (different
cwd). Claude sessions are keyed by cwd, so a worktreed run won't
pick up any prior session -- effectively fresh by cwd isolation.
But it adds worktree-management complexity for the dispatcher;
prefer the fresh-session flag unless the task genuinely benefits
from a sandbox worktree (e.g. parallel dispatches that might
touch the same files).

## Related

- [`orchestration-prompt-template`](../orchestration-prompt-template/SKILL.md) --
  the full prompt template that incorporates the prevention rules
  above.
- [`dispatch-options`](../dispatch-options/SKILL.md) -- pick the
  dispatch mechanism with the observability surface you need
  (e.g. roba's `--trace`).
