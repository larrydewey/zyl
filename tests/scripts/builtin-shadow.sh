#!/usr/bin/env bash
# Spec 1.3.2: a local named like a built-in is E_SHADOWS_BUILTIN, and every other name the compiler mentions reaches a local when called.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_shadow_test.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

# The reserved list, read from the check itself.
sed -n '/^(defn bs-names/,/^$/p' "$ROOT/stdlib/compiler/shadow_check.zyl" | grep -o '"[^"]*"' | tr -d '"' | sort -u > "$SCRATCH/reserved"
[ "$(wc -l < "$SCRATCH/reserved")" -gt 150 ] || fail "could not read bs-names"
# Every name the compiler spells as a string: a head it may dispatch on.
grep -ohE '"[^" \\]+"' "$ROOT"/stdlib/compiler/*.zyl | tr -d '"' \
  | grep -E '^[a-zA-Z!%*+<>=?_-][a-zA-Z0-9!%*+<>=?_-]*$' | grep -vxE 'true|false|unit|_' | sort -u > "$SCRATCH/names"
comm -23 "$SCRATCH/names" "$SCRATCH/reserved" > "$SCRATCH/free"
[ "$(wc -l < "$SCRATCH/free")" -gt 500 ] || fail "too few candidate names"

# A reserved name as a let, parameter, match, catch and for binder: each is rejected.
probe_reserved() {
  local n="$1" d="$SCRATCH/r_$2"
  mkdir -p "$d"
  printf '(defn main ()\n  (let %s 1 0))\n' "$n" > "$d/let.zyl"
  printf '(defn f (%s) 0)\n(defn main () (f 1))\n' "$n" > "$d/param.zyl"
  printf '(defn main ()\n  (match (Some 1) (Some %s 0) (None 0)))\n' "$n" > "$d/match.zyl"
  printf '(defn main ()\n  (try 0 (catch %s 1)))\n' "$n" > "$d/catch.zyl"
  printf '(defn main ()\n  (let _ (for (%s 0) false unit) 0))\n' "$n" > "$d/for.zyl"
  local f out
  for f in let param match catch for; do
    if out="$("$ZYL" check "$d/$f.zyl" 2>&1)"; then echo "reserved \`$n\` as a $f binder was accepted: $out"; fi
  done
}
# Any other name, bound to a function and called, must call it.
probe_free() {
  local n="$1" d="$SCRATCH/f_$2"
  mkdir -p "$d"
  printf '(defn main ()\n  (let %s (fn (_a) 7)\n    (begin (print (%s 1)) 0)))\n' "$n" "$n" > "$d/p.zyl"
  if "$ZYL" "$d/p.zyl" -o "$d/p" >"$d/err" 2>&1; then
    [ "$("$d/p")" = "7" ] || echo "a local named \`$n\` is not what (${n} 1) calls: add it to bs-names"
  fi
}
export -f probe_reserved probe_free
export ZYL SCRATCH
# Control: the five templates compile with an ordinary name.
probe_reserved zz_ok 0 > "$SCRATCH/ctl"
[ "$(grep -c accepted "$SCRATCH/ctl")" = 5 ] || fail "binder templates do not compile: $(cat "$SCRATCH/ctl")"
nl -ba "$SCRATCH/reserved" | xargs -P8 -n2 bash -c 'probe_reserved "$1" "$0"' > "$SCRATCH/out_r"
nl -ba "$SCRATCH/free" | xargs -P8 -n2 bash -c 'probe_free "$1" "$0"' > "$SCRATCH/out_f"
[ -s "$SCRATCH/out_r" ] && fail "$(head -5 "$SCRATCH/out_r")"
[ -s "$SCRATCH/out_f" ] && fail "$(head -5 "$SCRATCH/out_f")"

# The diagnostic is located at the binder and suggests a rename; zyl check agrees with a build.
cat > "$SCRATCH/loc.zyl" <<'EOF'
(defn total (xs)
  (match xs
    (Nil 0)
    (Cons print rest (+ print (total rest)))))
(defn main () (total [1 2]))
EOF
out="$("$ZYL" "$SCRATCH/loc.zyl" -o "$SCRATCH/loc" 2>&1 || true)"
case "$out" in *"E_SHADOWS_BUILTIN"*"loc.zyl:4:11"*"print-value"*) ;; *) fail "located report: $out" ;; esac
out2="$("$ZYL" check "$SCRATCH/loc.zyl" 2>&1 || true)"
case "$out2" in *"E_SHADOWS_BUILTIN"*"loc.zyl:4:11"*) ;; *) fail "zyl check disagrees: $out2" ;; esac
echo "builtin-shadow: ok"
