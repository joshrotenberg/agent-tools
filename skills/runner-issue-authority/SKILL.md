---
name: runner-issue-authority
description: When dispatched with an issue number, the runner's authoritative source for what to do is `gh issue view <N>`, NOT the dispatcher's paraphrase. The dispatcher's invocation provides the issue number and any explicit overrides; the runner self-fetches. This keeps state in GitHub (where it belongs) and avoids paraphrase drift.
---

# Authority for task content (runner)

When dispatched with an issue number, **`gh issue view <N>` is your
authoritative source for what the task is.** This is non-negotiable.

## Rules

- **Always fetch first.** Your first action when dispatched with an
  issue number is `gh issue view <N>`. Do it before composing the
  prompt, even if the dispatcher's invocation includes a paraphrase
  or summary of the issue body.
- **The dispatcher does NOT paste the issue body.** That's an
  anti-pattern -- it duplicates state that lives in GitHub, risks
  paraphrase drift, and violates the state-externalization corollary
  (the issue is the durable source; conversation is transient).
- **The dispatcher's invocation provides three things:**
  - (a) the issue number (and optionally repo path / owner)
  - (b) explicit constraints / overrides / scope-narrowers that
    don't appear in the issue
  - (c) sometimes a pointer like "focus on X" or "skip Y."
- **Synthesize:** issue body (authoritative) + dispatcher's
  constraints (local overrides). If they conflict, the dispatcher's
  explicit override wins -- the issue is the spec; the dispatcher
  is the local interpreter for this particular dispatch.

## Dispatch shape you'll see

The dispatcher sends a minimal structured directive (per the
dispatcher's dispatch-format discipline):

```
implement #<N> in <repo-path>

constraints:
- <override or scope-narrower>
- <override or scope-narrower>
```

- First line is the directive (`implement #N`, `fix CI in PR #N`,
  etc.).
- `<repo-path>` is optional when the issue is in the current cwd's
  project.
- `constraints:` is optional. The dispatcher includes it only
  when they have explicit overrides; if the directive is bare, the
  issue body is the spec.

## Why this matters

If the dispatcher paraphrases the issue into the dispatch prompt:

- The dispatch prompt bloats (dispatcher context burns tokens to
  write the paraphrase)
- Drift risk: dispatcher's summary diverges from the actual issue
- State duplication: same content in GitHub AND in the dispatch
  prompt
- Violates the state-externalization corollary: state should live in
  durable stores (GitHub issues), not transit through the
  conversation

The cleanest contract: the issue body is in GitHub; the dispatcher
gives you a pointer; you fetch.

## Dynamic context injection

Skills support a dynamic context injection syntax: a line beginning with `!`
followed by a shell command in backticks is executed before Claude sees the
skill content. The command output replaces that line.

This means runner-issue-authority could be invoked as a slash command that
auto-fetches the issue body as part of loading:

```
!`gh issue view $ARGUMENTS --json title,body,labels`
```

When a user runs `/runner-issue-authority 42`, Claude Code executes
`gh issue view 42 --json title,body,labels` before processing the skill, and
the live JSON output is injected into the skill content. The agent sees the
issue title, body, and labels without a separate explicit fetch step.

The key constraint: `$ARGUMENTS` is only populated when the skill is invoked
as a slash command with an argument. Skills that are auto-loaded as session
context (not slash-commanded) receive an empty `$ARGUMENTS` -- so the explicit
`gh issue view <N>` fetch rule in this skill still applies in the auto-loaded
case. Dynamic injection and the explicit-fetch rule are complementary, not
alternatives.

## Related

- [`draft-pr-first`](../draft-pr-first/SKILL.md) -- the lifecycle
  the runner follows after fetching the issue.
- [`orchestration-prompt-template`](../orchestration-prompt-template/SKILL.md)
  -- the prompt-composition template the runner uses.
