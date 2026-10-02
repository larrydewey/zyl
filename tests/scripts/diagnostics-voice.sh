#!/usr/bin/env bash
# Pins the compiler's voice on the probe program of docs/diagnostics.md: a change in wording is a change here.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
cat > "$work/probe.zyl" <<'Z'
(defn classify (o) (match o (Some x (+ x 1)) (None 0)))
(defn twice (n) (let n (+ n 1) (let n (* n 2) n)))
(defn main ()
  (let r (classify (Some 4))
    (print (string-append "r=" (int->string r)))
    (print (string-append "t=" (int->string (twice "x"))))))
Z
cat > "$work/want" <<'W'
warning[W_SHADOWED_BINDING]: `n` shadows an outer binding of the same name
  --> probe.zyl:2:17
   |
 2 | (defn twice (n) (let n (+ n 1) (let n (* n 2) n)))
   |                 ^
   = help: rename one of the two bindings
warning[W_SHADOWED_BINDING]: `n` shadows an outer binding of the same name
  --> probe.zyl:2:32
   |
 2 | (defn twice (n) (let n (+ n 1) (let n (* n 2) n)))
   |                                ^
   = help: rename one of the two bindings
error[E_UNBOUND_VARIABLE]: `int->string` is not defined
  --> probe.zyl:5:32
   |
 5 |     (print (string-append "r=" (int->string r)))
   |                                ^
   = help: Zyl spells it `Show.show`
error[E_UNBOUND_VARIABLE]: `string-append` is not defined
  --> probe.zyl:5:12
   |
 5 |     (print (string-append "r=" (int->string r)))
   |            ^
   = help: Zyl spells it `str-concat`
error[E_TYPE_MISMATCH]: `twice` takes `Int` as its 1st argument (`n`), but this is `String`
  --> probe.zyl:6:52
   |
 6 |     (print (string-append "t=" (int->string (twice "x"))))))
   |                                                    ^
 2 | (defn twice (n) (let n (+ n 1) (let n (* n 2) n)))
   |              - `n` is declared here
error[E_TYPE_MISMATCH]: main must return the exit status, an Int, but this is `Unit`
  --> probe.zyl:6:5
   |
 6 |     (print (string-append "t=" (int->string (twice "x"))))))
   |     ^
   = help: end its body with `0`
4 errors; fix the first one first
W
got=$(cd "$work" && "$ZYL" probe.zyl -o p 2>&1); status=$?
[ $status -ne 0 ] || { echo "FAIL: the probe compiled"; exit 1; }
printf '%s\n' "$got" | sed "s#$work/##g" > "$work/got"
diff -u "$work/want" "$work/got" || { echo "FAIL: the probe's diagnostics changed"; exit 1; }
# One error: no closing count line.
printf '(defn main () (begin (print (+ 1 "a")) 0))\n' > "$work/one.zyl"
one=$(cd "$work" && "$ZYL" one.zyl -o o 2>&1)
printf '%s\n' "$one" | grep -q "errors; fix the first" && { echo "FAIL: a count line after one error: $one"; exit 1; }
printf '%s\n' "$one" | grep -q "PANIC" && { echo "FAIL: PANIC after a type error: $one"; exit 1; }
# A standard-library module's warnings are not the user's; ZYL_WARN_ALL=1 shows them.
printf '(use compiler/provenance)\n(defn main () 0)\n' > "$work/w.zyl"
n=$(cd "$work" && "$ZYL" w.zyl -o w 2>&1 | grep -c '^warning')
[ "$n" -eq 0 ] || { echo "FAIL: $n stdlib warnings shown"; exit 1; }
n=$(cd "$work" && ZYL_WARN_ALL=1 "$ZYL" w.zyl -o w 2>&1 | grep -c '^warning')
[ "$n" -gt 0 ] || { echo "FAIL: ZYL_WARN_ALL=1 shows no stdlib warning"; exit 1; }
# Output printed before a panic comes before the PANIC line, even through a pipe.
printf '(defn main () (begin (print "before") (panic "boom") 0))\n' > "$work/pf.zyl"
(cd "$work" && "$ZYL" pf.zyl -o pf) || { echo "FAIL: pf did not build"; exit 1; }
order=$("$work/pf" 2>&1 | tr '\n' '|')
[ "$order" = "before|PANIC: boom|  in main|" ] || { echo "FAIL: output order: $order"; exit 1; }
echo "diagnostics voice: probe output pinned"
