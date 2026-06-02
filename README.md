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

## Entry point

After install, the primary invocation is:

```
claude --agent dispatcher
```

Dispatcher reads your GitHub issue queue, decides execution shape, and fires
runners. Runners dispatch workers that branch, edit files, open PRs, watch CI,
and merge. The entire pipeline runs automatically.

Typical session:

1. File issues (describe what you want done)
2. Run: `claude --agent dispatcher`
3. Review merged PRs

## Agents

| Agent | What it does | Invoke with |
|---|---|---|
| `dispatcher` | Scopes units of work, decides execution shape, fires runners | `@dispatcher work the backlog` (in-session) or `claude --agent dispatcher` (CLI) |
| `runner` | Implements one GitHub issue end-to-end (branch, draft PR, CI, merge) | `@runner implement #N` |
| `reviewer` | Reviews a PR: approve+merge, request-changes+draft, or approve+note ordering | `@reviewer review #N` |
| `worker` | Bounded code-change executor; reads context, edits files, commits | (dispatched by runner) |

See `agents/README.md` for invocation details and when to skip the dispatcher and
go straight to the runner.

## Feedback loop

The `field-feedback` and `agent-feedback` skills file GitHub issues automatically
when agents encounter problems during dispatch. `@dispatcher triage open issues`
labels and prioritizes them. Runners work the queue. The loop closes.

## Getting started on a new project

1. `touch CLAUDE.md` -- marks the project for workspace survey.
2. Write Overview, Architecture, and Current Status sections.
3. `@dispatcher work the backlog` or `@runner implement #N`.

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

## Install from a release

To install without cloning the repo:

```bash
# Latest release
gh release download --repo joshrotenberg/agent-tools \
  --pattern "*.tar.gz" --dir /tmp/agent-tools
cd /tmp/agent-tools && tar xzf *.tar.gz && ./install.sh

# Specific version
gh release download v0.2.0 --repo joshrotenberg/agent-tools \
  --pattern "*.tar.gz" --dir /tmp/agent-tools
cd /tmp/agent-tools && tar xzf *.tar.gz && ./install.sh
```

Releases are created automatically when `feat:`, `fix:`, or `docs:` commits
land on main. See [releases](https://github.com/joshrotenberg/agent-tools/releases)
for available versions.

## License

Licensed under [MIT](LICENSE-MIT) or [Apache 2.0](LICENSE-APACHE), at your option.
