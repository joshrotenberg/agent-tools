---
name: workspace-survey
description: How the dispatcher discovers projects in the workspace, reads their state, and assembles a workspace-level picture. The filesystem layout IS the workspace map; no separate config required.
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
roba                 | ~/Code/active/rust/roba              | 0        | 0         | 12          | -
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

## Optional: config file (deferred)

A workspace config at `~/.config/agent-tools/workspace.toml` could
carry priority overrides, dormant flags, custom roots, etc. Not
shipped in v1. Add when the filesystem walk becomes lossy (e.g.
projects in non-standard locations, priority hints that the
filesystem layout can't express).
