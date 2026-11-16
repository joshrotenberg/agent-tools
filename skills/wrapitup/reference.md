# Wrap it up: reference

Extended treatment of the rules in [SKILL.md](SKILL.md): the before/after examples, the
rationale, and the sections that matter for substantial artifacts. The core file is the
protocol; this is the argument for it.

Most of what an agent writes is conversation about the work rather than the work. It is
padding that survives because it sounds polite. Cut it.

## The cut list, with examples

**Preamble.** Start with the answer.

> Great question! Let me take a look at that for you. I'll start by examining the file
> structure to understand how things are organized.

Delete entirely. The first sentence should carry information.

**Narrating what you are about to do.** Tool calls are visible.

> Now I'll read the config file to see what's in it.
> Let me search for where this function is defined.

Delete. Act, then report what you found. One short line before a long or surprising
operation is fine; a running commentary is not.

**Recap of visible work.** If it is in the transcript above, do not restate it.

> To summarize what I did: I read the file, found the bug on line 42, fixed it, and then
> ran the tests to confirm.

Replace with the part that is not visible: what it means.

> The bug was an off-by-one in the retry loop; tests pass.

**Closing offers.** Every one of these is deletable.

> Let me know if you'd like me to explain further!
> Would you like me to continue with the next step?
> Feel free to ask if you have any questions.
> I hope this helps!

If a real decision is needed, ask a specific question. Otherwise stop.

**Restating the request.** The user knows what they asked.

> You asked me to find why the tests are failing. To do that, I need to first understand
> the test setup.

**Self-congratulation.** "Perfect!", "Excellent!", "Great news!" applied to your own work.
Also applies to section headers that praise the result.

**Narrating your own rigor.** The most seductive one, because it arrives exactly where
real content should and sounds like substance.

> Checked it empirically, and the evidence is sharper than an assertion:
> Rather than take that at face value, I went and looked:
> Let me verify this properly instead of guessing.
> I'll check the actual config rather than infer from the tool list.

Delete the sentence and lead with the evidence. It speaks for itself, which is the entire
reason you gathered it.

The line to hold: the *verification status* of a claim is information; the *act* of
verifying is not a virtue worth narrating. "Tests pass, ran them just now" earns its
words. "I didn't want to just assume, so I actually ran the tests, and the results are
illuminating" does not. Same for method compliments after the fact: "better than we
remembered", "sharper than expected", "good thing I looked".

Compress to a marker or drop it:

> Verified: 152 pass.
> Unverified, from the docs: the flag defaults to false.

**Stacked hedges.** One qualifier is honest. Three is noise.

> It seems like this might possibly be related to what could be a race condition.

Say what you believe and how sure you are.

> Probably a race condition; I have not reproduced it.

**Options you will not pursue.** If you already decided, do not survey the alternatives
you rejected. Give the recommendation and one line of why.

**Apology and self-criticism.** Correct the error, do not perform contrition. One
sentence, then continue.

## The three registers

Defined in [SKILL.md](SKILL.md); here each in depth.

### Terse

A single fact, a confirmation, a location, a number, a yes or no.

> Fixed: the validator was never applied to piped input (`editor.rs:995`).
>
> 152 pass. Coverage 65%.
>
> No. The archive scan stops at 400 sessions, so that result is partial.

Do not decorate a fact with structure. A table with one row is a sentence wearing a hat.

### Structured

Two different things wear this name. Keep them apart.

**Structured prose** is a table or list for a human to scan: a status sweep, a comparison
across fixed dimensions, a catalog, per-item results. The shape carries meaning the prose
would have to spell out.

The test is whether the items share a schema. Three findings each with a file, a
severity, and a fix are a table. Three loosely related observations are prose.

Do not force it. If two of the cells would be empty or say "n/a", it was not a table.

**Structured data** is the actual payload, shown rather than described. This applies
whenever the thing under discussion already has a schema someone else defined: protocol
messages, API responses, tool results, config, log records, query output.

The rule there is short and absolute:

> Never paraphrase a payload you can show.

Prose about data is strictly worse than the data. It is longer, it loses the exact keys,
it silently drops fields, and it cannot be copied, diffed, or piped.

> The response came back successfully with the session identifier and a cost of about a
> tenth of a cent, and it indicated the session can still be resumed.

Show it instead, trimmed to what matters:

```json
{ "session_id": "6adde3cc-...", "cost_usd": 0.0011,
  "continuation": { "resumable": true } }
```

Trimming is expected, and say so when you trim: `{...12 more keys}` beats quietly
dropping them. What you must not do is retype the values into a sentence.

This register is heaviest in protocol and data work and nearly absent in others. Reach
for it when a payload exists; do not manufacture JSON for things that were never data.

### Conversational

Judgment calls, disagreement, design tradeoffs, why something surprised you, what you
recommend and why, anything where a bare conclusion would be unusable because the reader
needs to check your reasoning to trust it.

This is the register most often *wrongly avoided* after someone asks for less verbosity.
Compressing a design argument to a bullet list destroys it: the connective tissue was the
content. Conversational is not permission to pad, it is an obligation to actually reason
rather than assert.

Still cut preamble, narration, and closing offers here. Those are never any register.

## Show it instead of describing it

A separate axis from the registers: the registers decide how much, this decides what
shape. The strongest argument for it is not that visuals are pleasant to read:

> **A diagram is checkable. Prose is not.**

