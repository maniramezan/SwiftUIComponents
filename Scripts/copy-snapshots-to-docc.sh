#!/bin/bash
# Copies rendered snapshot images into the DocC Resources folder so they can
# be referenced in documentation articles and symbol pages.
#
# The snapshot tests always run in record mode and write into __Snapshots__.
# This script must be called AFTER `swift test --filter ComponentSnapshot`
# and BEFORE `swift package generate-documentation`.
#
# Usage:
#   ./Scripts/render-docc-snapshots.sh
#   ./Scripts/copy-snapshots-to-docc.sh

set -euo pipefail

SNAPSHOT_DIR="Tests/SwiftUIComponentsTests/Snapshots/__Snapshots__/ComponentSnapshotTests"
DOCC_RESOURCES="Sources/Components/Components.docc/Resources"

if [ ! -d "$SNAPSHOT_DIR" ]; then
    echo "warning: Snapshot directory not found at $SNAPSHOT_DIR — skipping image copy."
    echo "         Run 'swift test --filter ComponentSnapshot' first to generate images."
    exit 0
fi

found=0
mkdir -p "$DOCC_RESOURCES"

for img in "$SNAPSHOT_DIR"/*.png; do
    [ -f "$img" ] || continue
    basename=$(basename "$img")
    # swift-snapshot-testing appends ".1" before the extension for the first
    # variant: "designFoo.1.png" -> "designFoo.png"
    clean_name="${basename/.1/}"
    cp "$img" "$DOCC_RESOURCES/$clean_name"
    echo "  copied $clean_name"
    found=$((found + 1))
done

if [ "$found" -eq 0 ]; then
    echo "warning: No PNG files found in $SNAPSHOT_DIR — DocC images will be missing."
    echo "         Run 'swift test --filter ComponentSnapshot' to generate them."
    exit 0
fi

echo "Done. $found image(s) copied to $DOCC_RESOURCES"
