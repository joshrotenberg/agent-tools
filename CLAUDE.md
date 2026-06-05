# agent-tools

Project context for Claude Code sessions. Read this before
changing anything substantial. Global conventions live in
`~/.claude/CLAUDE.md`; this file adds agent-tools-specific
context.

This file is the durable local design home: positioning,
decisions, working conventions, pending work. Anything
actionable that needs cross-session memory lives here.
CLAUDE.md is intentionally tracked in this repo (committed
in #50); a `!CLAUDE.md` line in `.gitignore` overrides the
global ignore.

## What agent-tools is

Personal customization layer for working with Claude Code:

- **`skills/`** -- operational knowledge files that extend any
  agent's context (process discipline, dispatch patterns,
  sandbox preflight, release-audit anchoring, git workflow).
- **`agents/`** -- five subagent definitions:
  - `dispatcher` -- gathers context, decides execution shape,
    fires runners
  - `runner` -- executes one task end-to-end
  - `worker` -- bounded code-change task; no lifecycle
  - `auditor` -- read-only codebase audit against a rubric
  - `reviewer` -- reviews a PR; merges or requests changes
- **`install.sh`** -- idempotent copy into
  `~/.claude/{skills,agents}/` for Claude Code auto-discovery.

The repo is a curated convention -- one way to use Claude Code,
not THE way. Skills and agent bodies are Task-tool-centric; they
also work under `claude -p` (or any wrapper) for headless use.

Repo: <https://github.com/joshrotenberg/agent-tools> (private).

## The model (load-bearing)

**Durable state is the substrate.** Issues, PRs, project
CLAUDE.md files, code itself, the workspace filesystem layout.
Everything that matters lives there.

**Agents and conversations are ephemeral.** They read durable
state on invocation, write durable state on return. A fresh
session can re-read durable state and continue from where the
previous one left off.

**A unit of work** is defined by durable state, not by an
arbitrary size limit. "Implement #42" is a unit. "Work the 4
release-blocker issues for v0.2" is a unit. "Audit release
readiness across foo and bar" is a unit. The boundary comes
from what the issues + PRs + code say belongs together.

**The dispatcher decides the execution shape per unit:**

| shape | when |
|---|---|
| Single runner (default) | Most code-change work; well-defined task |
| Parallel runners | Multiple independent tasks, different files |
| Sequential runners | A's output (in durable state) is B's input |
| Chained agents (design → impl → review) | Future shape; build when single-runner visibly breaks |
| Audit + remediate | Survey first (read-only), then per-finding dispatch |

The shape is a per-unit choice, NOT an architectural commitment.

## The two roles

**Runner** (task-level). Reads `gh issue view N`, composes prompt
per [`orchestration-prompt-template`](skills/orchestration-prompt-template/SKILL.md),
runs the draft-PR-first lifecycle synchronously (branch → draft
PR → dispatch → push → ready → watch CI → merge). Returns when
the lifecycle is complete.

**Dispatcher** (scope-flexible). Takes a directive, scopes the
unit(s) of work, gathers durable context, decides execution
shape, fires. Doesn't do task-level work itself. Earns its keep
when scoping or shape decisions are non-trivial; routine
single-task work skips the dispatcher and goes straight to a
runner.

## Architecture / file layout

