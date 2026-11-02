#!/usr/bin/env bash
# Point the Action at a new opencomplai release: scripts/bump-cli-version.sh 0.14.0
# Then add a CHANGELOG entry, commit, and publish a new Action release.
set -euo pipefail
v="${1:?usage: bump-cli-version.sh X.Y.Z}"
[[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "not a release number: $v" >&2; exit 2; }
cd "$(dirname "$0")/.."
sed -i -E '/^  version:/,/^  [a-z-]+:$/ s/default: "[0-9.]+"/default: "'"$v"'"/' action.yml
grep -n -A2 '^  version:' action.yml
