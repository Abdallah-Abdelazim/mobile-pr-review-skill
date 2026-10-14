#!/usr/bin/env bash
# Usage:
#   prepare-diff.sh annotate < raw.diff > pr.diff   # prints "files=N added=X removed=Y renamed=Z" to stderr
#   prepare-diff.sh check pr.diff < anchors.tsv     # anchors: path<TAB>RIGHT|LEFT<TAB>line[<TAB>start_line]; prints invalid ones, exit 1 if any
#   prepare-diff.sh slice pr.diff < paths.txt > shard.diff   # keeps only the sections for the listed paths (one per line)
set -euo pipefail

# Lockfiles, binaries, snapshots and build output: reviewed by stat line only.
export NOISE='(\.lock|Package\.resolved|\.(png|jpe?g|webp|gif|pdf|jar|aar|so|a|ttf|otf|mp4|zip|snap))$|(^|/)(build|__snapshots__)/'

annotate() {
  awk '
    BEGIN { noise = ENVIRON["NOISE"] }  # -v would unescape the backslashes in the regex
    function flush() {
      if (path == "" && rfrom != "") { printf "=== %s (renamed from %s, no content change)\n", pend, rfrom; files++; renamed++; return }
      if (path == "") return
      if (skip) printf "=== %s (omitted: +%d/-%d lines, lockfile/binary/snapshot)\n", path, fa, fr
      files++
    }
    function unquote(s) { if (s ~ /^"/) { s = substr(s, 2); sub(/"$/, "", s) }; return s }
    /^diff --git / {
      flush(); path = rfrom = ""; skip = 0; fa = fr = 0; inhunk = 0
      if ($0 ~ / "b\//) { pend = $0; sub(/.* "b\//, "", pend); sub(/"$/, "", pend) } else { np = split($0, p, " b/"); pend = p[np] }
      next
    }
    !inhunk && /^rename from / { rfrom = unquote(substr($0, 13)); next }
    !inhunk && /^Binary files / { path = pend; skip = 1; next }
    !inhunk && /^\+\+\+ / {
      if ($0 == "+++ /dev/null") path = pend
      else { path = substr($0, 5); sub(/\t$/, "", path); path = unquote(path); sub(/^b\//, "", path) }
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
    END { flush(); printf "files=%d added=%d removed=%d renamed=%d\n", files, added, removed, renamed > "/dev/stderr" }
  '
}

check() {
  awk '
    FNR == NR {
      if (/^=== /) { path = substr($0, 5); sub(/ \((omitted|renamed from) .*$/, "", path); next }
      if (/^@@ /) { hunk++; next }
      if (/^[RL][0-9]+ /) { side = (substr($0, 1, 1) == "R") ? "RIGHT" : "LEFT"; ok[path "\t" side "\t" substr($1, 2) + 0] = hunk }
      next
    }
    {
      split($0, a, "\t"); k = a[1] "\t" a[2] "\t" a[3]
      if (!(k in ok)) { print "invalid anchor: " $0; bad = 1; next }
      if (a[4] == "") next
      # GitHub rejects a range whose ends are on different sides or in different hunks.
      s = a[1] "\t" a[2] "\t" a[4]
      if (!(s in ok) || ok[s] != ok[k] || a[4] + 0 >= a[3] + 0) { print "invalid range: " $0; bad = 1 }
    }
    END { exit bad }
  ' "$1" -
}

slice() {
  awk '
    FNR == NR { want[$0] = 1; next }
    /^=== / { path = substr($0, 5); sub(/ \((omitted|renamed from) .*$/, "", path); keep = (path in want) }
    keep
  ' - "$1"
}

case "${1:-}" in
  annotate) annotate ;;
  check) check "$2" ;;
  slice) slice "$2" ;;
  *) echo "usage: $0 annotate | check <pr.diff> | slice <pr.diff>" >&2; exit 2 ;;
esac
