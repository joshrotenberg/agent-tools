---
name: standalone-docs
description: >-
  The default is not to create standalone markdown docs files (a `docs/`
  directory, a `NOTES.md`, an `ARCHITECTURE.md` written for its own sake).
  They drift faster than anything else in a repo because nothing exercises
  them. Route the content to code docs, README, CLAUDE.md, an ADR, or the
  issue body instead. Load before creating any markdown file that is not a
  README, a CHANGELOG, or CLAUDE.md.
---

# standalone-docs

A standalone docs file is a markdown file written to explain
something, living outside the paths a reader or a test already
touches: `docs/architecture.md`, `NOTES.md`, `design/overview.md`.

**The default is not to create one.** Not never, but the bar is
high enough that clearing it is a conversation, not a judgment call
made mid-task.

## Why the default is no

Everything else in a repo has something that exercises it. Code has
tests. The README is the first thing a visitor reads. CLAUDE.md is
loaded every session. A CHANGELOG entry is generated from commits.
When any of those goes wrong, something notices.

A file under `docs/` is referenced by nothing, read on no schedule,
and asserted by no test. Nothing notices when it goes wrong, so it
is usually wrong within a release or two, and it stays wrong. The
common outcome is worse than a stale doc: the file gets proposed,
agreed to, and never written.

A stale doc is not neutral. It is worse than no doc, because a
reader who finds it trusts it.

## Where the content actually goes

Before proposing a new file, route the content:

| the content is | destination |
|---|---|
| What a function, type, or module does | code docs (rustdoc, docstrings) |
| What the project is, how to start | README |
| Design decisions and project context for agents | CLAUDE.md |
| A decision with alternatives and consequences | an ADR |
| What changed in this release | CHANGELOG, generated from commits |
| Why this specific change was made | the issue or PR body |
| Findings a later dispatch consumes | issue comment, or a scratch file outside the repo |
| A runnable example | an `examples/` file that CI builds |

The last row is the pattern worth reaching for. An example CI
compiles cannot silently drift, because the build breaks. Prefer a
mechanism that fails loudly over prose that fails quietly.

## If a standalone doc still seems right

**Propose it and wait.** Do not create it as part of a task. Say
what it would cover, why no destination above fits, and what will
exercise it. Then wait for agreement.

The justification has to answer one question: **what will catch
this when it goes wrong?** Acceptable answers name a mechanism:

- A test asserts against it (a doctest, a literate test, a snapshot)
- CI builds or lints it
- It is linked from the README, so readers hit it on the normal path
- It is on the release checklist and gets read before every release

"It is important" and "we will keep it updated" are not mechanisms.
If nothing will catch it, the content goes to a destination from
the table.

## The obligation a surviving doc carries

Any standalone doc that does get created carries an accuracy check
from that point on.

**At minimum, before a release.** Read it against the current code.
Not "does it exist," but "is each claim in it still true."

**Preferably on the maintenance sweep**, using the same git-log-gap
heuristic `maintenance-sweep` applies to CLAUDE.md staleness:

```bash
git log -1 --format=%cr -- docs/<file>.md      # last touch of the doc
git log -1 --format=%cr -- <the code it describes>   # last touch of the subject
```

A doc untouched across months of active commits to its subject is
a staleness candidate. Flag it; do not silently rewrite it.

**A doc that fails its check twice gets deleted, not fixed again.**
Two consecutive drifts is evidence that nothing is exercising it,
which means the original justification did not hold. Delete it and
route the content per the table.

## Anti-patterns

- **Creating a `docs/` file as a side effect of a task.** The file
  was never proposed, so nobody agreed to maintain it.
- **Proposing a doc without naming what will exercise it.** The
  proposal is incomplete; it is asking for agreement on a
  maintenance cost nobody has estimated.
- **"We will keep it updated" as the justification.** That is an
  intention, not a mechanism. It is also the exact sentence that
  precedes every stale doc.
- **Writing prose where a compiled example would do.** An example
  CI builds cannot drift silently.
- **Splitting the README into a `docs/` tree because the README
  got long.** A long README is read. A short README plus five
  unread files is worse.
- **Fixing the same drifted doc a second time.** Delete it instead;
  the drift is the signal.
- **Treating a stale doc as harmless.** A reader who finds it
  trusts it, which makes it worse than nothing.

## Related skills

- [`non-pr-output-conventions`](../non-pr-output-conventions/SKILL.md)
  -- where a dispatched run's output goes; the in-repo file
  destination is subject to the bar above.
- [`maintenance-sweep`](../maintenance-sweep/SKILL.md) -- the sweep
  that flags a doc as a staleness candidate.
- [`release-audit-anchoring`](../release-audit-anchoring/SKILL.md)
  -- the pre-release pass where the accuracy check runs.
- [`durable-context`](../durable-context/SKILL.md) -- what state
  survives a session, and why CLAUDE.md is a destination a doc file
  usually is not.
