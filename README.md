# What Have I Done

**A completion gate for AI agents.** The discipline of proving that finished
work is the *right* work, before ever saying "done."

Agents are good at finishing things and bad at noticing they finished the wrong
thing. The failure is predictable: the work drifts a little from the ask, the
agent's own todo list says complete, and the summary reports success — with the
divergence invisible until someone else finds it.

This package installs a set of skills that fire at exactly that moment, on
whichever agent harness you use.

## The loop

```
Reconstruct what was actually asked  (their words, not your summary)
        ↓
Ledger every step against evidence   (observed facts, not beliefs)
        ↓
Review it adversarially              (a skeptic, not its maker)
        ↓
Rework what diverged                 (fix the work, not the verdict)
        ↓
Report — with the evidence, and with what you could not verify
```

**This is not a coding tool.** It gates *claims*, so it works the same for a
document, a dataset, a research answer, a config change, a deploy, or a design.
The evidence taxonomy covers all of them.

## The skills

| Skill | Fires when |
|---|---|
| **using-what-have-i-done** | Session start. The bootstrap — this is what makes the rest actually trigger. |
| **what-have-i-done** | You are about to claim work is done. The entry point; orchestrates the rest. |
| **reconstructing-intent** | You need what was *actually* asked, sorted into required / constraint / implied / yours |
| **building-evidence-ledgers** | You need claims turned into a table of claim → concrete proof |
| **adversarial-self-review** | The work needs judging by a skeptic instead of by its maker |
| **closing-the-review-loop** | A review returned findings and they must be fixed, not argued with |
| **reporting-honestly** | The gate passed and you are writing the message that hands work back |
| **writing-review-skills** | You are adding to or editing this library |

Each is a directory under [`skills/`](skills/) with a `SKILL.md`. Skills name
**actions** — "dispatch a subagent", "read a file" — never one runtime's tool
names, which is what lets the same text run everywhere.

## Why the bootstrap matters

A skill folder on its own is dead weight: present on disk, never invoked. What
makes skills fire is a **bootstrap injected at session start** that tells the
agent the gate exists and is mandatory.

Every harness injects that differently, which is why there is an adapter per
harness. They all inject the same file —
[`skills/using-what-have-i-done/SKILL.md`](skills/using-what-have-i-done/SKILL.md)
— so no adapter can drift from the others.

## Install

See [INSTALL.md](INSTALL.md) for full commands. Quick reference:

| Harness | Mechanism |
|---|---|
| Claude Code | plugin; `hooks/hooks.json` auto-loads the session-start hook |
| Cursor | plugin; `hooks/hooks-cursor.json` runs `sessionStart` |
| Codex / Codex CLI | plugin; skills surface natively (**no hook** — by design) |
| GitHub Copilot CLI | plugin; `AGENTS.md` + auto-discovered `skills/` |
| OpenCode | JS plugin — see [`.opencode/INSTALL.md`](.opencode/INSTALL.md) |
| Pi | TS extension, declared in `package.json` |
| Gemini CLI | extension; `GEMINI.md` is the declared context file |
| Anything else | point session-start injection at the bootstrap — see [docs/porting.md](docs/porting.md) |

Each row means the wiring is present and its artifacts are tested. It does not
mean the acceptance test has been run on that harness — run it yourself, per
harness, before relying on it.

After copying, make the hook scripts executable once:

```bash
chmod +x hooks/run-hook.cmd hooks/session-start scripts/*.sh tests/*.sh
```

## Acceptance test

The only test that matters. In a **clean session**, give the agent a small
multi-step task and let it finish.

**Pass:** before saying "done", it re-reads your request, builds an evidence
ledger, and reviews each step.

**Fail:** it goes straight to "done." The bootstrap is not loading for that
harness — recheck its trigger-layer files in [INSTALL.md](INSTALL.md).

Run it per harness. A pass on one proves nothing about another.

## Tests

```bash
./tests/run-all.sh
```

Covers: the hook's JSON shape for each harness (and that it emits exactly one
field), manifest validity and version lockstep, skill frontmatter and
portability, link resolution, the in-process adapters, and that the package
contains no absolute paths or references to other projects.

## Contributing

Read [CLAUDE.md](CLAUDE.md) first — it holds the rules that keep this working
across harnesses. Then use the `writing-review-skills` skill; it is the
methodology for changing anything under `skills/`.

## License

[MIT](LICENSE)
