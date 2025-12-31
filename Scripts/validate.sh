#!/bin/zsh

set -euo pipefail

swift package resolve
swift format lint --configuration .swift-format --recursive --strict --parallel Sources Tests
swift build
swift test --parallel
