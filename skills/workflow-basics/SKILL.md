---
name: workflow-basics
description: When deciding between the Workflow tool and the Task tool for large-scale orchestration (50+ agents) -- use this. Covers what the Workflow tool is, its critical no-direct-I/O constraint, the fan-out + synthesize and chained design->impl->review shapes it fits, and when the simpler Task tool wins instead.
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

## Related

- [`orchestration-patterns`](../orchestration-patterns/SKILL.md) --
  the broader execution-shape table; Workflow is the at-scale
  implementation of the audit + remediate and chained shapes.
- [`dispatch-options`](../dispatch-options/SKILL.md) -- the dispatch
  mechanisms for everything below Workflow scale.
