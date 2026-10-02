#!/usr/bin/env bash
# An uncaught panic's backtrace (runtime/rt/panic.zyl, codegen's zyl_syms table): the `in` lines under PANIC,
# innermost first, 32 at most, in both link modes; nothing on the caught paths; byte-identical binaries.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_bt_test.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }
build() { "$ZYL" "$SCRATCH/$1.zyl" -o "$SCRATCH/$1" >/dev/null 2>&1 || fail "compile $1"; }
# Runs $1, keeps its stderr in $ERR and its status in $RC.
run() { set +e; "$SCRATCH/$1" >"$SCRATCH/$1.out" 2>"$SCRATCH/$1.err"; RC=$?; set -e; ERR="$SCRATCH/$1.err"; }
ins() { grep -c '^  in ' "$1" || true; }

# A non-tail recursion; the optimizer unrolls one level and the base case tail-jumps, so one parse-line frame remains.
cat > "$SCRATCH/nested.zyl" <<'EOF2'
(use collections/vec)

(defn parse-line (v n)
  (if (= n 0) (vec-get! v 7) (let r (parse-line v (- n 1)) (* r r))))

(defn parse-file (v)
  (let a (parse-line v 2)
    (let _ (print a) (+ a 1))))

(defn main ()
  (let v (vec-push (vec-new) 1)
    (let _ (print (parse-file v)) 0)))
EOF2
build nested
run nested
[ "$RC" = 1 ] || fail "nested: exit $RC"
want='PANIC: E_INDEX_OUT_OF_BOUNDS: vec-get! index 7 is outside a Vec of 1 elements
  = help: use `(vec-get? v i)` and match its Option, or check the index against `vec-len` first
  in vec-get!
  in parse-line
  in parse-file
  in main'
[ "$(cat "$ERR")" = "$want" ] || fail "nested: stderr: $(cat "$ERR")"

# `zyl eval` interprets in the compiler binary: its frames are the interpreter's, so it prints none.
set +e; "$ZYL" eval "$SCRATCH/nested.zyl" >/dev/null 2>"$SCRATCH/eval.err"; set -e
grep -q '^PANIC: E_INDEX_OUT_OF_BOUNDS' "$SCRATCH/eval.err" || fail "eval: no PANIC line"
[ "$(ins "$SCRATCH/eval.err")" = 0 ] || fail "eval: interpreter frames: $(grep '^  in ' "$SCRATCH/eval.err" | head -3)"

# The same binary twice: the table is part of the image and must not vary.
"$ZYL" "$SCRATCH/nested.zyl" -o "$SCRATCH/nested2" >/dev/null 2>&1 || fail "compile nested2"
cmp -s "$SCRATCH/nested" "$SCRATCH/nested2" || fail "two compiles differ"

# Deeper than 32 frames: 32 `in` lines, and main is past the cap.
cat > "$SCRATCH/deep.zyl" <<'EOF'
(use collections/vec)

(defn deep (v n)
  (if (= n 0) (vec-get! v 7) (let r (deep v (- n 1)) (* r r))))

(defn main ()
  (let v (vec-push (vec-new) 1)
    (let _ (print (deep v 100)) 0)))
EOF
build deep
run deep
[ "$RC" = 1 ] || fail "deep: exit $RC"
[ "$(ins "$ERR")" = 32 ] || fail "deep: $(ins "$ERR") frames"
grep -q '^  in main$' "$ERR" && fail "deep: main inside the cap"
[ "$(grep -m2 "^  in " "$ERR" | tail -1)" = "  in deep" ] || fail "deep: innermost frame"

# A caught panic prints nothing: try/catch, and the test harness's FAIL.
cat > "$SCRATCH/caught.zyl" <<'EOF'
(use collections/vec)

(defn main ()
  (let v (vec-push (vec-new) 1)
    (let r (try (vec-get! v 7) (catch e -1))
      (let _ (print r) 0))))
EOF
build caught
run caught
[ "$RC" = 0 ] || fail "caught: exit $RC"
[ ! -s "$ERR" ] || fail "caught: stderr: $(cat "$ERR")"
[ "$(cat "$SCRATCH/caught.out")" = "-1" ] || fail "caught: stdout"

cat > "$SCRATCH/harness.zyl" <<'EOF'
(use collections/vec)

(test "out of range"
  (let v (vec-push (vec-new) 1)
    (assert-equal (vec-get! v 7) 1)))

(run-tests)
EOF
build harness
run harness
grep -q 'FAIL: E_INDEX_OUT_OF_BOUNDS' "$SCRATCH/harness.out" || fail "harness: no FAIL line"
[ "$(ins "$ERR")" = 0 ] || fail "harness: frames on a caught path: $(cat "$ERR")"

# A program that calls foreign C links hosted over libc; the table and the walk are the same.
cat > "$SCRATCH/hosted.zyl" <<'EOF'
(capabilities ffi)
(use collections/vec)
(extern "abs" (Int) Int)

(defn parse-line (v n)
  (if (= n 0) (vec-get! v 7) (let r (parse-line v (- n 1)) (* r r))))

(defn main ()
  (let v (vec-push (vec-new) (ffi-call "abs" -1 1000))
    (let _ (print (parse-line v 2)) 0)))
EOF
build hosted
run hosted
[ "$RC" = 1 ] || fail "hosted: exit $RC"
[ "$(grep -m1 "^  in " "$ERR")" = "  in vec-get!" ] || fail "hosted: innermost frame: $(cat "$ERR")"
grep -q '^  in parse-line$' "$ERR" || fail "hosted: no parse-line frame"
[ "$(tail -1 "$ERR")" = "  in main" ] || fail "hosted: outermost frame: $(tail -1 "$ERR")"

# An actor's panic ends only the actor and is re-raised at the join, so the backtrace is the joiner's.
cat > "$SCRATCH/actor.zyl" <<'EOF'
(capabilities actor)
(use collections/vec)
(use actor/actor)

(defn parse-line (v n)
  (if (= n 0) (vec-get! v 7) (let r (parse-line v (- n 1)) (* r r))))

(defn main ()
  (let v (vec-push (vec-new) 1)
    (let a (spawn (fn () (parse-line v 2)))
      (let _ (actor-wait a) 0))))
EOF
build actor
run actor
[ "$RC" = 1 ] || fail "actor: exit $RC"
want='PANIC: E_INDEX_OUT_OF_BOUNDS: vec-get! index 7 is outside a Vec of 1 elements
  = help: use `(vec-get? v i)` and match its Option, or check the index against `vec-len` first
  in main'
[ "$(cat "$ERR")" = "$want" ] || fail "actor: stderr: $(cat "$ERR")"

echo "panic-backtrace: ok"
