#!/usr/bin/env bash
# Run every test in this suite. Exits non-zero if any of them fails.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

TESTS=(
    test-isolation.sh
    test-manifests.sh
    test-skills.sh
    test-links.sh
    test-session-start.sh
    test-plugins.sh
)

FAILED=()

for t in "${TESTS[@]}"; do
    printf '\n\033[1;34m=== %s ===\033[0m\n' "$t"
    if bash "${SCRIPT_DIR}/${t}"; then
        :
    else
        FAILED+=("$t")
    fi
done

printf '\n\033[1m========================================\033[0m\n'
if [ ${#FAILED[@]} -eq 0 ]; then
    printf '\033[32mAll %d test files passed.\033[0m\n' "${#TESTS[@]}"
    exit 0
fi
printf '\033[31m%d of %d test files failed:\033[0m\n' "${#FAILED[@]}" "${#TESTS[@]}"
for t in "${FAILED[@]}"; do printf '  - %s\n' "$t"; done
exit 1
