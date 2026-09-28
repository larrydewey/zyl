#!/usr/bin/env bash
# --runtime-module compiles only the bundled runtime; a copy elsewhere is refused.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_rtlock_test.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

mkdir -p "$SCRATCH/runtime/rt"
printf '(defn zyl_peek (a) (ffi-call "%%load64" a 1))\n' > "$SCRATCH/runtime/rt/rt.zyl"
out="$("$ZYL" "$SCRATCH/runtime/rt/rt.zyl" -o "$SCRATCH/rt.s" --runtime-module 2>&1 || true)"
printf '%s\n' "$out" | grep -q 'E_FFI_RESTRICTED' || fail "copy was not refused: $out"
[ -s "$SCRATCH/rt.s" ] && fail "copy produced output"
"$ZYL" "$ZYL_HOME/runtime/rt/rt.zyl" -o "$SCRATCH/ok.s" --runtime-module || fail "bundled runtime refused"
grep -q '^\.globl zyl_cstr_len' "$SCRATCH/ok.s" || fail "no export"
grep -q '^\.globl main' "$SCRATCH/ok.s" && fail "runtime module has a main"
# A bundle's runtime may use only its own runtime/rt modules.
B="$SCRATCH/bundle"
mkdir -p "$B/runtime/rt"
ln -s "$ZYL_HOME/stdlib" "$B/stdlib"
printf '(use core/list)\n(defn zyl_x () 0)\n' > "$B/runtime/rt/rt.zyl"
out="$(ZYL_HOME="$B" "$ZYL" "$B/runtime/rt/rt.zyl" -o "$SCRATCH/b.s" --runtime-module 2>&1 || true)"
printf '%s\n' "$out" | grep -q 'E_FFI_RESTRICTED' || fail "stdlib use was not refused: $out"
echo ok
