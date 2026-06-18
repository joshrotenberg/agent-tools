---
name: git-branch-pr-workflow
description: Before making any non-trivial code, docs, or config change -- create a feature branch first, then open a PR. Never commit directly to main. Apply by default before any edit; this is the baseline branch discipline that all other git skills build on.
allowed-tools: Bash(git *) Bash(gh *)
---

# Git branch + PR workflow

Default to `git checkout -b <type>/<description>` **before any
edits**. Never commit directly to main, even on solo projects.
Conventional commit prefixes: `feat`, `fix`, `refactor`, `chore`,
`ci`, `docs`, `test`. Push branch, open PR, let the user (or the
dispatcher loop) merge.

## When to apply

- Any code change beyond a trivial typo
- Any docs change that affects committed content
- Any config or workflow change

## Why

- Keeps the commit log on main clean and bisectable
- CI runs against the PR before main moves
- Squash-merge gives main a clean linear history
- Even solo, the PR body is a useful place to record the "why"

## How to apply

1. Before any change, `git checkout -b <type>/<short-description>`.
2. Make commits with conventional-commit messages
   (`<type>: <description>`; `!` marks breaking).
3. Push: `git push -u origin <branch>`.
4. Open the PR: `gh pr create [--draft]` with a tight body that
   references the underlying issue (use a `Closes #N` keyword in the
   PR body so the merge closes the linked issue).
5. Wait for CI; merge with `gh pr merge --squash --delete-branch`.

## Commit-message conventions

- `feat: ...` -- new user-visible behavior
- `fix: ...` -- bug fix
- `refactor: ...` -- internal restructuring, no behavior change
- `chore: ...` -- repo maintenance (dependencies, config, etc.)
- `ci: ...` -- CI/release-process changes
- `docs: ...` -- documentation only
- `test: ...` -- tests only

Append `!` to mark a breaking change: `refactor!: cut --head and
--tail (closes #42)`.

The same prefixes apply to **issue titles**, not only commits,
branches, and PR titles. An issue that proposes a new skill is
`feat: ...`; an issue documenting a bug is `fix: ...`. The
`triage` skill normalizes issue titles to this scheme.

## No trailers, author is the repo owner

Do not include "Generated with Claude Code" or "Co-Authored-By"
trailers on any commit. The commit author is always the repo
owner (`Josh Rotenberg <joshrotenberg@gmail.com>`); no
co-author is added. After committing, verify before pushing:

```bash
git log -1 --format='%an <%ae>%n%(trailers)'
```

The author line must be the repo owner and the trailers must be
empty. If a trailer slipped in, amend it out (`git commit --amend`)
before pushing.

## Related

- [`git-fix-pr-branching`](../git-fix-pr-branching/SKILL.md) -- how
  to handle fixes when a PR is open vs merged.
- [`heredoc-backticks`](../heredoc-backticks/SKILL.md) -- formatting
  the PR body without breaking the markdown.
