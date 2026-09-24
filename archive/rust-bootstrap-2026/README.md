# Archived: Rust bootstrap compiler

This is the original Rust implementation of the Zyl compiler. It built
the self-hosted seeds up to its retirement (commit `baa773a`, "archive
the Rust bootstrap", 2026-09-17); every seed committed since then —
two dozen of them, including the one currently at
`build/boot/stage2.s` / `build/boot/stage2.bin` — was produced by the
self-hosted compiler itself via `./boot.sh --bootstrap-from-self`. It is
**not** part of the active build, test, or use path. See
`docs/rust-eviction-plan.md` for the full history of how and why it was
retired.

## Why this still exists

Zyl is self-hosting: `stdlib/compiler/*.zyl` is a real compiler,
written in Zyl, that compiles itself. `./boot.sh` verifies this fixed
point using nothing but `cc` — no Rust involved.

The one place Rust used to be load-bearing was **reseeding**: whenever
a change to the compiler source moved the fixed point, something had
to produce a new, trustworthy `stage2.s`. It turns out this doesn't
actually require Rust either — `./boot.sh --bootstrap-from-self`
reseeds using nothing but the *previous* committed seed, iterating
`stage1 -> stage2 -> stage3 -> ...` until two consecutive rounds match
(verified empirically to converge to the exact same result Rust used
to produce, starting from a seed many commits stale). That's the
normal reseed path now.

This archive was kept as the fallback for the one case self-iteration
genuinely can't solve: a change so large that the *previous* seed's
compiler can't even **parse** the new source — new syntax, not just new
behavior. An old compiler binary that has never seen a new special
form has no way to bootstrap understanding of it from nothing.

## It no longer works as that fallback

The Rust compiler can no longer read the current compiler source. Run
against `selfhost/zyl_selfhost_compiler.zyl` as of 2026-09-23, it stops
in its lexer:

```
[Phase 1] Parsing selfhost/zyl_selfhost_compiler.zyl ...
  Tokenizing...
Error: lexer: unterminated string at 2:91337-2:91338
```

That position is the REPL's terminal code (`"\e["`): the self-hosted
lexer accepts the `\e` escape and the Rust one does not. Even past that,
the source now depends on much the Rust implementation never had (see
below). So the practical way through a change the old seed cannot
parse is to land it in two steps: first teach the self-hosted compiler
to accept the new syntax without using it in the compiler's own source,
reseed with `--bootstrap-from-self`, and only then start using it.

## Using it anyway

```sh
cd /path/to/zyl-repo
cargo build --release --manifest-path archive/rust-bootstrap-2026/Cargo.toml \
    --target-dir archive/rust-bootstrap-2026/target
```

or run `./boot.sh --bootstrap-from-rust` from the repo root, which does
exactly this, compiles the bundle with the Rust-built compiler into a
stage1 binary, and then drives that binary through the legacy
fixed-path protocol (`/tmp/zyl_boot_in.zyl` → `/tmp/zyl_boot_out.s`) to
produce a new `stage2.s`. Given the lexer failure above, today this
fails at the first step. The build directory (`target/`) is ignored by
git.

## Layout

Preserved as its own self-contained Cargo project (`Cargo.toml`,
`Cargo.lock`, `src/`) rather than flattened, so it stays buildable in
place. It defines two binaries, `zyl` (`src/main.rs`) and `zyl-repl`
(`src/repl.rs`). One path did need fixing for the move:
`src/runtime.rs`'s `include_str!` of `runtime/actor_runtime.{c,h}` now
points three directories up (`../../../runtime/...`) instead of one,
since the real runtime lives at the actual repo root, not next to this
archived crate. Because it embeds the *current* runtime at build time,
the archived compiler links against a runtime that has moved on since
it was frozen.

`src/main.rs.bak` is a stray leftover from whenever this compiler was
last actively developed — kept as-is rather than cleaned up, since
nothing here is being maintained going forward.

## What it's missing

This Rust implementation predates most of what the self-hosted
compiler (`stdlib/compiler/*.zyl`) gained after it was frozen, among
them: real closure free-variable capture, `try`/`catch` via the
runtime's setjmp/longjmp panic-frame stack, per-ADT match exhaustiveness
and unreachable-arm checking, literal/OR/range/guarded patterns, `_` as
the universal discard, the `Secret` capability and its constant-time
checks, byte/atomic/Endian primitives, the spec v5.0 package system
(manifests, canonical symbol keys, visibility, MVS, lock, store,
signed index, capability enforcement), located `error[CODE]`
diagnostics, and the `\e` string escape. Its own understanding of the
language is frozen at whatever it was when this archive was made.
