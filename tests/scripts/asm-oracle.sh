#!/usr/bin/env bash
# compiler/asm_x86 against GNU as: every register x every supported form, byte-exact with the same relocation sites and kinds (skipped without as/objdump).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/stage2.bin"
command -v as >/dev/null && command -v objdump >/dev/null && command -v python3 >/dev/null || { echo "skip: no as/objdump/python3"; exit 0; }
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_asm_oracle.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
python3 "$ROOT/tests/scripts/asm_oracle.py" gen "$SCRATCH/sweep.s"
cat > "$SCRATCH/dump.zyl" <<'ZEOF'
(use compiler/asm_x86)
(defn arg (i) (ffi-call "zyl_arg_str" i 1000))
(defn main () (let _ (ax-dump-list (arg 1) (str-concat (arg 2) "/my.text") (str-concat (arg 2) "/my.rel") (str-concat (arg 2) "/my.lst")) 0))
(numeric checked)
ZEOF
ZYL_EXTERNAL_LD=1 "$ZYL" "$SCRATCH/dump.zyl" -o "$SCRATCH/dump" >/dev/null 2>&1 || { echo "FAIL: dumper did not build"; exit 1; }
"$SCRATCH/dump" "$SCRATCH/sweep.s" "$SCRATCH" || { echo "FAIL: dumper"; exit 1; }
python3 "$ROOT/tests/scripts/asm_oracle.py" cmp "$SCRATCH/sweep.s" "$SCRATCH" > "$SCRATCH/report" || { cat "$SCRATCH/report" | head -30; echo "FAIL: encodings differ from GNU as"; exit 1; }
echo ok
