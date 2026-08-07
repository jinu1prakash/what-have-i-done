#!/usr/bin/env bash
# Shared helpers for the test suite. Source this, don't run it.

FAILURES=0

pass() { printf '  \033[32m[PASS]\033[0m %s\n' "$1"; }

fail() {
    printf '  \033[31m[FAIL]\033[0m %s\n' "$1"
    shift
    for line in "$@"; do printf '         %s\n' "$line"; done
    FAILURES=$((FAILURES + 1))
}

section() { printf '\n\033[1m%s\033[0m\n' "$1"; }

# Every test script ends with this.
finish() {
    if [ "$FAILURES" -eq 0 ]; then
        printf '\n\033[32m%s: all checks passed\033[0m\n' "$(basename "$0")"
        exit 0
    fi
    printf '\n\033[31m%s: %d check(s) failed\033[0m\n' "$(basename "$0")" "$FAILURES"
    exit 1
}

# Locate the repo root from any test script's directory.
repo_root() { (cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd); }

# A JSON reader that works with either python3 or node, so the suite runs
# wherever one of them exists. The hook itself needs neither.
JSON_RUNNER=""
if command -v python3 >/dev/null 2>&1; then
    JSON_RUNNER="python3"
elif command -v node >/dev/null 2>&1; then
    JSON_RUNNER="node"
fi

require_json_runner() {
    if [ -z "$JSON_RUNNER" ]; then
        fail "no python3 or node available to parse JSON"
        finish
    fi
}

# json_valid FILE -> exit 0 if the file parses as JSON
json_valid() {
    case "$JSON_RUNNER" in
        python3) python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$1" 2>&1 ;;
        node) node -e 'JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"))' "$1" 2>&1 ;;
    esac
}

# json_get FILE DOTTED.PATH -> prints the value, or nothing if absent
json_get() {
    case "$JSON_RUNNER" in
        python3)
            python3 -c '
import json, sys
d = json.load(open(sys.argv[1]))
for k in sys.argv[2].split("."):
    if isinstance(d, list):
        d = d[int(k)]
    elif isinstance(d, dict) and k in d:
        d = d[k]
    else:
        sys.exit(0)
print(d if not isinstance(d, (dict, list)) else json.dumps(d))
' "$1" "$2" 2>/dev/null
            ;;
        node)
            node -e '
const d0 = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
let d = d0;
for (const k of process.argv[2].split(".")) {
  if (d === null || d === undefined || !(k in d)) process.exit(0);
  d = d[k];
}
console.log(typeof d === "object" ? JSON.stringify(d) : d);
' "$1" "$2" 2>/dev/null
            ;;
    esac
}
