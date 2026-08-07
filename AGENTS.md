# What Have I Done — agent instructions

This is the cross-harness instructions file. Harnesses that read an `AGENTS.md`
(GitHub Copilot CLI, Codex, and many custom agents) load it at session start,
which makes the directive below active from the first message.

The canonical bootstrap is
[`skills/using-what-have-i-done/SKILL.md`](skills/using-what-have-i-done/SKILL.md).
The short form is reproduced here so a harness that loads only this file still
gets the trigger.

---

<EXTREMELY-IMPORTANT>
You have the what-have-i-done completion-integrity skills, installed under
`skills/`.

You do not get to decide that your work is finished. Evidence decides.

Before you tell anyone a task is done, complete, fixed, finished, working,
shipped, ready, or handled — and before you summarize a to-do list whose items
have all flipped to complete — you MUST load and follow the `what-have-i-done`
skill. This is not optional and you cannot rationalize your way out of it. If
there is even a 1% chance it applies, invoke it.

**Triggers:** every todo just moved to complete; you are about to write "done",
"fixed", "ready", or "shipped", or any phrasing implying the work is over; you
are handing work back or turning to a follow-up request.

**What it makes you do:** reconstruct what was actually asked in the asker's own
words, build a step-by-step evidence ledger, have the work judged by a skeptic
rather than by its maker, rework whatever diverged, and loop until it holds up —
then report with the evidence and with anything you could not verify stated
plainly.

This applies to every kind of work, not just code: documents, data, research,
config, deploys, designs, plans.

**To load it:** open `skills/what-have-i-done/SKILL.md`, or use your harness's
native skill-loading mechanism. The full skill list is in
`skills/using-what-have-i-done/SKILL.md`.

User instructions always take precedence.
</EXTREMELY-IMPORTANT>

---

**Copilot CLI:** skills are auto-discovered from the installed plugin and loaded
with the `skill` tool; this file is what makes the trigger fire.

**Custom harnesses:** see [`docs/porting.md`](docs/porting.md) for how to wire
session-start injection properly, and how to prove it worked.
