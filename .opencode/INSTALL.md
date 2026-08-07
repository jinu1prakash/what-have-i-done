# Installing What Have I Done for OpenCode

## Prerequisites

- [OpenCode](https://opencode.ai) installed

## Installation

Add the package to the `plugin` array in your `opencode.json` (global at
`~/.config/opencode/opencode.json`, or project-level):

```json
{
  "plugin": ["what-have-i-done@git+<your-git-url>.git"]
}
```

For local development, point at the checkout directly:

```json
{
  "plugin": ["/absolute/path/to/what-have-i-done"]
}
```

Restart OpenCode. The plugin does two things on load:

1. Registers this package's `skills/` directory with OpenCode's skill discovery,
   so no symlinks are needed.
2. Injects the `using-what-have-i-done` bootstrap into the first user message of
   each session, which is what makes the completion gate actually fire.

## Verify the install

Ask OpenCode:

```
What do you do before telling me a task is done?
```

If the bootstrap loaded, it will describe the completion-integrity gate —
reconstructing intent, an evidence ledger, an adversarial review pass — rather
than giving a generic answer.

You can also check the logs:

```bash
opencode run --print-logs "hello" 2>&1 | grep -i what-have-i-done
```

The `2>&1` matters: OpenCode writes logs to stderr.

## Tool mapping

Skills in this package speak in **actions** ("dispatch a subagent", "create a
todo", "read a file") so the same skill text runs on every harness. On OpenCode
those actions resolve to:

| Action a skill requests | OpenCode tool |
|---|---|
| Read a file | `read` |
| Create / edit / delete a file | `apply_patch` |
| Run a shell command | `bash` |
| Search file contents / find files by name | `grep`, `glob` |
| Fetch a URL | `webfetch` |
| Invoke a skill | native `skill` tool |
| Dispatch a subagent (`Subagent (general-purpose):` template) | `task` with `subagent_type: "general"` |
| Create / update todos | `todowrite` |

The same table is kept in
[`../skills/using-what-have-i-done/references/opencode-tools.md`](../skills/using-what-have-i-done/references/opencode-tools.md).
If you change one, change both.

## Usage

Skills load through OpenCode's native `skill` tool:

```
use skill tool to list skills
use skill tool to load what-have-i-done
```

In normal use you should not need to do this by hand — the bootstrap tells the
agent to load `what-have-i-done` on its own before it claims anything is
finished.

## Troubleshooting

### The agent still says "done" without reviewing

The bootstrap isn't loading. Check, in order:

1. The `plugin` entry in `opencode.json` resolves to this package.
2. `skills/using-what-have-i-done/SKILL.md` exists in the installed copy.
3. The log grep above finds the plugin.

### Skills not found

Use the `skill` tool to list what OpenCode discovered. If this package's skills
are absent, the plugin's `config` hook isn't running — see the previous section.

### Updating

OpenCode resolves git-backed plugin specs through a lockfile or cache, so a
restart may not pick up the newest commit. If updates don't appear, clear
OpenCode's package cache or reinstall the plugin. To pin a version, append a tag
to the spec: `what-have-i-done@git+<your-git-url>.git#v1.0.0`.
