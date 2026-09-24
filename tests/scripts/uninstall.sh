#!/usr/bin/env bash
# uninstall.sh must remove only what install.sh installs, keep the user's
# keys, package store and REPL files, and delete everything only with
# --purge. Runs against a scratch ZYL_HOME, never the real ~/.zyl.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_uninstall_test.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

layout() {
    local h="$1"
    mkdir -p "$h/bin" "$h/stdlib/core" "$h/keys" "$h/store/x" "$h/index"
    for f in stage2.bin zyl-repl-bin zyl-lsp-bin zyl zyl-repl zyl-lsp; do
        echo x > "$h/bin/$f"
    done
    echo x > "$h/stdlib/core/core.zyl"
    for f in actor_runtime.c actor_runtime.h env env.fish; do echo x > "$h/$f"; done
    echo secret > "$h/keys/publisher.key"
    echo x > "$h/store/x/pkg"
    echo x > "$h/repl_history"
    echo x > "$h/replrc"
}

# Default: installed files go, user data stays.
H="$SCRATCH/home1"
layout "$H"
echo mine > "$H/bin/my-tool"
out="$(ZYL_HOME="$H" "$ROOT/uninstall.sh" </dev/null)"
[ -f "$H/keys/publisher.key" ] || fail "keys removed without --purge"
[ -f "$H/store/x/pkg" ] || fail "store removed without --purge"
[ -f "$H/repl_history" ] && [ -f "$H/replrc" ] || fail "REPL files removed"
[ -f "$H/bin/my-tool" ] || fail "a file install.sh did not write was removed from bin/"
for f in bin/stage2.bin bin/zyl bin/zyl-lsp-bin stdlib actor_runtime.c env env.fish; do
    [ -e "$H/$f" ] && fail "$f not removed"
done
echo "$out" | grep -q "keys/" || fail "kept keys/ not reported"
echo "$out" | grep -q "purge" || fail "--purge not mentioned"

# Only installed files present: the directory itself goes.
H="$SCRATCH/home2"
mkdir -p "$H/bin" "$H/stdlib"
echo x > "$H/bin/zyl"; echo x > "$H/env"
ZYL_HOME="$H" "$ROOT/uninstall.sh" </dev/null >/dev/null
[ -e "$H" ] && fail "empty install directory left behind"

# --purge without a terminal and without --yes refuses.
H="$SCRATCH/home3"
layout "$H"
if ZYL_HOME="$H" "$ROOT/uninstall.sh" --purge </dev/null >/dev/null 2>&1; then
    fail "--purge ran without confirmation"
fi
[ -f "$H/keys/publisher.key" ] || fail "unconfirmed --purge removed keys"

# --purge --yes removes everything.
out="$(ZYL_HOME="$H" "$ROOT/uninstall.sh" --purge --yes </dev/null)"
[ -e "$H" ] && fail "--purge --yes left $H"
echo "$out" | grep -q "WARNING" || fail "--purge printed no warning"

echo "uninstall: ok"
