#!/usr/bin/env bash
# The runtime's buffered stdout (runtime/rt/out.zyl): print formats, flush points, ordering, threads, SIGPIPE.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export ZYL_HOME="${ZYL_HOME:-$ROOT/build/boot}"
ZYL="$ROOT/build/boot/zyl-self"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zyl_stdout_test.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { echo "FAIL: $*"; exit 1; }
build() { "$ZYL" "$SCRATCH/$1.zyl" -o "$SCRATCH/$1" >/dev/null 2>&1 || fail "compile $1"; }

# print's three formats: "%lld\n", "%s\n", "%f\n".
cat > "$SCRATCH/fmt.zyl" <<'EOF'
(defn main ()
  (begin
    (print 0) (print -1) (print 9223372036854775807) (print (- 0 9223372036854775807))
    (print "") (print "a b")
    (print 0.0) (print -0.0) (print 2.5e-7) (print 1e20) (print 0.1234565) (print (/ 1.0 0.0)) (print (/ -1.0 0.0))
    0))
(numeric checked)
EOF
build fmt
# The bytes glibc's printf gave before print moved to the runtime.
want=$(printf '%s\n' 0 -1 9223372036854775807 -9223372036854775807 '' 'a b' \
  0.000000 -0.000000 0.000000 100000000000000000000.000000 0.123456 inf -inf)
[ "$("$SCRATCH/fmt" | cat)" = "$want" ] || fail "print formats: $("$SCRATCH/fmt" | cat)"

# A child's output follows what the parent printed before spawning it; exit flushes.
cat > "$SCRATCH/order.zyl" <<'EOF'
(defn main ()
  (let _ (print "a")
    (let _ (ffi-call "zyl_system_cmd" "echo b" 5000)
      (let _ (print "c") (exit 3)))))
(numeric checked)
EOF
build order
set +e; out=$("$SCRATCH/order" | cat); rc=${PIPESTATUS[0]}; set -e
[ "$out" = "$(printf 'a\nb\nc')" ] || fail "spawn order: $out"
"$SCRATCH/order" >/dev/null && fail "exit code lost"
[ "$("$SCRATCH/order" >/dev/null; echo $?)" = 3 ] || fail "exit code"

# A panic still delivers the buffered stdout, after the stderr text of the panic.
cat > "$SCRATCH/panic.zyl" <<'EOF'
(defn main () (let _ (print "before") (let _ (panic "boom") 0)))
(numeric checked)
EOF
build panic
out=$("$SCRATCH/panic" 2>/dev/null | cat || true)
[ "$out" = "before" ] || fail "panic lost stdout: $out"

# Actors print whole lines: every line intact, none lost, 8 x 2000 in all.
cat > "$SCRATCH/actors.zyl" <<'EOF'
(capabilities actor)
(use actor/actor)
(defn say (k i) (if (= i 2000) 0 (let _ (print (str-concat "actor-line-" (str-concat (ffi-call "zyl_int_text" k 1000) "-0123456789abcdefghijklmnopqrstuvwxyz"))) (say k (+ i 1)))))
(defn go (k) (if (= k 8) 0 (let _ (spawn (fn () (say k 0))) (go (+ k 1)))))
(defn main () (let _ (go 0) 0))
(numeric checked)
EOF
build actors
"$SCRATCH/actors" > "$SCRATCH/actors.out"
[ "$(wc -l < "$SCRATCH/actors.out")" = 16000 ] || fail "actor lines lost: $(wc -l < "$SCRATCH/actors.out")"
bad=$(grep -cvE '^actor-line-[0-7]-0123456789abcdefghijklmnopqrstuvwxyz$' "$SCRATCH/actors.out" || true)
[ "$bad" = 0 ] || fail "$bad torn actor lines"

# Large output through head: the default SIGPIPE kills (141); ignored, EPIPE is silent and the exit is 0.
cat > "$SCRATCH/big.zyl" <<'EOF'
(defn loop (i) (if (< i 300000) (let _ (print i) (loop (+ i 1))) 0))
(defn main () (loop 0))
(numeric checked)
EOF
build big
[ "$("$SCRATCH/big" | md5sum)" = "$(seq 0 299999 | md5sum)" ] || fail "big output differs"
set +e; first=$("$SCRATCH/big" | head -1); rc=${PIPESTATUS[0]}; set -e
[ "$first" = 0 ] && [ "$rc" = 141 ] || fail "head: '$first' rc=$rc"
set +e; err=$( (trap '' PIPE; "$SCRATCH/big" 2>&1 >&3 | cat; exit "${PIPESTATUS[0]}") 3> >(head -1 >/dev/null) ); set -e
[ -z "$err" ] || fail "EPIPE printed: $err"

# On a terminal each line is written as it is printed.
if command -v script >/dev/null && command -v strace >/dev/null; then
  script -qc "strace -f -o $SCRATCH/tty.trace -e trace=write $SCRATCH/fmt" /dev/null >/dev/null 2>&1 || true
  if [ -s "$SCRATCH/tty.trace" ]; then
    [ "$(grep -c 'write(1' "$SCRATCH/tty.trace")" = 13 ] || fail "tty not line-buffered"
  fi
fi
echo ok
