---
name: github-authoring
description: When writing any issue, PR, or commit message, use this for the authoring standard. Covers structure (headings, lists, tables, fenced blocks, the bug block, the before/after) and voice (factual, no emdashes, no editorializing labels, conventional-commit prefixes, no commit trailers).
---

# GitHub authoring

The authoring standard for every issue, PR, and commit in this
repo. Two parts: how the text is structured, and how it reads.
This applies to text authored by an agent and by the repo owner
alike.

## When to apply

Whenever composing the body or title of:

- A GitHub issue
- A pull request
- A commit message

## Structure

Pick the structure that fits the content. The defaults:

- **Headings** to separate sections (What, Why, How, etc.).
- **Bullet lists** for unordered points; **numbered lists** for
  ordered steps.
- **Tables** for comparisons (option A vs option B, before vs
  after, layer-by-layer).
- **Fenced code blocks** for commands, diffs, and config. Never
  inline a multi-line command in prose.

### Bug reports: the "what is the bug" block

A bug issue states three things explicitly:

```text
Repro:    the exact steps or command that triggers it
Observed: what actually happens
Expected: what should happen instead
```

Without all three, a reader cannot confirm the bug or verify a
fix. Include the version, environment, or commit when they
affect the repro.

### Features: before/after

A feature issue or PR shows the change as before/after. A table
or two fenced blocks both work:

| Before | After |
|---|---|
| current behavior | new behavior |

State what the user could not do before and can do after.

## Voice

- **Factual and technical.** State facts, not their importance.
  Write "the parser drops unquoted `: ` in descriptions," not
  "the parser has a serious problem with descriptions."
- **No emdashes.** Use a colon, a comma, parentheses, or two
  separate sentences instead. The emdash is the one punctuation
  mark this repo does not use in authored GitHub text.
- **No editorializing labels.** Drop "(critical)", "the key
  part", "the important bit", "note that", and similar. If a
  point matters, the fact carries it; the label adds nothing a
  reader can act on.
- **Never use the term "load bearing."** State what the thing
  does and what breaks without it, in plain terms.

## Titles: conventional-commit prefixes

Commit, PR, and issue titles all take a conventional-commit
prefix:

- `feat:` new user-visible behavior
- `fix:` bug fix
- `refactor:` internal restructuring, no behavior change
- `chore:` repo maintenance (dependencies, config)
- `ci:` CI or release-process changes
- `docs:` documentation only
- `test:` tests only

Append `!` to mark a breaking change (`refactor!: drop --head`).

## Commits: no trailers, author is the repo owner

- Do not add a `Co-Authored-By` trailer.
- Do not add a "Generated with Claude Code" trailer.
- The commit author is always the repo owner.

After committing, verify:

```bash
git log -1 --format='%an <%ae>'   # repo owner
git log -1 --format='%(trailers)' # empty
```

If a trailer appears, amend it out before pushing
(`git commit --amend` and remove the trailer line).

## Anti-patterns

- Emdashes anywhere in the authored body or title.
- Editorializing labels like "(critical)" or "the key part."
- The phrase "load bearing."
- A multi-line command pasted into prose instead of a fenced
  block.
- A bug report missing repro, observed, or expected.
- A commit carrying a `Co-Authored-By` or "Generated with
  Claude Code" trailer.
- A title without a conventional-commit prefix.

## Related

- [`git-branch-pr-workflow`](../git-branch-pr-workflow/SKILL.md):
  the branch + PR discipline these titles and bodies ride on.
- [`triage`](../triage/SKILL.md): labels the issues this skill
  helps author.
- [`heredoc-backticks`](../heredoc-backticks/SKILL.md): keeps the
  fenced blocks rendering when a body is piped through a
  single-quoted heredoc into `gh`.
