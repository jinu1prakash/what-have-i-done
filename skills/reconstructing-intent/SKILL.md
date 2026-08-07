---
name: reconstructing-intent
description: Use when you need to establish what was actually asked for before judging whether work matches it - at a completion gate, when work has drifted mid-task, or when you are about to review your own output
---

# Reconstructing Intent

## Overview

You cannot check work against the request if the "request" you are checking
against is your own summary of it. By the time you finish a task, the version
of the ask in your head has been through several rounds of paraphrase, each one
quietly bending it toward what you built.

**Core principle:** Reconstruct the ask from the asker's words, not from your
memory of them.

## The Iron Law

```
GO BACK TO THE ORIGINAL WORDS. YOUR PARAPHRASE IS EVIDENCE OF NOTHING.
```

## The Method

### 1. Re-read the source, not your summary

Find the actual text: the first request, and every clarification, correction,
answer, and "actually, ..." since. Read them in order. Corrections outrank the
original — the last thing said about a point is what was asked.

If the request came with attachments, a linked ticket, a spec, or a prior plan
you agreed to, that is source too.

### 2. Sort every element into four buckets

This sort is the whole skill. Do it explicitly, in writing.

| Bucket | What goes in it | How it's used at the gate |
|---|---|---|
| **Required** | Stated outcomes. "Add X." "Fix Y." "Answer Z." | Missing one = **Missing** |
| **Constraint** | Explicit musts, don'ts, formats, values, limits, tools, tone, deadlines | Violating one = at least **Diverged** |
| **Implied acceptance** | Not stated, but the request is plainly worthless without it | Judge it; call it out as an inference |
| **Yours** | Anything you added, assumed, or decided on your own | Guilty until proven necessary — see below |

Quote the source for every Required and Constraint row. If you cannot quote it,
it belongs in **Yours**.

### Every constraint protects something. Name it.

For each Constraint row, write the *reason* next to it — what breaks if it is
violated. Constraints are usually stated as a rule ("keep the same format") but
exist to protect a consumer ("because a downstream job parses it").

This matters because **honoring the letter of a constraint while defeating what
it protects is Diverged, not Matches.** That failure is invisible without this
column: you check the rule, the rule passes, and the thing the rule existed to
protect is broken anyway.

| Constraint as stated | What it protects | Letter kept, spirit broken |
|---|---|---|
| "keep the output format exactly" | a downstream job that parses it | format identical, but the numbers now mean something different — the job silently consumes wrong data |
| "don't rename the headings" | deep links from other pages | headings kept, but a section's content moved under a different one |
| "keep it in the same file" | people's existing links and references | same filename, but the sheet they linked to was deleted |
| "don't add dependencies" | a box that only has stdlib | no new package, but the code now shells out to a binary that isn't there |

When the letter and the purpose diverge, the purpose is the constraint. If you
cannot honor both, that is a decision for the asker, not for you.

### 3. Be honest about the Yours bucket

Everything in **Yours** is scope the asker did not choose. Each item is one of:

- **Necessary enabler** — the required outcome is impossible without it. Say why
  in one line. This survives review.
- **Unrequested extra** — useful, maybe even good, but nobody asked. This is
  **Diverged**, and it goes in the report. It does not become acceptable because
  it turned out well.
- **Substitution** — you did a different thing than asked because you judged it
  better. This is the most dangerous item in the bucket, because it looks like
  completion. It is **Diverged** unless the asker agreed to the swap.

### 4. Write down what "done" means, in their terms

One short paragraph, in the asker's vocabulary, that someone who never saw your
work could hold the output against. If you cannot write it without using words
they never used, you have not reconstructed the intent — you have restated your
plan.

### 5. Name what is genuinely ambiguous

Where the request could reasonably be read two ways and you picked one, say so
and say which. An ambiguity you flag is a question. An ambiguity you silently
resolve is a defect waiting to be found.

## Worked Example

> **Ask:** "Can you clean up the quarterly numbers spreadsheet? The regional
> splits are a mess. Keep it in the same file, finance needs the tab names
> stable."
>
> Later: "Oh — Q3 is the one that matters, don't worry too much about Q1."

| Bucket | Item | Source |
|---|---|---|
| Required | Clean up the regional splits | "the regional splits are a mess" |
| Required | Prioritize Q3 | "Q3 is the one that matters" |
| Constraint | Same file — no new workbook | "keep it in the same file" |
| Constraint | Tab names unchanged | "finance needs the tab names stable" |
| Implied | Existing formulas keep working | Cleanup that breaks downstream refs is not cleanup |
| Yours | Added a summary chart | Nobody asked → **Diverged (extra)** |
| Yours | Deleted the empty Q1 tab | "don't worry too much about Q1" ≠ delete it → **Diverged** |

**Done means:** the regional splits in the existing workbook are consistent and
readable, Q3 most of all, with every original tab still present under its
original name and downstream references intact.

Note what the sort catches: "don't worry too much about Q1" reads as permission
right up until you write it next to what you actually did to Q1.

## Common Mistakes

| Mistake | Why it fails |
|---|---|
| Reconstructing from your own plan document | The plan is already your interpretation. Go upstream. |
| Treating the first message as the whole ask | Later corrections override it. |
| Dropping constraints that feel minor | "Same file" and "same tab names" are the constraints that get silently broken. |
| Listing task titles instead of outcomes | "Refactor the parser" is a title. What was it *for*? |
| Leaving the Yours bucket empty | If it's empty you didn't look. You always add something. |
| Rewriting vague asks into precise ones | If it was vague, record it as vague and flag it. |

## Red Flags - STOP

- You are writing the intent from memory without re-reading anything
- Every Required row is your phrasing, no quotes
- The Yours bucket is empty
- You are arguing that an extra "is really part of" a required item
- The "done means" paragraph uses your project vocabulary, not theirs
- A Constraint row has no "what it protects" — you have not understood it yet
- You are treating a passing aside ("X is what really matters", "don't worry
  about Y") as an instruction to change what the thing does
- Someone's sign-off is doing work in your reasoning without you having checked
  what it covered

**Next:** feed this reconstruction into `building-evidence-ledgers`.
