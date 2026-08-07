# What Counts as Evidence

Evidence is an **observed fact** that someone else could re-observe. Everything
below is organized the same way: the claim you want to make, what actually
proves it, and the near-miss that feels like proof but isn't.

The near-miss column is the important one. Almost nobody writes "trust me" in an
evidence cell. People write the thing in the third column.

## Universal rules

1. **Fresh beats remembered.** If you changed anything since you last checked,
   you have not checked.
2. **Pointable beats described.** "The output below" beats "I confirmed it."
3. **The artifact beats the process.** "I ran the process correctly" is not
   evidence the artifact is correct.
4. **Absence needs evidence too.** "I didn't break anything" is a claim. What did
   you check?

---

## Software and code

| Claim | Evidence | Not evidence |
|---|---|---|
| Tests pass | Test command output run now: counts, 0 failures, exit code | "Should pass", a run from before your last edit |
| Build works | Build command, exit 0 | Linter passed; "no errors in the editor" |
| Bug is fixed | The original failing input now produces the correct output | "I changed the code that looked wrong" |
| Regression won't recur | Test fails when the fix is reverted, passes when restored | Test passes once |
| Feature exists | The diff plus a run exercising the new path | "I implemented it" |
| Nothing else broke | Full suite run, compared to a known baseline | Only the new tests were run |
| Performance improved | Before/after measurement, same conditions, stated method | "It should be faster now" |
| Subagent finished its task | The diff or artifact it produced, inspected by you | The subagent's own success report |

## Documents and prose

| Claim | Evidence | Not evidence |
|---|---|---|
| Covers every requested section | Section headings listed against the requested list | "I covered everything" |
| Matches the requested format | The output shown beside the requested format | "I followed the template" |
| Length/tone constraint met | The actual count, or the constraint quoted next to a sample | "It reads about right" |
| Facts are accurate | Each claim traced to its source | "It's consistent with what I know" |
| Edits were applied | Before/after of the changed passages | "I made the edits" |
| Nothing was lost in a rewrite | Old section list vs new; explicit note on anything dropped | The new version reads complete |

## Data and analysis

| Claim | Evidence | Not evidence |
|---|---|---|
| The number is right | The query/computation plus its output, and a second path to the same answer | One computation, unchecked |
| Data was cleaned | Row/column counts before and after, and what was dropped and why | "I cleaned it" |
| Nothing was silently dropped | Reconciliation: input rows = kept + dropped, with the drop reason | Output looks reasonable |
| The chart shows what I say | The chart plus the underlying numbers | The chart alone |
| Result is not an artifact of one choice | The result under a different reasonable choice | A single run |
| Joined correctly | Match rate, and inspection of unmatched keys | Row count went up |

## Research and factual answers

| Claim | Evidence | Not evidence |
|---|---|---|
| This is what the source says | Quote plus locator (page, section, URL, timestamp) | Your summary of it |
| I searched thoroughly | The queries run and what each returned, including empty results | "I looked into it" |
| No contradicting source exists | The specific counter-search you ran | You didn't happen to see one |
| The source is current | The document's own date, checked | It was the top result |
| The answer is complete | Each part of the question mapped to where it's answered | The answer feels complete |

## Operations, infrastructure, config

| Claim | Evidence | Not evidence |
|---|---|---|
| The change is live | Read the state back from the live system | The apply command exited 0 |
| The service is healthy | Health endpoint / metric observed after the change | "It deployed successfully" |
| Config is valid | Validator output, or the system loading it | "The syntax looks fine" |
| It's reversible | The rollback path, stated and ideally exercised | "We can always revert" |
| Permissions are right | The permission read back, and a negative test | You set it in the UI |
| No collateral impact | The dependent systems you checked, named | Nothing paged |

## Design and interface work

| Claim | Evidence | Not evidence |
|---|---|---|
| It matches the spec/mock | Side-by-side, with named deltas | "It looks like the mock" |
| It works at other sizes | Rendered at the other sizes, observed | The CSS has breakpoints |
| It's accessible | Contrast values, keyboard traversal, labels checked | "I used semantic elements" |
| The empty/error states work | Each state triggered and observed | The states are implemented |
| It works with real content | Rendered with real-length content | It works with placeholder text |

## Process claims (any domain)

| Claim | Evidence | Not evidence |
|---|---|---|
| I did every step | Per-step artifacts, one each | A completed checklist you ticked |
| I followed the plan | Plan items mapped to what was produced | "I worked from the plan" |
| A step was needed | The asker's words requesting it | "It seemed useful" |
| A constraint was honored | The constraint quoted next to the thing that honors it | You remember the constraint |
| I asked and they agreed | The exchange, quoted | "They seemed fine with it" |

---

## The three phrases that are never evidence

- **"Should"** — "should work", "should be fine". Marks a prediction.
- **"I "** + a verb about your own action — "I implemented it", "I checked it",
  "I made sure". Describes the work, not the result.
- **Anything about how it looks to you** — "looks right", "seems correct",
  "reads well". Your impression is what the review exists to test.

When one of these is the best you have, the row is **Unverifiable**. Write that
down. It is a legitimate outcome; pretending otherwise is not.
