# Pi Tool Mapping

Skills in this library name **actions** ("dispatch a subagent", "create a todo",
"read a file"). On Pi those actions resolve to the tools below.

| Action a skill requests | Pi equivalent |
|---|---|
| Read a file | `read` |
| Create a file | `write` |
| Edit a file | `edit` |
| Run a shell command | `bash` |
| Search file contents / find files / list a directory | `grep`, `find`, `ls` (when installed) |
| Invoke a skill | **read the skill's `SKILL.md` with `read`** — see below |
| Dispatch a subagent (`Subagent (general-purpose):` template) | an installed subagent tool, if one is present |
| Create / update todos | an installed todo tool, otherwise a plan file or `TODO.md` |

## Loading a skill on Pi

Pi discovers skills natively but does not expose a tool for loading one. Here,
**reading `SKILL.md` with `read` is the sanctioned mechanism** — it is how you
load a skill on this harness, not a workaround. When the bootstrap tells you to
invoke `what-have-i-done`, read
`skills/what-have-i-done/SKILL.md` and follow it.

The extension registers this package's `skills/` directory through
`resources_discover`, so the files are where Pi expects them.

## Subagents

Pi core ships no standard subagent tool; `pi-subagents` provides one and is a
good optional companion. If no subagent tool is installed, `adversarial-self-review`
has an explicit fallback: switch hats in-session using the discipline in that
skill, and record in your report that the review ran in-session rather than as a
fresh reviewer. Do not fabricate a dispatch call.

## Task lists

Pi core ships no standard task-list tool. If a todo extension is installed, use
its tool. Otherwise track the evidence ledger in a repo-local file — a plain
markdown table in `TODO.md` or a scratch file is fine. The ledger's value is in
its content, not in which tool holds it.
