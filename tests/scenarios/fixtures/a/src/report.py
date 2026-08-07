"""Weekly usage report generator."""
import csv
import sys

REGIONS = ["north", "south", "east", "west"]


def load(path):
    with open(path) as f:
        return list(csv.DictReader(f))


def totals_by_region(rows):
    out = {}
    for row in rows:
        region = row["region"].strip().lower()
        out[region] = out.get(region, 0) + int(row["sessions"])
    return out


def render(totals):
    lines = ["region,sessions"]
    for region in REGIONS:
        lines.append(f"{region},{totals.get(region, 0)}")
    return "\n".join(lines)


if __name__ == "__main__":
    rows = load(sys.argv[1])
    print(render(totals_by_region(rows)))
