---
name: workflow-basics
description: When deciding between the Workflow tool and the Task tool for large-scale orchestration (50+ agents) -- use this. Covers what the Workflow tool is, its critical no-direct-I/O constraint, the harness relay frame that can pull agents off their assigned task, the fan-out + synthesize and chained design->impl->review shapes it fits, and when the simpler Task tool wins instead.
---

# Workflow basics

The Workflow tool (Claude Code v2.1.154+, research preview, Pro+
plans) runs a JavaScript orchestration script in an isolated
background runtime. The script holds the entire plan and spawns
agents; your conversation context receives only the final answer.

## What it is

- A **JavaScript script** that describes the orchestration: which
  agents to spawn, in what order, how to combine their output.
- Runs in an **isolated background runtime**, separate from your
  conversation. The script is the plan; it persists across the run.
- **Scale**: up to 16 agents concurrent, scaling to 50-1000+ agents
  per run.
- **Context model**: only the final synthesized answer returns to
  your context. The intermediate fan-out stays in the runtime.
- Accepts an **`args`** parameter for parameterized runs.
- A paused run can **resume within the same session** with cached
  results from already-completed agents.

## Critical constraint: the script has no direct I/O

The orchestration script itself **cannot read or write files or run
shell commands**. Only the agents the script spawns can do I/O.

This shapes how you write a workflow: the script is pure
coordination logic (spawn, gather, combine). Anything that touches
the filesystem, git, or a shell must be delegated to a spawned
agent. Don't write a script that tries to `readFile` or exec a
command -- it has no such capability.

## When to use vs the Task tool

| dimension | Workflow tool | Task tool |
|---|---|---|
| **Plan location** | In the JS script (durable across run) | In the dispatching conversation |
| **Context model** | Only final answer returns | Each agent's output returns to context |
| **Scale** | 50-1000+ agents | A handful of parallel agents |
| **Repeatability** | Parameterized via `args`, resumable | One-shot per dispatch |

Reach for **Workflow** when the orchestration is large enough that
holding every agent's output in conversation context would blow the
budget, or when the same multi-agent plan should run repeatably with
different inputs.

Reach for the **Task tool** for everything smaller: a single runner,
a few parallel runners, anything where you want each agent's output
visible in your context.

## Best-fit shapes

- **Audit + remediate fan-out at scale.** A survey phase spawns
  dozens of read-only agents (one per file, module, or finding),
  then a synthesis phase combines findings. When the fan-out is 50+
  agents, the Task tool's per-agent context return doesn't fit;
  Workflow keeps it in the runtime and returns only the synthesis.
- **Chained design -> impl -> review.** The script sequences the
  phases and passes each phase's output to the next as script-local
  data, returning only the final reviewed result.

## NOT for

- **Single-runner tasks.** One issue, one PR -- use a runner via the
  Task tool. A workflow script is pure overhead here.
- **Small parallel tasks.** A few independent edits across different
  files -- the Task tool with parallel dispatches is simpler and
  keeps each result in context.

The dividing line is scale and context pressure, not task type. If
the Task tool fits, it's the simpler choice.

## Reference example

The bundled **`/deep-research`** workflow is the canonical pattern:
fan out web searches and source fetches across many agents,
cross-check claims adversarially, then synthesize a single cited
report. It demonstrates fan-out -> verify -> synthesize end to end.

## Harness relay frame

Observed 2026-09-28 on Claude Code 2.1.284 (macOS desktop app). Every
`agent()` the Workflow tool spawns receives two framed messages ahead
of the script-written prompt:

| frame | header | contents | stated authority |
|---|---|---|---|
| 1 | `[Workflow harness -- user request]` | the user's most recent human chat message, verbatim | "the only user voice in this task"; where the computed task conflicts with it, "this request wins" |
| 2 | `[Workflow harness -- computed task]` | the script's per-agent prompt | "no user authority" |

The literal headers use an em dash; `--` stands in for it here. The
strings are compiled into the `claude` binary and gated by the env var
`CLAUDE_CODE_WORKFLOW_PROMPT_PROVENANCE`, falling back to the
GrowthBook gate `tengu_bubbly_harbor` (default true). Third-party
testing reports the env var has no effect in 2.1.283; it has not been
tested on 2.1.284 here, so do not rely on it to turn the frame off.

### Failure mode

The relayed message is whatever the user last typed, which may be
unrelated to the workflow. An agent that judges its task to conflict
with it can drop the task and answer the message instead. The script
receives that answer as an ordinary result.

Observed: a 3-agent fan-out where each agent was asked to write a
haiku. Two complied. The third judged the haiku task to conflict with
the relayed message, invoked the `workflow-basics` and
`workflow-authoring` skills, and answered the relayed message. A
downstream judge agent with no grading criteria picked that off-task
output as the winner. The upstream reports below describe the same
behavior, including cases where the relayed message was stale or
unrelated to the workflow.

### Mitigations

- **Write each agent prompt so it visibly serves the user's launching
  request.** An agent comparing the two frames should find no conflict.
- **State the user's intent in the prompt**, not only the mechanical
  task. One sentence naming the request the workflow was launched for.
- **Give judge and aggregator agents explicit grading criteria and the
  original task spec.** An output that answers a different question can
  then be scored as off-task instead of compared on its own merits.
- **Avoid sending unrelated chat messages while a workflow is
  launching.** The relayed frame carries the most recent human message,
  so an unrelated one sent around launch can be the one relayed.
- **Validate each agent's output against its assigned task before
  aggregating.** Drop or re-run outputs that do not address it.

### Upstream reports

- [anthropics/claude-code#96640](https://github.com/anthropics/claude-code/issues/96640)
- [anthropics/claude-code#95369](https://github.com/anthropics/claude-code/issues/95369)

## Anti-patterns

- Using Workflow for single-runner tasks -- one issue, one PR, one runner; a workflow script is pure overhead here.
- Writing I/O in the orchestration script -- the script has no direct I/O; delegate filesystem and shell work to agents.
- Assuming each agent's output returns to context -- only the final synthesized answer
  does; intermediates stay in the runtime.
- Assuming the script's per-agent prompt is the only instruction an agent sees -- the harness relays the user's latest
  chat message ahead of it and tells the agent that message wins on conflict (see Harness relay frame).
- Running a judge or aggregator agent with no grading criteria -- it can select an off-task output as the winner.

## Related

- [`orchestration-patterns`](../orchestration-patterns/SKILL.md) --
  the broader execution-shape table; Workflow is the at-scale
  implementation of the audit + remediate and chained shapes.
- [`dispatch-options`](../dispatch-options/SKILL.md) -- the dispatch
  mechanisms for everything below Workflow scale.
