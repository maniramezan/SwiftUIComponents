#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
# SwiftParser and SwiftSyntax ship with the selected Xcode toolchain.
swift_binary="$(xcrun --find swift)"
host_libraries="${swift_binary:h}/../lib/swift/host"
exec "$swift_binary" -I "$host_libraries" -L "$host_libraries" \
    -Xlinker -rpath -Xlinker "$host_libraries" Scripts/format-comments.swift "$@"
