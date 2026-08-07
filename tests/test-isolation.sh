#!/usr/bin/env bash
# Pre-publication gate.
#
# This package is meant to be public. Everything below is a class of thing that
# must never reach a public repository: personal contact details, credentials,
# machine paths, references to unrelated projects, and local build cruft.
#
# It is a gate, not a lint. A single hit fails the suite. Run it before every
# push -- git history is permanent, and a leak removed in a later commit is
# still in the history.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./helpers.sh
source "${SCRIPT_DIR}/helpers.sh"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$ROOT" || exit 1

# check_absent PATTERN LABEL [EXTRA_GREP_ARGS...]
#
# This file necessarily contains every pattern it searches for, so it excludes
# itself. Patterns also bracket one letter -- fo[o] matches "foo" as a regex
# while this file never contains the literal word -- so the repo stays clean
# under a naive `grep -ri <word> .`, the check a reader is most likely to run.
check_absent() {
    local pattern="$1" label="$2"; shift 2
    local hits
    # -e is required: several patterns start with '-' and would otherwise be
    # parsed as grep options.
    hits="$(grep -rniE -e "$pattern" . \
        --exclude-dir=.git \
        --exclude-dir=node_modules \
        --exclude="$(basename "$0")" \
        "$@" 2>/dev/null)"
    if [ -z "$hits" ]; then
        pass "$label"
    else
        # shellcheck disable=SC2086
        fail "$label" $(printf '%s\n' "$hits" | head -8 | sed 's/^/  /')
    fi
}

section "no personal contact details"

# Any address except the reserved example domains, which exist only as invented
# fixture data (RFC 2606 reserves example.com/net/org for exactly this).
addresses="$(grep -rnoE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' . \
    --exclude-dir=.git --exclude="$(basename "$0")" 2>/dev/null \
    | grep -viE '@example\.(com|net|org)' || true)"
if [ -z "$addresses" ]; then
    pass "no email addresses outside the reserved example domains"
else
    # shellcheck disable=SC2086
    fail "email address in a public repo (gets scraped, and git history is permanent)" \
        $(printf '%s\n' "$addresses" | head -6 | sed 's/^/  /')
fi

section "no credentials"

check_absent '-----BEG[I]N [A-Z ]*PRIVATE KEY-----' "no private keys"
check_absent 'gh[p]_[A-Za-z0-9]{20,}|githu[b]_pat_[A-Za-z0-9_]{20,}' "no GitHub tokens"
check_absent 'sk-[a-z]{0,10}[A-Za-z0-9_-]{24,}' "no API keys (sk- style)"
check_absent 'AKI[A][0-9A-Z]{16}' "no AWS access key IDs"
check_absent 'xox[baprs]-[A-Za-z0-9-]{10,}' "no Slack tokens"
check_absent 'AIz[a][0-9A-Za-z_-]{35}' "no Google API keys"
check_absent '(secret|password|passwd|token|api_?key)[[:space:]]*[:=][[:space:]]*.[A-Za-z0-9/+_-]{16,}' \
    "no inline secrets"

for f in .env .env.local .npmrc .netrc id_rsa id_ed25519 credentials.json; do
    [ -e "$f" ] && fail "$f is present and must never be published" || pass "$f absent"
done

section "no machine paths"

# An absolute home path is a leak regardless of whose it is: it names a user.
check_absent '/Us[e]rs/[a-z]' "no macOS home-directory paths"
check_absent '/hom[e]/[a-z]+/' "no Linux home-directory paths"
check_absent 'C:\\\\Us[e]rs\\\\' "no Windows home-directory paths"
check_absent 'proj-aur[a]|experiment-wor[k]' "no private project directory names"

section "no references to other projects or employers"

check_absent 'sup[e]rpower' "no borrowed-project references (1/2)"
check_absent '\bobr[a]\b' "no borrowed-project references (2/2)"
check_absent '\brok[u]\b' "no employer references"

section "no local cruft"

# Anything matching these should have been caught by .gitignore. Finding one on
# disk means either the ignore rule is missing or something was force-added.
cruft="$(find . \
    \( -path ./.git -o -path ./node_modules \) -prune -o \
    \( -name '__pycache__' -o -name '*.pyc' -o -name '.DS_Store' \
       -o -name 'Thumbs.db' -o -name '*.log' -o -name '*.bak' -o -name '*.orig' \
       -o -name '*.rej' -o -name '*.swp' -o -name '*~' -o -name '.idea' \
       -o -name '.vscode' -o -name 'node_modules' -o -name '*.zip' \) \
    -print 2>/dev/null)"
if [ -z "$cruft" ]; then
    pass "no caches, editor state, logs, or build artifacts on disk"
else
    # shellcheck disable=SC2086
    fail "local cruft present" $(printf '%s\n' "$cruft" | head -8 | sed 's/^/  /')
fi

# Historical scaffolding from how this package was first generated.
for stale in create_all_files.py create_remaining.py make_hooks_exec.py dist; do
    [ -e "$stale" ] && fail "$stale still present (generator scaffolding)" \
        || pass "$stale absent"
done

section "no empty or oversized files"

empty="$(find . -type f -empty -not -path './.git/*' 2>/dev/null)"
[ -z "$empty" ] && pass "no empty files" \
    || fail "empty files present" $(printf '%s\n' "$empty" | sed 's/^/  /')

# Nothing here should be large. A big file in a skills repo is a mistake --
# a committed archive, a stray binary, a pasted transcript.
big="$(find . -type f -size +256k -not -path './.git/*' 2>/dev/null)"
[ -z "$big" ] && pass "no file over 256k" \
    || fail "unexpectedly large file(s)" $(printf '%s\n' "$big" | sed 's/^/  /')

finish
