# agents

Subagent definitions for the **dispatcher + runner** model:

- **Dispatcher** -- takes a directive, gathers everything the
  unit of work needs from durable state, decides the execution
  shape, fires. Scope-flexible: handles one task, multi-task
  in one project, or work across multiple projects.
- **Runner** -- executes one task end-to-end (issue → PR →
  merged) under the draft-PR-first lifecycle.

Each agent is a markdown file with YAML frontmatter (`name`,
`description`, `tools`, `model`, `skills`) plus a system-prompt
body. Structurally compatible with Claude Code's
`.claude/agents/` convention; `install.sh` at the repo root
copies them into `~/.claude/agents/`.

## The model

```
human (directive)
  ↓
dispatcher        -- gathers durable context; decides shape
  ↓ fires
runner (or runners, or chain, or audit + remediate)
  ↓ produces
durable state     -- merged PR + CLAUDE.md updates + closed issues
```

The dispatcher's load-bearing decision is the **execution
shape**: single runner (default), parallel runners, sequential
runners, chained agents (future), audit + remediate. See
[`orchestration-patterns`](../skills/orchestration-patterns/SKILL.md).

## When to invoke each

| situation | who to call |
|---|---|
| One task, well-defined ("implement #N here") | Skip the dispatcher; the human IS the dispatcher. Dispatch a `runner` directly. |
| Backlog work in one project | `dispatcher` |
| Cross-project work in one sitting | `dispatcher` |
| Audit / survey / strategic dispatch | `dispatcher` |
| A specific task within any of the above | `runner`, dispatched by the dispatcher (or by you directly) |

The dispatcher earns its keep when unit-of-work scoping or
execution-shape choice is non-trivial. For routine single-task
work, going straight to the runner skips ceremony.

## Available agents

| Agent | Scope | When to invoke |
|---|---|---|
| [`runner`](runner.md) | One task: implement one issue end-to-end | "implement #N" (direct or via dispatcher) |
| [`dispatcher`](dispatcher.md) | One or many units of work; one or many projects | "work the backlog in foo", "work across foo and bar", "audit release readiness" |
| [`worker`](worker.md) | One bounded code-change task; no lifecycle | Dispatched by runner or dispatcher to make file edits, validate, and commit |
| [`auditor`](auditor.md) | One codebase audit against a rubric | "audit <domain> in <repo>", dispatched by dispatcher for audit+remediate shape |
| [`reviewer`](reviewer.md) | One PR: review, then merge or request changes | "review PR #N", or dispatched by dispatcher for the review shape |

## Installation

These agents ship with the agent-tools plugin (see the
[root README](../README.md#install)):

```
/plugin marketplace add joshrotenberg/agent-tools
/plugin install agent-tools@agent-tools
```

Or copy them into `~/.claude/agents/` from the repo root:

```bash
./install.sh
```

See the root README for options (`--to`, `--force`, `--skip`, `--dry-run`).

After install, any Claude Code session can spawn:

```
@dispatcher work the backlog in this project
@dispatcher work across foo and bar
@runner implement #N
```

## Dispatch mechanism

The agents are dispatch-agnostic. They can be driven by Claude
Code's Task tool, by [`roba`](https://github.com/joshrotenberg/roba),
by `claude -p` directly, or by any wrapper that takes an
`--agent NAME` flag. See
[`dispatch-options`](../skills/dispatch-options/SKILL.md) for the
trade-off table.

## Format

Each agent is a flat `<name>.md` file (the `name:` field must match the
file name):

```
---
name: <kebab-case-name>
description: <one-line: what it does + how to invoke>
tools: <comma-separated tool list>
model: <model id>
skills:
  - <skill name, loaded into the agent's context>
---

# <Title>

<system-prompt body>
```

The `skills:` frontmatter list is the agent's "doctrine" --
operational knowledge it pulls in from `../skills/`. The body
itself stays slim: identity, lifecycle, contract. Procedural
detail lives in the skills.
