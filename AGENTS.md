# AGENTS.md

This repo ships operational knowledge files (skills) and subagent definitions
(agents) for use with Claude Code's dispatcher+runner model. `install.sh`
copies them into `~/.claude/{skills,agents}/` for auto-discovery. Everything
here is Task-tool-centric, and also works under `claude -p` or any other
wrapper for headless use.

## Install

As a Claude Code plugin (CLI + desktop; the repo is its own marketplace):

```
claude plugin marketplace add joshrotenberg/agent-tools
claude plugin install agent-tools@agent-tools
```

Or copy into `~/.claude/` directly:

```bash
./install.sh   # see README for --force, --dry-run, --to, --skip options
```

## Structure

- `skills/<name>/SKILL.md` -- operational knowledge files; loaded into agent
  context by name via frontmatter `skills:` list
- `agents/<name>.md` -- subagent definitions (`dispatcher`, `runner`, `worker`,
  `auditor`, `reviewer`)

## Naming conventions

- Kebab-case for all directory and file names
- `name:` frontmatter field must match the skill directory name / agent file
  name exactly
- Skill names: noun-phrases describing what the skill is about
  (`spiral-diagnosis`, `sandbox-preflight`, not `diagnoseSpirale`)
- Agent names: role nouns (`runner`, `dispatcher`)

## Key constraints for any edits

- No emojis in skill/agent body content, commits, or docs
- No em dashes -- use double hyphens or rephrase
- Skill and agent body language is Task-tool-centric; keep process guidance
  mechanism-neutral where natural, but the Task tool is the assumed default
  (mention roba / `claude -p` only where genuinely relevant, e.g. headless)
- Read `CLAUDE.md` decisions log before changing anything substantial
  (CLAUDE.md is tracked in this repo)

## Skill body discipline

Each skill covers ONE thing well and stays under 500 lines. Procedural
detail belongs in skills; agent bodies stay slim. A skill body should be
self-contained: frontmatter, what it covers, when to apply, the pattern,
anti-patterns, related skills.

## Agent body discipline

Agent bodies reference skills via the frontmatter `skills:` list rather
than reimplementing skill content inline. The body covers: identity, when
to invoke vs skip, inputs/outputs, lifecycle loop, discipline rules,
anti-patterns, and related agents. Target 130-200 lines per agent.

## Required Secrets

| Secret | Used by | Purpose |
|---|---|---|
| `ANTHROPIC_API_KEY` | `token-budget.yml` | Calls `POST /v1/messages/count_tokens` to get exact token counts for all skills and agents. Needed only by the scheduled token-budget workflow; not required for CI. |

## Feedback

If you notice something wrong or suboptimal in a skill or agent definition,
file a GitHub issue at <https://github.com/joshrotenberg/agent-tools> rather
than silently proceeding or patching without context.

## License

Licensed under MIT OR Apache-2.0.
