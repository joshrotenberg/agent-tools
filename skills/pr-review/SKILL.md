---
name: pr-review
description: When reviewing a PR in agent-tools -- reads the diff and issue, checks conventions, approves+merges, approves+notes ordering, or requests changes+converts to draft.
---

# pr-review

Review a PR in the agent-tools repo. Read the diff and the originating issue, run
the checklist below, check for ordering conflicts, then take exactly one action.

## When to apply

- When the dispatcher or reviewer agent needs to evaluate and land (or send back) a PR
- Works for any PR in joshrotenberg/agent-tools; conventions are agent-tools-specific

## Review checklist

### Scope

- Changes match the issue spec exactly -- no scope creep, no missing required pieces
- Only files in scope for the issue were changed; no unrelated files

### Conventions

- No emojis anywhere in changed content
- No em dashes -- use double hyphens or rephrase
- Dispatch-agnostic language: roba appears as one option among several, not the assumed mechanism

### Frontmatter (SKILL.md and AGENT.md files)

- `name:` field present, non-empty, matches the parent directory name exactly
- `description:` field present, non-empty, under 1024 chars
- `description:` uses trigger-condition language ("when X", "use when", "before Y")

### Skill body quality

- Under 500 lines
- Covers ONE topic (not bundled concerns)
- Cross-links (`[text](../skill/SKILL.md)`) resolve to real files

### Agent body quality

- Under 200 lines
- Body is slim: identity + lifecycle + discipline + anti-patterns
- Procedural detail lives in skills, not repeated in body

### Markdown formatting

- Blank lines before and after every fenced code block
- Lines under 120 characters (tables and code blocks may exceed this)
- Headings follow a logical hierarchy (no skipped levels)

## Ordering awareness

Before deciding to merge, check for open PRs that touch the same files:

```bash
gh pr list --json number,headRefName,files --jq '
  .[] | select(.number != ENV.PR) |
  {number: .number, files: [.files[].path]}'
```

If another open PR modifies a file this PR also modifies, approve but do NOT merge.
Comment "LGTM; merge after #X (both modify <file>)."

## Decision actions

```bash
# APPROVE + MERGE (all checks pass, no ordering conflicts)
gh pr review $PR --approve --body "LGTM: <one-line summary of what was verified>"
gh pr merge $PR --squash --delete-branch

# APPROVE, ordering dependency (checks pass, but conflicts expected)
gh pr review $PR --approve --body "LGTM; merge after PR #X (both modify <file>)"
# Do NOT merge

# REQUEST CHANGES (issues found)
gh pr review $PR --request-changes --body "$(cat <<'REVIEW'
<bullet list, one specific issue per bullet>
REVIEW
)"
gh pr ready $PR --undo
```

## Status report

Every reviewer response ends with:

```
STATUS: merged | approved_pending_order | needs_work | blocked
PR: #N
NOTES: <one-line summary>
```

## Anti-patterns

- Approving because the PR description sounds correct without reading the diff
- Merging when an ordering dependency exists
- Requesting vague changes ("this could be clearer") without a specific actionable fix
- Editing files instead of requesting changes

## Related skills

- [`runner-issue-authority`](../runner-issue-authority/SKILL.md) -- the issue is the authoritative spec, not the PR body
- [`sandbox-preflight`](../sandbox-preflight/SKILL.md) -- verify `gh` is available before starting
- [`heredoc-backticks`](../heredoc-backticks/SKILL.md) -- formatting review bodies passed to `gh pr review`

## Known limitations

### Self-approval blocked

GitHub prevents PR owners from approving their own PRs. When `gh pr review N --approve`
returns `Can not approve your own pull request`, fall back to:

```bash
gh pr comment $PR --body "Review: LGTM. <summary>

STATUS: approved_pending_order
"
```

The STATUS block in the comment serves as the approval signal for the dispatcher.
Self-approval of your own PRs is not required -- the comment record is sufficient.

### Ordering direction

When two PRs modify the same file, the ordering check should determine which should merge
*first*, not just that an ordering exists:

- **Independent/simpler PRs merge first.** A PR that only touches frontmatter fields
  should merge before a PR that rewrites body content in the same file.
- **Baseline PRs merge before additive PRs.** A lint-fix PR establishes the clean
  baseline; content-adding PRs rebase on top.
- The later PR in the sequence may need a rebase after the first merges -- note this
  in the approval comment rather than blocking the first PR from merging.

Heuristic: "which PR has fewer dependencies?" -- that one merges first.
