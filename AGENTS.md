# Zyl — Agent Instructions

## Project Identity

**Zyl** is a deterministic Lisp systems language with region-based memory, Hindley-Milner type inference with capability types, actor concurrency, SSA IR (ICNF), FFI safety via pinning/timeout enforcement, hygienic macros, and full determinism. S-expression syntax targeting x86_64 native code. Ultimate goal: self-hosting.

## Authoritative Sources (in order)

1. **`zyl_specification.txt`** — Canonical language specification (v4.2)
2. **`spec/`/** — Structured reference copy of specification, organized by semantic domain
3. **`docs/rust-eviction-plan.md`** — Self-hosting status, the fixed-point invariant, and the survey of self-hosted-compiler gaps (mostly closed as of this writing — see the doc for current state)
4. **`PROGRESS.md`** — Current implementation state and next priorities
5. **`docs/`/** — Architecture decisions, implementation history, design rationale
6. **Source code** — Authority for implemented behavior (overrides specification on implementation details). The compiler is self-hosted: `stdlib/compiler/*.zyl` + `selfhost/` is the ACTIVE implementation. `archive/rust-bootstrap-2026/` is the original Rust implementation, frozen and kept only as a reseed fallback — never the thing to edit for a language change.

## Session Protocol

- Read `PROGRESS.md` at session start to understand current state.
- Consult `zyl_specification.txt` or `spec/` for language semantics.
- Consult `docs/` for architectural decisions and implementation history.
- Consult source code when specification and implementation conflict.
- Update `PROGRESS.md` when phases or tasks are completed.
- Record new files created, modifications made, and known limitations.

## Compilation Pipeline (Strict Phase Order)

No phase may depend on a later phase. Determinism is required at every step.

1. Parsing → AST
2. Macro Expansion (innermost-first, gensym hygiene)
3. Type Inference + Trait Resolution (+ derive validation)
4. Region Inference + Capture Analysis
5. Monomorphization (alphabetical canonical naming)
6. ICNF Generation (SSA IR with region annotations)
7. Optimization (safe only)
8. Code Generation → x86_64
9. Linking
10. Contract Injection (optional overlay)
11. Hash Finalization

## Non-Negotiable Constraints

### Determinism
- Same source + same inputs → identical binaries and observable outputs
- All data structures use ordered iteration (indexmap, hashbrown sorted keys)
- No randomness, no timestamps, no scheduling-dependent behavior

### Evaluation Order
- Strict left-to-right evaluation. Never reorder side effects.
- Function application: evaluate function, then arguments sequentially.

### Region System
- Regions are compile-time enforced: Stack, Heap, Global, Circular, Pin
- Escape analysis with region promotion (Stack → Heap)
- No value may escape its assigned region

### Capability Types
- TCap: shared immutable access (any number of references)
- TMut: exclusive mutable ownership (exactly one reference)
- TMut/TCap aliasing invariant enforced at compile time

### FFI Safety
- FFI calls require Pin region + timeout parameter
- FFI_Pinnable types: Int, Float, Bool, String, Vec<T>, composed types

### Struct Immutability
- Struct fields are immutable by default
- Mutation via `let-mut` rebinding only
- Direct field mutation (`set! (struct-get p "x") 5`) is forbidden

### Match Exhaustiveness
- Exhaustiveness is a compile-time error if not satisfied

### Contracts
- Contracts never alter core semantics (type inference, ownership, regions, concurrency)
- Contracts are an optional overlay

## Architecture Decisions (Do Not Reverse)

- **No-dispatch parsing:** All S-expressions → raw Call/Apply → PostProcessor
- **Innermost-first macro expansion** with gensym hygiene
- **ICNF as custom SSA IR** (not LLVM) for region annotation flow
- **Region-based memory** (not GC) for deterministic reclamation
- **Capability types** (TCap/TMut) for compile-time aliasing control
- **Structs immutable by default** (rebinding only)
- **Safe-only optimizations** (constant folding, DCE — no reordering)

## Development Commands

No Rust, no Cargo — the compiler is self-hosted and builds with `cc`:

```bash
./boot.sh                       # Build + verify the self-hosting fixed point
build/boot/zyl-self hello.zyl -o hello   # Compile a program
./hello                         # Run it
```

After editing anything under `stdlib/compiler/*.zyl`, `selfhost/`, or
`runtime/actor_runtime.c`, re-run `./boot.sh` — a source change that
alters the compiler's own output breaks the fixed point (`FIXED POINT
BROKEN` or `reproduced asm differs from committed seed`), which needs
reseeding before anything else will trust the new `build/boot/stage2.s`:

```bash
python3 selfhost/assemble.py    # Re-bundle stdlib/compiler/*.zyl into selfhost/zyl_selfhost_compiler.zyl
./boot.sh --bootstrap-from-self # Reseed using the self-hosted compiler (no Rust)
./boot.sh                       # Verify the new seed reaches a clean fixed point
git add -f build/boot/stage2.s build/boot/stage2.bin && git commit
```

`--bootstrap-from-self` fails only when a change is so large the old
seed can't even parse the new source (new syntax, not just new
behavior) — see `archive/rust-bootstrap-2026/README.md` for that
fallback, and `docs/rust-eviction-plan.md` for the full story.

## Regression Tests

```bash
./run_regression_tests.sh --quick   # Smoke tests + unit test
./run_regression_tests.sh --full    # All tests
./run_regression_tests.sh --filter structs  # Struct regression tests only
```

**Trigger before modifying struct-related code** (`ast.zyl`, `codegen.zyl`, `icnf.zyl`, `type_inference.zyl`, `parser.zyl`, `region_inference.zyl` under `stdlib/compiler/`):
```bash
./run_regression_tests.sh --filter structs
```

Full test infrastructure documented in `docs/regression-tests.md`. All tests use the `(test "name" (assert-equal ...))` harness defined in `stdlib/testing/testing.zyl`.

**S-expression balance** is critical — always run `--filter balanced-parens` after modifying parser/lexer.

## Architecture Notes

- Entry point: `selfhost/driver.zyl` (assembled into `selfhost/zyl_selfhost_compiler.zyl` by `selfhost/assemble.py`, compiled to `build/boot/stage2.bin`/`zyl-self`). `tools/repl.zyl` is a REPL but is an unfinished skeleton — treat it as such, not a working tool.
- Single binary — no workspace, no crates, no Cargo anywhere in the active path
- Spec v5.0 features (package management, workspaces, feature flags) are NOT implemented; do not build them
- All error codes from spec §28 must be defined and used consistently
