#!/bin/zsh

set -euo pipefail

swift package resolve
swift format lint --configuration .swift-format --recursive --strict --parallel Sources Tests
python3 Scripts/check-localizations.py
swift build -Xswiftc -warnings-as-errors
# Run all tests except ComponentSnapshotTests, which always exits non-zero
# in record mode (swift-snapshot-testing design). Snapshots are rendered
# separately by the docs workflow via `swift test --filter ComponentSnapshot`.
swift test --parallel --skip ComponentSnapshot
