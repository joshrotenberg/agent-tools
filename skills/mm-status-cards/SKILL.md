---
name: mm-status-cards
description: Repeatable containers for common actions and status. Use when presenting a GitHub issue or PR (status, triage output, sweep results, "where does this stand"), and when the next step is the user choosing among enumerable options (which issue to work next, which PRs to dispatch, pick an approach) - render the fixed card for the entity, and offer the choice as a popup instead of a prose question.
allowed-tools: Bash(gh issue view:*), Bash(gh pr view:*), Bash(gh issue list:*), Bash(gh pr list:*)
---

# Status cards

Recurring entities get a fixed container: same fields, same order, every time, so the
reader never re-learns the shape. Complements wrapitup: wrapitup picks the register,
this pins the schema for the two entities that always carry the same few facts, and for
the decision that usually follows them.

## The card rule

- One to three entities: cards. More: a wrapitup structured table with the same fields
  as columns. A card is for looking at one thing, not scanning a queue.
- A field with nothing in it is stated, not dropped: `review: none`, `linked PR: none`.
  Shape stability is the point; this is the deliberate exception to wrapitup's
  empty-cells rule.
- Every line except `next:` is machine-derived from `gh`. `next:` is the one line of
  judgment, and a card without it is inventory, not status.
- The `[repo]` tag appears only when the conversation spans repos.

## Issue card

    #142  fix: REPL history dropped on SIGINT                [jpx]
    p1 · bug · size:S · open 12d · unassigned
    blocked-by: #139 · linked PR: none
    next: reproduce on 0.4.3, then dispatch

Line 1: number, title, repo if ambiguous. Line 2: triage labels (priority, category,
size), age, assignee. Line 3: relations. Line 4: next step.

Fill from:

    gh issue view 142 --json number,title,labels,assignees,createdAt,url

`gh issue view --json` does not expose linked PRs; that fact comes from the PR side
(`closingIssuesReferences`) or the issue timeline. If unknown, write `linked PR: ?`
rather than guessing `none`.

## PR card

    #214  refactor: mark public enums non_exhaustive         [jpx]
    ready · CI green · review: approved · +312 −188 · 8 files
    issue: #209 · last push 2h ago
    next: merge is the maintainer's call

Line 1: number, title, repo if ambiguous. Line 2: draft/ready, CI, review state,
diffstat. Line 3: linked issue, last activity. Line 4: next step.

Fill from:

    gh pr view 214 --json number,title,isDraft,statusCheckRollup,reviewDecision,additions,deletions,changedFiles,closingIssuesReferences,updatedAt,url

`CI red` never stands alone on a card: name the failing job and paste its error below
the card, per wrapitup (never summarise an error).

## Offering choices

When the next step is the user picking among enumerable options, use the choice popup
(AskUserQuestion), not a prose question. The canonical case: triage ranked the backlog,
now which issue gets worked.

- **Radio** for pick-one. **Checkboxes** (multiSelect) when working several in parallel
  is plausible and the dispatcher could fan out.
- **Top 3-4 only, ranked.** The popup is a shortlist, not the queue; the cut forces
  triage to actually rank. "Other" is provided automatically, never add your own.
- **Option label:** `#N few-word-slug`. **Description:** one line of why it is a
  candidate, plus priority and size.
- **Interactive sessions only.** A headless or dispatched run never blocks on a popup;
  it reports the queue in prose or a table instead.
- **Only decisions that are the user's:** priority, scope, irreversible steps. A choice
  with an obvious default is made, stated in one line, not asked.

After selection: card the picks, then act on them.

## Composition

The usual sequence at the end of a triage or sweep:

    a table      the ranked queue (wrapitup structured)
    a popup      the top 3-4 as radio or checkboxes
    cards        the user's picks, each with a next line
    action       dispatch or start work

Card first when presenting one thing; popup first when presenting a choice. Never popup
what you have not first shown.
