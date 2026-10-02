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
  '(vec-get! (vec-push (vec-new-cap 2) "v") 0)' \
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
# :type sees the session's defs; an entry's actors are joined before the prompt.
out3="$(printf '%s\n' \
  '(def n 3)' \
  ':type (+ n 1)' \
  '(capabilities actor)' \
  '(use actor/actor)' \
  '(def c (chan 2))' \
  '(def tx (chan-tx c))' \
  '(def rx (chan-rx c))' \
  '(spawn (fn () (begin (print "from actor") (chan-send tx 41))))' \
  '(+ (chan-recv rx) 1)' \
  | timeout 60 "$ZYL" repl 2>&1)" || fail "repl exited non-zero: $out3"
plain3="$(printf '%s' "$out3" | sed 's/\x1b\[[0-9;]*m//g')"
for want in '(+ n 1) : Int' 'from actor' '=> 42'; do
  printf '%s' "$plain3" | grep -qF -- "$want" || fail "missing '$want' in: $out3"
done
# An alias entry stays in the session and is transparent; a reserved name is refused.
out4="$(printf '%s\n' \
  '(alias RsM Int)' \
  '(defn rs-m ((x RsM)) x)' \
  '(rs-m "s")' \
  '(defn setup () 1)' \
  '(rs-m 7)' \
  | timeout 60 "$ZYL" repl 2>&1)" || fail "repl exited non-zero: $out4"
plain4="$(printf '%s' "$out4" | sed 's/\x1b\[[0-9;]*m//g')"
for want in 'takes `Int` as its 1st argument (`x`), but this is `String`' 'error[E_RESERVED_KEYWORD]' '=> 7'; do
  printf '%s' "$plain4" | grep -qF -- "$want" || fail "missing '$want' in: $out4"
done
echo "repl-session: ok"
