---
name: dispatch-options
description: Trade-offs between the four common ways to dispatch a subagent (Task tool / Bash + roba / Bash + claude-wrapper / Bash + claude -p direct). Helps orchestrators and runners pick the right mechanism for a given job.
---

# Dispatch options

There is no single right way to dispatch a subagent. Pick by what
the dispatch actually needs.

## The four options

| option | how | what it gives you | what you give up |
|---|---|---|---|
| **Task tool** | `Task(subagent_type: "X", prompt: "...")` | Same cwd, lowest overhead, native Claude Code integration, no process boundary | No different cwd, no worktree, no observability handle, no scriptable exit code, no `--trace`, child uses parent's permission state |
| **Bash + roba** | `Bash: roba --agent X -f /tmp/prompt.md` | Different cwd via `-C`, worktree isolation via `-w`, JSONL trace via `--trace`, typed exit codes, agent-ABI JSON envelope, process boundary | Roba installed, extra hop, slightly more setup per call |
| **Bash + claude-wrapper** | `Bash: claude-wrapper --print --agent X ...` (or library call) | Direct claude wrapper, fine-grained control of permission shape, programmable from Rust | More verbose, less ergonomic than roba |
| **Bash + claude -p direct** | `Bash: claude -p --agent X "..."` | Minimal -- no wrapper at all | No retry, no typed errors, no envelope, no observability, prompt visible in argv |

## When each fits

**Default to Task tool when:**

- The work happens in the same cwd as your session
- You don't need worktree isolation
- The dispatch is brief (<5 min) and you'll be re-invoked on
  completion
- You don't need to share the dispatch outcome with anything outside
  Claude Code

This is the normal in-session subagent path. Use it.

**Reach for Bash + roba when:**

- The dispatch needs to run IN A DIFFERENT CWD (e.g. dispatcher
  dispatching project-rooted orchestrators). Task tool can't do
  this; only a separate process with `-C` (or `cd`) can.
- You need worktree isolation (`-w` / `-w=NAME`) -- two dispatches
  that might touch the same files.
- You want observability: `--trace PATH` writes the spawned
  session's JSONL events for later inspection (spiral diagnosis,
  audit, replay).
- The dispatch outcome needs to be machine-readable (typed exit
  codes, versioned JSON envelope).
- The dispatch will be invoked from outside Claude Code too (CI
  scripts, cron, other agents), and you want a stable contract.
- The dispatch is long-running and you want it to survive your
  session compacting or restarting.

**Reach for Bash + claude-wrapper when:**

- You're scripting from Rust and want library-level control over
  permissions, retry policy, model selection
- Roba's surface doesn't expose what you need but the wrapper does

**Reach for Bash + claude -p direct when:**

- You want the absolute minimum surface, no dependencies
- You're running a quick one-shot that doesn't need any of the
  above

Avoid for production dispatch loops -- the lack of typed exits and
the argv-visible prompt make it a poor citizen.

## A note on cwd

The Task tool spawns a subagent in the **parent's cwd**. There's
no way to change it. If the subagent must operate in a different
directory (e.g. a project root different from your current
working directory), you MUST use a Bash-based dispatch with `-C`
or `cd`.

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

Default to Task tool for in-project work, Bash + roba for
cross-project or long-running work, Bash + claude -p only for
quick one-shots. The three-way choice covers ~95% of real
dispatch needs.
