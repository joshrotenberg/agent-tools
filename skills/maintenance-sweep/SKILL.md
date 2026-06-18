---
name: maintenance-sweep
description: When the directive is "status check," "what's new across my projects," or "sweep maintenance" -- run a per-project, read-mostly, non-PR sweep. For each project under the owner-prefixed layout, gather stars/forks, open issues/PRs split into mine vs community vs bots, package downloads, release-due (unreleased conventional commits), a test run, a stale-CLAUDE.md flag, and branch-cleanup candidates. Emit a fresh per-project report every sweep; NEVER cache status back into a workspace/manager CLAUDE.md.
---

# Maintenance sweep

A per-project health check that reads each active project's durable
state -- GitHub, package registries, git history, the test command --
and reconstitutes a fresh report every time. It is **read-and-report,
not work-an-issue.** The output is a per-project report, never a PR
and never a status cache written upward into a manager CLAUDE.md.

This is the Code Manager's "what's going on across my projects?"
ritual realized as a skill: map, not model. The sweep reconstitutes
state on demand; it holds none.

## When to use

- The directive is a status check: "what's new," "status update,"
  "sweep the projects," "are any of these due for a release?"
- At the start of a check-in ritual, to surface what changed since
  the last sit-down before deciding where to dispatch work.

## When NOT to use

- **You actually want to work an issue.** That's dispatcher -> runner,
  not a sweep. The sweep tells you *that* a project has a community PR
  waiting; it does not review or merge it.
- **You want to write a fix or a CLAUDE.md edit.** The sweep is
  read-only over project contents. Any change it proposes is *proposed*
  -- filed as an issue or handed to a worker (see Output discipline).
- **A single project, deep.** For one project's full context, read its
  CLAUDE.md directly; the sweep is the cross-project skim.

## Layout: owner-prefixed enumeration

Projects live at `~/Code/<host>/<owner>/<repo>` (today `<host>` is
always `github.com`). Enumerate the active set with:

```bash
ls -d ~/Code/github.com/*/*
```

Each match is a project root. A project is in scope if it has a
`.git/` (and typically a `CLAUDE.md`). Derive `<owner>/<repo>` from
the path for the `gh` calls below -- the path is the map.

## The seven axes

Run these per project. Each axis degrades gracefully: if an axis
can't run (no remote, not published, no test command), record `-`
and move on -- never block the sweep on one missing signal.

### (a) Stars / forks

```bash
gh api repos/<owner>/<repo> --jq '{stars: .stargazers_count, forks: .forks_count}'
```

### (b) Open issues / PRs -- mine vs community vs bots

Split every count three ways. Bots are excluded by matching `[bot]$`
on the author login; "mine" is the owner; "community" is everyone
else who is not a bot.

```bash
# My open issues (exclude PRs)
gh api 'repos/<owner>/<repo>/issues?state=open&creator=<owner>&per_page=100' \
  --jq '[.[] | select(.pull_request | not)] | length'

# Community issues (exclude me and bots)
gh api 'repos/<owner>/<repo>/issues?state=open&per_page=100' \
  --jq '[.[] | select(.user.login != "<owner>" and (.user.login | test("\\[bot\\]$") | not) and (.pull_request | not))] | length'

# Community PRs (exclude me and bots)
gh api 'repos/<owner>/<repo>/pulls?state=open&per_page=100' \
  --jq '[.[] | select(.user.login != "<owner>" and (.user.login | test("\\[bot\\]$") | not))] | length'
```

Community issues and community PRs are the highest-signal axis -- they
are humans, not bots, touching the project. Surface them first in the
report.

### (c) Package downloads (where published)

Only for projects that actually publish a package; skip with `-`
otherwise.

- **Elixir / Hex:**

  ```bash
  gh api -X GET https://hex.pm/api/packages/<name> \
    --jq '{recent: .downloads.recent, all: .downloads.all}'
  ```

