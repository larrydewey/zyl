# Zyl — Agent Instructions

## Project Identity

**Zyl** is a deterministic Lisp systems language with region-based memory, Hindley-Milner type inference with capability types, actor concurrency, SSA IR (ICNF), FFI safety via pinning/timeout enforcement, hygienic macros, and full determinism. S-expression syntax targeting x86_64 native code. Ultimate goal: self-hosting.

## Authoritative Sources (in order)

1. **`zyl_specification.txt`** — Canonical language specification (v4.1, final locked version)
2. **`spec/`/** — Structured reference copy of specification, organized by semantic domain
3. **`Cargo.toml`** — Dependencies and binary targets
4. **`PROGRESS.md`** — Current implementation state and next priorities
5. **`docs/`/** — Architecture decisions, implementation history, design rationale
6. **Source code** — Authority for implemented behavior (overrides specification on implementation details)

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

```bash
cargo build          # Build both binaries (zyl, zyl-repl)
cargo run --bin zyl  # Run compiler binary
cargo run --bin zyl-repl  # Run REPL
cargo check          # Fast compile check
```

## Regression Tests

Before modifying struct-related code (`ast.rs`, `codegen.rs`, `icnf.rs`, `type_inference.rs`, `parser.rs`, `region_inference.rs`), run struct regression tests documented in `docs/regression-tests.md`.

## Architecture Notes

- Entry points: `src/main.rs` (compiler), `src/repl.rs` (REPL)
- Single binary — no workspace, no crates
- Spec v5.0 features (package management, workspaces, feature flags) are NOT implemented; do not build them
- All error codes from spec §28 must be defined and used consistently
