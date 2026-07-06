# Zyl — Agent Instructions

## Project Vision

**Zyl** is a deterministic Lisp systems language with region-based memory, Hindley-Milner type inference with capability types, actor concurrency, SSA IR (ICNF), FFI safety via pinning/timeout enforcement, hygienic macros, and full determinism. S-expression syntax targeting x86_64 native code. Ultimate goal: self-hosting.

## Current State

**Phase 1 complete (Parsing → AST).** `src/` contains lexer, parser, AST definitions, error model, entry points, and REPL stub. Builds and runs successfully with test programs. The spec is locked at v4.1 — all implementation must conform to it. See **PROGRESS.md** for detailed status of each phase.

## Authoritative Sources (read in order)

1. **`zyl_specification.txt`** — Complete language spec, compilation pipeline, error model
2. **`Cargo.toml`** — Dependencies and binary targets
3. **`PROGRESS.md`** — Phase-by-phase implementation status; read every session to know where we left off
4. This file

## Session Protocol

- Always start by reading `PROGRESS.md` to understand current state and what's next.
- When a phase or task is completed, update its section in `PROGRESS.md`: mark items done, add test results, note any new files created/modified, and record known limitations.

## Compilation Pipeline (from spec §22)

Strict phase order — each phase must be implemented before the next:

1. Parsing → AST
2. Macro Expansion (innermost-first, gensym hygiene)
3. Type Inference + Trait Resolution (+ derive validation)
4. Region Inference + Capture Analysis
5. Monomorphization (alphabetical canonical naming)
6. ICNF Generation (SSA IR with region annotations)
7. Optimization (safe only)
8. Code Generation → x86_64
9. Linking
10. Contract Injection (optional overlay, §23)
11. Hash Finalization

**Rule:** No phase may depend on a later phase. Determinism is required at every step (§27).

## Key Implementation Constraints

- **Strict left-to-right evaluation** — never reorder side effects (§§5, 11, 26)
- **Region rules are compile-time enforced** — Stack/Heap/Pin/Circular/Global with escape analysis (§9)
- **Capability types govern aliasing** — TMut exclusive vs TCap shared (§4.3, §10)
- **FFI requires Pin region + timeout parameter on every ffi-call** (§16)
- **Structs are immutable by default** — mutation via rebinding only (let-mut), direct field mutation forbidden (§10, §21.6)
- **Match exhaustiveness is a compile error** (§8.3)
- **Contracts never alter core semantics** — they're an optional overlay (§§8, 23)

## Dependencies (Cargo.toml)

| Crate | Purpose |
|-------|---------|
| `serde` + `serde_json` | Serialization for AST/ICNF exchange and test output |
| `sha2` | Deterministic hash finalization (§11), binary fingerprinting |
| `thiserror` | Error types matching spec error model (E_*) |
| `indexmap` | Ordered maps — deterministic iteration required by spec |
| `smallvec` | Small optimization for AST nodes, environments |
| `hashbrown` | Map collection implementation with sorted-key determinism (§4.2) |
| `crossbeam-channel` | Actor mailbox communication (no shared mutable state) |

Dev: `criterion` for benchmarks.

## Developer Commands

```bash
cargo build          # Build both binaries (zyl, zyl-repl)
cargo run --bin zyl  # Run compiler binary
cargo run --bin zyl-repl  # Run REPL
cargo test           # Tests (once src/ exists with #[cfg(test)] modules)
cargo check          # Fast compile check during development
```

## Architecture Notes for Implementation

- Entry points: `src/main.rs` (compiler), `src/repl.rs` (interactive mode)
- The compiler is a single binary — no workspace, no crates yet
- Spec v5.0 features (package management, workspaces, feature flags) are **not** implemented; do not build them
- All error codes from spec §28 must be defined and used consistently