- **Rust / crates.io:** use the `cratesio-mcp` server's
  `get_crate_info` for each published crate (recent + all-time
  downloads). Fall back to
  `gh api -X GET https://crates.io/api/v1/crates/<name> --jq '.crate.downloads'`
  if the MCP server isn't available.

### (d) Release due? -- unreleased conventional commits

A project is "release due" when there are user-facing conventional
commits (`feat:`, `fix:`, `perf:`) on the default branch since the
last published tag. Check the commits since the last tag:

```bash
git -C <path> fetch --tags --quiet
last_tag=$(git -C <path> describe --tags --abbrev=0 2>/dev/null)
git -C <path> log --oneline "${last_tag}..origin/main" 2>/dev/null
```

If that range contains `feat:` / `fix:` / `perf:` commits, flag
**release due** with the count; `chore:`/`docs:`/`test:`-only ranges
are not release-due.

Do not determine "released" from in-tree files alone. **Anchor on
`origin/main` and cross-check the published version against the
registry** -- this is exactly the discipline in
[`release-audit-anchoring`](../release-audit-anchoring/SKILL.md).
Reuse it; don't reinvent the version-reconciliation logic here. A
mismatch between the in-tree version and the registry is usually
release-plz state mid-flight, not a finding.

### (e) Test run

Run the project's own test command (read it from CLAUDE.md or the
manifest -- `cargo test`, `mix test`, `npm test`, etc.). Record
`pass` / `fail` / `-` (no test command). Keep it a single bit of
signal; a failing suite is a flag to investigate, not something the
sweep fixes.

### (f) Stale CLAUDE.md flag

Flag a project's CLAUDE.md as possibly stale when it has drifted from
the code -- e.g. the file is much older than recent substantive
commits, or references versions/paths that no longer match. A cheap
heuristic:

```bash
git -C <path> log -1 --format=%cr -- CLAUDE.md   # last CLAUDE.md touch
git -C <path> log -1 --format=%cr                 # last commit overall
```

A large gap (months of active commits, untouched CLAUDE.md) earns a
`stale?` flag. The flag is a *proposal to review*, not a license to
edit -- see below.

### (g) Branch cleanup

List local and remote branches that are candidates for deletion. Two
categories:

- **Merged or closed.** Branches whose PR is merged or closed -- the
  work has landed (or been abandoned) and the branch is dead weight.
- **Stale.** Branches with no open PR and no recent commits -- no
  activity, nothing tracking them, candidates to prune.

```bash
# Local branches already merged into the default branch
git -C <path> branch --merged origin/main | grep -vE '^\*|main$'

# Remote branches and their merge state against origin/main
git -C <path> branch -r --merged origin/main | grep -vE 'origin/main$|origin/HEAD'

# PR state per branch (merged / closed / open / none)
gh pr list --repo <owner>/<repo> --state all --json headRefName,state,number \
  --jq '.[] | {branch: .headRefName, state: .state, number: .number}'

# Last commit date per branch, to spot stale ones
git -C <path> for-each-ref --sort=committerdate \
  --format='%(committerdate:relative)  %(refname:short)' refs/heads refs/remotes
```

Cross-reference the three signals: a branch whose PR is `MERGED` or
`CLOSED`, or a branch with no PR and a last commit older than the
staleness window, is a deletion candidate. Record the count of
candidates and list them in the expansion below the table.

This axis is **propose-only**, same discipline as the rest. The
read-only sweep does not delete branches. Deletion candidates are
surfaced in the report and routed to a worker, or run on confirmation:

```bash
git -C <path> branch -d <branch>                  # local, merged
git push <remote> --delete <branch>               # remote
```

Never run those from the sweep itself. The sweeper reads and reports;
a separate writer (worker, or the owner on confirmation) deletes.

## Output discipline

**Emit a per-project report, reconstituted fresh every sweep.** One
row or section per project. The report is the durable artifact for
this run; next sweep produces a new one from current state.

**NEVER cache status into a workspace or manager CLAUDE.md.** Writing
per-project last-seen counts upward into `~/Code/CLAUDE.md` (or any
workspace-level file) violates *map, not model*: the manager would
start holding a stale model of every project instead of a map of
where they are. Reconstitute on demand; do not persist the readout.

