#!/usr/bin/env python3

import json
import sys
import subprocess
from pathlib import Path


FULL_THRESHOLD = 20.0
CHANGED_THRESHOLD = 80.0


def executable_lines(file):
    line_counts = {}
    for segment in file.get("segments", []):
        line, _column, count, has_count = segment[:4]
        if has_count:
            line_counts[line] = max(line_counts.get(line, 0), count)
    return line_counts


def changed_source_lines(base_ref):
    result = subprocess.run(
        ["git", "diff", "--unified=0", base_ref, "--", ":(glob)Sources/**/*.swift"],
        check=True,
        capture_output=True,
        text=True,
    )
    changed = {}
    current_file = None

    for line in result.stdout.splitlines():
        if line.startswith("+++ b/"):
            current_file = line.removeprefix("+++ b/")
            continue
        if not current_file or not line.startswith("@@"):
            continue

        header = line.split("@@", 2)[1].strip()
        for part in header.split():
            if not part.startswith("+"):
                continue
            start_count = part[1:].split(",", 1)
            start = int(start_count[0])
            count = int(start_count[1]) if len(start_count) == 2 else 1
            if count == 0:
                continue
            changed.setdefault(current_file, set()).update(range(start, start + count))

    return changed


def main():
    if len(sys.argv) not in (2, 4):
        print(
            "usage: check-coverage.py <codecov-json> [--changed <base-ref>]",
            file=sys.stderr,
        )
        return 2

    coverage_path = Path(sys.argv[1])
    if not coverage_path.exists():
        print(f"error: coverage file not found: {coverage_path}", file=sys.stderr)
        return 2

    root = Path.cwd().resolve()
    data = json.loads(coverage_path.read_text())
    totals = {}
    changed_lines = None
    if len(sys.argv) == 4:
        if sys.argv[2] != "--changed":
            print("error: expected --changed <base-ref>", file=sys.stderr)
            return 2
        changed_lines = changed_source_lines(sys.argv[3])

    for item in data.get("data", []):
        for file in item.get("files", []):
            filename = Path(file.get("filename", "")).resolve()
            try:
                relative = filename.relative_to(root)
            except ValueError:
                continue

            parts = relative.parts
            if len(parts) < 3 or parts[0] != "Sources":
                continue

            target = parts[1]
            source_path = str(relative)
            line_counts = executable_lines(file)

            if changed_lines is not None:
                source_changed_lines = changed_lines.get(source_path, set())
                line_counts = {
                    line: count
                    for line, count in line_counts.items()
                    if line in source_changed_lines
                }

            executable = len(line_counts)
            covered = sum(1 for count in line_counts.values() if count > 0)
            target_totals = totals.setdefault(target, [0, 0])
            target_totals[0] += covered
            target_totals[1] += executable

    if not totals:
        if changed_lines is not None:
            print("No changed executable source lines found; changed-line coverage passes.")
            return 0
        print("error: no package source coverage found", file=sys.stderr)
        return 2

    covered = sum(total[0] for total in totals.values())
    executable = sum(total[1] for total in totals.values())
    percentage = covered / executable * 100 if executable else 0

    for target, (target_covered, target_executable) in sorted(totals.items()):
        target_percentage = target_covered / target_executable * 100 if target_executable else 0
        print(f"{target}: {target_covered}/{target_executable} lines = {target_percentage:.1f}%")

    if changed_lines is not None and executable == 0:
        print("No changed executable source lines found; changed-line coverage passes.")
        return 0

    threshold = CHANGED_THRESHOLD if changed_lines is not None else FULL_THRESHOLD
    label = "Changed source coverage" if changed_lines is not None else "Total source coverage"
    print(f"{label}: {covered}/{executable} lines = {percentage:.1f}%")
    print(f"Required minimum: {threshold:.1f}%")

    if percentage < threshold:
        print("error: source coverage is below the required minimum", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
