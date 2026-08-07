#!/usr/bin/env bash
# Create one isolated workspace for a pressure-scenario run.
#
# Usage:  make-workspace.sh <a|b> <run-id>
# Prints the workspace path on stdout.
#
# Every run needs its own copy: agents modify these files, and a shared
# workspace would let one run contaminate the next.
#
# Override the parent directory with WHID_LAB, e.g.
#   WHID_LAB=~/scratch/whid ./make-workspace.sh a red1

set -euo pipefail

if [ $# -ne 2 ]; then
    sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
fi

SCENARIO="$1"
RUN_ID="$2"
HERE="$(cd "$(dirname "$0")" && pwd)"
LAB="${WHID_LAB:-${TMPDIR:-/tmp}/whid-lab}"

case "$SCENARIO" in
    a|b) ;;
    *) echo "unknown scenario '$SCENARIO' (expected a or b)" >&2; exit 1 ;;
esac

SOURCE="${HERE}/fixtures/${SCENARIO}"
[ -d "$SOURCE" ] || { echo "missing fixtures at $SOURCE" >&2; exit 1; }

DEST="${LAB}/runs/${SCENARIO}-${RUN_ID}"
rm -rf "$DEST"
mkdir -p "$DEST"
cp -R "${SOURCE}/." "$DEST/"

printf '%s\n' "$DEST"
