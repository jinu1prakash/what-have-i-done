---
name: writing-review-skills
description: Use when creating a new skill for this library, editing an existing one, or verifying that a skill actually changes agent behavior before shipping it
---

# Writing Review Skills

## Overview

A skill is not documentation. It is behavior-shaping text that has to work on an
agent under pressure — tired, out of context, mid-task, and looking for a reason
to skip the step. Text that reads well and changes nothing is the default
outcome, not the exception.

**Core principle:** If you did not watch an agent fail without the skill, you do
not know whether the skill teaches the right thing.

**REQUIRED BACKGROUND:** this library exists to enforce evidence before claims.
A skill you have not tested is a claim without evidence. The same rule applies
to the thing enforcing the rule.

## The Iron Law

```
NO SKILL WITHOUT A BASELINE FAILURE YOU ACTUALLY OBSERVED
```

Applies to new skills and to edits. Wrote it before testing? Delete it and start
from the baseline. Not for "a small addition," not for "just a section," not for
"a documentation fix." Do not keep the untested draft as reference. Delete means
delete.

## Skill Anatomy

```
skills/
  skill-name/
    SKILL.md              # required
    supporting-file.md    # only for heavy reference or a reusable template
```

Frontmatter, two required fields, under 1024 characters total:

```yaml
---
name: skill-name
description: Use when [triggering conditions and symptoms]
---
```

`name` uses lowercase letters, numbers, and hyphens, and matches the directory.

### The description rule

**The description states when to invoke the skill. It never summarizes what the
skill does.**

This is the single highest-leverage line in a skill and the easiest to get
wrong. A description that summarizes the workflow becomes a shortcut: the agent
reads the summary, believes it has the gist, and never opens the body. A skill
whose body describes a four-step loop, with a description that says "reviews the
work," reliably produces one review.

```yaml
# BAD — summarizes the process; the agent will follow this instead of the skill
description: Use at completion - build a ledger, dispatch a reviewer, then loop

# BAD — first person
description: I help you check your work before saying it's done

# BAD — describes the skill rather than the trigger
description: A discipline for evidence-backed self-review

# GOOD — triggering conditions only
description: Use when a to-do list has just gone all-complete, or any work is
  about to be reported as done, fixed, finished, shipped, ready, or working
```

Write in third person. Lead with "Use when". Name concrete symptoms and
situations. Keep it technology-agnostic unless the skill genuinely is not.

## Match the Form to the Failure

Classify the baseline failure before choosing a form. The form that fixes one
failure type measurably backfires on another.

| Baseline failure | Right form | Wrong form |
|---|---|---|
| Knows the rule, skips it under pressure | Iron Law + rationalization table + red flags | Soft guidance ("prefer", "consider") |
| Complies, but the output has the wrong shape — buried caveats, bloated prose, missing sections | Positive contract: state what the output **is**, its parts, in order | Prohibition list ("don't bury", "never omit") |
| Omits a required element from something they already produce | Structural: a REQUIRED slot in the template they fill | Prose reminders near the template |
| Behavior should vary by situation | A conditional keyed to something observable | Unconditional rule plus exemption clauses |

**Why prohibitions backfire on shaping problems.** Under a competing incentive,
an agent negotiates with "don't X" — and a negotiated prohibition produces more
of the unwanted content than saying nothing at all. A contract leaves nothing to
negotiate: the output matches the stated shape or it does not.

`reporting-honestly` is the worked example in this library. Its failure mode is
shape, so it is written as a five-part contract with no prohibition list.
`what-have-i-done` and `closing-the-review-loop` are discipline failures, so
they carry Iron Laws and rationalization tables.

**Two rules whichever form you choose:**

- **No nuance clauses.** "Do X unless it doesn't matter" reopens the
  negotiation. A real exception is its own conditional on an observable
  predicate.
- **Exemption clauses do not scope.** "This limit doesn't apply to code blocks"
  still suppresses code blocks. Restructure so the rule cannot reach the exempt
  part.

## Bulletproofing Against Rationalization

