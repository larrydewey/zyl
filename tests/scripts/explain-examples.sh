#!/usr/bin/env bash
# Every `zyl explain` table entry: the wrong program raises its code, the corrected one builds and exits 0.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
Z="$ROOT/build/boot/zyl-self"
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
codes=$(grep -oE '\(ExN "[EW]_[A-Z0-9_]+"' "$ROOT/stdlib/compiler/explain.zyl" | sed 's/(ExN "//;s/"//')
[ -n "$codes" ] || { echo "no table entries found"; exit 1; }
fail=0; n=0
for c in $codes; do
  n=$((n+1))
  out=$(cd "$work" && "$Z" explain "$c")
  printf '%s\n' "$out" | awk '/^  wrong:$/{f=1;next} /^  right:$/{f=0} f' | sed 's/^    //' > "$work/wrong.zyl"
  printf '%s\n' "$out" | awk '/^  right:$/{f=1;next} /^$/{f=0} f' | sed 's/^    //' > "$work/right.zyl"
  [ -s "$work/wrong.zyl" ] && [ -s "$work/right.zyl" ] || { echo "FAIL $c: no wrong/right program in explain output"; fail=1; continue; }
  got=$(cd "$work" && { "$Z" wrong.zyl -o w 2>&1 && ./w 2>&1 >/dev/null; }; rm -f "$work/w")
  printf '%s\n' "$got" | grep -q "$c" || { echo "FAIL $c: wrong program did not raise it:"; printf '%s\n' "$got" | head -5; fail=1; }
  got=$(cd "$work" && "$Z" right.zyl -o r 2>&1 && ./r 2>&1 >/dev/null) || { echo "FAIL $c: corrected program failed:"; printf '%s\n' "$got" | head -5; fail=1; }
  rm -f "$work/r"
done
# `zyl explain warnings`: every severity-2 code is listed, each with what
# to do, and the count matches the catalog. A warning a reader cannot act
# on is the one that reads as a failure.
w=$("$Z" explain warnings)
for c in $("$Z" explain | awk '/warning\)/ {print $1}' | tr -d '`'); do
  printf '%s\n' "$w" | grep -q "^  $c  " || { echo "FAIL warnings: $c not listed"; fail=1; }
done
listed=$(printf '%s\n' "$w" | grep -c '^  [EW]_')
catalog=$(grep -oE '" [0-9]+ 2 "' "$ROOT/stdlib/compiler/error_codes.zyl" | wc -l)
[ "$listed" -eq "$catalog" ] || { echo "FAIL warnings: $listed listed, $catalog in the catalog"; fail=1; }
printf '%s\n' "$w" | grep -q "the build goes on" || { echo "FAIL warnings: does not say the build goes on"; fail=1; }
one=$("$Z" explain W_UNUSED_PARAMETER)
printf '%s\n' "$one" | grep -q "(definitions and bindings, warning)" || { echo "FAIL explain: severity not named"; fail=1; }
printf '%s\n' "$one" | grep -q "the build goes on" || { echo "FAIL explain: no 'the build goes on' for a warning"; fail=1; }

[ $fail -eq 0 ] && echo "explain examples: $n codes, every wrong program raises its code, every fix runs; $listed warnings listed with fixes"
exit $fail
