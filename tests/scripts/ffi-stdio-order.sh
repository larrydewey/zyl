#!/usr/bin/env bash
# Zyl's stdout and a foreign function's libc stdout stay in program order, also when piped.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_ffi_order.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
printf '(capabilities ffi)\n(extern "puts" (String) Int)\n(defn main () (begin (print "zyl first") (ffi-call "puts" "c second" 1000) (print "zyl third") 0))\n' > "$SCRATCH/o.zyl"
"$ZYL" "$SCRATCH/o.zyl" -o "$SCRATCH/o" >/dev/null
out="$("$SCRATCH/o" | cat)"
[ "$out" = "$(printf 'zyl first\nc second\nzyl third')" ] || { echo "FAIL: order: $out"; exit 1; }
echo ok
