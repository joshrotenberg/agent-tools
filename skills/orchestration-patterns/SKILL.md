---
name: orchestration-patterns
description: When the dispatcher is scoping a unit of work or deciding how to execute it -- use this to define what the unit is and pick the right execution shape (single runner / parallel / sequential / chained / audit + remediate). Default to single runner; reach for other shapes only when the unit justifies the coordination cost.
---

# Orchestration patterns

The substrate is durable state: issues, PRs, project CLAUDE.md
files, the code itself, the workspace filesystem layout. Agents
and conversations are ephemeral. This skill describes how to
think about units of work against that substrate, and how to
pick the right execution shape.

## What's a unit of work?

A self-contained slice of durable state. The pieces:

| piece | what it is |
|---|---|
| **Input** | A GitHub issue (or a bundle of related issues), the directive interpreting it |
| **Context** | The project's CLAUDE.md + the relevant code state + the open/draft PRs that matter |
| **Output** | PR shape: merged PR + CLAUDE.md updates + closed issues. Non-PR shape: structured text to a durable destination (stdout, CLAUDE.md entry, issue comment, findings file) + optionally new issues spawned for follow-on work |

A unit isn't sized by line count or hours. It's sized by what
the durable state says belongs together. "Implement #42" is a
unit. "Work the 4 release-blocker issues for v0.2" is a unit.
"Audit release readiness across foo and bar" is a unit. The
dispatcher decides where the boundaries are; the substrate (not
an arbitrary rule) defines what's coherent.

## The dispatcher's decision

For each unit, the dispatcher picks an **execution shape**:

| shape | when it fits | example |
|---|---|---|
| **Single runner** | Small, well-defined task. Issue clearly says what; code clearly receives it. | "Fix the off-by-one in `parse_offset` per #142" |
| **Parallel runners** | Multiple independent tasks. Different files, no semantic interaction. | "Bump 3 dep versions; each in its own PR" |
| **Sequential runners** | Order matters: A's output (in durable state) is B's input. | "Add the type in PR-A; implement against it in PR-B" |
| **Chained agents** (design → impl → review) | Larger work; design quality matters; same-context conflation is a real risk | "Refactor the auth layer to support OIDC" (currently a future shape; build when justified) |
| **Audit + remediate** | Read-only survey first; then per-finding runner dispatch | "Audit release-readiness across foo and bar; fix what's blocking" |
| **Researcher** | Read-only directive produces an answer, report, or explanation -- no code change | "compare actix-web vs axum for HTTP server use" |
| **Auditor** | Read-only directive produces structured findings; may spawn issues for actionable items | "security audit src/auth/", "why is test_foo failing?" |

Default: single runner. Reach for the others only when the unit
justifies the coordination cost.

## Where each shape is right

### Single runner

The 90% case. One issue, one PR, one runner doing design +
implementation + verification within its lifecycle. Most code
changes look like this.

When in doubt, pick this. Coordination is overhead; if you can
do the work in one runner, do it in one runner.

### Parallel runners

When you have N independent tasks. The unit is "bump these 3
dep versions" or "add docs for these 4 functions" -- each piece
truly doesn't interact with the others.

Verify independence first. If two tasks touch the same file,
parallel makes them conflict. Per
[`orchestrator-parallelization`](../orchestrator-parallelization/SKILL.md)
for the fan-out heuristics + the worktree isolation pattern for
same-repo parallel.

### Sequential runners

When task A's output is task B's input via durable state. A
opens a PR adding a type; B opens a PR using that type after A
merges. The dispatcher fires A, waits for merge, then fires B.

Don't try to make B's runner aware of A's runner directly --
that's coupling agents. Couple via durable state: A's merged PR
is what B reads.

### Chained agents

For larger work where the design-vs-implementation gap is real.
A designer agent reads the issue + context and writes a design
to a durable artifact (PR body, issue comment); an implementer
agent reads the design and produces the PR; a reviewer agent
reads the PR and produces review comments.

Costs are real: handoff overhead, context-translation loss
between agents (the designer's intuition doesn't always survive
the written spec). Use ONLY when:

- The unit is large enough that conflating design + implement
  in one runner produces worse outcomes
- Same-context review (the runner reviewing its own work) is
  visibly missing things
- The work is security-sensitive enough that independent eyes
  are the point, not the cost

The basic chain is realized by the current dispatcher+runner+reviewer
model: the dispatcher reads the issue, scopes it, and decides the
approach (the design step); the runner implements; the reviewer agent
provides independent review. A dedicated design agent that writes a
spec to a durable artifact before the runner starts would be the
natural extension for larger or security-sensitive work.

