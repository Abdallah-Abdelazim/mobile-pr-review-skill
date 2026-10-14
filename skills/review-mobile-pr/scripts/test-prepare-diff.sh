#!/usr/bin/env bash
# Self-check for prepare-diff.sh: bash scripts/test-prepare-diff.sh
set -euo pipefail
cd "$(dirname "$0")"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/raw.diff" <<'EOF'
diff --git a/app/Foo.java b/app/Foo.java
--- a/app/Foo.java
+++ b/app/Foo.java
@@ -1,2 +1,2 @@
 a
-b
+B
diff --git a/yarn.lock b/yarn.lock
--- a/yarn.lock
+++ b/yarn.lock
@@ -1 +1 @@
-x
+y
diff --git a/my dir/A.kt b/my dir/A.kt
--- a/my dir/A.kt
+++ b/my dir/A.kt
@@ -1,2 +1,3 @@
 a
 b
+c
diff --git a/app/Two.kt b/app/Two.kt
--- a/app/Two.kt
+++ b/app/Two.kt
@@ -1,3 +1,3 @@
 a
-b
+B
 c
@@ -10,3 +10,4 @@
 j
 k
+k2
 l
diff --git a/old/B.kt b/new/B.kt
similarity index 100%
rename from old/B.kt
rename to new/B.kt
diff --git "a/caf\303\251.kt" "b/caf\303\251.kt"
--- "a/caf\303\251.kt"
+++ "b/caf\303\251.kt"
@@ -1 +1,2 @@
 a
+b
EOF

./prepare-diff.sh annotate < "$tmp/raw.diff" > "$tmp/pr.diff" 2> "$tmp/stats"
grep -qx '=== app/Foo.java' "$tmp/pr.diff"           # .java is code, not noise
grep -qx 'L2 -b' "$tmp/pr.diff"
grep -qx 'R2 +B' "$tmp/pr.diff"
grep -q '^=== yarn.lock (omitted: +1/-1' "$tmp/pr.diff"
grep -qx '=== my dir/A.kt' "$tmp/pr.diff"            # tab after path stripped
grep -qx 'R3 +c' "$tmp/pr.diff"
grep -qx '=== new/B.kt (renamed from old/B.kt, no content change)' "$tmp/pr.diff"   # pure rename kept
grep -qxF '=== caf\303\251.kt' "$tmp/pr.diff"       # git-quoted path unquoted
grep -qx 'files=6 added=6 removed=3 renamed=1' "$tmp/stats"

printf 'my dir/A.kt\tRIGHT\t3\napp/Foo.java\tLEFT\t2\napp/Foo.java\tRIGHT\t2\n' | ./prepare-diff.sh check "$tmp/pr.diff"
! printf 'app/Foo.java\tRIGHT\t9\n' | ./prepare-diff.sh check "$tmp/pr.diff" > /dev/null
! printf 'yarn.lock\tRIGHT\t1\n' | ./prepare-diff.sh check "$tmp/pr.diff" > /dev/null
printf '%s\tRIGHT\t2\n' 'caf\303\251.kt' | ./prepare-diff.sh check "$tmp/pr.diff"

# Ranges (4th column = start_line): same side, same hunk, start < line.
printf 'app/Two.kt\tRIGHT\t3\t1\napp/Two.kt\tRIGHT\t13\t10\n' | ./prepare-diff.sh check "$tmp/pr.diff"
{ printf 'app/Two.kt\tRIGHT\t12\t2\n' | ./prepare-diff.sh check "$tmp/pr.diff" || true; } | grep -q '^invalid range:'   # crosses hunks
! printf 'app/Two.kt\tRIGHT\t2\t2\n' | ./prepare-diff.sh check "$tmp/pr.diff" > /dev/null                # start == line
! printf 'app/Two.kt\tLEFT\t2\t1\n' | ./prepare-diff.sh check "$tmp/pr.diff" > /dev/null                 # line 1 exists only on RIGHT

[ "$(printf 'my dir/A.kt\n' | ./prepare-diff.sh slice "$tmp/pr.diff" | head -1)" = '=== my dir/A.kt' ]
! printf 'my dir/A.kt\n' | ./prepare-diff.sh slice "$tmp/pr.diff" | grep -q Foo.java
[ "$(printf 'new/B.kt\n' | ./prepare-diff.sh slice "$tmp/pr.diff")" = '=== new/B.kt (renamed from old/B.kt, no content change)' ]

echo "prepare-diff.sh: all checks passed"
