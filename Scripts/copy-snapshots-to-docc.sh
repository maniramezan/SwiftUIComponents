#!/bin/bash
# Copies snapshot reference images into the DocC Resources folder
# so they can be referenced in documentation articles and symbol pages.
#
# Usage: ./Scripts/copy-snapshots-to-docc.sh

set -euo pipefail

SNAPSHOT_DIR="Tests/SwiftUIComponentsTests/Snapshots/__Snapshots__/ComponentSnapshotTests"
DOCC_RESOURCES="Sources/Components/Components.docc/Resources"

if [ ! -d "$SNAPSHOT_DIR" ]; then
    echo "Error: Snapshot directory not found at $SNAPSHOT_DIR"
    echo "Run snapshot tests first to generate reference images."
    exit 1
fi

mkdir -p "$DOCC_RESOURCES"

for img in "$SNAPSHOT_DIR"/*.png; do
    [ -f "$img" ] || continue
    basename=$(basename "$img")
    # Convert "testFunctionName.1.png" -> "testFunctionName.png"
    clean_name="${basename/.1/}"
    cp "$img" "$DOCC_RESOURCES/$clean_name"
    echo "Copied $clean_name"
done

echo "Done. Images available in $DOCC_RESOURCES"
