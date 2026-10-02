#!/usr/bin/env bash
# The catalog is exact: every code in error_codes.zyl is raised somewhere, and every raised code is catalogued.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
CAT=stdlib/compiler/error_codes.zyl
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
grep -oE '\(EC "[EW]_[A-Z0-9_]+"' "$CAT" | sed 's/(EC "//;s/"//' | sort -u > "$tmp/defined"
# A raise is the code at the start of a string literal, after `PANIC: `, or inside `[...]`; comment lines do not count.
find stdlib selfhost runtime tools -name '*.zyl' ! -path "$CAT" ! -path stdlib/compiler/explain.zyl -print0 | sort -z \
  | xargs -0 grep -hvE '^[[:space:]]*;' \
  | grep -oE '"(PANIC: )?[EW]_[A-Z0-9_]+|\[[EW]_[A-Z0-9_]+\]' \
  | sed -E 's/^"(PANIC: )?//;s/^\[//;s/\]$//' | sort -u > "$tmp/raised"
dead=$(comm -23 "$tmp/defined" "$tmp/raised")
undef=$(comm -13 "$tmp/defined" "$tmp/raised")
status=0
if [ -n "$dead" ]; then echo "defined in $CAT but raised nowhere:"; echo "$dead" | sed 's/^/  /'; status=1; fi
if [ -n "$undef" ]; then echo "raised but not defined in $CAT:"; echo "$undef" | sed 's/^/  /'; status=1; fi
[ $status -eq 0 ] && echo "error codes: $(wc -l < "$tmp/defined") defined, every one raised, none raised undefined"
exit $status
