# agent-tools

My custom skills and subagents for working with Claude Code.

## What's in here

- **`skills/`** -- operational knowledge. Process discipline, git
  workflow, dispatch patterns, sandbox preflight, release-audit
  anchoring, and the rest of the patterns I've found load-bearing
  across projects.
- **`agents/`** -- subagent definitions. `runner` does one task
  end-to-end; `dispatcher` gathers context, decides execution
  shape, and fires runners (single, parallel, sequential, etc.).

The shape: a **unit of work** is defined by durable state (issue,
PR, project CLAUDE.md, code). The dispatcher reads that
state, decides how to execute, and fires. The runner does one
task end-to-end. Everything else is ephemeral -- conversations,
agent context, dispatch sessions all read durable state on
invocation and write durable state on return.

This is a personal customization layer. The patterns are
general -- adopt or fork as you like -- but the curation is
opinionated.

## Install

```bash
./install.sh
```

Copies `skills/*` into `~/.claude/skills/` and `agents/*` into
`~/.claude/agents/`, where Claude Code auto-discovers them.

Options:

- `--to PATH` -- install under PATH/skills and PATH/agents
  instead of `~/.claude/`
- `--force` -- overwrite existing entries without prompting
- `--skip` -- skip existing entries without prompting (default
  on non-TTY)
- `--dry-run` -- print what would be copied; touch nothing

## Dispatch

The agents are dispatch-agnostic. You can drive `runner` with:

- The Task tool (Claude Code native, simplest)
- [`roba`](https://github.com/joshrotenberg/roba) -- a mechanical
  CLI wrapper around `claude -p` (`roba --agent runner ...`)
- `claude -p --agent runner` directly
- Any other wrapper that takes an agent name and a prompt

See `skills/dispatch-options` for the trade-off table.

## Status

Active and changing. Skills get added or refined as I dogfood
across projects; the dispatcher + runner agents have settled
against the unit-of-work + execution-shape framing.
