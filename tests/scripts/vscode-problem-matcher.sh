#!/usr/bin/env bash
# The VS Code extension's `$zyl` problem matcher (editors/vscode/package.json)
# must parse the compiler's real diagnostics: the headline gives severity,
# code and message, and the `-->` line the file, line and column.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_matcher_test.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
command -v python3 >/dev/null || { echo "ok (python3 not installed; skipped)"; exit 0; }

printf '(defn main ()\n  (let unused 1\n    (begin (print (undefined-fn 2)) 0)))\n' > "$SCRATCH/bad.zyl"
"$ZYL" "$SCRATCH/bad.zyl" -o "$SCRATCH/bad" > "$SCRATCH/out.txt" 2>&1 || true
python3 - "$ROOT/editors/vscode/package.json" "$SCRATCH/out.txt" <<'PY'
import json, re, sys
pm = json.load(open(sys.argv[1]))["contributes"]["problemMatchers"][0]
head, loc = (re.compile(p["regexp"]) for p in pm["pattern"])
lines = open(sys.argv[2]).read().splitlines()
found = []
for i, line in enumerate(lines):
    m = head.match(line)
    if m and i + 1 < len(lines):
        l = loc.match(lines[i + 1])
        if l:
            found.append((m.group(1), m.group(2), l.group(2), l.group(3)))
kinds = {(k, c) for k, c, _, _ in found}
assert ("warning", "W_UNUSED_VARIABLE") in kinds, found
assert ("error", "E_UNBOUND_VARIABLE") in kinds, found
assert all(int(line) > 0 and int(col) > 0 for _, _, line, col in found), found
print("ok")
PY
