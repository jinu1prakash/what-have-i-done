#!/usr/bin/env bash
# Every JSON file must parse, every versioned manifest must agree, and the
# per-harness wiring must point at files that exist.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./helpers.sh
source "${SCRIPT_DIR}/helpers.sh"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$ROOT" || exit 1

require_json_runner

section "every JSON file parses"

while IFS= read -r f; do
    err="$(json_valid "$f")"
    if [ -n "$err" ]; then
        fail "$f is not valid JSON" "$err"
    else
        pass "$f"
    fi
done < <(find . -name '*.json' -not -path './node_modules/*' -not -path './.git/*' | sort)

section "versions are in lockstep"

# Keep this list in sync with .version-bump.json
declare -a VERSIONED=(
    "package.json|version"
    ".claude-plugin/plugin.json|version"
    ".claude-plugin/marketplace.json|plugins.0.version"
    ".codex-plugin/plugin.json|version"
    ".cursor-plugin/plugin.json|version"
    "gemini-extension.json|version"
)

REFERENCE="$(json_get package.json version)"
if [ -z "$REFERENCE" ]; then
    fail "package.json has no version"
else
    for entry in "${VERSIONED[@]}"; do
        file="${entry%%|*}"; path="${entry##*|}"
        actual="$(json_get "$file" "$path")"
        if [ "$actual" = "$REFERENCE" ]; then
            pass "$file ($path) = $REFERENCE"
        else
            fail "$file ($path) = '${actual:-<missing>}', expected '$REFERENCE'"
        fi
    done
fi

section "per-harness wiring points at real files"

# Cursor declares its skills dir and hooks file explicitly.
cursor_skills="$(json_get .cursor-plugin/plugin.json skills)"
cursor_hooks="$(json_get .cursor-plugin/plugin.json hooks)"
[ -d "$cursor_skills" ] && pass "cursor skills path exists: $cursor_skills" \
    || fail "cursor skills path missing: ${cursor_skills:-<unset>}"
[ -f "$cursor_hooks" ] && pass "cursor hooks file exists: $cursor_hooks" \
    || fail "cursor hooks file missing: ${cursor_hooks:-<unset>}"

# Codex surfaces skills natively and runs NO session-start hook. The empty
# hooks object is what suppresses auto-discovery of hooks/hooks.json.
codex_hooks="$(json_get .codex-plugin/plugin.json hooks)"
if [ "$codex_hooks" = "{}" ]; then
    pass "codex declares empty hooks (suppresses hooks.json auto-discovery)"
else
    fail "codex hooks should be {} but is '${codex_hooks:-<missing>}'" \
         "Codex runs no session-start hook; a non-empty value re-enables the wrong contract."
fi

codex_skills="$(json_get .codex-plugin/plugin.json skills)"
[ -d "$codex_skills" ] && pass "codex skills path exists: $codex_skills" \
    || fail "codex skills path missing: ${codex_skills:-<unset>}"

# Gemini's context file must exist and be declared.
gemini_ctx="$(json_get gemini-extension.json contextFileName)"
[ -f "$gemini_ctx" ] && pass "gemini context file exists: $gemini_ctx" \
    || fail "gemini context file missing: ${gemini_ctx:-<unset>}"

# package.json main -> the OpenCode plugin; pi fields -> extension and skills.
pkg_main="$(json_get package.json main)"
[ -f "$pkg_main" ] && pass "package.json main exists: $pkg_main" \
    || fail "package.json main missing: ${pkg_main:-<unset>}"

pi_ext="$(json_get package.json pi.extensions.0)"
[ -f "$pi_ext" ] && pass "pi extension exists: $pi_ext" \
    || fail "pi extension missing: ${pi_ext:-<unset>}"

pi_skills="$(json_get package.json pi.skills.0)"
[ -d "$pi_skills" ] && pass "pi skills path exists: $pi_skills" \
    || fail "pi skills path missing: ${pi_skills:-<unset>}"

# Claude Code auto-discovers hooks/hooks.json; the command must reference the
# wrapper via the plugin-root variable Claude Code exports.
hook_cmd="$(json_get hooks/hooks.json hooks.SessionStart.0.hooks.0.command)"
case "$hook_cmd" in
    *'${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd'*session-start*)
        pass "hooks.json command uses \${CLAUDE_PLUGIN_ROOT} and run-hook.cmd" ;;
    *)  fail "hooks.json command looks wrong: '${hook_cmd:-<missing>}'" ;;
esac

section "no abandoned harness wiring"

for orphan in hooks/hooks-codex.json hooks/session-start-codex; do
    [ -e "$orphan" ] \
        && fail "$orphan still exists - Codex runs no session-start hook" \
        || pass "$orphan absent (correct)"
done

section "hook scripts are executable"

for script in hooks/session-start hooks/run-hook.cmd; do
    [ -x "$script" ] && pass "$script is executable" \
        || fail "$script is not executable (chmod +x it)"
done

finish
