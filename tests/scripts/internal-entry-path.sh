#!/usr/bin/env bash
# Internal mode (raw entries allowed) is granted to the checkout's own listed paths, never to a file that merely ends the same way.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_internal_path.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }
raw='(capabilities io ffi actor)
(defn main () (begin (print (ffi-call "zyl_word_load" 4198400 1000)) 0))'
for p in tools/repl.zyl selfhost/driver.zyl tests/regression/compiler.zyl tests/unit_test.zyl regression/runtime-heap.zyl; do
    mkdir -p "$SCRATCH/$(dirname "$p")"
    printf '%s\n' "$raw" > "$SCRATCH/$p"
    if out=$("$ZYL" "$SCRATCH/$p" -o "$SCRATCH/out" 2>&1); then fail "$p outside the checkout compiled in internal mode"; fi
    echo "$out" | grep -q E_FFI_RESTRICTED || fail "$p: expected E_FFI_RESTRICTED, got: $out"
done
# The checkout's own entry still compiles in internal mode.
"$ZYL" check "$ROOT/tests/regression/runtime-heap.zyl" >/dev/null 2>&1 || fail "the checkout's runtime-heap.zyl lost internal mode"
echo ok