**Any proposed CLAUDE.md edit is *proposed*, never applied by the
sweeper.** The stale-CLAUDE.md flag (axis f) surfaces a candidate for
revision -- it does not authorize the read-only sweep to rewrite that
file. Route the proposal per
[`non-pr-output-conventions`](../non-pr-output-conventions/SKILL.md):

- File it as an issue (`gh issue create`) in the affected project, or
- Hand it to a worker as a bounded edit task.

The sweeper reads and reports; a separate writer (issue -> runner ->
worker) makes the change. Same rule for any other actionable finding
(a failing test, a release that's due): the sweep surfaces it and
routes it; it does not act on it.

### Report shape

A tight table, one row per project, sorted by signal (community
issues/PRs first, then release-due, then the rest):

```
project       | stars | forks | mine i/pr | community i/pr | bots | downloads | release | tests | claude.md | branches
my-crate      | 45    | 6     | 2 / 0     | 3 / 1          | 4    | 8.2k/mo   | DUE (4) | pass  | stale?    | 3
my-lib        | 12    | 1     | 0 / 0     | 0 / 0          | 1    | 1.1k/mo   | -       | pass  | ok        | 0
local-tool    | -     | -     | -         | -              | -    | -         | -       | fail  | ok        | 1
```

The `branches` column is the count of branch-cleanup candidates (axis
g). Below the table, expand only the rows that need action: which
community PRs are waiting, what's release-due and why, which tests
failed, which CLAUDE.md looks stale and the proposed routing, and
which branches are deletion candidates with their reason (merged,
closed, or stale).

## Graceful degradation (local-only / no-remote)

For a repo with no GitHub remote (local-only), skip the `gh` axes
(a, b, c) -- record `-` -- and run only the local axes (d release
check against any local tags, e test run, f CLAUDE.md staleness, g
branch cleanup over local branches only, without the PR-state
cross-reference).
Do not fail the sweep because one repo has no remote. Full handling
of local-only and non-standard-remote repos is tracked separately in
issue #222; this skill just degrades cleanly for now.

## Anti-patterns

- **Caching the readout upward.** Writing sweep results into a
  workspace/manager CLAUDE.md -- this is the cardinal violation of
  *map, not model*. Reconstitute every sweep; persist nothing.
- **Editing a project's CLAUDE.md from the sweep.** The stale flag is
  a proposal; the read-only sweeper never writes it. File or hand off.
- **Deleting branches from the sweep.** Axis (g) lists deletion
  candidates; the read-only sweeper never runs `branch -d` or
  `push --delete`. Hand the candidates to a worker or delete on
  confirmation.
- **Working an issue mid-sweep.** The moment you review a community PR
  or write a fix, you've left the sweep and started a runner's job --
  dispatch one instead.
- **Blocking on a missing axis.** A no-remote repo or an unpublished
  package is a `-`, not a stop. Degrade and continue.
- **Treating in-tree version as published.** Cross-check the registry
  (per `release-audit-anchoring`) before calling a release due.

## Related skills

- [`non-pr-output-conventions`](../non-pr-output-conventions/SKILL.md)
  -- where the report lands and how a proposed edit is routed (issue
  vs worker handoff); the sweep is a non-PR read-mostly shape.
- [`release-audit-anchoring`](../release-audit-anchoring/SKILL.md) --
  the release-due axis reuses its anchor-on-`origin/main` +
  cross-check-the-registry discipline.
- [`workspace-survey`](../workspace-survey/SKILL.md) -- the
  dispatcher's lighter project-discovery map (PRs/issues/CI only); the
  sweep is the deeper per-project health pass on top of that map.
- [`durable-context`](../durable-context/SKILL.md) -- why the sweep
  reconstitutes from durable state every time and caches nothing.
- [`triage`](../triage/SKILL.md) -- the read-only-pass-that-writes-
  findings sibling, scoped to the open-issue queue rather than
  cross-project health.
