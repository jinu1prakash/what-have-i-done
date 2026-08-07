#!/usr/bin/env bash
# Skill frontmatter is what makes a skill discoverable, and the description
# rules are what make it get read rather than skimmed. Both are checked here.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./helpers.sh
source "${SCRIPT_DIR}/helpers.sh"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$ROOT" || exit 1

BOOTSTRAP_SKILL="skills/using-what-have-i-done/SKILL.md"

section "every skill directory has a SKILL.md"

for dir in skills/*/; do
    name="$(basename "$dir")"
    [ -f "${dir}SKILL.md" ] && pass "$name has SKILL.md" \
        || fail "$name has no SKILL.md"
done

section "frontmatter is well-formed"

# extract_frontmatter FILE -> prints the YAML block between the --- fences
extract_frontmatter() {
    awk 'NR==1 && $0=="---" {inblock=1; next} inblock && $0=="---" {exit} inblock {print}' "$1"
}

for file in skills/*/SKILL.md; do
    dir_name="$(basename "$(dirname "$file")")"

    if [ "$(head -1 "$file")" != "---" ]; then
        fail "$file does not start with YAML frontmatter"
        continue
    fi

    fm="$(extract_frontmatter "$file")"
    name="$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -1)"
    # description may wrap onto continuation lines
    desc="$(printf '%s\n' "$fm" | awk '
        /^description:/ {sub(/^description:[[:space:]]*/, ""); print; found=1; next}
        found && /^[[:space:]]+/ {sub(/^[[:space:]]+/, " "); printf "%s", $0; next}
        found {exit}
    ' | tr -d '\n')"

    if [ -z "$name" ]; then
        fail "$file has no name field"
    elif [ "$name" != "$dir_name" ]; then
        fail "$file name '$name' does not match directory '$dir_name'"
    elif ! printf '%s' "$name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
        fail "$file name '$name' is not lowercase-hyphenated"
    else
        pass "$dir_name: name valid"
    fi

    if [ -z "$desc" ]; then
        fail "$file has no description field"
        continue
    fi

    case "$desc" in
        "Use when"*) pass "$dir_name: description starts with 'Use when'" ;;
        *) fail "$file description must start with 'Use when', got: ${desc:0:60}..." ;;
    esac

    fm_chars="$(printf '%s' "$fm" | wc -c | tr -d ' ')"
    if [ "$fm_chars" -le 1024 ]; then
        pass "$dir_name: frontmatter ${fm_chars} chars (limit 1024)"
    else
        fail "$file frontmatter is ${fm_chars} chars, limit is 1024"
    fi

    # First person in a description means it was written as chat, not as a
    # trigger the agent matches against.
    if printf '%s' "$desc" | grep -qiE '(^|[^[:alnum:]])(I |I'"'"'ll|my |we )'; then
        fail "$file description uses first person; descriptions are third person"
    fi
done

section "bootstrap skill lists every top-level skill"

for dir in skills/*/; do
    name="$(basename "$dir")"
    [ "$name" = "using-what-have-i-done" ] && continue
    if grep -q "\`$name\`" "$BOOTSTRAP_SKILL"; then
        pass "bootstrap lists $name"
    else
        fail "bootstrap does not list '$name' - agents will not know it exists"
    fi
done

section "bootstrap stays small (it loads every session)"

words="$(wc -w < "$BOOTSTRAP_SKILL" | tr -d ' ')"
if [ "$words" -le 1000 ]; then
    pass "bootstrap is ${words} words (budget 1000)"
else
    fail "bootstrap is ${words} words; it is injected every session, keep it under 1000"
fi

section "skills name actions, not one harness's tool names"

# Skill bodies must stay portable. Tool names belong in references/.
HARNESS_TOOLS='TodoWrite|todowrite|apply_patch|run_shell_command|activate_skill|invoke_agent|write_todos|webfetch|subagent_type'
for file in skills/*/SKILL.md skills/*/*.md; do
    case "$file" in
        skills/using-what-have-i-done/references/*) continue ;;
        skills/writing-review-skills/*) continue ;;   # documents the rule, quotes examples
    esac
    if grep -qE "$HARNESS_TOOLS" "$file"; then
        fail "$file names harness-specific tools" \
             "$(grep -nE "$HARNESS_TOOLS" "$file" | head -3)" \
             "Move tool names into skills/using-what-have-i-done/references/."
    else
        pass "$(basename "$(dirname "$file")")/$(basename "$file"): portable"
    fi
done

section "no @-includes between skills (they force-load and burn context)"

for file in skills/*/*.md; do
    if grep -qE '^\s*@\./|^\s*@skills/' "$file"; then
        fail "$file uses an @-include; cross-reference by skill name instead"
    fi
done
pass "no @-includes in skill bodies"

finish
