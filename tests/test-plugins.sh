#!/usr/bin/env bash
# The in-process adapters (OpenCode plugin, Pi extension) are the bootstrap for
# their harnesses. Verify they parse, register the skills directory, and inject
# the bootstrap exactly once.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./helpers.sh
source "${SCRIPT_DIR}/helpers.sh"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$ROOT" || exit 1

if ! command -v node >/dev/null 2>&1; then
    section "in-process adapters"
    pass "skipped: node not available"
    finish
fi

section "OpenCode plugin"

if node --check .opencode/plugins/what-have-i-done.js 2>/dev/null; then
    pass "parses as valid JavaScript"
else
    fail "syntax error" "$(node --check .opencode/plugins/what-have-i-done.js 2>&1)"
fi

if node "${SCRIPT_DIR}/opencode-plugin.test.mjs"; then
    pass "behavior tests passed"
else
    fail "behavior tests failed (output above)"
fi

section "Pi extension"

# The Pi extension is TypeScript that Pi runs directly, so there is no build
# step to lean on. Check the structural contract instead.
PI_EXT=".pi/extensions/what-have-i-done.ts"

for handler in resources_discover session_start session_compact agent_end context; do
    if grep -q "pi.on(\"${handler}\"" "$PI_EXT"; then
        pass "registers '${handler}' handler"
    else
        fail "$PI_EXT does not register the '${handler}' handler"
    fi
done

if grep -q 'export default function' "$PI_EXT"; then
    pass "has a default export"
else
    fail "$PI_EXT has no default export; Pi will not load it"
fi

# The dedup marker must appear both in the injected string and in the guard.
marker_uses="$(grep -c 'BOOTSTRAP_MARKER' "$PI_EXT")"
if [ "$marker_uses" -ge 3 ]; then
    pass "dedup marker defined, injected, and checked"
else
    fail "$PI_EXT uses BOOTSTRAP_MARKER only ${marker_uses}x; expected define + inject + guard"
fi

# Pi keeps its tool mapping in two places: piToolMapping() inline and
# references/pi-tools.md. The inline copy is what gets injected, so nothing the
# reference documents may be missing from it. (Only the reference's mapping
# TABLE counts -- its prose names things like resources_discover that are not
# tools the model calls.)
PI_REF="skills/using-what-have-i-done/references/pi-tools.md"
pi_ref_tools="$(grep '^|' "$PI_REF" | grep -oE '`[a-z_]+`' | tr -d '`' | sort -u)"
pi_missing=""
for tool in $pi_ref_tools; do
    grep -q "\\\\\`${tool}\\\\\`" "$PI_EXT" || pi_missing="${pi_missing} ${tool}"
done
if [ -z "$pi_missing" ]; then
    pass "inline mapping covers every tool in references/pi-tools.md ($(echo "$pi_ref_tools" | tr '\n' ' '))"
else
    fail "Pi inline mapping is missing tools the reference documents:${pi_missing}" \
         "Update piToolMapping() in ${PI_EXT}, or the table in ${PI_REF}."
fi

# Both adapters must read the bootstrap from the skill file, not a stale copy.
for adapter in .opencode/plugins/what-have-i-done.js "$PI_EXT"; do
    if grep -q 'using-what-have-i-done' "$adapter"; then
        pass "$(basename "$adapter") reads the bootstrap from the skill file"
    else
        fail "$adapter does not reference the using-what-have-i-done skill"
    fi
done

finish
