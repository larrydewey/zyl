#!/usr/bin/env bash
# An actor's exit or stack overflow lands at its join: same output under every schedule (spec 14, 15).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_actorstop.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

cat > "$SCRATCH/exit.zyl" <<'ZYL'
(capabilities actor)
(use actor/actor)
(defn loop (i n) (if (= i n) 0 (let _ (print i) (loop (+ i 1) n))))
(defn main ()
  (let a (spawn (fn () (begin (print "child") (exit 7))))
    (begin (loop 0 200) (actor-wait a) (print "unreached") 0)))
ZYL
cat > "$SCRATCH/overflow.zyl" <<'ZYL'
(capabilities actor)
(use actor/actor)
(defn deep (n) (+ 1 (deep (+ n 1))))
(defn spin (n acc) (if (= n 0) acc (spin (- n 1) (+ acc 1))))
(defn main ()
  (let a (spawn (fn () (begin (print "a start") (deep 0))))
    (let b (spawn (fn () (print (spin 3000000 0))))
      (begin (actor-wait b) (print "joined b") (try (actor-wait a) (catch e (print "caught"))) (print "after") 0))))
ZYL
# Two overflows, neither joined: the first in spawn order is reported at exit.
cat > "$SCRATCH/unjoined.zyl" <<'ZYL'
(capabilities actor)
(use actor/actor)
(defn deep (n) (+ 1 (deep (+ n 1))))
(defn main ()
  (let a (spawn (fn () (begin (print "a") (deep 0))))
    (let b (spawn (fn () (begin (print "b") (deep 0))))
      (begin (print "main") 0))))
ZYL
for p in exit overflow unjoined; do
    "$ZYL" "$SCRATCH/$p.zyl" -o "$SCRATCH/$p" > "$SCRATCH/build.log" 2>&1 || fail "build $p: $(cat "$SCRATCH/build.log")"
done

run() { set +e; out=$(env "$@" 2>"$SCRATCH/err"); rc=$?; set -e; }

want_exit="$(seq 0 199; echo child)"
for env in "X=1" "ZYL_SCHED=deterministic" "ZYL_SCHED_CHAOS=3"; do
    run $env "$SCRATCH/exit"
    [ "$rc" -eq 7 ] || fail "exit in an actor ($env) exited $rc: $(cat "$SCRATCH/err")"
    [ "$out" = "$want_exit" ] || fail "exit in an actor ($env): $out"
    grep -q E_DEADLOCK "$SCRATCH/err" && fail "spurious E_DEADLOCK ($env)"

    run $env "$SCRATCH/overflow"
    [ "$rc" -eq 1 ] || fail "actor overflow ($env) exited $rc"
    [ "$out" = "$(printf '3000000\njoined b\na start')" ] || fail "actor overflow ($env) stdout: $out"
    grep -q 'E_STACK_OVERFLOW' "$SCRATCH/err" || fail "no E_STACK_OVERFLOW ($env): $(cat "$SCRATCH/err")"

    run $env "$SCRATCH/unjoined"
    [ "$rc" -eq 1 ] || fail "unjoined overflows ($env) exited $rc"
    [ "$out" = "$(printf 'main\na')" ] || fail "unjoined overflows ($env) stdout: $out"
    [ "$(grep -c E_STACK_OVERFLOW "$SCRATCH/err")" -eq 1 ] || fail "unjoined overflows ($env) stderr: $(cat "$SCRATCH/err")"
done
echo ok
