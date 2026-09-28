#!/usr/bin/env bash
# The landing page's examples (website/examples) compile, run and print their .out (stdout) and .err (stderr) files.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_site_examples.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

n=0
for src in "$ROOT"/website/examples/*.zyl; do
  name="$(basename "$src" .zyl)"
  "$ZYL" "$src" -o "$SCRATCH/$name" >"$SCRATCH/$name.log" 2>&1 || fail "$name does not compile: $(cat "$SCRATCH/$name.log")"
  status=0
  (cd "$SCRATCH" && timeout 60 "./$name") >"$SCRATCH/$name.got" 2>"$SCRATCH/$name.goterr" || status=$?
  want_status=0
  [ -f "${src%.zyl}.status" ] && want_status="$(cat "${src%.zyl}.status")"
  [ "$status" = "$want_status" ] || fail "$name exited $status, expected $want_status"
  diff -u "${src%.zyl}.out" "$SCRATCH/$name.got" || fail "$name stdout differs"
  want_err=/dev/null
  [ -f "${src%.zyl}.err" ] && want_err="${src%.zyl}.err"
  diff -u "$want_err" "$SCRATCH/$name.goterr" || fail "$name stderr differs"
  n=$((n + 1))
done
[ "$n" -ge 5 ] || fail "expected at least 5 examples, found $n"
echo "site-examples: ok ($n)"
