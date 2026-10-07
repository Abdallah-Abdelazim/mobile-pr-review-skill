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
EOF

./prepare-diff.sh annotate < "$tmp/raw.diff" > "$tmp/pr.diff" 2> "$tmp/stats"
grep -qx '=== app/Foo.java' "$tmp/pr.diff"           # .java is code, not noise
grep -qx 'L2 -b' "$tmp/pr.diff"
grep -qx 'R2 +B' "$tmp/pr.diff"
grep -q '^=== yarn.lock (omitted: +1/-1' "$tmp/pr.diff"
grep -qx '=== my dir/A.kt' "$tmp/pr.diff"            # tab after path stripped
grep -qx 'R3 +c' "$tmp/pr.diff"
grep -qx 'files=3 added=3 removed=2' "$tmp/stats"

printf 'my dir/A.kt\tRIGHT\t3\napp/Foo.java\tLEFT\t2\napp/Foo.java\tRIGHT\t2\n' | ./prepare-diff.sh check "$tmp/pr.diff"
! printf 'app/Foo.java\tRIGHT\t9\n' | ./prepare-diff.sh check "$tmp/pr.diff" > /dev/null
! printf 'yarn.lock\tRIGHT\t1\n' | ./prepare-diff.sh check "$tmp/pr.diff" > /dev/null

[ "$(printf 'my dir/A.kt\n' | ./prepare-diff.sh slice "$tmp/pr.diff" | head -1)" = '=== my dir/A.kt' ]
! printf 'my dir/A.kt\n' | ./prepare-diff.sh slice "$tmp/pr.diff" | grep -q Foo.java

echo "prepare-diff.sh: all checks passed"
