---
name: dispatch-wait-react
description: How to coordinate with background tasks (dispatched sessions, CI watches, sub-agent dispatches) without polling or sleep-looping. Use Monitor for live streaming output; use run_in_background for fire-and-forget final-result cases. Wait for the harness notification, peek at in-flight output deliberately, surface stalled runs after a reasonable clock budget.
---

# Dispatch, wait, react

When you fire a long-running command -- a dispatched session, a `gh pr
checks --watch`, a sub-agent run -- the right coordination pattern
is **background + notification, not poll-and-sleep.** This skill
codifies the mechanism that turns "I fired something and now I'm
idle" into "I fired something, here's exactly how I track progress
and act on completion."

## Who this is for

**Primarily the dispatcher** (the interactive session with the
user). The dispatcher wants to stay responsive to the user while
dispatches run, CI watches, etc. The "background + notification" pattern
serves that.

**The runner subagent is different.** A runner subagent invocation
must complete the FULL lifecycle (fire roba, push, mark ready,
watch CI, merge or surface) before returning to the dispatcher,
because the runner's return signals "task done." If the runner
backgrounds the dispatch and returns early, the lifecycle is
orphaned. The runner should fire its dispatch **synchronously** (no
`run_in_background`) and only return once the lifecycle is done.
See [`../../agents/runner/AGENT.md`](../../agents/runner/AGENT.md)
for the runner-specific discipline.

## When to apply (dispatcher)

- Any dispatch you fire as a Bash command (roba / claude -p /
  claude-wrapper, etc.)
- Any CI watch (`gh pr checks <PR> --watch`)
- Any sub-agent invocation that runs long
- Any other Bash command that takes >5 seconds and produces a
  result you'll act on

## Choosing between Monitor and run_in_background

Two mechanisms, different contracts:

| mechanism | use when | what you get |
|---|---|---|
| `Monitor` tool | You want live output as it arrives (tail-and-react) | Each stdout line delivered as a notification; you react per line |
| `Bash(run_in_background=true)` | You want fire-and-forget; only the final result matters | Task ID + output file; single notification on exit |

**Use Monitor for:**

- Tailing CI logs in real time
- Watching a long build where you want to surface progress or
  errors as they happen
- Streaming sub-agent output live to the user
- Any case where intermediate lines change what you do next

**Use run_in_background for:**

- Dispatched sessions where intermediate output isn't actionable
  (you only care if it succeeded or failed)
- `gh pr checks --watch` when you want a single "done" signal
- Parallel fan-out where you want the notification fan-in pattern

**Monitor availability constraint:** Monitor is NOT available when
`DISABLE_TELEMETRY` or `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`
env vars are set. When those vars are set, fall back to
`Bash(run_in_background=true)` and use the peek-at-output pattern
(section 3 below) to observe progress.

## The shape

### 1a. Use `Monitor` when you want live streaming output

```
Monitor(command="gh run watch 12345 --log")
# Each stdout line arrives as a notification; you react as they come.
```

The Monitor tool fires the command and notifies you once per stdout
line. You can react to each line (surface status to the user,
detect a failure mid-run, etc.) rather than waiting for the full
run to complete.

When Monitor is unavailable (telemetry disabled), use
`Bash(run_in_background=true)` and peek at the output file
deliberately (see section 3).

### 1b. Use `Bash(run_in_background=true)` for fire-and-forget

You get back a task ID + an output-file path. Do NOT fire long-
running commands without `run_in_background`; that blocks your
turn waiting and burns budget on the same context. The default
should be: if it might take >5s, background it.

```
Bash(command="roba --fresh --full-auto -C /path -f task.md", run_in_background=true)
=> Background job b7jv3db8o; output at /private/tmp/.../b7jv3db8o.output
```

### 2. Don't sleep-poll

Don't write a `while not_done; sleep 10; check; end` loop. The
harness will send a `<task-notification>` automatically when the
background command exits, carrying the task ID, exit status, and
output-file path. Your job is to **wait for that notification**,
not to invent a polling loop.

If you find yourself reaching for `sleep` to wait on a background
job, stop -- you're rebuilding what the harness already provides
for free.

### 3. Peek at progress deliberately, not on every turn

Mid-run, you CAN read the output file via the Read tool to see
what's been produced so far. That's free -- no spawned cost, just
file IO. Good triggers to peek:

- **The user asks "what's going on?"** -- read the output and
  surface a short status.