For discipline skills only.

**Close loopholes by name.** "Delete it" invites "but I'll keep it as
reference." Say: *Delete it. Start over. Don't keep it as reference, don't adapt
it, don't look at it. Delete means delete.*

**Cut off spirit-versus-letter early.** State it once, near the top:
*Violating the letter of this rule is violating the spirit of this rule.*

**Build the rationalization table from real baselines.** Every excuse an agent
actually produced goes in, in its own words, with the counter next to it.
Invented excuses are weaker than observed ones — an agent recognizes its own
phrasing.

**Give a red-flags list.** Short, scannable, phrased as thoughts rather than
rules, so an agent can catch itself mid-rationalization.

## RED-GREEN-REFACTOR for Skills

### RED — observe the failure

Run the pressure scenario with a subagent, **without** the skill. Record what it
actually did and the exact words it used to justify it. Combine pressures for
discipline skills: time, sunk cost, authority, exhaustion, a plausible shortcut.

If the baseline does not fail, stop. There is nothing to fix and the skill will
only add tokens.

### GREEN — write the minimum

Address the specific rationalizations you observed. Nothing for hypothetical
cases. Re-run the same scenarios with the skill present.

### REFACTOR — close what opened

New rationalization? Add its counter. Re-test until it holds.

### Micro-test the wording first

Pressure scenarios are the final gate but are slow per iteration. Test wording
cheaply first — see
[testing-skills-with-subagents.md](testing-skills-with-subagents.md).

## Conventions for This Library

- **Skills name actions, never tools.** "Dispatch a subagent", "read a file",
  "create a todo". Tool names live in
  `skills/using-what-have-i-done/references/<harness>-tools.md`. If you find
  yourself editing a skill body to make a harness work, the fix belongs in the
  mapping instead.
- **Domain-neutral by default.** This library gates *claims*, not code. Every
  table that carries a code example carries a non-code one too. If a skill only
  makes sense for software, it is in the wrong library.
- **Cross-reference by skill name.** `` `building-evidence-ledgers` ``. Never
  `@`-include another skill — that force-loads it and burns context before it is
  needed.
- **Flowcharts only for non-obvious decisions** or loops you might exit early.
  Reference material is a table. Linear steps are a numbered list.
- **One excellent example** beats five mediocre ones in five formats.
- **Token discipline.** `using-what-have-i-done` is injected into every session:
  keep it tight. Other skills should stay under ~800 words of body.

## Checklist

Create one task per item.

**RED**
- [ ] Pressure scenario written (3+ combined pressures for a discipline skill)
- [ ] Run without the skill; baseline behavior recorded verbatim
- [ ] Rationalizations extracted from what the agent actually said

**GREEN**
- [ ] `name` is lowercase-hyphenated and matches the directory
- [ ] Frontmatter has `name` and `description`, under 1024 characters
- [ ] Description starts with "Use when", third person, triggers only, no
      workflow summary
- [ ] Form matches the baseline failure type
- [ ] Addresses the observed failures specifically
- [ ] Actions named, not tools
- [ ] Carries at least one non-code example
- [ ] Re-run with the skill; agent now complies

**REFACTOR**
- [ ] New rationalizations countered
- [ ] Rationalization table built from real runs
- [ ] Red-flags list present (discipline skills)
- [ ] Re-tested until it holds

**SHIP**
- [ ] Listed in `using-what-have-i-done`'s skill table if it is a top-level entry
- [ ] Cross-references resolve
- [ ] `tests/run-all.sh` passes

## Anti-Patterns

| Anti-pattern | Why |
|---|---|
| Narrative ("in one session we found...") | Too specific to reuse |
| The same example in five languages | Five mediocre examples, five things to maintain |
| Code inside a flowchart node | Cannot be copied, hard to read |
| Generic node labels (`step1`, `helper2`) | Labels should carry meaning |
| Batch-writing several skills, testing later | Untested skills are untested code |
| Editing a skill body to fit one harness | The fix belongs in the tool mapping |
