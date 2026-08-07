# Porting to a New Harness

How to make these skills auto-trigger on an agent harness that isn't already
supported.

The integration mechanism differs per harness and keeps changing. This guide
teaches the **invariants** and points at a live reference implementation to
copy. Where this guide and the code disagree, the code wins — fix the guide.

## Part 1 — How this works everywhere

The content is the same on every harness. What changes is the thin layer that
delivers it and translates its instructions into real tool names.

1. **Skills (harness-agnostic).** Everything in `skills/` is the source of
   truth. Skills describe *actions* — "invoke a skill", "read a file", "dispatch
   a subagent", "create a todo" — and never name a specific tool. That is what
   lets one skill body run everywhere.

2. **Tool mapping (per-harness).** The action vocabulary translated into real
   tool names, in
   `skills/using-what-have-i-done/references/<harness>-tools.md` and/or inline in
   the harness's bootstrap injector.

3. **Bootstrap (per-harness).** At the start of every session, the full
   `skills/using-what-have-i-done/SKILL.md` goes into the model's context,
   wrapped in `<EXTREMELY_IMPORTANT>` tags, with the tool mapping and a note that
   the skill is already loaded. **The bootstrap is the entire integration.**
   Without it the skill files are inert.

### Two rules

**1. Skills name actions, not tools.** Do not edit skill bodies to fit your
harness. A port adds a tool mapping and a bootstrap injector; it never reaches
into `skills/*/SKILL.md` to swap tool names. If you find yourself doing that,
the fix belongs in the mapping.

**2. Ship through the harness's own install mechanism. Never edit the user's
files.** The bootstrap, the skills, and the mapping all arrive as part of what
the harness installs. A port must not write into a user's global config
(`settings.json`, a personal `AGENTS.md`, `~/.bashrc`). The harness owns what it
loads; your install artifact is the only thing you get to write.

## Part 2 — Can this harness be supported?

### Hard requirement: automatic session-start injection

The harness must let you inject text into the model's context **at the start of
every session, with no per-session opt-in.** This is non-negotiable. It can be:

- a **hook system** that runs a shell command at session start and reads its
  stdout, or
- an **in-process plugin** with a lifecycle callback that can mutate the message
  array, or
- an **instructions file** that *your installed extension ships and declares*.

If the only way to get the bootstrap in front of the model is for the user to opt
in each session, the acceptance test will fail and the harness cannot be properly
supported. This is the most common reason a "port" isn't one.

### Everything else

| Capability | Needed for | If absent |
|---|---|---|
| Skill discovery + invocation | Loading a skill's content on demand | If there is no skill tool, the sanctioned fallback is reading `SKILL.md` directly. Say so in the mapping. |
| File read | Nearly every skill | Essential. |
| Run a shell command | Gathering evidence | Essential — without it, most evidence is unobtainable. |
| Subagent dispatch | `adversarial-self-review` | Degradable: the skill has an explicit in-session fallback. Never invent a dispatch call. |
| Todo tracking | Ledger and checklists | Degradable: a file works. |

## Part 3 — Definition of done

1. The bootstrap loads at session start, every session, no opt-in.
2. A tool mapping exists for the harness.
3. Skills can be invoked — natively, or via the documented read-`SKILL.md`
   fallback — and the model follows them.
4. **The acceptance test passes** (Part 6). Capture the transcript.
5. `tests/run-all.sh` passes, with coverage for the new integration.
6. A real user can install it through the harness's own command.

Quick smoke check first: start a session and ask the model what it does before
telling you a task is done. If the bootstrap injected, it describes the gate.

## Part 4 — Pick an integration shape

**Find the harness's actual mechanism first.** Search its current docs; read an
existing third-party plugin for it (a working example beats docs); check what it
loads at startup. If it's underdocumented, reverse-engineer: grep the install
tree for hook event names, ask the running model to list the exact machine names
of every tool it can call, and prove every assumption with a **unique-marker
test** — inject a nonsense token through the mechanism you think works, start a
fresh session, and confirm the token reached the model.

**A fork does not inherit its parent's behavior.** A harness derived from another
may accept the parent's manifest fields and include syntax and still not honor
them. Verify with a marker.

| If the harness… | Shape | Copy from |
|---|---|---|
| runs a shell command at session start and reads stdout | **A — shell hook** | `hooks/session-start`, `hooks/hooks-cursor.json`, `.cursor-plugin/` |
| is a JS/TS plugin host with lifecycle callbacks | **B — in-process** | `.opencode/plugins/` (has a skill tool) or `.pi/extensions/` (has none) |
| always loads an extension-declared context file | **C — instructions file** | `gemini-extension.json` + `GEMINI.md` + `references/gemini-tools.md` |

