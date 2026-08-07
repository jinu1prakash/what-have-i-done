# Installing What Have I Done

The **skills** in `skills/` are identical on every harness. Only the **trigger
layer** — how the bootstrap gets injected at session start — differs.

| Harness | Trigger layer | Files |
|---|---|---|
| Claude Code | SessionStart hook | `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `hooks/hooks.json`, `hooks/run-hook.cmd`, `hooks/session-start` |
| Cursor | `sessionStart` hook | `.cursor-plugin/plugin.json`, `hooks/hooks-cursor.json`, `hooks/session-start` |
| GitHub Copilot CLI | SessionStart hook + `AGENTS.md` | `hooks/session-start`, `AGENTS.md`, `skills/` |
| Codex / Codex CLI | **none** — native skill discovery | `.codex-plugin/plugin.json`, `skills/` |
| OpenCode | in-process JS plugin | `.opencode/plugins/what-have-i-done.js`, `.opencode/INSTALL.md` |
| Pi | in-process TS extension | `.pi/extensions/what-have-i-done.ts`, `package.json` |
| Gemini CLI | extension-declared context file | `gemini-extension.json`, `GEMINI.md` |
| Anything else | any session-start context injection | `skills/using-what-have-i-done/SKILL.md`, `AGENTS.md` |

Make the scripts executable once after copying:

```bash
chmod +x hooks/run-hook.cmd hooks/session-start scripts/*.sh tests/*.sh
```

## Per-harness

**Claude Code.** Install as a local plugin. Point a marketplace at this folder
and install from it:

```bash
/plugin marketplace add /absolute/path/to/what-have-i-done
```

then `/plugin install what-have-i-done`. `hooks/hooks.json` is auto-discovered;
no `hooks` field in the manifest is needed.

**Cursor.** Add as a plugin. `.cursor-plugin/plugin.json` declares both
`skills` and `hooks`, and `hooks-cursor.json` runs the `sessionStart` hook.
Cursor reads `additional_context` (snake_case) rather than Claude Code's nested
`hookSpecificOutput` — `hooks/session-start` detects this from
`CURSOR_PLUGIN_ROOT` and emits the right one.

**GitHub Copilot CLI.** Install via your marketplace. Skills are auto-discovered
from the installed plugin and loaded with the `skill` tool; `AGENTS.md` makes the
trigger fire. Copilot CLI reads a top-level `additionalContext`, which the hook
emits when `COPILOT_CLI` is set.

**Codex / Codex CLI.** Install the plugin. Codex surfaces installed skills
natively and runs **no session-start hook** — `.codex-plugin/plugin.json`
declares `"hooks": {}` deliberately, to suppress auto-discovery of
`hooks/hooks.json`, which is written for a different harness's contract. Do not
add a Codex hooks file. See
[`skills/using-what-have-i-done/references/codex-tools.md`](skills/using-what-have-i-done/references/codex-tools.md).

Because nothing is injected here, the trigger is softer than elsewhere: it
depends on the agent acting on the `using-what-have-i-done` description it sees
in its skill index. Run the acceptance test on Codex specifically.

**OpenCode.** See [`.opencode/INSTALL.md`](.opencode/INSTALL.md).

**Pi.** `pi install git:<your-git-url>`, or `pi -e /path/to/this/package` for
local development. `package.json` registers both the extension and the skills
directory. Pi has no `Skill` tool — reading a `SKILL.md` with `read` *is* the
sanctioned way to load a skill there; see
[`references/pi-tools.md`](skills/using-what-have-i-done/references/pi-tools.md).

**Gemini CLI.** `gemini extensions install <path-or-repo>`. `GEMINI.md` is the
declared `contextFileName` and `@`-includes the bootstrap plus the Gemini tool
mapping. Gemini auto-discovers the bundled `skills/` directory, so the manifest
needs no `skills` field.

## Harnesses not listed above

Some agent runners have native skill *discovery* but no skill-loading tool, and
an installer that silently drops files its manifest doesn't declare. On those,
copying the Claude Code hook wiring is not enough — the bootstrap has to ride a
manifest-declared context file instead, or it vanishes at install time and the
gate never fires.

Do not assume a harness works because its plugin format looks familiar. Follow
[`docs/porting.md`](docs/porting.md), and prove the bootstrap reached the model
with a unique-marker test before adding a row to the table above.

## Any other harness

Two things are required:

1. **Make the skills discoverable.** Put `skills/` where your harness loads
   skills from, or have the agent read `skills/what-have-i-done/SKILL.md`
   directly.
2. **Inject the bootstrap at session start**, with no per-session opt-in.
   Whatever mechanism your harness has — a startup hook, a plugin lifecycle
   callback, an instructions file it always loads — point it at
   `skills/using-what-have-i-done/SKILL.md`.

Step 2 is the whole integration. Without it the skills are inert.

[`docs/porting.md`](docs/porting.md) covers how to pick an integration shape,
how to find your harness's exact contract, and how to prove the bootstrap
actually reached the model.

If your harness has no session-start mechanism at all, paste that file's
contents into its system prompt. The skills still work; they just will not
auto-trigger.

## Acceptance test

**Run this per harness. Passing on one proves nothing about another.**

In a clean session, give the agent a small multi-step task and let it finish.

- **Pass** — before saying "done" it re-reads your request, builds an evidence
  ledger, and reviews each step.
- **Fail** — it goes straight to "done."

On a failure, check in this order:

1. `skills/using-what-have-i-done/SKILL.md` exists in the *installed* copy.
2. The trigger-layer file for that harness is present and wired (table above).
3. For hook-based harnesses, run the hook by hand and confirm the JSON field:

   ```bash
   CLAUDE_PLUGIN_ROOT="$PWD" ./hooks/session-start
   ```

4. `./tests/run-all.sh` passes.

A quicker smoke check before the full test: ask the agent what it does before
telling you a task is done. If the bootstrap injected, it will describe the gate.
