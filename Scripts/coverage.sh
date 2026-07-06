#!/bin/zsh

set -euo pipefail

mode="full"
base_ref=""

if [ "$#" -gt 0 ]; then
    mode="$1"
fi

if [ "$mode" = "changed" ]; then
    if [ "$#" -ne 2 ]; then
        print -u2 "usage: coverage.sh changed <base-ref>"
        exit 2
    fi
    base_ref="$2"
elif [ "$mode" != "full" ]; then
    print -u2 "usage: coverage.sh [full|changed <base-ref>]"
    exit 2
fi

swift test --parallel --enable-code-coverage --skip ComponentSnapshot
coverage_path=$(swift test --show-codecov-path)

if [ "$mode" = "changed" ]; then
    python3 Scripts/check-coverage.py "$coverage_path" --changed "$base_ref"
else
    python3 Scripts/check-coverage.py "$coverage_path"
fi
