#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
./Scripts/format-comments.sh --fix
swift format --configuration .swift-format --in-place --recursive Sources Tests Scripts/format-comments.swift Package.swift
./Scripts/format-comments.sh --lint
