---
name: workspace-layout
description: The canonical owner-prefixed workspace layout. Every repo lives at ~/Code/<host>/<owner>/<repo> -- no active/ or language segment. Enumerate with `ls ~/Code/github.com/*/*`; resolve siblings by path arithmetic. The manager (workspace-root) CLAUDE.md is a map of where things are and how to read them, never a cache of per-project inventory or status. Load this whenever a session reasons about where a repo lives, walks the workspace, or resolves one project from another.
---

# Workspace layout

The canonical convention for where every repo lives and how the manager
session reasons about the workspace. This is the single source of truth
for the path shape; other skills (`workspace-survey`, dispatch, sibling
resolution) reference it rather than restating it.

## The path shape

Every clone lives at one derivable, owner-prefixed path:

```text
~/Code/<host>/<owner>/<repo>
```

- `<host>` is the forge host (`github.com` today; the segment leaves room
  for others without reshuffling).
- `<owner>` is the GitHub owner/org (`joshrotenberg`, `genagent`, ...).
- `<repo>` is the repository name.

Example: `~/Code/github.com/joshrotenberg/adrs`.

**No `active/`, no `inactive/`, no language/framework segment.** Those facts
are mutable and derivable; encoding them in the path rots it the moment a
project changes language or goes dormant. Forks need no `-fork` suffix
either -- the `<owner>` segment already disambiguates, and provenance lives
in `git remote`.

## Enumeration

The filesystem is the index. List every project with one glob:

```bash
ls -d ~/Code/github.com/*/*
```

`<host>/<owner>/<repo>` is exactly three levels deep, so `*/*` under a host
enumerates every repo. Do NOT walk by language buckets or look for an
`active/` root -- there is none.

A project is "in the workspace" if its directory exists under this layout.
Whether it is actively worked is a *reconstituted* fact (recent commits,
open PRs), not a path segment and not a cached flag.

## Sibling resolution is path arithmetic

Because the path is derivable, one project resolves another by relative
arithmetic from its own directory -- no lookup table, no config:

| Target | From `~/Code/<host>/<owner>/<repo>` |
|---|---|
| Same owner, other repo | `../<repo>` |
| Other owner, same host | `../../<owner>/<repo>` |
| Other host entirely | `../../../<host>/<owner>/<repo>` |

This is why the layout is owner-prefixed and flat: the deterministic cwd
makes cross-project consultation pure path math, and the matching escaped
dir under `~/.claude/projects/` is equally derivable.

## Map, not model: the manager CLAUDE.md

The workspace-root `~/Code/CLAUDE.md` (the "manager" / Code Manager context)
is a **map**: it says *where* projects are (this path convention + the
enumeration glob) and *how* to read each one. It is not an inventory and not
a status cache.

Specifically, the manager CLAUDE.md must NOT carry:

- A hardcoded project list / inventory (the glob enumerates it fresh).
- Per-project last-seen PR/issue/CI/notable-change status.
- Any "agents update this section when they learn something" cache.

Per-project status is **reconstituted on demand** -- read the project's own
files and query `gh` (or cratesio/hexpm) at the moment you need it, emit it
to a report, and let it go. Nothing flows *upward* into the manager
CLAUDE.md. The moment the map starts caching what is *inside* a project
rather than *where* it is and *how to read it*, pull it back: that is the
"map, not model" line, and crossing it turns the manager into the stateful
system it must never become.

## When to apply

- Any time a session needs the canonical path for a repo, or builds one
  from `<host>/<owner>/<repo>` parts.
- Walking/enumerating the workspace (use the glob above).
- Resolving a sibling project from the current one (path arithmetic).
- Deciding what belongs in the manager CLAUDE.md vs. what must be
  reconstituted (the map/model line).

## Anti-patterns

- Assuming an `~/Code/active/` root or a language/framework bucket -- there
  is none; that was the pre-reorg layout.
- Walking deep directory trees looking for `.git/` when a single
  `ls ~/Code/github.com/*/*` glob enumerates everything.
- Writing a project inventory or per-project status into the manager
  CLAUDE.md ("so the dispatcher doesn't have to re-survey") -- that is the
  cache the model forbids; reconstitute instead.

## Related

- [`workspace-survey`](../workspace-survey/SKILL.md) -- how the dispatcher
  enumerates projects under this layout and reconstitutes a status report.
- [`durable-context`](../durable-context/SKILL.md) -- why state is
  reconstituted from durable substrate, not carried in context or cached
  upward.
