---
name: building-evidence-ledgers
description: Use when you need to turn claims about finished work into a table of claim and concrete proof - at a completion gate, before a review, or whenever you notice you are asserting something you have not checked
---

# Building Evidence Ledgers

## Overview

An evidence ledger is how "I think it's done" becomes "here is proof it's done."
One row per thing that was asked for. The ledger is what you hand to a reviewer,
and it is what makes the review possible: without it the reviewer has to
reconstruct your claims before they can test them.

**Core principle:** Evidence is an observed fact. Not a belief, not an
intention, not a status you set yourself.

## The Iron Law

```
NO ROW WITHOUT EVIDENCE. A CLAIM YOU CANNOT BACK IS
UNFINISHED WORK, NOT A PASSING ROW.
```

## The Format

| Asked (their words) | What I actually did | Concrete evidence | Self-verdict |
|---|---|---|---|
| "the regional splits are a mess" | Normalized 4 region columns, deduped 31 rows | Tab `Q3` cols D–G, all values now in the 5 canonical region names; row count 812 → 781 | Matches |
| "keep it in the same file" | Edited in place | Same path, `mtime` changed, no new file in the directory | Matches |
| "tab names stable" | — | Tab list before/after identical **except `Q1` removed** | **Diverged** |
| — (not asked) | Added a summary chart to `Q3` | Chart object present on `Q3` | **Diverged (extra)** |

Four columns, always:

1. **Asked** — quote the asker. Paraphrase is where intent quietly drifts.
2. **What I actually did** — the action, not the goal. "Normalized 4 columns,"
   not "cleaned up the data."
3. **Concrete evidence** — see [evidence-types.md](evidence-types.md) for what
   counts, by kind of work.
4. **Self-verdict** — your honest first call. The reviewer overwrites it.

Fill the self-verdict in *before* you look for reasons a row is fine. Your first
instinct about a shaky row is usually right.

## Rules

- **One row per asked-for thing.** If a single task had sub-steps with separate
  risks, split it into separate rows. A row that bundles four things hides three.
- **Fresh evidence only.** "It passed earlier" is not evidence that it passes
  now. If you changed anything after you last checked, you have not checked.
- **Evidence must be reproducible by someone else.** "I looked at it and it's
  right" is not evidence. "Rows 12–18 of the output, shown below" is.
- **Add rows for things nobody asked for.** Every item in the `Yours` bucket
  from `reconstructing-intent` gets its own row with an empty "Asked" column and
  a **Diverged (extra)** self-verdict. Let the reviewer rule on it. Omitting the
  row is the single most common way this gate gets quietly defeated.
- **A missing row is a finding.** If something was asked for and has no row, the
  answer is not "it was implied" — it is **Missing**.
- **Do not grade your own excuses.** "Kept it simple," "seemed useful," "would
  have taken too long" belong nowhere in the ledger. They are not evidence and
  they do not change a verdict.

## Getting Evidence You Don't Have

When you write a row and realize you have no evidence, you have three honest
options and one dishonest one.

| Situation | Do this |
|---|---|
| Evidence is obtainable now | Go get it. Run the thing, open the file, check the output. This is almost always the answer. |
| Obtainable but expensive | Get it anyway if the claim is load-bearing. Cost is not an exemption for a Required row. |
| Genuinely not obtainable by you | Mark the row **Unverifiable** and state exactly what evidence would settle it and who could get it. |
| — | ~~Assert it anyway with a hedge~~ — "should work" in an evidence column is a false row. |

An Unverifiable row is an honest outcome. It does not block completion, but it
must survive all the way into the final report — see `reporting-honestly`.

### Never supply a missing fact

The most dangerous gap is not the one you cannot verify. It is the one where the
work has a hole shaped like a specific fact — a URL, a deadline, a threshold, a
name, a contact, a version, a time — and you do not have that fact.

**When the fact is not in your sources, name the gap. Do not fill it.**

An invented specific is worse than a blank one. A blank is obviously incomplete
and someone fixes it. A plausible invention looks finished, gets shipped, and is
discovered by whoever relies on it.

| The hole | Fill it with |
|---|---|
| "see the handbook" — but where does it live? | "I don't know where the handbook is kept; this needs a real pointer before it goes out." |
| A process needs a lead time | the lead time you were told, or nothing — never a plausible-sounding one |
| A reference needs a link | a link you actually followed, or a named gap |
| A step needs an owner | the owner named in your sources, or "unassigned — who owns this?" |

The tell is writing a specific you cannot trace to a source. If you are about to
produce a value and cannot say where it came from, you are inventing it.

This applies to your own report as much as to the artifact. A number, a count,
or a filename in your report is a claim like any other.

## Common Mistakes

| Mistake | Why it fails |
|---|---|
| Evidence column restates the action | "I implemented it" describes the work, not proof of it. |
| Citing your own todo status | You set that. It is the claim, not the check. |
| Citing a run from before your last edit | Stale. Re-run. |
| One row for the whole task | Bundling hides the parts that failed. |
| Skipping rows for unrequested extras | This is how divergence ships. |
| "Tests pass" as evidence for a requirement | Tests prove behavior, not that the behavior is the one asked for. |
| Marking everything Matches on the first pass | If nothing is Diverged or Unverifiable, look harder — you are grading generously. |

## Red Flags - STOP

- An evidence cell containing "should", "presumably", "I believe", "looks right"
- Evidence you cannot point someone else to
- A row you would not want the asker to read
- Realizing you are writing the ledger to justify the work rather than test it

**Next:** hand the ledger to `adversarial-self-review`.
