# skills

Operational knowledge files for the dispatcher + runner agents.
Each skill is a markdown file with YAML frontmatter that extends
an agent's context with how-to guidance. Structurally compatible
with Claude Code's `.claude/skills/` convention; `install.sh` at
the repo root copies them into `~/.claude/skills/`.

Agents pull skills in via their `skills:` frontmatter list. The
agent body stays slim (identity + lifecycle); the procedural meat
lives here.

## Available skills

### Orchestration model

| Skill | When to use |
|---|---|
| [`orchestration-patterns`](orchestration-patterns/SKILL.md) | Units of work + execution shapes (single runner / parallel / sequential / chained / audit + remediate). Pick the simplest shape that fits. |
| [`workspace-survey`](workspace-survey/SKILL.md) | How the dispatcher discovers projects in the workspace (for multi-project units) |

### Dispatch

| Skill | When to use |
|---|---|
| [`dispatch-options`](dispatch-options/SKILL.md) | Pick the dispatch mechanism: Task tool / Bash + roba / claude-wrapper / claude -p direct. Trade-off table |
| [`dispatch-wait-react`](dispatch-wait-react/SKILL.md) | Coordinating with long-running background dispatches without polling or sleep-looping |
| [`orchestrator-parallelization`](orchestrator-parallelization/SKILL.md) | When to fan out runners vs sequence them (for the parallel-runner shape) |
| [`orchestration-prompt-template`](orchestration-prompt-template/SKILL.md) | Writing the prompt and wrapping the PR lifecycle when dispatching a runner |
| [`spiral-diagnosis`](spiral-diagnosis/SKILL.md) | When a dispatched session hangs, produces no output, or seems stuck |

### Lifecycle

| Skill | When to use |
|---|---|
| [`draft-pr-first`](draft-pr-first/SKILL.md) | Opening a draft PR with the plan as the body BEFORE the work starts |
| [`sandbox-preflight`](sandbox-preflight/SKILL.md) | Start of any runner dispatch -- verify needed tools are in the sandbox allowlist; fail loud on a block |
| [`runner-issue-authority`](runner-issue-authority/SKILL.md) | The runner's authoritative source is `gh issue view <N>`, not the dispatcher's paraphrase |
| [`runner-synchronous-lifecycle`](runner-synchronous-lifecycle/SKILL.md) | The runner fires its dispatch synchronously and only returns after the full lifecycle is complete |
| [`release-audit-anchoring`](release-audit-anchoring/SKILL.md) | Release-audit work -- anchor analysis on `origin/main` not the working tip; cross-check published versions externally |

### Review

| Skill | When to use |
|---|---|
| [`pr-review`](pr-review/SKILL.md) | When reviewing a PR in agent-tools -- reads the diff and issue, checks conventions, approves+merges, approves+notes ordering, or requests changes+converts to draft |

### Git + tooling hygiene

| Skill | When to use |
|---|---|
| [`git-branch-pr-workflow`](git-branch-pr-workflow/SKILL.md) | Any non-trivial work that becomes a PR |
| [`git-fix-pr-branching`](git-fix-pr-branching/SKILL.md) | A PR is open and needs a fix |
| [`git-delete-merged-branches`](git-delete-merged-branches/SKILL.md) | After a PR merges, cleaning up the local branch |
| [`heredoc-backticks`](heredoc-backticks/SKILL.md) | Piping markdown into `gh issue create` / `gh pr create` |

### Meta

| Skill | When to use |
|---|---|
| [`agent-feedback`](agent-feedback/SKILL.md) | When you notice something wrong or suboptimal in a skill or agent definition -- file an issue rather than silently proceeding |

## Installation

From the repo root:

```bash
./install.sh
```

Copies all skills to `~/.claude/skills/`. See the root README for
options.

You can also read the files directly from this directory.

## Format

Each skill is a directory containing a `SKILL.md` with YAML
frontmatter:

```
---
name: <kebab-case-name>
description: <one-line: what it provides + when to invoke>
---

# <Title>

<body>
```

The `name:` field must match the directory name. The
`description:` is what Claude Code shows when listing skills and
what agents read when deciding whether to load.
