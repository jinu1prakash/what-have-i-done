#!/usr/bin/env bash
# Set the version across every manifest listed in .version-bump.json.
#
# Usage:
#   scripts/bump-version.sh 1.2.0     set an explicit version
#   scripts/bump-version.sh patch     bump the patch component
#   scripts/bump-version.sh minor     bump the minor component
#   scripts/bump-version.sh major     bump the major component
#
# Every harness reads its own manifest, so a version that only lands in some of
# them ships stale metadata to the rest. tests/test-manifests.sh enforces this.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ $# -ne 1 ]; then
    sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "bump-version.sh requires python3" >&2
    exit 1
fi

python3 - "$1" <<'PY'
import json, re, sys
from pathlib import Path

arg = sys.argv[1]
config = json.loads(Path(".version-bump.json").read_text())
entries = config["files"]


def get(doc, dotted):
    cur = doc
    for key in dotted.split("."):
        cur = cur[int(key)] if isinstance(cur, list) else cur[key]
    return cur


def put(doc, dotted, value):
    keys = dotted.split(".")
    cur = doc
    for key in keys[:-1]:
        cur = cur[int(key)] if isinstance(cur, list) else cur[key]
    last = keys[-1]
    if isinstance(cur, list):
        cur[int(last)] = value
    else:
        cur[last] = value


current = get(json.loads(Path("package.json").read_text()), "version")

if arg in ("major", "minor", "patch"):
    if not re.fullmatch(r"\d+\.\d+\.\d+", current):
        sys.exit(f"cannot bump non-semver current version {current!r}")
    major, minor, patch = (int(p) for p in current.split("."))
    if arg == "major":
        major, minor, patch = major + 1, 0, 0
    elif arg == "minor":
        minor, patch = minor + 1, 0
    else:
        patch += 1
    new = f"{major}.{minor}.{patch}"
elif re.fullmatch(r"\d+\.\d+\.\d+([-+].+)?", arg):
    new = arg
else:
    sys.exit(f"{arg!r} is neither a semver version nor major/minor/patch")

for entry in entries:
    path = Path(entry["path"])
    if not path.exists():
        sys.exit(f"{path} is listed in .version-bump.json but does not exist")
    doc = json.loads(path.read_text())
    put(doc, entry["field"], new)
    path.write_text(json.dumps(doc, indent=2) + "\n")
    print(f"  {path} ({entry['field']}) -> {new}")

print(f"\n{current} -> {new} across {len(entries)} manifests")
PY

echo
echo "Verifying..."
"${ROOT}/tests/test-manifests.sh"
