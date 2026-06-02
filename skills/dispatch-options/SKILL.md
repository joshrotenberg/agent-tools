---
name: dispatch-options
description: When choosing how to dispatch a subagent -- consult this before firing any dispatch. Covers the two primary mechanisms (Task tool / Bash + claude -p) and when each fits: default to Task tool for in-project work, reach for Bash + claude -p when you need a different cwd, process boundary, or long-running dispatch.
---

# Dispatch options

There is no single right way to dispatch a subagent. Pick by what
the dispatch actually needs.

## The two options

| option | how | what it gives you | what you give up |
|---|---|---|---|
| **Task tool** | `Task(subagent_type: "explore"\|"plan"\|"runner", prompt: "...")` | Same cwd, lowest overhead, native Claude Code integration. Pass `isolation: "worktree"` for same-repo branch + file work -- agent gets its own checkout, path and branch returned on completion. | No different cwd (without worktree), no scriptable exit code, child uses parent's permission state |
| **Bash + claude -p** | `Bash: claude -p --agent X "..."` | Different cwd via `--add-dir` or `cd`, process boundary, survives session crash, backgroundable with `run_in_background` | No retry, no typed errors, prompt visible in argv |

> If you use roba, `roba -w` is equivalent to `isolation: "worktree"` and
> `roba --trace` provides a structured JSONL trace. These docs don't assume
> roba is installed.

## When each fits

**Default to Task tool when:**

- The work happens in the same cwd as your session
- The dispatch is brief (<5 min) and you'll be re-invoked on
  completion
- You don't need to share the dispatch outcome with anything outside
  Claude Code

For same-repo runner dispatches (branch + file changes), add
`isolation: "worktree"`. The agent gets its own checkout;
the dispatcher's working tree is unaffected. See the
[worktree lifecycle pattern](#task-tool-worktree-isolation) below.

This is the normal in-session subagent path. Use it.

**Reach for Bash + claude -p when:**

- The dispatch needs to run IN A DIFFERENT CWD (e.g. dispatcher
  dispatching project-rooted orchestrators). Task tool can't do
  this; only a separate process with `cd` or `--add-dir` can.
- The dispatch outcome needs to be observable outside Claude Code
  (backgrounded via `run_in_background`, output file inspectable).
- The dispatch will be invoked from outside Claude Code too (CI
  scripts, cron, other agents), and you want a stable contract.
- The dispatch is long-running and you want it to survive your
  session compacting or restarting.

## Task tool worktree isolation

For any same-repo Task dispatch that creates a branch and modifies
files, use `isolation: "worktree"`. No external tool required --
the Task tool provides this natively.

```
# Dispatch with worktree isolation (same-repo runner work)
Task(subagent_type: "runner", isolation: "worktree", prompt: ...)
# => if agent made changes, returns {path: "/tmp/wt-xxx", branch: "fix/whatever"}
# => if agent made no changes, worktree is cleaned up automatically

# Push from the returned worktree path
git -C <returned-path> push -u origin <returned-branch>

# Dispatcher removes the worktree after push
git worktree remove <returned-path>
```

Cross-repo dispatches and read-only dispatches do not need
worktree isolation -- there is no collision risk.

The branch + empty commit + push + draft PR setup still happens
in the dispatcher's main checkout BEFORE firing the isolated
runner dispatch. Only the runner's file-modification work runs
inside the worktree.

## Task tool subagent_type values

`subagent_type` controls which tools the spawned subagent can use.
Known values:

| type | tools available | when to use |
|---|---|---|
| `general-purpose` | all tools | default when no type specified |
| `explore` | Glob, Grep, LS, Read, WebFetch, WebSearch (no Edit/Write/Bash) | dispatcher gather-context step; prevents accidental edits |
| `plan` | all tools except Task, ExitPlanMode, Edit, Write, NotebookEdit | design-before-impl shapes |
| `bash` | Bash only | scripted one-shots, CI steps |
| `runner` / `dispatcher` | per the installed agent definition | this project's custom named agents under `~/.claude/agents/` |

### Model override

Pass `model: haiku | sonnet | opus` to override the model per dispatch:

- `haiku` -- quick reads, exploration, mechanical tasks
- `sonnet` -- implementation (default for most dispatches)
- `opus` -- high-stakes design decisions, hard algorithmic problems

### Effort hint

Pass `effort: low | medium | high | xhigh | max` to hint at thinking budget:

- `low` / `medium` -- exploration, mechanical changes, quick reads
- `high` -- standard implementation (default)
- `xhigh` / `max` -- hard algorithmic problems or complex design

Example combining both:

```
Task(subagent_type: "explore", model: "haiku", effort: "low", prompt: "...")
Task(subagent_type: "runner", model: "sonnet", effort: "high", prompt: "...")
```

### Context isolation

Task tool subagents receive only what their prompt contains -- they have no
access to the parent conversation history. Every piece of context needed must
be in the prompt.

## A note on cwd

The Task tool spawns a subagent in the **parent's cwd**. There's
no way to change it without worktree isolation. If the subagent
must operate in a different directory (e.g. a project root
different from your current working directory), you MUST use a
Bash-based dispatch with `-C` or `cd`.

This is the load-bearing reason the workspace dispatcher
dispatches orchestrators via Bash, not via Task tool: each
dispatcher must run in its own project's cwd to pick up the
right CLAUDE.md + repo state.

## A note on process boundaries

Task tool subagents share the parent's process and resource model.
A long-running Task subagent ties up your session; if your session
crashes, the subagent goes with it.

Bash-based dispatches are separate processes. They survive your
session crashing. Their state (output, exit code) is independently
inspectable. They can be backgrounded with `run_in_background=true`
and their completion notification re-enters your session
asynchronously.

For long-running dispatch (large refactors, multi-task batches),
prefer Bash-based dispatch even when cwd doesn't require it.

## When in doubt

Default to Task tool (with `isolation: "worktree"` for file-
modifying same-repo work). Reach for Bash + claude -p for
cross-project, different-cwd, or long-running work.
The two-option choice covers ~95% of real dispatch needs.