### Audit + remediate

Two-phase: a read-only auditor surfaces findings; a per-finding
runner dispatch (parallel or sequential) addresses each.
Findings land in durable state (a tracking issue, or comments
on existing issues) so the runner phase can pick them up
without re-running the audit.

Right shape for release audits, security scans, dependency
sweeps.

For large-scale fan-out (50+ agents per run), the Workflow tool
is the right mechanism -- it keeps the per-agent output in an
isolated runtime instead of returning each result to context.
See [`workflow-basics`](../workflow-basics/SKILL.md).

For the dispatcher-side mechanics of reading finding-issues and deciding parallel vs sequential
runner dispatch, see [`audit-remediate-handoff`](../audit-remediate-handoff/SKILL.md).

**Triage-then-dispatch** is a variant: a read-only triage pass
labels the open-issue queue by component, category, and priority
(durable findings), then the dispatcher scopes runners against the
labeled queue. See [`triage`](../triage/SKILL.md).

### Researcher

The read-only, text-output shape. The unit is a question, comparison,
or status request. The dispatcher fires a `subagent_type: "explore"`
Task dispatch (or researcher agent when available). Output goes to
the destination per
[`non-pr-output-conventions`](../non-pr-output-conventions/SKILL.md):
stdout for ephemeral answers, issue comment or file for durable
reports.

No branch, no PR, no CI watch. The synchronous hold-open contract
still applies: the dispatch must complete and deliver to the durable
destination before the dispatcher returns.

### Auditor

The read-only, findings-output shape. The unit is an audit or
diagnosis directive. Output is structured findings delivered to a
durable destination per
[`non-pr-output-conventions`](../non-pr-output-conventions/SKILL.md).
Actionable findings above a threshold get filed as new issues; the
dispatcher can immediately dispatch runners on them (the
"audit + remediate" shape extended to include the non-PR audit phase
explicitly).

No branch, no PR. The synchronous hold-open contract applies.

## Single-project vs multi-project units

The dispatcher handles both. Single-project units stay in one
project's cwd; multi-project units survey across projects and
dispatch per-project runners.

For multi-project surveys, see
[`workspace-survey`](../workspace-survey/SKILL.md). The
filesystem layout IS the workspace map; the dispatcher walks it
to enumerate active projects.

What multi-project units shouldn't do:

- Treat cross-project state as a single conversation. State
  externalizes: each project's CLAUDE.md owns its own context.
- Run multi-project runners that span repos. A runner is
  task-scoped; if work crosses repos, that's multiple runner
  dispatches, not one runner with multi-repo awareness.
- Assume coordination via the dispatcher's memory. Coordinate
  via GitHub state (e.g. "this PR closes both #N in foo and
  #M in bar via cross-repo issue references").

## State externalization, restated

Every shape relies on the same rule: state lives in durable
stores. Issues, PRs, project CLAUDE.md, code, the workspace
filesystem. The dispatcher and runners are transient; they
read durable state on invocation and write durable state on
return.

A fresh dispatcher session can re-survey, re-scope, and
re-dispatch. A fresh runner session can re-read the issue +
CLAUDE.md and continue. The shapes are not stateful processes
-- they're just patterns of dispatch against durable state.

## When NOT to invoke the dispatcher

If the unit is small and well-defined, the human IS the
dispatcher; invoke a runner directly via Task tool or Bash.
The dispatcher agent earns its keep when:

- Unit scoping is non-trivial
- Execution shape needs deliberate choice
- Multi-project surveying is required
- The work has order dependencies that need explicit sequencing

For the routine case (one issue, one runner, one PR), the
dispatcher adds ceremony.

## Anti-patterns

- Coupling runners via agent memory instead of durable state -- agents are transient; coordination must go through the substrate.
- Multi-repo runners spanning repositories in one dispatch -- cross-repo work is multiple runners, not one per repo.
- Conflating design and implementation when same-context review misses things -- use the chained shape or split the unit.

## Related

- [`workspace-survey`](../workspace-survey/SKILL.md) -- how the
  dispatcher discovers projects for multi-project units.
- [`dispatch-options`](../dispatch-options/SKILL.md) -- pick the
  dispatch mechanism per shape.
- [`orchestrator-parallelization`](../orchestrator-parallelization/SKILL.md)
  -- fan-out heuristics for the parallel-runner shape.
- [`orchestration-prompt-template`](../orchestration-prompt-template/SKILL.md)
  -- how to compose the per-runner prompt.