Shapes compose. Skill *discovery* and *bootstrap delivery* need not use the same
one — but both must ride the install mechanism.

> **A hook *system* is not a session-start *event*.** A harness can have a
> hooks mechanism, and even contain the string `SessionStart` in its binary,
> while exposing no session-start event that can inject context. Confirm the
> specific event exists before committing to Shape A.

## Part 5 — The procedure

### Shape A — shell hook

`hooks/session-start` reads the bootstrap skill, wraps it, escapes it, and prints
JSON. **The field name and nesting differ per harness, and getting it wrong fails
silently.** Three branches exist today:

| Harness | Detected by | Emits |
|---|---|---|
| Cursor | `CURSOR_PLUGIN_ROOT` | `{"additional_context": "…"}` |
| Claude Code | `CLAUDE_PLUGIN_ROOT` and no `COPILOT_CLI` | `{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "…"}}` |
| Copilot CLI / SDK standard | otherwise | `{"additionalContext": "…"}` |

Emit **exactly one**. Claude Code reads both `additional_context` and
`hookSpecificOutput` without de-duplicating, so emitting two double-injects.

Add a fourth branch, or a dedicated `hooks/session-start-<harness>` if the
harness needs different wording. **If your harness also sets an env var an
earlier branch keys on, order your branch before it** — that is why the Cursor
branch is first.

The hook-config schema also varies: compare `hooks/hooks.json` (Claude Code:
`matcher`, `type`, `shell`, `async`, `${CLAUDE_PLUGIN_ROOT}`) against
`hooks/hooks-cursor.json` (`"version": 1`, lowercase `sessionStart`, relative
command, none of those fields). Match whichever is closest, not a template.

Wrong matcher strings mean the hook silently never fires. Get them from the
harness's docs, or empirically: register a throwaway hook that dumps its
environment and emits a marker.

### Shape B — in-process plugin

Read the bootstrap skill, strip its YAML frontmatter, and assemble
`<EXTREMELY_IMPORTANT>` + a note that the skill is already loaded + the body +
the inline tool mapping. Inject it as a **user-role message**, not a system
message.

Three things to replicate:

- **Dedup guard.** The callback fires repeatedly — OpenCode's transform runs on
  every agent step, Pi's `context` on every turn. Check for a marker before
  injecting. Cache the content at module level so you are not re-reading
  `SKILL.md` each time.
- **Compaction.** Re-inject after compaction. Pi sets a flag on `session_start`
  and `session_compact`, clears it on `agent_end`, and inserts after any leading
  compaction-summary messages.
- **Message shape is per-harness.** Pi builds
  `{ role, content: [{ type, text }], timestamp }`; OpenCode manipulates
  `message.info.role` and `message.parts[]`. Copying a reference's object literal
  verbatim fails silently. Find yours.

If your harness has no skill tool, use Pi's wording ("do not try to load it
again") rather than OpenCode's ("do not use the skill tool") — and say plainly
in the mapping that reading `SKILL.md` is the blessed path there.

### Shape C — instructions file

There is no injector: assemble nothing, strip nothing. The context file your
extension ships pulls in the bootstrap skill and the tool mapping. `GEMINI.md`
does it with two `@`-includes; the harness loads them raw, frontmatter and all.

**Prove the include is actually expanded.** A Gemini-derived harness can accept
`@./path` syntax and treat it as a hint the model *may* read — emitting a
file-read tool call — rather than a guaranteed inline expansion. Run a
unique-marker test: if the marker is not in context *without* a tool call,
inline the content instead of including it.

### Tool mapping

Cover every action: read a file; create/edit/delete a file; run a shell command;
search contents and find files; fetch a URL; **dispatch a subagent** (including
how the agent type is passed and any config flag that enables it); **create and
update todos**; **invoke a skill**.

**Get the real tool names from the harness. Never invent them.** If the docs
don't list them, ask the running model to list the exact machine names of every
tool it can call.

Where the mapping lives depends on shape: Shape A → `references/` only; Shape B →
inline in the injected string, and Pi keeps it in `references/` too (update both
or the port is half-done); Shape C → `references/`, pulled into the context file.

Add a line for your harness to the "Platform Adaptation" section of
`skills/using-what-have-i-done/SKILL.md`. That section is a pointer list, so it
is the one edit to a skill body a port may make. Touch nothing else.

