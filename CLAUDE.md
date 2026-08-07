# Contributing to this repository

This package is behavior-shaping text plus the thin layer that delivers it. Both
halves break in quiet ways, so the rules below are not style preferences.

## The five rules

**1. Skills name actions, never tools.** "Dispatch a subagent", "read a file",
"create a todo". Real tool names live only in
`skills/using-what-have-i-done/references/<harness>-tools.md`. If you are editing
a `SKILL.md` to make a harness work, the fix belongs in the mapping instead.
`tests/test-skills.sh` enforces this.

**2. This library gates claims, not code.** It has to read naturally for a
document, a dataset, a research answer, a deploy, or a design. Every table that
carries a code example carries a non-code one. A skill that only makes sense for
software belongs in a different library.

**3. The description states triggers, never the workflow.** A description that
summarizes what the skill does becomes a shortcut the agent takes *instead of*
reading the skill. Start with "Use when", third person, symptoms and situations
only.

**4. No skill without an observed baseline failure.** Use the
`writing-review-skills` skill. If you did not watch an agent fail without the
text, you do not know whether the text teaches the right thing — and this is the
library that exists to enforce evidence before claims.

**5. `tests/run-all.sh` passes before anything ships.**

## What lives where

```
skills/                 the content — identical on every harness
hooks/                  Shape A adapters (shell hook + polyglot wrapper)
.opencode/ .pi/         Shape B adapters (in-process plugins)
GEMINI.md  AGENTS.md    Shape C adapters (instructions files)
.*-plugin/              per-harness manifests
docs/porting.md         how to add a harness
tests/                  the suite
scripts/bump-version.sh version lockstep across six manifests
```

## Editing the bootstrap

`skills/using-what-have-i-done/SKILL.md` is injected into **every session on
every harness**. Every adapter reads that one file, so there is nothing to keep
in sync — but every word costs tokens in every conversation. The suite caps it at
1000 words. Adding a top-level skill means adding a row to its skill table; the
suite checks that too.

## Duplicated text that must stay in sync

Two places intentionally duplicate the OpenCode tool mapping, because the plugin
injects it inline rather than relying on the reference file being read:

- `skills/using-what-have-i-done/references/opencode-tools.md`
- the `TOOL_MAPPING` constant in `.opencode/plugins/what-have-i-done.js`
- the table in `.opencode/INSTALL.md`

Pi has the same split between `references/pi-tools.md` and `piToolMapping()`.
Change one, change the others.

## Adding a harness

Read [`docs/porting.md`](docs/porting.md) in full. The short version: the
bootstrap must inject at session start with no per-session opt-in, it must ride
the harness's own install mechanism rather than editing the user's config, and
the acceptance test must pass on that harness specifically. Passing on one
harness proves nothing about another.

Add test coverage for the new integration. For a shell hook, extend
`tests/test-session-start.sh` and assert your harness's field is emitted *and the
other shapes are not*.

## Versioning

Six manifests carry a version. Never edit them by hand:

```bash
./scripts/bump-version.sh patch
```

## Zero runtime dependencies

`hooks/session-start` runs with nothing but coreutils — no python3, node, or jq.
The suite tests this with a stripped PATH. The test suite itself may use python3
or node; the shipped code may not.
