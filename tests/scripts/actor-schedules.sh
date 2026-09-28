#!/usr/bin/env bash
# Kahn actors (runtime/rt/chan.zyl): deadlock, exit order, panics and main's panic give fixed output under every schedule.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_sched_test.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }
build() { "$ZYL" "$SCRATCH/$1.zyl" -o "$SCRATCH/$1" >/dev/null 2>&1 || fail "compile $1"; }
# Runs $1 under each schedule; every run must print exactly $2 (stdout then stderr) and exit $3.
check() {
  local mode out
  for mode in A=1 ZYL_SCHED=deterministic ZYL_SCHED_CHAOS=1 ZYL_SCHED_CHAOS=9 ZYL_SCHED_CHAOS=31; do
    out="$(env "$mode" timeout 20 "$SCRATCH/$1" 2>"$SCRATCH/err"; echo "exit $?")"
    out="$out
$(cat "$SCRATCH/err")"
    [ "$out" = "$2
exit $3
$4" ] || fail "$1 under $mode: $out"
  done
}

cat > "$SCRATCH/dl.zyl" <<'EOF'
(defn main ()
  (let c (chan 1)
    (let rx (chan-rx c)
      (let tx (chan-tx c)
        (let _ (spawn (fn () (let _ (print "child waits") (chan-recv rx))))
          (let _ (print "main waits") (let _ (chan-recv (chan-rx (chan 1))) (let _ (chan-send tx 1) 0))))))))
EOF
build dl

cat > "$SCRATCH/exit.zyl" <<'EOF'
(defn main ()
  (let _ (spawn (fn () (print "one")))
    (let _ (spawn (fn () (let _ (print "two") (error "late"))))
      (let _ (spawn (fn () (print "three"))) (let _ (print "main end") 0)))))
EOF
build exit

cat > "$SCRATCH/mp.zyl" <<'EOF'
(defn main ()
  (let c (chan 1)
    (let rx (chan-rx c)
      (let _ (spawn (fn () (let _ (print "never shown") (chan-recv rx))))
        (let _ (print "main") (error "main fails"))))))
EOF
build mp

cat > "$SCRATCH/late.zyl" <<'EOF'
(use actor/actor)
(defn spin (n) (if (= n 0) 0 (spin (- n 1))))
(defn main ()
  (let c (chan 1)
    (let rx (chan-rx c)
      (let tx (chan-tx c)
        (let a (spawn (fn () (let _ (chan-send tx 1) (chan-send tx 2))))
          (let _b (spawn (fn () (let _ rx (let _ (spin 30000000) (print "b done")))))
            (let _ (actor-wait a) 0)))))))
EOF
build late

check dl "main waits
child waits" 1 "PANIC: E_DEADLOCK: every live actor is blocked on a channel or a join"
check exit "main end
one
two
three" 1 "PANIC: late"
check mp "main" 1 "PANIC: main fails"
check late "b done" 1 "PANIC: E_DEADLOCK: every live actor is blocked on a channel or a join"
echo ok
