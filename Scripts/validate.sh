#!/bin/zsh

set -euo pipefail

run_tests="true"

while [ "$#" -gt 0 ]; do
    case "$1" in
        --skip-tests)
            run_tests="false"
            shift
            ;;
        *)
            print -u2 "usage: validate.sh [--skip-tests]"
            exit 2
            ;;
    esac
done

swift package resolve
swift format lint --configuration .swift-format --recursive --strict --parallel Sources Tests
python3 Scripts/check-localizations.py
swift build -Xswiftc -warnings-as-errors
# Run all tests except ComponentSnapshotTests, which always exits non-zero
# in record mode (swift-snapshot-testing design). Snapshots are rendered
# separately by the docs workflow via `swift test --filter ComponentSnapshot`.
if [ "$run_tests" = "true" ]; then
    swift test --parallel --skip ComponentSnapshot
fi