Prose lets a claim pass unverified. "The parameter is still reachable through the
profile" reads as fact and survives review, because checking it means holding four files
in your head. The same claim as a call path is wrong at a glance:

    ask(profile: "repo")
      -> runOptsFrom(a)
           permissionMode: a.permission_mode ?? profileSpec(a.profile).permissionMode
                           ^^^^^^^^^^^^^^^^^ removed from the schema, always undefined

That is the same failure the protect list (in [SKILL.md](SKILL.md)) is about, caught by
form rather than by diligence.

**Formats worth reaching for, and when:**

    type signature      before implementation. Shape settles arguments prose cannot.
    call path           control flow, "who calls what". Where a claim about reachability lives.
    diff syntax         a change, against just enough unchanged context to locate it.
    file tree           one line of responsibility per entry. Never the whole tree.
    state table         a small state machine, or a matrix where two axes cross.
    pseudocode          an algorithm whose shape matters more than its syntax.

**Rules that keep this from becoming decoration:**

- **A wrong diagram is worse than wrong prose**, because it looks authoritative and
  invites less scrutiny. Only draw what you have actually verified; if a box is a guess,
  say so in the box.
- **Match the medium.** In a terminal, text structures render and mermaid does not. Reach
  for mermaid only where it will actually be drawn.
- **Show the mechanism, not the vibe.** Three boxes labelled Input, Process, Output
  convey nothing that the sentence did not. If the picture is not more specific than the
  prose it replaces, it is worse than the prose.
- **Small.** A visual that needs scrolling has become a document.

They compose with the registers: a terse verdict, a small diagram as the evidence, one
conversational paragraph on what it means.

## Reporting a run

Anything that executed reports in a fixed shape rather than as narrative: a dispatch, a
test suite, a build, a triage. The reader wants to know what happened, whether it worked,
and what to do, and a paragraph makes them extract all three.

**The shape:**

    one line     what ran and whether it worked
    a fence      the evidence, verbatim, not paraphrased
    a table      only if several things ran and they share a schema
    prose        only for what the evidence does not say

Example:

> `#13` merged clean, tests green.
>
> ```
> 193 passed, 0 failed
> src/archive.ts  +18 −4
> ```
>
> Prefix matching is case-sensitive, which the issue did not specify. Assumed sensitive
> because ids are hex.

The fence is doing the real work. **Paste the output; do not describe it.** "Tests
passed" is a claim; `193 passed, 0 failed` is a fact, and the difference is exactly the
checkable form the protect list argues for.

**Fence anything a machine produced:** command output, diffs, file lists, JSON, errors,
counts. Reserve prose for judgment, assumptions, and what you would do next, the things
no tool emitted.

**Never summarise an error.** Paste it. A summarised error has had the useful part
removed by someone who did not yet know which part was useful.

## Mixing, and picking wrong

Most substantial responses use more than one register. Lead with the register the
*headline* demands, then shift. A common good shape: terse verdict, structured evidence,
one conversational paragraph for what it means and what you would do.

Do not shift registers more than the content requires. Alternating between a table and a
paragraph for every point reads as indecision.

| Mistake | Result |
|---|---|
| Conversational for a status report | The default failure. Padding that sounds thoughtful. |
| Terse for a judgment call | Drops the reasoning that made the answer worth anything. |
| Structured for a single fact | A one-row table. Ceremony around nothing. |
| Structured for an argument | Bullets that assert instead of reason. |

If unsure between two, ask what the reader does next. Acts on it, terse. Compares,
decides, or files it, structured. Argues with it, conversational.

## Artifacts, not just replies

The same format optionally covers anything written down: issues, pull requests, prompts,
design docs, commit messages. One shape means a reader learns it once, and a report reads
the same whether a person or an agent produced it.

    issue     what is wrong or wanted, the evidence, what it would cost. Not a narrative.
    PR        what changed and why, measured before and after, what must not regress.
    prompt    the request, the constraints, the shape of the answer. No throat-clearing.
    doc       lead with the decision, put the evidence in a fence, state the cost.

The rules transfer unchanged: lead with the conclusion, fence anything a machine
produced, prefer the checkable form, protect the caveats, never summarise an error.

Two that matter more in artifacts than in chat, because an artifact is read later by
someone without the conversation:

- **State the cost.** A doc that only lists wins reads as marketing, and the costs are
  the part a reader can argue with.
- **Say what you did not verify.** In chat an unverified claim gets corrected in the next
  message. In a document it becomes the record.

Optional, like everything else here. A project with its own house style wins; this is
what to use when nothing else is specified.

## Worked example

Before:

> Great question! Let me investigate that for you.
>
> I'll start by looking at the test file to understand what's being tested. Then I'll
> examine the implementation to see where the mismatch might be.
>
> [tool calls]
>
> Perfect! I found the issue. So what I did was, I read through the test file and then
> looked at the implementation, and I discovered that there seems to be what might be a
> problem with how the timeout is configured. I've gone ahead and fixed it by changing
> the value from 100 to 1000.
>
> Let me know if you'd like me to explain anything further or if you'd like me to run
> the tests again!

After:

> The test asserted a 100ms timeout against a handler that sleeps 500ms. Raised it to
> 1000ms; suite passes.
>
> Worth noting: the handler's 500ms is itself arbitrary, so this test will drift again if
> anyone touches it. A fake clock would fix it properly.

The second is shorter and says strictly more. It also volunteers a caveat the first one
never reached.
