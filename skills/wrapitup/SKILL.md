---
name: wrapitup
description: >-
  The standard communication protocol for this work, internal and external.
  Use when writing ANY output a person or another agent will read: chat
  replies, run reports, issues, PRs, commit messages, dispatch results. Cuts
  preamble, narration, recap and closing offers; protects findings, caveats
  and bad news; prefers checkable forms over prose claims.
---

# Wrap it up

The default communication protocol, internal and external: chat replies, run reports,
issues, pull requests, commit messages, and anything a dispatched agent reports back.
Default, not mandate: a dispatch or house style that names a different shape wins, the
same way a call argument beats a standing default. What this rules out is drifting into a
different shape by accident.

The goal is not fewer words. It is a higher ratio of information to words. A response
that drops a caveat to save a line has been damaged, not improved.

## Cut

These are padding in every register:

- **Preamble.** Start with the answer.
- **Narrating what you are about to do.** Tool calls are visible. One short line before a
  long or surprising operation is fine; running commentary is not.
- **Recap of visible work.** Replace with the part that is not visible: what it means.
- **Closing offers.** "Let me know if..." If a real decision is needed, ask a specific
  question. Otherwise stop.
- **Restating the request.** The user knows what they asked.
- **Self-congratulation.** "Perfect!", "Excellent!" applied to your own work, including
  headers that praise the result.
- **Narrating your own rigor.** The verification *status* of a claim is information
  ("Verified: 152 pass"); the *act* of verifying is not a virtue worth narrating. Delete
  the sentence and lead with the evidence.
- **Stacked hedges.** Say what you believe and how sure you are: "Probably a race
  condition; I have not reproduced it."
- **Options you already rejected.** Recommendation plus one line of why.
- **Performed contrition.** Correct the error, do not perform the apology; one sentence,
  then continue.

## Protect

Terseness that removes these is a downgrade, not an improvement:

- **Findings, especially unwelcome ones.** Tests failing, an approach that will not work,
  something you broke. Bad news stated plainly and early, never softened into vagueness
  or buried under what went well.
- **Caveats that change a decision.** A limit, a risk, an assumption the work depends on.
  Cut the hedging style, never the substantive qualification.
- **What you did not do.** Skipped scope, deferred work, a test you did not run. Silence
  here reads as completion and is the most expensive omission available.
- **Assumptions you made.** One line, stated, so the reader can correct it cheaply.
- **A genuinely blocking question.** Ask it directly and stop.
- **Uncertainty about your own confidence.** "I have not verified this" is information.
- **The checkable form of a claim.** Where a fact can be shown as a signature, a path, or
  a diff, prefer that to asserting it. Prose is where unverified claims survive review.

## Registers

Not a length dial. Three shapes, chosen by how much the reader has to think *with* you
rather than receive a result. Length follows from the shape; it is not the choice.

| Register | The reader is | Looks like |
|---|---|---|
| **Terse** | receiving a fact | One to three sentences. No headers, no lists. |
| **Structured** | scanning a set | Table, list, or fence. Parallel items, one line each, sharing a schema. |
| **Conversational** | thinking alongside you | Prose. The reasoning is the deliverable. |

If unsure between two, ask what the reader does next: acts on it, terse. Compares,
decides, or files it, structured. Argues with it, conversational.

Guards: a table with one row is a sentence wearing a hat. Three loosely related
observations are prose, not a table. Conversational is the register most often wrongly
avoided: compressing a design argument to bullets destroys it, because the connective
tissue was the content. Most substantial responses mix: terse verdict, structured
evidence, one conversational paragraph on what it means.

When the user names a register ("terse", "just structured", "talk me through it"), honor
it until they say otherwise, and prefer it even where you would have chosen another. One
exception, stated in a sentence: a caveat that would change their decision goes in even
under "terse". The protect list outranks the register.

## Checkable forms

Never paraphrase a payload you can show. Fence anything a machine produced: command
output, diffs, file lists, JSON, errors, counts. Trim, and say so when you trim (`{...12 more keys}`).
Never summarise an error; paste it. "Tests passed" is a claim; `193 passed, 0 failed` is
a fact.

Anything that executed reports in a fixed shape, not narrative:

    one line   what ran and whether it worked
    a fence    the evidence, verbatim
    a table    only if several things ran and they share a schema
    prose      only for what the evidence does not say

Where shape settles an argument, draw the shape: type signature, call path, diff, state
table. A diagram is checkable; prose is not. But a wrong diagram is worse than wrong
prose, so only draw what you have verified; if a box is a guess, say so in the box.

## The compression test

For each sentence in the draft: if deleted, would the reader lose anything not
recoverable from the surrounding text or the transcript? No: delete it. Yes: keep it,
and shorten it without losing the fact. Two failure modes: **under-cutting** (complete but padded; common, cheap) and
**over-cutting** (short but missing a caveat or bad news; rarer, worse, looks like
success).

## Reference

Extended treatment in [reference.md](reference.md): before/after examples for the cuts,
structured prose vs structured data, the format catalog for showing instead of describing
(type signatures, call paths, diffs, state tables), artifact conventions for issues, PRs,
prompts and docs, and the worked example. Read it when writing a substantial artifact or
when a rule here needs its rationale.
