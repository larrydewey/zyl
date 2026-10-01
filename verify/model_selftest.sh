#!/usr/bin/env bash
# Prove that verify/model.py fails when it should.
#
# model.py's result is only evidence if the checker can fail. This runs it
# against a deliberately broken copy of the model -- one that lets a region
# release a block another region still owns, i.e. a double free -- and
# requires a violation to be reported.
#
# The broken copy is written to a scratch directory and never touches the
# repository, so nothing here can weaken the real check.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SCRATCH=$(mktemp -d "${TMPDIR:-/tmp}/zyl-model-selftest.XXXXXX")
trap 'rm -rf "$SCRATCH"' EXIT

python3 - "$SCRIPT_DIR/model.py" "$SCRATCH/model_broken.py" <<'PY'
import sys

src_path, dst_path = sys.argv[1], sys.argv[2]
src = open(src_path).read()

# op_release_block gains a path that hands the top region a block belonging to
# a lower one, then releases it. That is a double free, and it breaks block
# conservation, so the model checker must report it.
old = """    if idx >= len(blocks):
        return None
    target = blocks[idx]"""
new = """    if idx >= len(blocks):
        return None
    if idx == 0 and not s.get("_bugged"):
        others = [b for r, bs in s["regions"][:-1] for b in bs]
        if others:
            t = dict(s)
            t["_bugged"] = 1
            t["regions"] = s["regions"][:-1] + ((rid, blocks + (others[0],)),)
            t["_created"] = s.get("_created", 0)
            return t
    target = blocks[idx]"""

if src.count(old) != 1:
    sys.stderr.write("model_selftest: op_release_block moved; the injection no longer applies\n")
    sys.exit(2)
open(dst_path, "w").write(src.replace(old, new))
PY
if [ $? -ne 0 ]; then
    echo "model_selftest: could not build the broken model"
    exit 1
fi

# The broken model lives outside the repo, so give it the source it
# cross-checks by pointing it at the real tree.
out=$(cd "$REPO_ROOT" && ZYL_REPO_ROOT="$REPO_ROOT" ZYL_MODEL_STATES=200000 ZYL_MODEL_DEPTH=6 \
      python3 "$SCRATCH/model_broken.py" 2>&1)
rc=$?

if [ "$rc" -eq 0 ]; then
    echo "model_selftest: FAILED -- a double-free allocator passed the checker"
    echo "$out" | sed 's/^/    /'
    exit 1
fi

if ! echo "$out" | grep -q "INVARIANT VIOLATED"; then
    echo "model_selftest: the broken model failed for the wrong reason:"
    echo "$out" | sed 's/^/    /'
    exit 1
fi

trace=$(echo "$out" | grep "via:" | head -1 | sed 's/^ *//')
echo "  ok  a double-free allocator is caught ($trace)"
exit 0