```
agent-tools/
├── README.md                                  # repo-level framing
├── CLAUDE.md                                  # this file (tracked)
├── install.sh                                 # idempotent install
├── .claude-plugin/
│   ├── plugin.json                            # plugin manifest
│   └── marketplace.json                       # self-marketplace catalog
├── .gitignore                                 # .DS_Store + !CLAUDE.md override
├── agents/
│   ├── README.md                              # the dispatcher + runner model
│   ├── dispatcher.md                          # scopes the unit, decides shape, fires
│   ├── runner.md                              # one task end-to-end (issue → PR → merged)
│   ├── worker.md                              # bounded code-change task; no lifecycle
│   ├── auditor.md                             # read-only audit against a rubric
│   └── reviewer.md                            # review a PR; merge or request changes
└── skills/
    ├── README.md                              # categorized skill index
    │
    ├── # Orchestration model
    ├── durable-context/                       # what state survives a session
    ├── orchestration-patterns/                # units of work + execution shapes
    ├── workflow-basics/                       # Workflow tool vs Task tool (50+)
    ├── non-pr-output-conventions/             # where non-PR output lands
    ├── triage/                                # label the open-issue queue
    ├── workspace-survey/                      # how dispatcher finds projects
    ├── audit-protocol/                        # rubric + 5-phase auditor contract
    ├── audit-remediate-handoff/               # findings → per-finding runners
    │
    ├── # Dispatch
    ├── dispatch-options/                      # Task tool / claude -p trade-offs
    ├── dispatch-wait-react/                   # background + notification, not polling
    ├── orchestrator-parallelization/          # fan-out heuristics
    ├── orchestration-prompt-template/         # how to write the runner prompt
    ├── spiral-diagnosis/                      # when a dispatched session hangs
    ├── runner-vs-worker/                      # dispatch a runner or a worker?
    │
    ├── # Lifecycle
    ├── draft-pr-first/                        # PR before work
    ├── sandbox-preflight/                     # fail loud on blocked tools
    ├── runner-issue-authority/                # gh issue view is authoritative
    ├── runner-synchronous-lifecycle/          # runner holds open until PR is merged
    ├── release-audit-anchoring/               # anchor on origin/main
    │
    ├── # Review
    ├── pr-review/                             # review a PR in agent-tools
    │
    ├── # Git + tooling hygiene
    ├── git-branch-pr-workflow/                # branch + PR discipline
    ├── git-fix-pr-branching/                  # branch off main, not off open PR
    ├── heredoc-backticks/                     # gh issue/PR body formatting
    │
    └── # Meta
    ├── agent-feedback/                        # file an issue on a bad skill/agent
    ├── field-feedback/                        # file a dispatch-time issue
    ├── skill-capabilities/                    # allowed-tools + dynamic injection
    └── install-cadence/                       # re-install after merged PRs
```

27 skills + 5 agents + repo files. Skills are categorized in
`skills/README.md` (visible there).

## Decisions log

### 2026-06-04: packaged as a Claude Code plugin

