# AGENTS.md

This repo ships operational knowledge files (skills) and subagent definitions
(agents) for use with Claude Code's dispatcher+runner model. `install.sh`
copies them into `~/.claude/{skills,agents}/` for auto-discovery. Everything
here is dispatch-agnostic -- works with the Task tool, roba, `claude -p`, or
any wrapper.

## Install

```bash
./install.sh   # see README for --force, --dry-run, --to, --skip options
```

## Structure

- `skills/<name>/SKILL.md` -- operational knowledge files; loaded into agent
  context by name via frontmatter `skills:` list
- `agents/<name>/AGENT.md` -- subagent definitions (`dispatcher`, `runner`)

## Naming conventions

- Kebab-case for all directory and file names
- `name:` frontmatter field must match the directory name exactly
- Skill names: noun-phrases describing what the skill is about
  (`spiral-diagnosis`, `sandbox-preflight`, not `diagnoseSpirale`)
- Agent names: role nouns (`runner`, `dispatcher`)

## Key constraints for any edits

- No emojis in skill/agent body content, commits, or docs
- No em dashes -- use double hyphens or rephrase
- All skill and agent body language must be dispatch-agnostic; roba is one
  dispatch option among several, not the assumed mechanism
- Read `CLAUDE.md` decisions log before changing anything substantial
  (CLAUDE.md is untracked but present locally after clone + setup)

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

## Feedback

If you notice something wrong or suboptimal in a skill or agent definition,
file a GitHub issue at https://github.com/joshrotenberg/agent-tools rather
than silently proceeding or patching without context.
