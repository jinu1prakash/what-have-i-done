#!/usr/bin/env bash
# The session-start hook must emit EXACTLY ONE context field, and it must be the
# one the running harness reads. The wrong field means the bootstrap silently
# never injects; two fields means it injects twice.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./helpers.sh
source "${SCRIPT_DIR}/helpers.sh"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
HOOK="${ROOT}/hooks/session-start"
WRAPPER="${ROOT}/hooks/run-hook.cmd"

require_json_runner
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# run_hook OUTFILE ENV... -- runs the hook with a clean environment plus the
# given assignments, capturing stdout.
run_hook() {
    local out="$1"; shift
    env -i PATH="${PATH}" HOME="${TMP}" "$@" bash "$HOOK" > "$out" 2> "${out}.err"
}

# check_shape LABEL EXPECTED_PATH ABSENT_KEY_1 ABSENT_KEY_2 ENV...
check_shape() {
    local label="$1" expected="$2" absent1="$3" absent2="$4"; shift 4
    local out="${TMP}/${label// /_}.json"

    if ! run_hook "$out" "$@"; then
        fail "$label: hook exited non-zero" "$(cat "${out}.err")"
        return
    fi

    local parse_err
    parse_err="$(json_valid "$out")"
    if [ -n "$parse_err" ]; then
        fail "$label: stdout is not valid JSON" "$parse_err" "$(head -c 200 "$out")"
        return
    fi

    local value
    value="$(json_get "$out" "$expected")"
    if [ -z "$value" ]; then
        fail "$label: expected field '$expected' missing" "$(head -c 200 "$out")"
        return
    fi

    if ! printf '%s' "$value" | grep -q 'using-what-have-i-done'; then
        fail "$label: injected context does not contain the bootstrap skill"
        return
    fi
    if ! printf '%s' "$value" | grep -q 'EXTREMELY_IMPORTANT'; then
        fail "$label: injected context is not wrapped in EXTREMELY_IMPORTANT"
        return
    fi

    # The other two shapes must be absent -- a harness that reads more than one
    # field would otherwise double-inject.
    for absent in "$absent1" "$absent2"; do
        if [ -n "$(json_get "$out" "$absent")" ]; then
            fail "$label: field '$absent' should be absent but is present"
            return
        fi
    done

    pass "$label -> $expected only"
}

section "session-start emits the right JSON shape per harness"

check_shape "Claude Code" \
    "hookSpecificOutput.additionalContext" "additional_context" "additionalContext" \
    CLAUDE_PLUGIN_ROOT="$ROOT"

check_shape "Cursor" \
    "additional_context" "additionalContext" "hookSpecificOutput" \
    CURSOR_PLUGIN_ROOT="$ROOT"

# Cursor may also set CLAUDE_PLUGIN_ROOT; the Cursor branch must win.
check_shape "Cursor (also sets CLAUDE_PLUGIN_ROOT)" \
    "additional_context" "additionalContext" "hookSpecificOutput" \
    CURSOR_PLUGIN_ROOT="$ROOT" CLAUDE_PLUGIN_ROOT="$ROOT"

check_shape "Copilot CLI" \
    "additionalContext" "additional_context" "hookSpecificOutput" \
    CLAUDE_PLUGIN_ROOT="$ROOT" COPILOT_CLI=1

check_shape "Unknown harness (SDK standard)" \
    "additionalContext" "additional_context" "hookSpecificOutput" \
    SOME_OTHER_HARNESS=1

section "session-start has no runtime dependencies"

# The hook must work with nothing but bash and coreutils on PATH -- no python3,
# node, or jq. Those are exactly the tools an earlier version depended on, and
# their absence is silent: the hook would emit raw text and inject nothing.
BARE="${TMP}/bare"
mkdir -p "$BARE"
for tool in bash cat dirname pwd; do
    src="$(command -v "$tool")" && ln -sf "$src" "${BARE}/${tool}"
done
for forbidden in python3 python node jq; do
    if [ -e "${BARE}/${forbidden}" ]; then
        fail "test setup error: ${forbidden} leaked into the bare PATH"
    fi
done
if env -i PATH="$BARE" HOME="$TMP" CLAUDE_PLUGIN_ROOT="$ROOT" \
    "${BARE}/bash" "$HOOK" > "${TMP}/bare.json" 2>"${TMP}/bare.err"; then
    if [ -n "$(json_get "${TMP}/bare.json" 'hookSpecificOutput.additionalContext')" ]; then
        pass "runs with only coreutils on PATH (no python3/node/jq)"
    else
        fail "bare-PATH run produced no context" "$(head -c 200 "${TMP}/bare.json")"
    fi
else
    fail "bare-PATH run exited non-zero" "$(cat "${TMP}/bare.err")"
fi

section "session-start degrades safely"

# A broken install must not break the session.
STAGE="${TMP}/stage"
mkdir -p "${STAGE}/hooks"
cp "$HOOK" "${STAGE}/hooks/session-start"
if env -i PATH="${PATH}" HOME="$TMP" CLAUDE_PLUGIN_ROOT="$STAGE" \
    bash "${STAGE}/hooks/session-start" > "${TMP}/missing.json" 2>&1; then
    if [ ! -s "${TMP}/missing.json" ]; then
        pass "missing bootstrap skill: exits 0 with no output"
    else
        fail "missing bootstrap skill: expected empty output" "$(cat "${TMP}/missing.json")"
    fi
else
    fail "missing bootstrap skill: should exit 0, not fail the session"
fi

section "run-hook.cmd dispatches on Unix"

if env -i PATH="${PATH}" HOME="$TMP" CLAUDE_PLUGIN_ROOT="$ROOT" \
    bash "$WRAPPER" session-start > "${TMP}/wrapper.json" 2>"${TMP}/wrapper.err"; then
    if [ -n "$(json_get "${TMP}/wrapper.json" 'hookSpecificOutput.additionalContext')" ]; then
        pass "run-hook.cmd session-start produces the same output"
    else
        fail "run-hook.cmd produced no context" "$(head -c 200 "${TMP}/wrapper.json")"
    fi
else
    fail "run-hook.cmd exited non-zero" "$(cat "${TMP}/wrapper.err")"
fi

finish
