# Benchmarks

Seven small programs, each written in Zyl, C, C++, Rust and Go with the
same algorithm: `fib` (recursive calls), `loop` (integer arithmetic),
`list` (cons cells), `trees` (binary trees), `str` (int-to-string and
concatenation), `sieve` (byte array), `vec` (growable array).

    ./bench/build.sh      # C/C++ -O2, Rust opt-level=3, Go default
    python3 bench/matrix.py

The native-backend work (`docs/native-backend-design.md`) is measured
against this matrix.
