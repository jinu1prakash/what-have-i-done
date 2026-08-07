# Gemini CLI Tool Mapping

Skills in this library name **actions** ("dispatch a subagent", "create a todo",
"read a file"). On Gemini CLI those actions resolve to the tools below.

| Action a skill requests | Gemini CLI equivalent |
|---|---|
| Read a file | `read_file` |
| Read several files at once | `read_many_files` |
| Create a new file | `write_file` |
| Edit a file | `replace` |
| Run a shell command | `run_shell_command` |
| Search file contents | `grep_search` |
| Find files by name | `glob` |
| List a directory | `list_directory` |
| Fetch a URL | `web_fetch` |
| Search the web | `google_web_search` |
| Invoke a skill | `activate_skill` |
| Dispatch a subagent (`Subagent (general-purpose):` template) | `invoke_agent` with `agent_name: "generalist"` |
| Several dispatches in parallel | multiple `invoke_agent` calls in one response |
| Create / update todos | `write_todos` |

## Dispatching the reviewer

`adversarial-self-review` provides
[`reviewer-prompt.md`](../../adversarial-self-review/reviewer-prompt.md) with
placeholders — `[RECONSTRUCTED_INTENT]`, `[EVIDENCE_LEDGER]`, and the rest.
Fill every placeholder first, then pass the completed prompt to `invoke_agent`
as `agent_name: "generalist"`. The template carries the reviewer's role, review
criteria, and required output format; the subagent follows it.

`@generalist <prompt>` in chat is equivalent to the same `invoke_agent` call.

## Instructions file

Where a skill says "your instructions file", on Gemini CLI that is `GEMINI.md`.
Gemini loads it hierarchically: global at `~/.gemini/GEMINI.md`, then project and
ancestor directories.

This extension ships its own `GEMINI.md`, declared by `contextFileName` in
`gemini-extension.json`, and that file is what loads the bootstrap. It is part of
the installed extension — nothing here edits a `GEMINI.md` in your home
directory.

## Personal skills directory

User-level skills live at `~/.gemini/skills/`, with `~/.agents/skills/` as a
cross-runtime alias. Where both exist at the same scope, `.agents/skills/` wins.