- **You suspect a spiral** -- a small task that should take 2-3
  minutes has been running for 10+. Peek the output AND read the
  spawned claude session jsonl per
  [`../spiral-diagnosis/SKILL.md`](../spiral-diagnosis/SKILL.md)
  to identify echo-flush spam, cancellation cascades, or other
  diagnostic signatures.
- **You're chaining and want to surface partial info** -- e.g.
  the user is on remote control and you want to give them a brief
  "PR #N is in flight, agent is reading source files now."

Peek **deliberately**, not on every turn. Constantly reading the
output file converts coordination into polling -- wasted cycles
and noise in the transcript.

### 4. React to the notification

When the harness sends a `<task-notification>` for your job's
task ID, that's your cue to act. The notification carries:

- The task ID (matches what you got at launch)
- Status (completed / failed / killed)
- Exit code (in the failed case, often)
- The path to the output file

Act based on the exit code:

- **0 / completed cleanly** -- proceed with the next step in your
  lifecycle (push commits, mark PR ready, merge, etc).
- **Non-zero / failed** -- read the output file, decide refire vs
  hand-back per
  [`../spiral-diagnosis/SKILL.md`](../spiral-diagnosis/SKILL.md)
  (for roba runs) or the specific failure modes section of your
  agent's body (for other tools).

### 5. Have a clock budget

For each background task, have a rough sense of "too long":

| task | rough budget | reaction at 2x budget |
|---|---|---|
| Small dispatch (doc edit, small flag add) | 2-4 min | peek output + jsonl for spiral signatures |
| Medium dispatch (multi-file refactor, new module) | 5-10 min | same |
| Large dispatch (substantial new feature) | 10-15 min | same |
| `gh pr checks --watch` (CI watch) | 2-5 min | check PR state; maybe merged externally |
| Sub-agent invocation | varies | depends on the sub-agent's scope |

If the harness hasn't notified by 2x the rough budget, **peek
first** before assuming a hang. Then surface to the user with the
status + your read on what's happening.

Don't silently wait past 3x budget without surfacing -- that's a
real hang or a notification miss, and the user should know.

### 6. Composition

This skill sits underneath several lifecycle skills + agents:

- [`draft-pr-first`](../draft-pr-first/SKILL.md) -- fire the dispatch ->
  wait -> push -> ready -> watch CI -> wait -> merge. Each "wait"
  is the pattern in this skill.
- [`orchestration-prompt-template`](../orchestration-prompt-template/SKILL.md) --
  the PR-lifecycle pattern that includes `gh pr checks --watch` in
  background. Same wait shape.
- The dispatcher agent's parallelization heuristics
  ([`../../agents/dispatcher/AGENT.md`](../../agents/dispatcher/AGENT.md))
  -- fire N background tasks; the notification fan-in handles
  which finishes first. **Wait for ANY notification**, then
  handle that one job, then go back to waiting.
- [`spiral-diagnosis`](../spiral-diagnosis/SKILL.md) --
  when a wait is "too long" or the output file looks weird, peek
  the spawned jsonl. That skill describes the diagnostic side;
  this one describes the coordination side.

## Anti-patterns

- **Foreground long-running commands.** Blocks your turn, wastes
  budget, makes you unresponsive. Always background.
- **Sleep-polling.** Reinventing what the harness gives you for
  free. The notification is automatic; trust it.
- **Constant output-file polling.** Reading the output file every
  turn is polling-by-another-name. Peek deliberately.
- **run_in_background for live-tailing.** If you want to surface
  CI log lines, build output, or sub-agent progress as they happen,
  use Monitor instead. run_in_background gives you one notification
  at the end; Monitor gives you one per line.
- **Monitor when telemetry is disabled.** Monitor is unavailable
  when `DISABLE_TELEMETRY` or `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`
  is set. Don't assume Monitor is always present; check the env or
  fall back to run_in_background.
- **Silent indefinite waiting.** If a notification is taking too
  long, surface to the user with what you know. Don't sit on a
  stalled job in silence.
- **Firing serial when the work is parallel-safe.** Per the
  dispatcher's parallelization heuristics, when work is
  independent and different-file, fan out with background tasks
  -- the notification fan-in handles the join.

## Related

- [`draft-pr-first`](../draft-pr-first/SKILL.md) -- the PR
  lifecycle this skill enables.
- [`orchestration-prompt-template`](../orchestration-prompt-template/SKILL.md)
  -- the dispatcher's full prompt + PR-lifecycle pattern.
- [`spiral-diagnosis`](../spiral-diagnosis/SKILL.md) --
  what to do when "wait" is "too long."
