---
name: workspace-survey
description: When the dispatcher needs a workspace map -- at the start of any multi-project or scope-scoping invocation. Enumerate repos under the owner-prefixed layout with `ls ~/Code/github.com/*/*`, load each project's positioning and live GitHub state (open/draft PRs, issues, CI), and RECONSTITUTE a tight activity report. Re-survey on every invocation; never cache per-project status back into any workspace CLAUDE.md, and never rely on prior-session memory.
---

# Workspace survey

The dispatcher needs a workspace map. This skill describes how to
build one from durable state (the filesystem + GitHub) every time,
without depending on a separate config file, a cached inventory, or
in-conversation memory.

The path convention this survey walks is defined once in
[`workspace-layout`](../workspace-layout/SKILL.md) -- load it for the
canonical `~/Code/<host>/<owner>/<repo>` shape, the enumeration glob,
and the map-not-model rule. This skill is the survey *procedure* on top
of that layout.

## Discovery: the filesystem IS the map

Repos live under the owner-prefixed layout:

```text
~/Code/<host>/<owner>/<repo>
```

`<host>` is `github.com` today; `<owner>` is the GitHub owner
(`joshrotenberg`, `genagent`, ...); `<repo>` is the repo. There is NO
`active/` root and NO language/framework segment -- those were the
pre-reorg layout. Enumerate every project with one glob:

```bash
ls -d ~/Code/github.com/*/*
```

`<host>/<owner>/<repo>` is exactly three levels deep, so `*/*` under a
host lists every repo. Each result is a candidate project; confirm it's
a real one by the presence of `.git/` (and, for "is it under active
management," a `CLAUDE.md` -- see below). Do not walk by language buckets
and do not look for an `active/` directory.

## What constitutes "active"

Presence of `CLAUDE.md` in a repo is the active flag. A repo with no
CLAUDE.md is not under the dispatcher's purview, even if it has a git
dir. This gives the human a simple lever for "include this in the
workspace map" -- just touch a CLAUDE.md. "Active" is read fresh from the
filesystem each survey; it is never a path segment and never a cached
field.

## Sibling resolution is path arithmetic

Because the layout is derivable, one project resolves another by relative
arithmetic from its own directory -- no lookup table:

| Target | From `~/Code/<host>/<owner>/<repo>` |
|---|---|
| Same owner, other repo | `../<repo>` |
| Other owner, same host | `../../<owner>/<repo>` |
| Other host entirely | `../../../<host>/<owner>/<repo>` |

Use this when a cross-project blocker means one project's survey must
peek at a sibling (e.g. project A waits on project B's release).

## Per-project context loading

For each discovered project, the dispatcher should know:

1. **Path** (its canonical location under the owner-prefixed layout)
2. **Owner/repo** (the `<owner>/<repo>` slug, derived from the path --
   feeds straight into `gh -R <owner>/<repo>`)
3. **One-line positioning** (first paragraph of CLAUDE.md, or its
   `## What this is` / `## Overview` section)
4. **Live state** (from GitHub via `gh`, queried fresh each survey):
   - Open PRs (`gh -R <owner>/<repo> pr list`)
   - Draft PRs (`gh -R ... pr list --draft`)
   - Open issues (`gh -R ... issue list`)
   - CI status on open PRs (`gh -R ... pr checks <PR>`)

Read CLAUDE.md ONLY enough to get the positioning -- don't read
the whole file unless you need it for routing a directive. Per-task
context loading is the dispatcher's job.

## Reconstitute to a report -- never cache upward

The survey RECONSTITUTES status into a report and then lets it go. It
does **not** write any per-project status back into a workspace-root /
manager CLAUDE.md.

This is the "map, not model" line from
[`workspace-layout`](../workspace-layout/SKILL.md). The manager
CLAUDE.md is a map: it says where projects are (the layout + the
enumeration glob) and how to read each one. It must NOT carry:

- A hardcoded project inventory (the glob enumerates it fresh).
- Per-project last-seen PR/issue/CI/notable-change status.
- Any "agents update this section when they learn something" cache.

Every number in the survey is reconstituted on demand from durable
substrate (the filesystem + a fresh `gh` query) at the moment of the
survey, emitted to the report below, and discarded. Nothing flows
upward. State that was true 30 minutes ago may not be true now; a cached
inventory would be stale by design, which is exactly why the model
forbids it.

## Workspace context, NOT project context

The dispatcher should know the LAYOUT, not the DETAILS. If you
find yourself reading project source files, you've descended too
far. Hand off to the project's dispatcher/runner.

What the dispatcher carries:

- Which projects exist (from the glob)
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

A workspace survey returns a tight table (a transient report, not a
persisted file):

```text
project        | path                                          | open PRs | draft PRs | open issues | CI state
my-tool        | ~/Code/github.com/joshrotenberg/my-tool       | 0        | 0         | 12          | -
agent-tools    | ~/Code/github.com/joshrotenberg/agent-tools   | 1        | 0         | 0           | green
tower-mcp      | ~/Code/github.com/joshrotenberg/tower-mcp     | 3        | 1         | 8           | 1 red
some-lib       | ~/Code/github.com/genagent/some-lib           | 0        | 0         | 4           | -
```

Sort by activity (PRs first, then draft PRs, then issues). Suppress
fully-quiet projects unless the directive specifically asks for them.

## Refresh discipline

Re-survey at the start of EACH dispatcher invocation. Don't carry
state from a prior conversation and don't read it from a cached
inventory. The cost is two `gh` calls per project (PR list + issue
list), which is cheap relative to dispatch cost.

State that was true 30 minutes ago may not be true now (CI
finished, a PR landed, a new issue opened). The survey is the
ground truth; your conversation memory -- and any inventory someone
was tempted to cache -- is not.

## The workspace-level CLAUDE.md gap

Claude Code's CLAUDE.md discovery walks UP within a single
project's hierarchy -- it does not cross project boundaries. When
the dispatcher fires a worker into a specific project (e.g. with a
`cd <path> && claude -p` invocation), the spawned session loads only
that project's CLAUDE.md. Any workspace-level context -- the layer that
sits above individual projects -- is invisible to the worker.

That workspace-level context might carry:

- Cross-project conventions (shared commit format, release cadence)
- Workspace-level skills or dispatch patterns
- Cross-project blockers (project A waits on project B's release)

Note what it must NOT carry: per-project status or a project inventory.
The manager CLAUDE.md stays a map (see "Reconstitute to a report"
above); cross-project *conventions* are fine, cached *status* is not.

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
workarounds above visibly stop being enough. Note that such a file
would hold *conventions/overrides*, not a reconstitutable status cache.

## When to apply

- At the start of any dispatcher invocation that may span multiple projects.
- When the directive is "work across foo and bar" or similar multi-project scope.
- Skip for single-project invocations where the cwd is already the target project.

## Related

- [`workspace-layout`](../workspace-layout/SKILL.md) -- the canonical
  owner-prefixed path shape, enumeration glob, sibling arithmetic, and
  the map-not-model rule this survey obeys.
- [`orchestration-patterns`](../orchestration-patterns/SKILL.md) -- the unit-of-work model the survey feeds into
- [`dispatch-options`](../dispatch-options/SKILL.md) -- how to dispatch runners for each project discovered
- [`durable-context`](../durable-context/SKILL.md) -- why re-survey and reconstitute rather than relying on memory/cache
