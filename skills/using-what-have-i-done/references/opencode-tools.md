# OpenCode Tool Mapping

Skills in this library name **actions** ("dispatch a subagent", "create a todo",
"read a file"). On OpenCode those actions resolve to the tools below.

| Action a skill requests | OpenCode tool |
|---|---|
| Read a file | `read` |
| Create / edit / delete a file | `apply_patch` |
| Run a shell command | `bash` |
| Search file contents | `grep` |
| Find files by name | `glob` |
| Fetch a URL | `webfetch` |
| Invoke a skill | native `skill` tool |
| Dispatch a subagent (`Subagent (general-purpose):` template) | `task` with `subagent_type: "general"` |
| Create / update todos | `todowrite` |

This table is duplicated in the plugin's inline bootstrap
([`.opencode/plugins/what-have-i-done.js`](../../../.opencode/plugins/what-have-i-done.js))
and in [`.opencode/INSTALL.md`](../../../.opencode/INSTALL.md), because the
plugin injects the mapping alongside the bootstrap rather than relying on this
file being read. **If you change one, change all three.**

## Dispatching the reviewer

Fill every placeholder in
[`reviewer-prompt.md`](../../adversarial-self-review/reviewer-prompt.md) first,
then pass the completed prompt to `task` with `subagent_type: "general"`. The
template carries the reviewer's role and required output format.

## Skills discovery

The plugin registers this package's `skills/` directory through OpenCode's
`config` hook, so no symlinks are needed. Confirm with the `skill` tool that the
skills are listed; if they are not, the plugin is not loading — see
[`.opencode/INSTALL.md`](../../../.opencode/INSTALL.md).
