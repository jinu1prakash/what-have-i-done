# Codex Tool Mapping

Skills in this library name **actions** ("dispatch a subagent", "create a todo",
"read a file"). On Codex those actions resolve to the tools below.

| Action a skill requests | Codex equivalent |
|---|---|
| Read a file | Codex's file-read tool |
| Create / edit a file | `apply_patch` |
| Run a shell command | Codex's shell tool |
| Search file contents / find files by name | shell `rg` / `find` |
| Invoke a skill | Codex loads skills natively — invoke by name |
| Dispatch a subagent (`Subagent (general-purpose):` template) | Codex's agent/task tool, **if multi-agent is enabled** |
| Create / update todos | Codex's built-in todo tool |

## No session-start hook

Codex surfaces installed skills natively and runs **no** session-start hook.
`.codex-plugin/plugin.json` therefore declares `"hooks": {}` on purpose — that
empty object suppresses auto-discovery of `hooks/hooks.json`, which is written
for a different harness's contract. Do not add a Codex hooks file; the skills'
own descriptions are what surface them here.

This makes the trigger softer than on a harness that injects the bootstrap every
session. The practical consequence: run the acceptance test in
[`INSTALL.md`](../../../INSTALL.md) on Codex specifically rather than assuming
behavior carries over from another harness.

## Subagents

Codex gates subagent dispatch behind a multi-agent configuration flag. If it is
not enabled, `adversarial-self-review` has an explicit fallback: switch hats
in-session using the discipline in that skill, and say in your report that the
review ran in-session. Do not fabricate a dispatch call.

## Skills directory

Codex reads the `"skills": "./skills/"` path from the plugin manifest. Personal
skills live in Codex's own skills directory, with `~/.agents/skills/` recognized
as a cross-runtime alias.