- Distributed as a plugin (#202/#203): agents flattened to canonical
  `<name>.md`, `.claude-plugin/{plugin.json,marketplace.json}` added, repo
  is its own marketplace. Plugin is the primary install (CLI + desktop);
  `install.sh` retained for the `~/.claude/` copy path.
- Surfaced + fixed a latent bug: 6 components had invalid YAML `description`
  frontmatter (unquoted `: `) that the loose `validate-frontmatter.sh` missed
  but `claude plugin validate` caught. Converted to `>-` block scalars.

### 2026-06-04: dropped roba from the model (#206)

- Reframed the dispatch docs Task-tool-centric; roba demoted from a
  featured co-equal mechanism to a one-line "headless wrapper" footnote.
  Rationale: roba's edge is headless/CI/cron + different-cwd batch, but
  agent-tools work is interactive and now desktop-visible -- the Task tool
  (in-session background + worktree isolation) and the desktop app's native
  background-session view absorbed roba's niche; its `--trace`/JSONL story
  was a workaround for visibility that's now native.
- roba stays a separate tool (still usable via `roba --agent`); agent-tools
  just stops featuring it. Historical anecdotes + the "split from roba"
  entries are kept as provenance.

### 2026-06-02 morning

- **Split from roba** (roba #129 discussion). Agent-tools was
  bundled into the roba binary via `roba skill install` /
  `roba agent install`. Split out into a standalone repo
  because:
  - Roba should be a pure mechanical `claude -p` wrapper;
    bundling tied the binary's release cadence to skill
    curation.
  - The skills are dispatch-agnostic and shouldn't be coupled
    to one specific wrapper.
  - "BYO skills + agents" is a cleaner pitch for roba; one
    curated convention is a cleaner pitch for this repo.
- **One-way relationship.** agent-tools may have a roba
  dispatch option among others (per `dispatch-options`); roba
  doesn't know about agent-tools.
- **Migration path.** Skills + agents moved verbatim, then
  reworked against the new model. roba's `skills/` and
  `agents/` directories deleted in roba PR #130.

### 2026-06-02 midday: three-level model attempted

- Tried coordinator (workspace) → orchestrator (project) →
  runner (task) hierarchy.
- Wrote `coordinator/AGENT.md`, `orchestrator/AGENT.md`,
  `runner/AGENT.md`, plus `coordinator-orchestrator-protocol`
  skill, `workspace-survey` skill.
- **Rejected** later the same session.

### 2026-06-02 afternoon: reframed to dispatcher + runner

- The three-level model conflated **role with scope** and
  presumed long-running agents carrying cross-task state.
  But state should live in durable substrate (issues, PRs,
  CLAUDE.md, code), not in agents.
- Reframed:
  - **Dispatcher**: scope-flexible role. Same role handles one
    task, one project's backlog, or multi-project work.
  - **Runner**: task-level execution.
  - **Execution shape** (single / parallel / sequential / chained
    / audit + remediate): per-unit decision, not architectural.
- Deleted `coordinator/`, `coordinator-orchestrator-protocol/`;
  renamed `orchestrator/` → `dispatcher/`; rewrote
  `orchestration-patterns/` around units + shapes.
- This is the current shape.
- **Why this reframe is the right shape:** because the substrate
  IS the durable state. Roles describing levels of an
  organization (workspace/project/task) make sense in a human org
  where the levels carry distinct durable knowledge. Here the
  knowledge is in the substrate, so the "levels" are really just
  different ways of slicing the same substrate. One role
  (dispatcher) handles all scopes; the shape decision is what
  varies.

### Naming conventions

- `name:` field in frontmatter MUST match directory name.
- Kebab-case for everything (`dispatch-options`, not
  `dispatchOptions` or `dispatch_options`).
- Skill names are noun-phrases describing what the skill is
  about (`spiral-diagnosis`, `sandbox-preflight`,
  `workspace-survey`).
- Agent names are nouns describing the role (`runner`,
  `dispatcher`).

## Working conventions

### Agent body structure

Agents should be SLIM. The body covers:

- Frontmatter (name, description, tools, model, skills list)
- Identity (what role this is, what it doesn't do)
- When to invoke vs skip
- Inputs + outputs
- The work loop (high-level, NOT procedural detail)
- Discipline (5-7 rules max)
- Anti-patterns
- Related agents

Procedural meat lives in skills (the `skills:` frontmatter
list). The body shouldn't reimplement what a referenced skill
already covers; it should reference and load.

Target: 130-200 lines per agent.

### Skill body structure

Skills should be self-contained but cross-referenced. Each
skill covers ONE thing well:

- Frontmatter (name, description)
- What this is about (1-3 sentences)
- When to apply
- The pattern / discipline / mechanism
- Anti-patterns or common mistakes
- Related skills

Target: 50-200 lines per skill, depending on complexity.

### Dispatch phrasing (Task-tool-centric)

The Task tool is the assumed dispatch mechanism (`isolation:
"worktree"` for same-repo file work, `run_in_background` + notify
for async). Keep process guidance mechanism-neutral where that
costs no clarity -- "the dispatched session" reads fine whether
it's a Task subagent or a `claude -p` process. Mention alternatives
(`claude -p` for genuine headless automation; roba if you use it)
only where actually relevant, not as co-equal defaults. Don't bend
bodies to feature roba -- that hedging is what #206 walked back.

## Install + use loop

agent-tools is a plugin; the repo is its own marketplace. Primary path:

```
claude plugin marketplace add joshrotenberg/agent-tools
claude plugin install agent-tools@agent-tools     # components namespaced agent-tools:*
```

Or copy into `~/.claude/` (unnamespaced; `claude --agent dispatcher` works):

```bash
cd ~/Code/active/agent-tools && ./install.sh

# After install, any Claude Code session can spawn:
# @dispatcher work the backlog in this project
# @runner implement #N
```

For changes during development:

```bash
claude --plugin-dir .     # load the plugin for a session; reload after edits
# -- or, for the ~/.claude copy path --
./install.sh --force      # overwrite without prompting
```

`install.sh` flags: `--to PATH`, `--force`, `--skip`, `--dry-run`.

## Pending work / known gaps

### Residual roba mentions (intentional)

#206 reframed the dispatch docs Task-tool-centric and demoted roba
to a one-line "headless wrapper" footnote. A few skills still carry
roba as an *example* of a trace/worktree flag (`spiral-diagnosis`,
`orchestrator-parallelization`) and as historical incident anecdotes
(`sandbox-preflight`, `runner-synchronous-lifecycle`, `heredoc-backticks`,
`git-fix-pr-branching`). Those are kept on purpose -- examples and
provenance, not "the mechanism." Don't "fix" them.

### Chained execution shape (design → impl → review)

Documented in `orchestration-patterns` as a future shape. Build
when the single-runner approach visibly breaks for a specific
unit of work. Tracked in roba issue #127 (the brainstorm); when
this gets built, it likely produces new Layer 2 agents in
agent-tools (`designer`, `implementer`, `reviewer`) plus a
dispatcher update for the chained shape.

### Workspace config file

`workspace-survey` documents the filesystem-walk approach as
v1, with a config file as a deferred option. Build when the
filesystem walk gets lossy (projects in non-standard locations,
priority hints that the filesystem can't express).

### Runner/worker branch contamination (#209-#213)

Four open findings about concurrent agents in shared checkouts or
during branch navigation: (#209) stray commit from one runner
landed in another runner's squash merge; (#210) worker accidentally
switched branches mid-dispatch and contaminated an unrelated PR;
(#212) parallel runners in a shared checkout can cross-contaminate
branches; (#213) git stash during branch navigation risks committing
to the wrong branch. Likely produces a new skill or additions to
runner/worker bodies. CI flatten ripple (#211) has PR #214 open.

### Sandbox write-gate (#217-#218)

`sandbox-preflight` misses write-gate blocks -- needs a Step 0
write probe (#217). `orchestration-prompt-template` also needs
write-gate halt caveat, worktree isolation note, and single-commit
reminder (#218). Both open.

### New agents proposed (#200, #215, #216)

- `issue-groomer` (#200): validate open issues against current code,
  then comment or close stale ones.
- `workspace-groomer` (#215): survey and groom projects, sessions,
  worktrees, branches.
- `extract-and-promote` (#216): extract project learnings and propose
  enrichments to global skills/agents.

## Relationship to roba

As of #206, agent-tools is **Task-tool-centric** -- roba is no longer
a featured dispatch mechanism (desktop + the Task tool absorbed its
niche; see the 2026-06-04 decisions-log entry). roba remains a
separate, independent tool:

- agent-tools agents can still be driven via `roba --agent <name>`
  if you choose to (roba's `--agent NAME` flag is generic) -- but the
  docs assume the Task tool, not roba.
- roba does NOT know about agent-tools; it's purely mechanical.
  Bumping one repo doesn't bump the other.

## Desktop app

agent-tools was built against the `claude` CLI. The desktop
app (and claude.ai/code) is the same engine sharing the same
`~/.claude/` config home, so most of it ports unchanged. The
split (2026-06-04):

**Ports clean.** Skills (same `~/.claude/skills/` discovery),
settings.json / hooks / permissions, and the Task-tool dispatch
family (`dispatcher → runner → worker`, `auditor`, `reviewer`,
with `isolation: "worktree"`). Single-project `dispatcher →
runner` work is at parity.

**Exceptions (verify per machine).**

- **Bash subprocess dispatch.** `roba` / `claude -p` dispatch
  (roba-orchestrator, roba-runner, `dispatch-via-bash`, the Bash
  branch of `dispatch-options`) needs those binaries on PATH. A
  GUI launch may not inherit your shell PATH (the macOS Dock
  gotcha). Check in a desktop Bash cell: `which claude roba gh`.
  Fix by launching `open -a Claude` from a terminal, or pin
  PATH/env in `.claude/settings.json`.
- **Cross-project `workspace-survey`.** Desktop scopes file
  access to the open project folder(s); walking `~/Code/active/`
  needs those dirs added. Single-project dispatching is fine.

**Starting the dispatcher.** The dispatcher is a *driver* -- it
fires runners via `Task`, so it's meant to BE the top-level
session, not a spawned leaf. CLI: `claude --agent dispatcher`
pins the session to it (it "just uses it by default"). Desktop
has no launch flag, so load the persona into the top-level
session instead: `@agents/dispatcher.md` pulls the file inline,
or bake it into a project CLAUDE.md. Don't spawn the dispatcher
as a subagent -- that pushes its runner-spawning a level deeper;
the spawned-subagent form is for leaf agents like the runner.

Agents are now canonical flat `<name>.md` files (#202) -- the
form Claude Code documents and the `@`-picker expects -- which
should settle the desktop autocomplete question we couldn't
confirm earlier. The inline path-reference (`@agents/<name>.md`)
and natural-language delegation resolve them regardless.

## When in doubt

- Check this file: decisions log + pending work cover most
  "should we do X?" questions.
- Check `skills/README.md` and `agents/README.md` for the
  current shape of the library.
- Check `git log --oneline | head -20` for recent direction.
- For dispatch-mechanism questions, see `skills/dispatch-options/SKILL.md`.
- For "what's a unit of work" or "what execution shape," see
  `skills/orchestration-patterns/SKILL.md`.

## Read first, update last

Same discipline as roba's CLAUDE.md:

- **Read first.** Claude Code auto-loads this on cwd match.
- **Update last.** Before closing out work, ask: did this
  produce something worth capturing? Categories:
  - Decisions log entry (a settled choice)
  - Pending work entry (new gap surfaced)
  - Pattern that should become a skill (capture, then write
    the skill in a follow-up)
- **Don't update for nothing.** A small content edit doesn't
  need a CLAUDE.md update. The bar: "would future-me want to
  find this when grepping the durable design home?"

### 2026-06-03: self-audit session (17 issues, ~28 PRs)

Three-domain self-audit dispatched in parallel (3 auditors). Audit
produced 17 findings (#152-#168) -- all resolved in the same session.

**Agent body sizes reduced.** runner 199 → 158 lines; auditor
171 → 103 lines; reviewer 88 → 68 lines; dispatcher preload total
1888 → 1603 lines (removed draft-pr-first and sandbox-preflight,
which are covered by orchestration-prompt-template and runner
respectively).

**New skills added.** `runner-vs-worker` (decision boundary between
runner and worker; failure mode: runner opened as worker causes
unsolicited draft PR + CI + merge), `audit-protocol` (extracted
from auditor body: rubric format + 5-phase execution contract),
`audit-remediate-handoff` (findings → dispatcher labels in-progress
→ per-finding runners), `install-cadence` (run `./install.sh
--force` after each batch of merged PRs).

**`claude -p` does not support `-C` flag.** Fixed to
`cd <path> && claude -p` everywhere -- runner AGENT.md and
orchestration-prompt-template both had `claude -p -C $(pwd)`.

**Style-reference copy trap.** Worker prompts that reference an
existing file for style must say "for style reference ONLY -- do
not copy its content." Added to orchestration-prompt-template.

**Pre-merge diff validation.** After a roba parallel-runner
contamination incident (#198), added two disciplines to the runner
lifecycle: (1) store PR number from `gh pr create` output and only
ever merge that specific number; (2) run `gh pr diff --name-only
$PR` before `gh pr merge` to verify scope matches the task.

### 2026-06-02 evening: first full dogfood session

First real dispatcher session. Significant work done. Key decisions and lessons:

**Dispatch-agnostic sweep (issues #1-#2, PRs #3-#4 merged).** Removed all
roba-specific language from 5 skills and runner AGENT.md. Skills are now
dispatch-agnostic as designed.

**CI added (issues #6, #9-#11, #15, PRs #12-#16 merged).** GitHub Actions
workflow, frontmatter validation script, markdownlint, AGENTS.md, smoke tests,
agent-feedback skill.

**Worktree isolation: use `isolation: "worktree"` on all same-repo Agent
dispatches.** The Task/Agent tool has this built in natively. No external tool
required. Creates an isolated checkout; path+branch returned if agent makes
changes; auto-cleaned if no changes. Roba `-w` is the Bash-dispatch equivalent.

**`subagent_type: "runner"` runs the full lifecycle.** When dispatching via the
Task tool with `subagent_type: "runner"`, the runner reads the issue, branches,
opens a draft PR, dispatches a sub-session, pushes, watches CI, and merges. This
is the CORRECT use. Don't use it as a simple worker (just-edit-files-and-commit)
-- the installed runner will try to run the full lifecycle regardless of
constraints. For simple worker tasks, use `claude-server-worker` or a dedicated
worker agent until the runner is properly spec'd for both modes.

**Install cadence: run `./install.sh --force` after each batch of merged PRs.**
This keeps `~/.claude/agents/` and `~/.claude/skills/` in sync with the repo.
Skipping it means subagents use stale definitions, which causes unexpected
behavior (re-adding removed behaviors, wrong lifecycle). Dogfooding requires
installed agents to match repo state.

**Auto-merge on CI pass is the runner default (issue #17, PR #26 pending).** The
dispatch is the authorization. The global "don't merge unless asked" convention
applies to interactive sessions, not to the runner lifecycle.

**Researcher findings filed as issues #33-#37.** New Claude Code capabilities
to document: subagent_type taxonomy (explore, plan, bash), effort/memory fields,
Monitor tool for tailing, Workflow tool for multi-agent pipelines, dynamic context
injection in skills, allowed-tools in SKILL.md frontmatter.

## Dispatch and install conventions

### Install cadence

Run `./install.sh --force` after each batch of agent/skill PRs merges. The
installed `~/.claude/agents/` and `~/.claude/skills/` must match the repo or
dogfooding breaks -- subagents load stale definitions and reintroduce behaviors
you explicitly removed.

Rule of thumb: if you merged PRs, run install before dispatching.
