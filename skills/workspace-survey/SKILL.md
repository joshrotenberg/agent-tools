---
name: workspace-survey
description: When the dispatcher needs a workspace map -- at the start of any multi-project or scope-scoping invocation. Walk ~/Code/active/ for directories with both .git/ and CLAUDE.md, load each project's positioning and live GitHub state (open/draft PRs, issues, CI), and return a tight activity table. Re-survey on every invocation; do not rely on prior-session memory.
---

# Workspace survey

The dispatcher needs a workspace map. This skill describes how to
build one from durable state (the filesystem + GitHub) every time,
without depending on a separate config file or in-conversation
memory.

## Discovery: the filesystem IS the map

A "project" is any directory that has BOTH:

- `.git/` (it's a git repository)
- `CLAUDE.md` (it's actively being worked on)

The default workspace root is `~/Code/active/`. The dispatcher
walks subdirectories looking for the pair. Common layouts:

```
~/Code/active/
├── rust/<project>/      # group-by-language is common
├── elixir/<project>/
└── <project>/           # top-level for one-off projects
```

Walk depth ~3 levels under the workspace root. Stop descending into
a directory once you've matched a `.git/` -- nested git repos
aren't separate projects from the workspace's perspective.

## What constitutes "active"

Presence of CLAUDE.md is the active flag. A repo with no CLAUDE.md
is not under the dispatcher's purview, even if it has a git dir.
This gives the human a simple lever for "include this in the
workspace map" -- just touch a CLAUDE.md.

## Per-project context loading

For each discovered project, the dispatcher should know:

1. **Path** (its location on disk)
2. **Name** (basename of the path, or override from CLAUDE.md
   metadata if present)
3. **One-line positioning** (first paragraph of CLAUDE.md, or its
   `## What this is` / `## Overview` section)
4. **Live state** (from GitHub via `gh`):
   - Open PRs (`gh -R <owner>/<repo> pr list`)
   - Draft PRs (`gh -R ... pr list --draft`)
   - Open issues (`gh -R ... issue list`)
   - CI status on open PRs (`gh -R ... pr checks <PR>`)

Read CLAUDE.md ONLY enough to get the positioning -- don't read
the whole file unless you need it for routing a directive. Per-task
context loading is the dispatcher's job.

## Workspace context, NOT project context

The dispatcher should know the LAYOUT, not the DETAILS. If you
find yourself reading project source files, you've descended too
far. Hand off to the project's dispatcher.

What the dispatcher carries:

- Which projects exist
- Which are in flight (have open PRs or draft PRs)
- Which are dormant (no recent activity)
- High-level cross-project blockers (project A waiting on
  project B's release)

What the dispatcher does NOT carry:

- Specific issue contents
- Specific code conventions
- Architectural decisions
- Implementation history

## Survey output shape

A workspace survey returns a tight table:

```
project              | path                                 | open PRs | draft PRs | open issues | CI state
my-tool              | ~/Code/active/rust/my-tool           | 0        | 0         | 12          | -
agent-tools          | ~/Code/active/agent-tools            | 1        | 0         | 0           | green
tower-mcp            | ~/Code/active/rust/tower-mcp         | 3        | 1         | 8           | 1 red
claude-wrapper       | ~/Code/active/rust/claude-wrapper    | 0        | 0         | 4           | -
```

Sort by activity (PRs first, then draft PRs, then issues). Suppress
fully-quiet projects unless the directive specifically asks for
them.

## Refresh discipline

Re-survey at the start of EACH dispatcher invocation. Don't carry
state from a prior conversation. The cost is two `gh` calls per
project (PR list + issue list), which is cheap relative to dispatch
cost.

State that was true 30 minutes ago may not be true now (CI
finished, a PR landed, a new issue opened). The survey is the
ground truth; your conversation memory is not.

## The workspace-level CLAUDE.md gap

Claude Code's CLAUDE.md discovery walks UP within a single
project's hierarchy -- it does not cross project boundaries. When
the dispatcher fires a worker into a specific project (e.g. with a
`-C /path/to/project` cwd), the spawned session loads only that
project's CLAUDE.md. Any workspace-level context -- the layer that
sits above individual projects -- is invisible to the worker.

That workspace-level context might carry:

- Cross-project conventions (shared commit format, release cadence)
- Workspace-level skills or dispatch patterns
- The project name + role mapping (which repo plays which part)
- Cross-project blockers (project A waits on project B's release)

**v1 recommendation: document the limitation; don't build a
mechanism for it.** Two workarounds cover the real cases:

1. **Push it down.** Put any cross-project convention that workers
   need into each project's own CLAUDE.md. Duplication is the cost;
   discovery-for-free is the payoff.
2. **Pass it in the prompt.** Inject the relevant workspace context
   explicitly via the constraints/context section of the
   orchestration prompt template. The dispatcher already carries the
   workspace map; hand the worker the slice it needs.

**Possible future directions** (not commitments): a workspace
config file at `~/.config/agent-tools/workspace.toml` carrying
priority overrides, dormant flags, custom roots, and cross-project
context the filesystem walk can't express; or an upstream
claude-code feature that lets discovery cross a marked workspace
boundary. Build either only when the filesystem walk and the two
workarounds above visibly stop being enough.

## When to apply

- At the start of any dispatcher invocation that may span multiple projects.
- When the directive is "work across foo and bar" or similar multi-project scope.
- Skip for single-project invocations where the cwd is already the target project.

## Related

- [`orchestration-patterns`](../orchestration-patterns/SKILL.md) -- the unit-of-work model the survey feeds into
- [`dispatch-options`](../dispatch-options/SKILL.md) -- how to dispatch runners for each project discovered
- [`durable-context`](../durable-context/SKILL.md) -- why re-survey rather than relying on memory