## Part 6 — Verify

You cannot confirm a port by reading code.

**Automated.** Add to `tests/`: Shape A → assert the hook's stdout has exactly
the field your harness reads and not the others (extend
`tests/test-session-start.sh`). Shape B → a unit test with a faked plugin API
asserting the handlers register, the bootstrap injects once, and the dedup guard
holds (see `tests/opencode-plugin.test.mjs`).

**Live.** Install locally, restart the harness, and drive a real session. Most
harnesses are interactive TUIs that can't be driven by piping stdin, so run one
inside a detached tmux session:

```bash
mkdir -p /tmp/port-smoke
tmux new-session -d -s port-test -c /tmp/port-smoke '<harness-launch-command>'

# Real TUIs take longer to initialize than you expect. Capture BEFORE typing:
# first-run onboarding and "trust this folder?" are modal, and keystrokes sent
# during them select menu items instead of typing your prompt.
sleep 12
tmux capture-pane -t port-test -p

# Send text and Enter as SEPARATE calls with a beat between them; sending them
# together races on some TUIs. "Enter" is a key name, not "\n".
tmux send-keys -t port-test 'What do you do before telling me a task is done?'
sleep 0.4; tmux send-keys -t port-test Enter
sleep 5; tmux capture-pane -t port-test -p     # should describe the gate

# Acceptance test: a small multi-step task, then poll until the turn finishes.
tmux send-keys -t port-test 'Rename the two functions in notes.txt and tell me when done'
sleep 0.4; tmux send-keys -t port-test Enter
sleep 10; tmux capture-pane -t port-test -p    # PASS = review before "done"

tmux capture-pane -t port-test -p > /tmp/port-smoke/transcript.txt
tmux kill-session -t port-test
```

If the smoke check shows the model doesn't know about the gate, the bootstrap
isn't loading. Fix that before bothering with the acceptance test.

## Gotchas that have bitten porters

- **Opt-in isn't a port.** If the user must do anything per session, re-read
  Part 2.
- **Wrong JSON field → silent failure; two fields → double injection.** Shape A.
- **Hook-config schema varies per harness.** Match the closest existing file.
- **Plugin-root env var differs per harness.** The script re-derives the root
  itself; the *manifest command* is what needs the right variable.
- **Inject a user message, not a system message.** Shape B. Repeated system
  messages bloat tokens and break some models.
- **Per-step vs per-turn callbacks.** Copying one harness's dedup strategy onto
  the other's callback frequency breaks injection.
- **A plugin installer may silently strip undeclared files.** Make the bootstrap
  a component the installer recognizes — never a user-config edit.
- **Hunting for a skill-registration API that doesn't exist.** A harness with no
  skill system has nothing to register; the model reads `SKILL.md` on demand.
- **Keep hook scripts extensionless.** Some Windows handling prepends `bash` to
  any command containing `.sh`, which double-invokes.
- **Editing skill bodies to fit the harness.** Never. The fix goes in the mapping.

## Windows

Only relevant to Shape A. `hooks/run-hook.cmd` is a polyglot: valid as both a
Windows batch script and a Unix shell script. On Windows, `cmd.exe` runs the
batch portion, which locates bash (Git for Windows, then bash on PATH) and runs
the named hook; if no bash is found it exits cleanly so the harness still works,
just without injection. On Unix the leading `:` makes the batch block a no-op.

Keep hook scripts extensionless, and don't write per-OS variants — one bash
script plus the wrapper covers all three platforms.

## Reference integrations

| Harness | Entry point | Bootstrap | Mapping |
|---|---|---|---|
| Claude Code | `.claude-plugin/plugin.json` + `hooks/hooks.json` | hook → `hookSpecificOutput.additionalContext` | none needed |
| Cursor | `.cursor-plugin/plugin.json` + `hooks/hooks-cursor.json` | hook → `additional_context` | none needed |
| Copilot CLI | shares the Claude Code hook path | hook → `additionalContext` | none needed |
| Codex | `.codex-plugin/plugin.json` (empty `hooks`) | native skill discovery, no hook | `references/codex-tools.md` |
| OpenCode | `.opencode/plugins/*.js` via `package.json` `main` | in-process user-message injection | inline + `references/opencode-tools.md` |
| Pi | `.pi/extensions/*.ts` via `package.json` `pi` field | in-process, compaction-aware | inline + `references/pi-tools.md` |
| Gemini CLI | `gemini-extension.json` + `GEMINI.md` | context file `@`-includes | `references/gemini-tools.md` |
