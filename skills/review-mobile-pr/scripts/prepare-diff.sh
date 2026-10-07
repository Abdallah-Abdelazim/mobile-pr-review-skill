#!/usr/bin/env bash
# Usage:
#   prepare-diff.sh annotate < raw.diff > pr.diff   # prints "files=N added=X removed=Y" to stderr
#   prepare-diff.sh check pr.diff < anchors.tsv     # anchors: path<TAB>RIGHT|LEFT<TAB>line; prints invalid ones, exit 1 if any
#   prepare-diff.sh slice pr.diff < paths.txt > shard.diff   # keeps only the sections for the listed paths (one per line)
set -euo pipefail

# Lockfiles, binaries, snapshots and build output: reviewed by stat line only.
export NOISE='(\.lock|Package\.resolved|\.(png|jpe?g|webp|gif|pdf|jar|aar|so|a|ttf|otf|mp4|zip|snap))$|(^|/)(build|__snapshots__)/'

annotate() {
  awk '
    BEGIN { noise = ENVIRON["NOISE"] }  # -v would unescape the backslashes in the regex
    function flush() {
      if (path == "") return
      if (skip) printf "=== %s (omitted: +%d/-%d lines, lockfile/binary/snapshot)\n", path, fa, fr
      files++
    }
    /^diff --git / { flush(); path = ""; skip = 0; fa = fr = 0; inhunk = 0; split($0, p, " b/"); pend = p[length(p)]; next }
    !inhunk && /^Binary files / { path = pend; skip = 1; next }
    !inhunk && /^\+\+\+ / {
      path = ($0 == "+++ /dev/null") ? pend : substr($0, 7); sub(/\t$/, "", path)
      skip = (path ~ noise)
      if (!skip) print "=== " path
      next
    }
    !inhunk && /^(--- |index |old mode|new mode|deleted file|new file|similarity|rename |copy )/ { next }
    /^@@ / {
      inhunk = 1
      split($2, o, ","); split($3, n, ",")
      old = substr(o[1], 2) + 0; new = substr(n[1], 2) + 0
      if (!skip) print
      next
    }
    inhunk && /^\\/ { next }
    inhunk && /^\+/ { fa++; added++;   if (!skip) printf "R%d %s\n", new, $0; new++; next }
    inhunk && /^-/  { fr++; removed++; if (!skip) printf "L%d %s\n", old, $0; old++; next }
    inhunk && /^ /  { if (!skip) printf "R%d %s\n", new, $0; new++; old++; next }
    END { flush(); printf "files=%d added=%d removed=%d\n", files, added, removed > "/dev/stderr" }
  '
}

check() {
  awk '
    FNR == NR {
      if (/^=== /) { path = substr($0, 5); sub(/ \(omitted: .*$/, "", path); next }
      if (/^[RL][0-9]+ /) { side = (substr($0, 1, 1) == "R") ? "RIGHT" : "LEFT"; ok[path "\t" side "\t" substr($1, 2) + 0] = 1 }
      next
    }
    { split($0, a, "\t"); if (!((a[1] "\t" a[2] "\t" a[3]) in ok)) { print "invalid anchor: " $0; bad = 1 } }
    END { exit bad }
  ' "$1" -
}

slice() {
  awk '
    FNR == NR { want[$0] = 1; next }
    /^=== / { path = substr($0, 5); sub(/ \(omitted: .*$/, "", path); keep = (path in want) }
    keep
  ' - "$1"
}

case "${1:-}" in
  annotate) annotate ;;
  check) check "$2" ;;
  slice) slice "$2" ;;
  *) echo "usage: $0 annotate | check <pr.diff> | slice <pr.diff>" >&2; exit 2 ;;
esac
