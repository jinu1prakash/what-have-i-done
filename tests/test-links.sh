#!/usr/bin/env bash
# Every relative markdown link must resolve. A broken link in an INSTALL doc is
# a user hitting a 404 at exactly the moment they are trying to set this up.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./helpers.sh
source "${SCRIPT_DIR}/helpers.sh"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$ROOT" || exit 1

section "relative markdown links resolve"

checked=0
while IFS= read -r file; do
    dir="$(dirname "$file")"
    # Pull [text](target) targets, drop external and anchor-only links.
    while IFS= read -r target; do
        [ -z "$target" ] && continue
        case "$target" in
            http://*|https://*|mailto:*|'#'*) continue ;;
        esac
        # Strip any trailing anchor.
        path="${target%%#*}"
        [ -z "$path" ] && continue
        if [ ! -e "${dir}/${path}" ]; then
            fail "$file -> $target does not exist"
        fi
        checked=$((checked + 1))
    done < <(grep -oE '\]\([^)]+\)' "$file" | sed 's/^](//; s/)$//')
done < <(find . -name '*.md' -not -path './.git/*' -not -path './node_modules/*' | sort)

pass "checked ${checked} relative links"

section "@-includes in context files resolve"

# GEMINI.md uses @-includes; the harness loads them raw, so a bad path means the
# bootstrap silently never loads.
while IFS= read -r target; do
    [ -z "$target" ] && continue
    if [ -e "$target" ]; then
        pass "GEMINI.md includes $target"
    else
        fail "GEMINI.md includes '$target' which does not exist"
    fi
done < <(grep -oE '^@\./\S+' GEMINI.md | sed 's/^@\.\///')

section "files referenced by docs exist"

for required in LICENSE .opencode/INSTALL.md docs/porting.md INSTALL.md README.md; do
    [ -e "$required" ] && pass "$required exists" || fail "$required is missing"
done

finish
