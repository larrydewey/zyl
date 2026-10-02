#!/usr/bin/env bash
# W_PANIC_UNMARKED: a program's plain-named defn that calls panic directly
# is warned about, located at the defn, with the rename as the help; a
# `!` name, `main`, a test body, and a panic behind a callee are not.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_panic_unmarked.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }
compile() { "$ZYL" "$1" -o "$SCRATCH/out" 2>&1 || true; }

# A plain name that calls panic: the warning, at the defn, with the rename.
cat > "$SCRATCH/plain.zyl" <<'EOF'
(defn parse (s)
  (if (str-eq s "") (panic "empty") 1))
(defn main () (begin (print (parse "x")) 0))
EOF
out="$(compile "$SCRATCH/plain.zyl")"
printf '%s\n' "$out" | grep -q 'warning\[W_PANIC_UNMARKED\]: `parse` can stop the program but is not spelled `parse!`' \
  || fail "plain name: $out"
printf '%s\n' "$out" | grep -q -- '--> .*plain.zyl:1:1' || fail "location: $out"
printf '%s\n' "$out" | grep -q 'help: rename it `parse!` so callers can see it may stop the program, or return an Option' \
  || fail "help: $out"
[ -x "$SCRATCH/out" ] || fail "a warning must not stop the build"

# The same program with the name spelled: silent.
sed 's/parse/parse!/g' "$SCRATCH/plain.zyl" > "$SCRATCH/spelled.zyl"
out="$(compile "$SCRATCH/spelled.zyl")"
printf '%s\n' "$out" | grep -q 'W_PANIC_UNMARKED' && fail "spelled name warned: $out"

# main, a test body, and a caller of parse! (no direct panic): silent.
cat > "$SCRATCH/exempt.zyl" <<'EOF'
(use testing/testing)
(defn parse! (s) (if (str-eq s "") (panic "empty") 1))
(defn count (s) (+ 1 (parse! s)))
(test "a test body may panic" (assert-equal (try (parse! "") (catch _e 0)) 0))
(defn main () (begin (if (= (count "x") 2) 0 (panic "unreachable"))))
EOF
out="$(compile "$SCRATCH/exempt.zyl")"
printf '%s\n' "$out" | grep -q 'W_PANIC_UNMARKED' && fail "exempt definition warned: $out"

# JSON diagnostics carry the code and the location.
out="$("$ZYL" "$SCRATCH/plain.zyl" -o "$SCRATCH/out" --error-format=json 2>&1 || true)"
printf '%s\n' "$out" | grep -q '"severity":"warning","code":"W_PANIC_UNMARKED".*"line":1,"column":1' \
  || fail "json: $out"

echo "panic-unmarked: ok"
