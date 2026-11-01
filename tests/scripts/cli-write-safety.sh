#!/usr/bin/env bash
# A write the CLI cannot finish is an error with a nonzero exit, and a source file it rewrites is never left truncated.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
S="$(mktemp -d "${TMPDIR:-/tmp}/zyl_cliwrite.XXXXXX")"
trap 'chmod -R u+rwx "$S"; rm -rf "$S"' EXIT
fail() { echo "FAIL: $*"; exit 1; }
# RLIMIT_FSIZE=0 with SIGXFSZ ignored makes every write fail with EFBIG, as a full disk would.
# Its output goes through a pipe, since the limit would refuse a log file too.
full() { (trap "" XFSZ; ulimit -S -f 0; exec "$@") 2>&1 | cat; return "${PIPESTATUS[0]}"; }

printf '(defn main ()\n0)\n' > "$S/unfmt.zyl"
printf '(defn main ()\n  (let x 1\n    x)\n' > "$S/unbal.zyl"
cat > "$S/ok.zyl" <<'ZYL'
(defn main () (begin (print "hi") 0))
ZYL
chmod 754 "$S/unfmt.zyl"

before=$(cat "$S/unfmt.zyl")
if full "$ZYL" fmt "$S/unfmt.zyl" > "$S/log" 2>&1; then fail "fmt on a full disk exited 0: $(cat "$S/log")"; fi
[ "$(cat "$S/unfmt.zyl")" = "$before" ] || fail "fmt on a full disk changed the file"
grep -q "cannot write" "$S/log" || fail "fmt did not say it could not write: $(cat "$S/log")"
ls "$S" | grep -q zyl-tmp && fail "fmt left its temp file"

before=$(cat "$S/unbal.zyl")
if full "$ZYL" balance --fix "$S/unbal.zyl" > "$S/log" 2>&1; then fail "balance --fix on a full disk exited 0"; fi
[ "$(cat "$S/unbal.zyl")" = "$before" ] || fail "balance --fix on a full disk changed the file"

"$ZYL" fmt "$S/unfmt.zyl" > "$S/log" 2>&1 || fail "fmt: $(cat "$S/log")"
[ "$(stat -c %a "$S/unfmt.zyl")" = 754 ] || fail "fmt did not keep the file's mode"
"$ZYL" balance --fix "$S/unbal.zyl" > "$S/log" 2>&1 || fail "balance --fix: $(cat "$S/log")"
"$ZYL" balance "$S/unbal.zyl" > /dev/null 2>&1 || fail "balance --fix did not balance the file"

mkdir "$S/ro"; chmod 555 "$S/ro"
for args in "-o $S/ro/x" "--emit-asm -o $S/ro/x.s" "--emit-asm -o /dev/full"; do
    # shellcheck disable=SC2086
    if "$ZYL" "$S/ok.zyl" $args > "$S/log" 2>&1; then fail "build $args exited 0"; fi
    grep -q "cannot write" "$S/log" || fail "build $args: $(cat "$S/log")"
    grep -q PANIC "$S/log" && fail "build $args panicked: $(cat "$S/log")"
done
if full "$ZYL" "$S/ok.zyl" --emit-asm -o "$S/full.s" > "$S/log" 2>&1; then fail "--emit-asm on a full disk exited 0"; fi
if "$ZYL" doc "$S/ok.zyl" -o /dev/full > "$S/log" 2>&1; then fail "doc -o /dev/full exited 0"; fi

if [ "$(id -u)" != 0 ]; then
    cp "$S/ok.zyl" "$S/noperm.zyl"; chmod 000 "$S/noperm.zyl"
    if "$ZYL" fmt "$S/noperm.zyl" > "$S/log" 2>&1; then fail "fmt on an unreadable file exited 0"; fi
fi

if "$ZYL" "$S/ok.zyl" --contracts=bogus -o "$S/c" > "$S/log" 2>&1; then fail "--contracts=bogus was accepted"; fi
grep -q "unknown contract profile" "$S/log" || fail "--contracts=bogus: $(cat "$S/log")"
"$ZYL" --contracts=warn "$S/ok.zyl" -o "$S/c" > "$S/log" 2>&1 || fail "a flag before the file: $(cat "$S/log")"
[ "$("$S/c")" = hi ] || fail "a flag before the file built the wrong program"

mkdir "$S/adir.zyl"
if "$ZYL" "$S/adir.zyl" -o "$S/x" > "$S/log" 2>&1; then fail "a directory source exited 0"; fi
grep -q "is a directory" "$S/log" || fail "a directory source: $(cat "$S/log")"
if "$ZYL" /dev/null -o "$S/x" > "$S/log" 2>&1; then fail "an unknown command exited 0"; fi
echo "ok"
