# Archived: Rust bootstrap compiler

This is the original Rust implementation of the Zyl compiler. It built
every self-hosted seed up through the one currently committed at
`build/boot/stage2.s` / `build/boot/stage2.bin`, and is preserved here
in case it's ever needed again — it is **not** part of the active
build, test, or use path anymore. See `docs/rust-eviction-plan.md` for
the full history of how and why it was retired.

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

This archive is the fallback for the one case self-iteration genuinely
can't solve: a change so large that the *previous* seed's compiler
can't even **parse** the new source — new syntax, not just new
behavior. An old compiler binary that has never seen a new special
form has no way to bootstrap understanding of it from nothing; a
compiler that already understands the whole language (this one) can.

## Using it, if you ever actually need to

```sh
cd /path/to/zyl-repo
cargo build --release --manifest-path archive/rust-bootstrap-2026/Cargo.toml \
    --target-dir archive/rust-bootstrap-2026/target
```

or just run `./boot.sh --bootstrap-from-rust` from the repo root, which
does exactly this and then feeds the result through the normal reseed
pipeline.

## Layout

Preserved as its own self-contained Cargo project (`Cargo.toml` +
`src/`) rather than flattened, so it stays buildable in place. One path
did need fixing for the move: `src/runtime.rs`'s `include_str!` of
`runtime/actor_runtime.{c,h}` now points three directories up
(`../../../runtime/...`) instead of one, since the real runtime lives
at the actual repo root, not next to this archived crate.

`src/main.rs.bak` is a stray leftover from whenever this compiler was
last actively developed — kept as-is rather than cleaned up, since
nothing here is being maintained going forward.

## What it's missing, if you do end up needing it

This Rust implementation predates several features the self-hosted
compiler (`stdlib/compiler/*.zyl`) gained after it was frozen: real
closure free-variable capture, `try`/`catch` via the runtime's
setjmp/longjmp panic-frame stack, and full per-ADT match exhaustiveness
checking, among the fixes documented in `docs/rust-eviction-plan.md`'s
survey. If you use this to reseed, expect the resulting seed to need
those same fixes re-applied to the self-hosted source before the
regression suite (`./run_regression_tests.sh --full`) passes again —
this binary compiles the *current* `.zyl` source, but its own
understanding of the language is frozen at whatever it was when this
archive was made.
