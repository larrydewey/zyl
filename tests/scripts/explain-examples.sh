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
[ $fail -eq 0 ] && echo "explain examples: $n codes, every wrong program raises its code, every fix runs"
exit $fail
