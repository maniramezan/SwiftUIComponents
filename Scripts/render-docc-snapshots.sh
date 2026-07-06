#!/bin/zsh

set -euo pipefail

snapshot_dir="Tests/SwiftUIComponentsTests/Snapshots/__Snapshots__/ComponentSnapshotTests"

set +e
swift test --parallel --filter ComponentSnapshot
test_status=$?
set -e

if [ ! -d "$snapshot_dir" ]; then
    print -u2 "error: snapshot directory was not generated at $snapshot_dir"
    exit 1
fi

pngs=("$snapshot_dir"/*.png(N))
png_count=${#pngs}
if [ "$png_count" -eq 0 ]; then
    print -u2 "error: no snapshot PNGs were generated"
    exit 1
fi

if [ "$test_status" -ne 0 ]; then
    print "swift-snapshot-testing returned status $test_status after recording $png_count PNG(s); continuing."
else
    print "Recorded $png_count snapshot PNG(s)."
fi
