---
name: skill-capabilities
description: When authoring a new skill or updating an existing one -- reference this for the two advanced frontmatter capabilities: dynamic context injection via `!`command`` syntax and `allowed-tools` for pre-approving tool use. Apply selectively; both features add overhead and should only appear where they genuinely help.
---

# Skill capabilities reference

Two frontmatter capabilities are available in SKILL.md files that are
underused by default: dynamic context injection and `allowed-tools`.
This skill describes what they do, when to use them, and which skills in
this repo use each.

## Dynamic context injection

Any line in a skill body that contains `` !`command` `` is treated as an
inline shell execution. Claude Code runs the command before the skill
content is loaded into context, replacing the backtick expression with
the command's stdout.

```markdown
Current open issues: !`gh issue list --state open --json number,title,labels`
```

When this skill loads, the backtick expression is replaced with the live
output. The agent sees the issues list as part of the skill body, not as
a Bash tool call result.

### When to use dynamic context injection

Use it when:

- The skill is invoked to do a specific action (not just as background
  reference), AND
- Live state -- current git status, open issues, PR list -- would
  meaningfully change how the agent uses the skill, AND
- The command is fast (< 1 second) and low-cost.

Don't use it when:

- The skill is pure reference material (the agent reads it once at
  session start and doesn't invoke it again).
- The command might fail or produce large output (truncation degrades
  the skill body in unpredictable ways).
- The information is already available in the agent's context via
  another channel.

### `$ARGUMENTS` in dynamic injection

When a skill is used as a slash command (`/skill-name arg`), the user's
arguments are available as `$ARGUMENTS`:

```markdown
!`gh issue view $ARGUMENTS --json title,body,labels`
```

This only works for slash-command invocation. Background skills (always-
loaded from `~/.claude/skills/`) don't receive `$ARGUMENTS` -- those
expressions run with an empty argument and may produce errors or empty
output.

### Skills using dynamic injection in this repo

| Skill | Command | Purpose |
|---|---|---|
| `triage` | `gh issue list --state open --json number,title,labels` | Inject current open issue list at triage-start |

## allowed-tools

The `allowed-tools` frontmatter field pre-approves specific tools so
they run without per-use permission prompts while the skill is active.

```yaml
---
name: my-skill
description: ...
allowed-tools: Bash(gh:*) Bash(git:*)
---
```

Or using YAML list syntax:

```yaml
---
name: my-skill
description: ...
allowed-tools:
  - Bash(gh:*)
  - Bash(git:*)
---
```

### When to use allowed-tools

`allowed-tools` has effect only when the skill body directly invokes
commands via `!`command`` dynamic injection. If the skill body describes
commands for the agent to run (without `!`...`` markers), `allowed-tools`
does NOT pre-approve those commands -- the agent issues them via the Bash
tool, and the usual permission rules apply.

Use it when:

- The skill body contains `!`command`` patterns, AND
- Those commands need tools not in the agent's current allowlist.

The most common case: a skill with `!`gh ...`` patterns needs
`allowed-tools: Bash(gh:*)`.

For skills that only describe commands (reference material), adding
`allowed-tools` has no technical effect on those commands. However,
adding it signals to skill authors that this skill expects those tools to
be available when active.

### Scope guidance

Use narrow scopes:

- `Bash(gh:*)` not `Bash(*)` -- approve GitHub CLI, not all Bash
- `Bash(git:*)` not `Bash(*)` -- approve git, not all Bash
- List each tool separately; don't over-broad with `Bash(*)`

### Skills using allowed-tools in this repo

| Skill | allowed-tools | Reason |
|---|---|---|
| `triage` | `Bash(gh:*)` | Has `!`gh issue list...`` dynamic injection |
| `pr-review` | `Bash(gh:*)` | Reviewer actions (approve, merge, request-changes) use gh |

## Interaction between the two features

Dynamic context injection (`!`command``) executes commands during skill
loading. `allowed-tools` pre-approves the tool needed for those
commands. They work together: add `allowed-tools` to any skill that has
`!`command`` patterns using Bash.

A skill with only `!`gh ...`` patterns but no `allowed-tools: Bash(gh:*)`
will prompt the user each time the skill loads. Add both together.

## Checking for existing usage

To see which skills currently use these features:

```bash
grep -r "allowed-tools" skills/*/SKILL.md
grep -r "!\`" skills/*/SKILL.md
```

## Related

- [`orchestration-prompt-template`](../orchestration-prompt-template/SKILL.md)
  -- the prompt template for runner dispatches; similar frontmatter
  concepts apply when writing custom commands.
- [`sandbox-preflight`](../sandbox-preflight/SKILL.md) -- the runtime
  tool-availability check at dispatch start; complements `allowed-tools`
  at the session level.
