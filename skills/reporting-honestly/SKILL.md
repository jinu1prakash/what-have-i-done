---
name: reporting-honestly
description: Use when the completion gate has passed and you are writing the message that hands work back - the final report of what was done, what proves it, and what remains unverified
---

# Reporting Honestly

## Overview

The gate has run. The last thing that can go wrong is the report itself: the
evidence gets compressed into "done", the one thing you could not verify gets
softened into a passing sentence, and the caveat that mattered sits below the
fold. The review is only as good as what survives into the message.

**Core principle:** The report states what is true, in an order that puts what
the reader needs to act on first.

This is a shaping skill, so it is written as a contract. The report **is** the
parts below, in this order. Produce them and the report is right.

## The Contract

A completion report has these five parts, in this sequence:

```
1. VERDICT LINE      one sentence: what is done, and whether anything is open
2. WHAT WAS ASKED    the reconstructed intent, briefly, in their words
3. WHAT WAS DONE     per item: the action, and the evidence that proves it
4. OPEN              unverified items, unrequested extras, blocked items
5. NEXT              what the reader decides or does now
```

Part 4 appears whenever it has content, and it appears **before** any closing
summary — a reader who stops halfway has still seen it.

---

## Part 1 — Verdict line

One sentence. State the outcome and the presence of anything open.

> Regional splits are cleaned in the existing workbook; the Q1 tab I deleted has
> been restored, and one figure remains unverified.

> The parser handles all four input formats; all 34 tests pass. Nothing open.

The reader gets the shape of the situation before any detail.

## Part 2 — What was asked

Two or three lines, in the asker's vocabulary, from `reconstructing-intent`.
Quote the constraints verbatim.

> You asked me to clean up the regional splits, prioritizing Q3, "keep it in the
> same file", and keep the tab names stable for finance.

This is what makes the rest checkable: the reader can hold your report against
their own request without scrolling back.

## Part 3 — What was done

One item per thing that was asked, each with its action and its evidence.
Evidence goes inline — the number, the output, the location — not a claim that
evidence exists.

> - **Regional splits normalized.** Q3 columns D–G now use the five canonical
>   region names; 31 duplicate rows removed (812 → 781).
> - **Same file, tabs stable.** Edited in place; tab list is byte-identical to
>   the original.
> - **Q1 left alone.** Untouched, as you said not to worry about it.

Say what the work actually does. Where the outcome differs from the intent —
even slightly — the difference is the interesting part, so lead with it:

> - **Retry logic added, but on a fixed interval rather than the exponential
>   backoff you described** — the client library exposes no backoff hook. Live
>   at `client.ts:88`.

## Part 4 — Open

Everything the reader would want to know and would not learn from part 3. Give
each item its own line, and state what it would take to close it.

**Unverified.** Say what you could not confirm, and what would confirm it.

> - **The 4.2% figure is unverified.** It comes from the pivot on the `Raw` tab,
>   which I could not reconcile against the source export — the export wasn't in
>   the folder. Dropping that file in would settle it in a minute.

**Extras.** Anything you made that was not asked for, and what happens to it.

> - **I added a summary chart to Q3** that you didn't ask for. It's on the tab
>   now; say the word and I'll remove it.

**Blocked.** Anything you could not do, why, and what you need.

> - **The finance mirror is not updated.** I don't have write access to that
>   share. Someone with access needs to copy the workbook across.

**Still running.** Any check you started that has not returned by the time you
send. State what is outstanding and what you will do with the result — including
if the answer is that it will be lost.

> - **A second review pass is still running and I have no way to relay its
>   result after this message.** Everything above is from the first pass. If you
>   want that second opinion, ask me and I'll wait for it.

An unfinished check is not a caveat on a completed report — it means the report
is early. Prefer waiting. If you cannot wait, say the work is not yet cleared
rather than describing it as done with a note attached.

**Review mode.** When the review ran in-session rather than as a fresh reviewer,
one line saying so:

> - Reviewed in-session (no subagent available in this harness), so the review
>   shares my blind spots.

When there is genuinely nothing open, one line says so: *"Nothing open."*

## Part 5 — Next

What the reader does or decides now. One or two lines.

> Drop the source export in and I'll confirm the 4.2%. Tell me whether the chart
> stays.

When nothing is needed, say that: *"Nothing needed from you."*

---

## Two Worked Reports

**Clean pass:**

> Parser handles all four input formats; nothing open.
>
> You asked for CSV, TSV, and "the two weird pipe formats from the vendor",
> without adding dependencies.
>
> - **All four formats parse.** 34/34 tests pass, including 6 new cases built
>   from the vendor samples in `fixtures/vendor/`.
> - **No new dependencies.** `package.json` dependencies unchanged; parsing uses
>   the standard library only.
> - **Existing callers unaffected.** Full suite green, same 28 pre-existing tests
>   passing as before.
>
> Nothing open.
>
> Nothing needed from you.

**With open items:**

> Migration script is written and tested against a copy; it has not been run
> against production, and one edge case is unresolved.
>
> You asked for a script to move the legacy `users` rows into the new schema,
> "without downtime", and to run it yourself rather than have me run it.
>
> - **Script written.** `scripts/migrate-users.py`, batched at 500 rows, resumable
>   from a checkpoint file.
> - **Tested against a copy.** Full run on a 1.2M-row snapshot: 1,203,441 rows in,
>   1,203,441 out, 0 errors, 14 minutes.
> - **No downtime path.** Writes to the new table only; the cutover is a separate
>   step you control.
>
> Open:
> - **Rows with a null `created_at` are unresolved.** 412 in the snapshot. The
>   script currently assigns them epoch, which is a guess. Tell me what you want
>   and I'll change it.
> - **Never run against production.** Snapshot behavior is not proof of
>   production behavior.
>
> Decide the null `created_at` rule, then run it — I'd start with `--limit 1000`.

---

## Self-Check

Before sending, confirm each part is present and in order:

- [ ] **Verdict line** — one sentence, states whether anything is open
- [ ] **What was asked** — their words, constraints quoted
- [ ] **What was done** — one item per ask, evidence inline
- [ ] **Open** — unverified, extras, blocked, review mode; or "Nothing open"
- [ ] **Next** — what they decide or do; or "Nothing needed from you"

Then one final read: for every statement in part 3, point at the evidence that
makes it true. Any statement you cannot point at belongs in part 4.
