---
name: local-only-repos
description: When a repo has no GitHub remote (or is not yet a git repo) -- use this to route survey, sweep, and dispatch off the GitHub-centric path. Detect with `git remote` empty; treat blank GitHub columns as expected, not an error; route work to commits + CLAUDE.md instead of issues + PRs; degrade a maintenance sweep to the local-only axes.
---

# Local-only repos

The default model assumes a git repo with a GitHub remote: the issue
is the spec, the work ends in a PR, the survey reads `gh`. Real
local-only repos exist -- scratch projects, private tools never
pushed, and not-yet-git directories. For those the GitHub substrate
is absent, so survey, sweep, and dispatch take a different path. This
skill defines that path and how each tier adapts.

## Detection: `git remote` is the test

A repo is local-only when it has no GitHub remote. Detect it once,
per repo, from durable state:

```bash
git -C <path> remote          # empty output => no remote => local-only
```

Three cases, all routed here:

| Case | Signal | Routing |
|---|---|---|
| Git repo, no remote | `git remote` empty | Commits + CLAUDE.md path below |
| Git repo, non-GitHub remote | remote URL is not github.com | Same as no-remote for the `gh` axes |
| Not yet a git repo | no `.git/` | No git history either; CLAUDE.md is the only durable home until `git init` |

The detection is reconstituted each pass, never cached. A repo gains
a remote the moment someone runs `git remote add` + `git push`; the
next survey sees it and routes it back to the default GitHub path.

## Survey + sweep: blank GitHub columns are expected

In [`workspace-survey`](../workspace-survey/SKILL.md) and
[`maintenance-sweep`](../maintenance-sweep/SKILL.md) a local-only repo
is still a real project (the `CLAUDE.md` active-flag and the `.git/`
test are unchanged). What changes is that every GitHub-derived column
is blank by design:

- Open PRs, draft PRs, open issues, CI state (survey) -- record `-`.
- Stars, forks, issues/PRs split, downloads (sweep axes a, b, c) --
  record `-`.

A blank GitHub column on a local-only repo is the correct readout,
not a failed `gh` call. Do not emit an error, do not retry, and do
not drop the repo from the report. The survey already degrades each
`gh` axis to `-` on a missing signal; this skill states the rule:
detect no-remote up front and skip the `gh` axes deliberately rather
than letting each one fail.

## Dispatch: commits + CLAUDE.md, not issues + PRs

The GitHub-centric dispatch flow has no anchor here. There is no
issue to read as the spec ([`runner-issue-authority`](../runner-issue-authority/SKILL.md)
has nothing to point at) and no PR to open ([`draft-pr-first`](../draft-pr-first/SKILL.md)
has no remote to push to). Route work to the two durable layers that
do exist locally:

- **The spec lives in CLAUDE.md or the prompt.** With no issue, the
  task definition comes from a `## Pending work` entry in the repo's
  CLAUDE.md, or directly from the dispatch prompt. Hand the worker
  the slice it needs in the prompt rather than an issue number.
- **The work lands as commits.** With no PR, the unit of work
  completes when the change is committed to the local branch (or to
  `main` directly for a solo local repo). The commit message is the
  durable record of what changed, in place of a PR body.
- **Decisions and follow-ups land in CLAUDE.md.** Findings that would
  have become an issue go into a `## Pending work` entry instead --
  CLAUDE.md is the only durable, re-readable home a cold restart can
  pick up from (see [`durable-context`](../durable-context/SKILL.md)).

Everything else from the runner lifecycle that does not depend on a
remote still applies: a single focused commit, tests before commit,
conventional-commit messages.

## Maintenance sweep: which axes survive

The seven-axis sweep degrades to the axes that read local state. Per
[`maintenance-sweep`](../maintenance-sweep/SKILL.md):

| Axis | Local-only behavior |
|---|---|
| (a) Stars / forks | Skip -- `-`. Needs `gh api`. |
| (b) Issues / PRs split | Skip -- `-`. Needs `gh api`. |
| (c) Package downloads | Skip unless the repo publishes a package independent of GitHub; usually `-`. |
| (d) Release due? | Keep, against **local tags**. `git describe --tags --abbrev=0` then `git log <last_tag>..HEAD` -- no `origin/main` anchor and no registry cross-check, just local tags vs local `HEAD`. |
| (e) Test run | Keep, unchanged. Run the project's own test command; record `pass` / `fail` / `-`. |
| (f) Stale CLAUDE.md | Keep, unchanged. Compare last CLAUDE.md touch against last commit overall. |
| (g) Branch cleanup | Keep, over **local branches only**. `git branch --merged` against the local default branch; drop the `gh pr list` PR-state cross-reference (no PRs exist), so a branch is a candidate purely on merged-or-stale by local commit date. |

Do not fail the sweep because a repo has no remote. The release-due
axis loses its registry cross-check (there is no published version to
reconcile), so "release due" here means local unreleased
conventional commits since the last local tag, full stop.

## Anti-patterns

- **Treating an empty `gh` result as an error.** A local-only repo
  has no stars, issues, or PRs by definition; that is a `-`, not a
  failure. Detect no-remote and skip the `gh` axes deliberately.
- **Dropping a local-only repo from the survey.** It is still an
  active project if it has a CLAUDE.md. Blank GitHub columns, present
  in the report.
- **Looking for an issue to read or a PR to open.** There is none.
  The spec is CLAUDE.md or the prompt; the output is a commit and a
  CLAUDE.md entry.
- **Anchoring release-due on `origin/main`.** No remote means no
  `origin/main`. Anchor on local tags vs local `HEAD`.
- **Cross-referencing branch cleanup against PR state.** No PRs
  exist; judge local branches on merged-or-stale alone.
- **Caching the no-remote verdict.** Reconstitute it each pass; a
  repo can gain a remote at any time and route back to the default
  path.

## Related

- [`workspace-survey`](../workspace-survey/SKILL.md) -- the project
  map this skill blanks the GitHub columns of for no-remote repos.
- [`maintenance-sweep`](../maintenance-sweep/SKILL.md) -- the
  seven-axis health pass this skill degrades to the local axes.
- [`durable-context`](../durable-context/SKILL.md) -- why CLAUDE.md
  plus commits is the durable substrate when issues and PRs are absent.
- [`runner-issue-authority`](../runner-issue-authority/SKILL.md) --
  the issue-is-the-spec rule that has nothing to point at locally.
- [`release-audit-anchoring`](../release-audit-anchoring/SKILL.md) --
  the `origin/main` + registry discipline that degrades to local
  tags vs local `HEAD` with no remote.
