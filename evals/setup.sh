#!/usr/bin/env bash
# Usage: evals/setup.sh <fixture-dir> [<work-dir>]
# Builds a throwaway git repo: `main` = the fixture's base/, branch `pr` = head/ (checked out). Prints the repo path.
set -euo pipefail

fixture=$(cd "$1" && pwd)
work=${2:-$(mktemp -d)}
repo="$work/$(basename "$fixture")"
git_() { git -C "$repo" -c user.name=eval -c user.email=eval@example.com "$@"; }

rm -rf "$repo" && mkdir -p "$repo"
git_ init -q -b main
[ -d "$fixture/base" ] && cp -R "$fixture/base/." "$repo/"
git_ add -A && git_ commit -qm "base" --allow-empty
git_ checkout -qb pr
rsync -a --delete --exclude .git "$fixture/head/" "$repo/"
git_ add -A && git_ commit -qF "$fixture/intent.txt"
echo "$repo"
