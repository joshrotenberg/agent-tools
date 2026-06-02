---
name: field-feedback
description: When a dispatch-time issue surfaces -- wrapper bug, sandbox gap, missing skill, unexpected behavior -- file a structured GitHub issue to close the build-use-feedback loop.
---

# field-feedback

Every dispatched session is a potential signal source. When you
encounter a wrapper bug, sandbox gap, missing skill, or unexpected
behavior during real work, that observation belongs in a GitHub issue
-- not lost in the conversation transcript. This skill describes when
and how to file so the build-use-feedback loop closes automatically
without per-session reminders.

## When to apply

File when you observe:

- A **wrapper bug** -- roba, claude-wrapper, or claude -p behaved
  unexpectedly (wrong exit code, bad output envelope, unexpected
  session lifecycle behavior)
- A **sandbox / permission gap** -- a tool you needed wasn't in the
  allowlist, or the allowlist logic produced a wrong result
- A **missing skill or agent** -- a real situation arose with no
  documented guidance, and you had to improvise a workaround
- **Unexpected dispatch behavior** -- the session spiraled, toolcall
  cancellation cascades fired unexpectedly, the session transcript
  was structured wrong
- A **false-positive finding** -- a check flagged something that
  turned out to be correct behavior
- A **performance observation** worth tracking -- the session took
  far longer than expected for a well-scoped task

Do NOT file for:

- Routine clean completions (no signal)
- Stylistic preferences or wording nits
- Project-specific bugs that belong in the project's own tracker

## Threshold

Same discipline as `agent-feedback`:

- **(a) Divergence** -- you followed documented behavior and got a
  different result
- **(b) Gap** -- a real situation arose with no documented guidance,
  causing uncertainty or a workaround

File only when one of these applies.

## Target repo routing

Pick the target based on where the bug or gap lives:

| Observation | Target repo |
|---|---|
| Wrapper behavior, CLI flags, session lifecycle, exit codes | joshrotenberg/roba |
| Skill missing, skill/agent body wrong, cross-link broken | joshrotenberg/agent-tools |
| Project CLAUDE.md wrong, project CI failures, project-specific gaps | that project's repo |
| Unclear | default to joshrotenberg/agent-tools; note in the body which repo might be more appropriate |

## Privacy discipline

**Do NOT include work-project content in filed issues.** This means:

- No file paths from the project being worked on
- No source code or output from the project
- No reproduction steps that would reveal proprietary logic

Report the **pattern and the substrate's behavior**. Redact actual
code and files. Default conservative: when in doubt, describe the
behavior without quoting.

Acceptable auto-context (no privacy risk): wrapper version, OS,
model, task path first line (the issue number or file name, not
content), exit code, error envelope content from the wrapper itself.

## Auto-context to include

Include a structured auto-context block in the issue body. Use what
you have; omit fields you don't.

```
**Auto-context**
- wrapper: roba 0.2.1  (or: Task tool, claude -p, claude-wrapper)
- model: claude-sonnet-4-5
- os: darwin 24.x
- task: implement #42 in /path/to/repo  (issue number or task file name, not content)
- session-id: <from roba dispatch-start stderr if available>
- exit-code: 1
- error-envelope: <wrapper error output if any, redacted of project content>
```

## Title format

```
fix: <component> -- <one-line description>
feat: <component> -- <one-line description>
```

Use `fix:` for incorrect or unexpected behavior. Use `feat:` for
missing coverage or a new capability gap.

Component is the relevant area: `roba/session-lifecycle`,
`sandbox-preflight`, `spiral-diagnosis`, `dispatch-options`,
`field-feedback`, etc.

Examples:

```
fix: roba/session-lifecycle -- exit code 1 on clean run when output contains warnings
feat: sandbox-preflight -- no guidance for npm workspaces when package.json is nested
fix: spiral-diagnosis -- session-id not available from Task tool dispatch
```

## Required body sections

- **Context** -- what task was being worked on (issue number or type,
  not project content)
- **Observed behavior** -- what actually happened
- **Expected behavior** -- what the skill, doc, or design says should
  have happened
- **Auto-context** -- the structured block above
- **Suggested mitigations** -- proposed fix, workaround used, or
  open question

## Filing command

Check for duplicates before filing:

```bash
gh issue list --repo <target-repo> --state open --search "<keyword>"
```

If a similar open issue exists, comment on it instead of filing a new
one.

File the issue:

```bash
gh issue create \
  --repo <target-repo> \
  --title "fix: <component> -- <one-line description>" \
  --label "field-feedback" \
  --body "$(cat <<'EOF'
**Context**

<task type or issue number -- no project content>

**Observed behavior**

<specific description of what happened>

**Expected behavior**

<what the skill/doc/design says should happen>

**Auto-context**
- wrapper: <version or mechanism>
- model: <model>
- os: <os>
- task: <first line of task -- no content>
- exit-code: <code>

**Suggested mitigations**

<proposed fix, workaround, or open question>
EOF
)"
```

## Labels

- Always include `field-feedback`
- Add a sub-label if applicable:
  - `field-feedback/sandbox` -- sandbox or permission gaps
  - `field-feedback/missing-skill` -- skill or agent gaps
  - `field-feedback/false-positive` -- check flagged a correct result
  - `field-feedback/wrapper-bug` -- dispatch wrapper misbehavior

Note: labels must exist on the target repo. If the labels don't
exist, omit `--label` from the command and mention the intended
label in the body instead.

## One issue per observation

Don't bundle multiple unrelated findings into one issue. If you have
two distinct observations, file two issues.

## After filing

Continue the current task. Do not wait for the issue to be resolved.
Include the issue URL in your return summary to the dispatcher or
human.

## Anti-patterns

- Including project source code or file contents in the issue body
- Filing wrapper-specific bugs to joshrotenberg/agent-tools
- Filing agent-tools content gaps to joshrotenberg/roba
- Filing for routine clean completions (no signal value)
- Filing a duplicate without first checking existing issues
- Filing mid-task for something that doesn't affect the current work
- Vague body like "something seemed wrong" with no specific diagnosis

## Related skills

- [`agent-feedback`](../agent-feedback/SKILL.md) -- agent-tools-specific
  fast path for skill and agent definition issues (uses this skill's
  routing logic for non-agent-tools targets)
- [`sandbox-preflight`](../sandbox-preflight/SKILL.md) -- the check
  that surfaces sandbox gaps before a dispatch runs; field-feedback
  applies when a gap surfaces mid-run
- [`spiral-diagnosis`](../spiral-diagnosis/SKILL.md) -- diagnosing a
  hung or spiraling session; file a field-feedback issue when a spiral
  reveals a wrapper or tool bug
