#!/usr/bin/env bash
# A multi-entry REPL session: each entry's arena is released, so nothing a
# later entry reads (compiler side tables included) may point into it.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
fail() { echo "FAIL: $*"; exit 1; }

out="$(printf '%s\n' \
  '(+ 1 2)' \
  '(defn f (x) (str-concat x "!"))' \
  '(f "a")' \
  '(deftype RsT (RsA String) (RsB Int))' \
  '(defn g (t) (match t (RsA s s) (RsB _ "b")))' \
  '(g (RsA "x"))' \
  '(use collections/vec)' \
  '(vec-get (vec-push (vec-create-default 2) "v") 0)' \
  '(derive RsT Show)' \
  '(print (RsA "shown"))' \
  | timeout 60 "$ZYL" repl 2>&1)" || fail "repl exited non-zero: $out"
for want in '=> 3' '=> "a!"' '=> "x"' '=> "v"' 'RsA(shown)'; do
  printf '%s' "$out" | sed 's/\x1b\[[0-9;]*m//g' | grep -qF -- "$want" || fail "missing '$want' in: $out"
done
# A definition entered at the prompt can use a prompt `def`; the def's
# expression is not run again.
out2="$(printf '%s\n' \
  '(def base (begin (print "computed") 10))' \
  '(defn add-base (x) (+ x base))' \
  '(add-base 5)' \
  '(add-base 6)' \
  '(def greet "hi")' \
  '(defn shout () (str-concat greet "!"))' \
  '(shout)' \
  | timeout 60 "$ZYL" repl 2>&1)" || fail "repl exited non-zero: $out2"
plain="$(printf '%s' "$out2" | sed 's/\x1b\[[0-9;]*m//g')"
for want in '=> 15' '=> 16' '=> "hi!"'; do
  printf '%s' "$plain" | grep -qF -- "$want" || fail "missing '$want' in: $out2"
done
[ "$(printf '%s' "$plain" | grep -c computed)" = "1" ] || fail "a def's expression must run once: $out2"
echo "repl-session: ok"
