#!/bin/bash
# Build every benchmark in Zyl, C, C++, Rust and Go into bench/out/.
# Zyl uses build/boot/zyl-self (run ./boot.sh first) unless ZYL is set.
set -e
cd "$(dirname "$0")"
ROOT=$(cd .. && pwd)
ZYL=${ZYL:-$ROOT/build/boot/zyl-self}
export ZYL_HOME=${ZYL_HOME:-$ROOT/build/boot}
mkdir -p out
for f in fib loop list trees str sieve vec; do
    ( ulimit -v 4000000; "$ZYL" "$f.zyl" -o "out/$f.z" )
    gcc -O2 -o "out/$f.c.bin" "$f.c"
    g++ -O2 -o "out/$f.cpp.bin" "$f.cpp"
    rustc -C opt-level=3 -o "out/$f.rs.bin" "$f.rs"
    go build -o "out/$f.g" "$f.go"
done
echo "built into bench/out"
