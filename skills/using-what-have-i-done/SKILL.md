---
name: using-what-have-i-done
description: Use when starting any conversation - establishes the completion gate and how to reach the skills that enforce it, before any response including clarifying questions
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute one specific task, skip this
skill. Report your result to whoever dispatched you; the gate runs there.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
You do not get to decide that your work is finished. Evidence decides.

Before you tell anyone a task is done, complete, fixed, finished, working,
shipped, ready, or handled — and before you summarize a to-do list whose items
have all flipped to complete — you MUST invoke the `what-have-i-done` skill and
follow it.

This is not optional and you cannot rationalize your way out of it. If there is
even a 1% chance it applies, invoke it.
</EXTREMELY-IMPORTANT>

## The Rule

**Completion is a gate, not a feeling.** You pass through it by invoking
`what-have-i-done`, not by being confident.

Announce it plainly — "Running the completion gate before I call this done" —
then follow the skill exactly. If a skill has a checklist, create one task per
item.

This applies to every kind of work, not just code: a document, a dataset, a
research answer, a config change, a deploy, a design, a plan, a refactor, an
email you drafted. If you produced something and are about to hand it back, the
gate applies.

## The Skills

| Skill | Invoke it when |
|---|---|
| `what-have-i-done` | You are about to claim any work is done. **This is the entry point** — it orchestrates the rest. |
| `reconstructing-intent` | You need to establish what was *actually* asked, in the asker's own words |
| `building-evidence-ledgers` | You need to turn claims into a table of claim → concrete evidence |
| `adversarial-self-review` | You need the work judged by a skeptic instead of by its maker |
| `closing-the-review-loop` | A review returned findings and you must rework and re-review |
| `reporting-honestly` | The gate has passed and you are writing the actual completion message |
| `writing-review-skills` | You are creating or editing a skill in this library |

In the normal flow you invoke `what-have-i-done` and it pulls in the others.
Invoke a sub-skill directly when you need only that piece.

## Red Flags

These thoughts mean STOP — you are rationalizing your way past the gate:

| Thought | Reality |
|---|---|
| "I just did it, I know it works" | Knowing is not evidence. Run the gate. |
| "All my todos say completed" | A status you set yourself is a claim, not a check. |
| "It's basically what they asked" | "Basically" is exactly where divergence hides. |
| "The gate is overkill for this" | Small tasks are where unchecked drift ships. |
| "I'll just tell them and they can correct me" | Your job is to know before they do. |
| "I'm out of time / this session is long" | Fatigue is not an exemption. |
| "Reviewing my own work is redundant" | The maker is the worst judge of the making. |
| "I remember what that skill says" | Skills change. Load the current one. |
| "I'll run the gate after I reply" | The reply IS the claim. Gate first. |

## Skill Priority

If other skills also apply, they decide *how to do the work*. This library
decides *whether the work is finishable*. It runs last, and it runs regardless
of which other skills were used.

## Platform Adaptation

These skills name **actions** — "read a file", "dispatch a subagent", "create a
todo" — never one runtime's tool names, so the same text works everywhere. If
your harness is listed here, read its reference file for the translation:

- Codex: `references/codex-tools.md`
- Gemini CLI: `references/gemini-tools.md`
- OpenCode: `references/opencode-tools.md`
- Pi: `references/pi-tools.md`

If a skill asks for a capability your harness lacks (commonly: subagents), the
skill says what to do instead. Use that fallback. Never invent a tool call.

## User Instructions Win

Explicit user instructions — in a project instructions file or said directly —
take precedence over these skills, which in turn override default behavior. If
your human partner says to skip the gate, skip it and say that you did.
