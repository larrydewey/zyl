#!/usr/bin/env bash
# `zyl doc` renders a module's header, each definition's signature and the
# comment block above it; `;|` lines take precedence; in a package only
# `pub` definitions are listed; a directory is documented file by file in
# sorted order.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_doc_test.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

mkdir -p "$SCRATCH/lone" "$SCRATCH/pkg"
cat > "$SCRATCH/lone/shapes.zyl" <<'ZYL'
; === Shapes ===
; Module: shapes
; Geometry helpers.

(deftype Shape (Circle Int) (Rect Int Int))

; Area of a shape.
; Returns: Int
(defn area (s) (match s (Circle r (* 3 (* r r))) (Rect w h (* w h))))

; internal note, not the doc
;| The perimeter.
(defn perimeter (s) 0)

(defn undocumented () 0)
ZYL
out="$("$ZYL" doc "$SCRATCH/lone/shapes.zyl")"
echo "$out" | grep -q '^# Module `shapes`' || fail "module title"
echo "$out" | grep -q '^\*Shapes\*' || fail "header title"
echo "$out" | grep -q '^Geometry helpers.' || fail "header text"
echo "$out" | grep -q '(defn area (s))' || fail "signature"
echo "$out" | grep -q '^Area of a shape.' || fail "item doc"
echo "$out" | grep -q '^The perimeter.' || fail ";| doc"
if echo "$out" | grep -q 'internal note'; then fail ";| should win over plain comments"; fi
echo "$out" | grep -q '(deftype Shape (Circle Int) (Rect Int Int))' || fail "type signature"

cat > "$SCRATCH/pkg/zyl.pkg" <<'PKG'
(package (name "acme/docs") (version "0.1.0") (zyl "5.0") (edition "2026"))
PKG
cat > "$SCRATCH/pkg/api.zyl" <<'ZYL'
; Exported.
(pub defn visible () 1)
; Private.
(defn hidden () 2)
ZYL
out="$("$ZYL" doc "$SCRATCH/pkg")"
echo "$out" | grep -q 'visible' || fail "pub item listed"
if echo "$out" | grep -q 'hidden'; then fail "private item listed in a package"; fi

"$ZYL" doc "$SCRATCH/lone" -o "$SCRATCH/out.md"
grep -q '^# Module `shapes`' "$SCRATCH/out.md" || fail "-o writes the file"
echo "ok"
