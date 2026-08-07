# Bootstrap

The bootstrap is the **entire integration**. Without it the skills sit on disk
and are never invoked.

The bootstrap content is not stored here — it is
[`skills/using-what-have-i-done/SKILL.md`](skills/using-what-have-i-done/SKILL.md).
Keeping it in the skill file means there is exactly one copy: the harness
adapters all read that file, so no adapter can drift from the others.

## What every adapter does

At the start of every session, with no per-session opt-in, get the full contents
of `skills/using-what-have-i-done/SKILL.md` into the model's context, wrapped in
`<EXTREMELY_IMPORTANT>` tags, with a note that the skill is already loaded and
should not be loaded again.

| Harness | Adapter | Mechanism |
|---|---|---|
| Claude Code | `hooks/hooks.json` → `hooks/session-start` | shell hook, stdout JSON |
| Cursor | `hooks/hooks-cursor.json` → `hooks/session-start` | shell hook, stdout JSON |
| Copilot CLI | `hooks/session-start` (SDK-standard branch) | shell hook, stdout JSON |
| Codex | none — skills surface natively | see `references/codex-tools.md` |
| OpenCode | `.opencode/plugins/what-have-i-done.js` | in-process, injects a user message |
| Pi | `.pi/extensions/what-have-i-done.ts` | in-process, injects a user message |
| Gemini CLI | `GEMINI.md` (declared by `gemini-extension.json`) | extension-shipped context file |
| Copilot CLI, custom | `AGENTS.md` | instructions file |

## For a custom harness

Point whatever session-start context mechanism your harness has at
`skills/using-what-have-i-done/SKILL.md`. If it has none, paste that file's
contents into its system prompt — the skills still work, they just will not
auto-trigger.

Full instructions, including how to choose an integration shape and how to prove
it works: [`docs/porting.md`](docs/porting.md).
