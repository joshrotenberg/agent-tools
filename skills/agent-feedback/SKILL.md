---
name: agent-feedback
description: When you notice something wrong or suboptimal in a skill or agent definition -- file a GitHub issue on joshrotenberg/agent-tools rather than silently proceeding.
---

# agent-feedback

When an agent detects a problem in a skill or agent definition during
real use, that observation is valuable. This skill describes when and
how to file a GitHub issue so it isn't lost.

## When to apply

File an issue when you notice:

- A skill instruction didn't match what actually happened (divergence between the documented pattern and real behavior)
- A cross-link in a skill or agent body is broken or points to a renamed file
- A common situation that arose during the task isn't covered by the relevant skill
- A pattern in a skill is outdated (references stale tooling, superseded commands, or a deprecated execution shape)

Do NOT file for stylistic preferences or minor wording nits.

## Threshold

File when either condition is true:

- **(a) Divergence** -- you followed a skill's instructions and behavior was wrong or the outcome differed from what the skill described
- **(b) Gap** -- a real situation arose that the skill doesn't cover and the omission caused uncertainty or a workaround

If neither condition applies, continue without filing.

## Title format

```
fix: <skill-name> -- <one-line description>
feat: <skill-name> -- <one-line description>
```

Use `fix:` for incorrect or outdated instructions. Use `feat:` for missing coverage of a real situation.

Examples:

```
fix: sandbox-preflight -- blocked tool check silently no-ops when gh is missing
feat: orchestration-prompt-template -- no guidance for runner prompt when issue has no acceptance criteria
```

## Required body content

- **What the skill says** -- quote or paraphrase the relevant instruction
- **What actually happened or is missing** -- specific description; no vague summaries
- **Suggested fix or question** -- propose a change or ask a clarifying question

## Filing command

```bash
gh issue create \
  --repo joshrotenberg/agent-tools \
  --title "fix: <skill-name> -- <one-line description>" \
  --body "$(cat <<'EOF'
**What the skill says**

<quote or paraphrase>

**What actually happened / what is missing**

<specific description>

**Suggested fix or question**

<proposed change or question>
EOF
)"
```

Check for duplicates before filing:

```bash
gh issue list --repo joshrotenberg/agent-tools --state open
```

## One issue per observation

Don't bundle multiple unrelated findings into one issue. If you have
two distinct observations, file two issues.

## After filing

Continue the current task. Do not wait for the issue to be resolved.
Include the issue URL in your return summary to the dispatcher or human.

## Anti-patterns

- Filing mid-task for something that doesn't affect the current work (distraction)
- Vague body like "skill seems wrong" with no specific diagnosis
- Filing a duplicate without first checking `gh issue list`
- Filing for a preference rather than an observable divergence or gap

## Related skills

- [`runner-issue-authority`](../runner-issue-authority/SKILL.md) -- gh issue view as the authoritative source for task input
- [`spiral-diagnosis`](../spiral-diagnosis/SKILL.md) -- when a dispatched session is stuck (a different kind of feedback loop)
