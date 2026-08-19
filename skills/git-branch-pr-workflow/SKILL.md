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
   If the work closes an issue, claim it first
   (`gh issue edit <N> --add-label status/in-progress`); see the
   claim protocol in
   [`issue-pr-conventions`](../issue-pr-conventions/SKILL.md).
2. Make commits with conventional-commit messages
   (`<type>: <description>`; `!` marks breaking).
3. Push: `git push -u origin <branch>`.
4. Open the PR: `gh pr create [--draft]` with a tight body that
   references the underlying issue (use a `Closes #N` keyword in the
   PR body so the merge closes the linked issue).
5. Wait for CI; merge with `gh pr merge --squash --delete-branch`.

## Naming

Branch, issue title, PR title, and commit subject all take the same
conventional-commit prefix. The scheme, the type list, and the
tool-owned exemptions are in
[`issue-pr-conventions`](../issue-pr-conventions/SKILL.md).

Two rules that bite here specifically:

- **The branch prefix matches the PR type.** A `fix:` PR belongs on
  a `fix/` branch. Where they disagree, rename the branch
  (`git branch -m fix/<slug>`) before opening the PR.
- **No trailers, and the author is the repo owner.** Never add
  `Co-Authored-By` or a "Generated with Claude Code" line. Verify
  before pushing:

  ```bash
  git log -1 --format='%an <%ae>%n%(trailers)'
  ```

  The author must be the repo owner and the trailers must be empty.
  Amend before pushing if one slipped in.

## Related

- [`issue-pr-conventions`](../issue-pr-conventions/SKILL.md) -- the
  naming scheme, label taxonomy, and claim protocol.
- [`git-fix-pr-branching`](../git-fix-pr-branching/SKILL.md) -- how
  to handle fixes when a PR is open vs merged.
- [`heredoc-backticks`](../heredoc-backticks/SKILL.md) -- formatting
  the PR body without breaking the markdown.
