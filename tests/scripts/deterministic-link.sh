#!/usr/bin/env bash
# Two builds of the same source must produce byte-identical binaries, even
# from different directories to different output names. The generated
# assembly names its source with a fixed `.file` directive; before that
# the linker recorded cc's random temporary object name (/tmp/ccXXXXXX.o)
# in the symbol table and every build differed by those bytes.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_detlink_test.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

mkdir -p "$SCRATCH/a" "$SCRATCH/b"
cat > "$SCRATCH/a/prog.zyl" <<'EOF'
(defn sq (x) (* x x))
(defn main () (begin (print (sq 7)) 0))
EOF
cp "$SCRATCH/a/prog.zyl" "$SCRATCH/b/prog.zyl"

"$ZYL" "$SCRATCH/a/prog.zyl" -o "$SCRATCH/a/one" >/dev/null 2>&1 || fail "first build"
"$ZYL" "$SCRATCH/b/prog.zyl" -o "$SCRATCH/b/two" >/dev/null 2>&1 || fail "second build"
[ "$("$SCRATCH/a/one")" = "49" ] || fail "binary prints the wrong value"
cmp -s "$SCRATCH/a/one" "$SCRATCH/b/two" || fail "binaries differ: $(cmp "$SCRATCH/a/one" "$SCRATCH/b/two" || true)"
head -1 "$SCRATCH/a/one.s" | grep -qx '.file "prog.zyl"' || fail "assembly lacks .file \"prog.zyl\""

echo "deterministic-link: ok"
