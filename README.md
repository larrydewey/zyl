<div align="center">
  <img src="assets/logo.png" alt="Zyl Logo" width="150px"></img>
  <p><strong>Deterministic Power. Expressive Safety.</strong></p>
</div>


A deterministic Lisp systems language with region-based memory, capability types, actor concurrency, SSA IR, and native x86_64 code generation.

## Installation

Zyl is self-hosting and builds with nothing but `cc` — no Rust, no
Cargo, no other toolchain:

```bash
git clone https://github.com/your-org/zyl.git
cd zyl
./boot.sh
```

This links the committed compiler seed (`build/boot/stage2.s`) with
`cc`, verifies the self-hosting fixed point (the compiler reproduces
its own committed output, byte for byte, when compiling itself), and
writes `build/boot/zyl-self` — a wrapper you can invoke from anywhere.

## Usage

```bash
# Compile a Zyl source file
build/boot/zyl-self hello.zyl -o hello
./hello
```

`zyl-self` resolves its standard library and runtime relative to its
own directory (`build/boot/`), not your current working directory, so
it works the same regardless of where you invoke it from. Core
facilities (`Option`, `Result`, `List`, and core helpers) are available
automatically; additional libraries remain opt-in, for example:

```lisp
(use testing/testing)
```

Project-local modules are resolved relative to the source file being
compiled, so applications can keep their own libraries alongside their
source.

## Self-Hosting Status

**Self-hosting: complete, no Rust in the active path.** The Zyl
compiler written in Zyl (`stdlib/compiler/*.zyl`, `selfhost/`) compiles
itself end-to-end with a strict byte-identical fixed point, verified by
`./boot.sh`, and passes the full regression suite (`./run_regression_tests.sh
--full`) — 43/43 as of the latest survey in `docs/rust-eviction-plan.md`.

The original Rust bootstrap compiler is archived at
`archive/rust-bootstrap-2026/` (see its own README) — kept only as a
fallback for reseeding across a language change so large the previous
self-hosted seed can't parse the new source at all. The normal reseed
path, `./boot.sh --bootstrap-from-self`, needs no Rust either: it
iterates the self-hosted compiler against its own new output until two
consecutive rounds match.

The Zyl-written compiler handles the full pipeline: Parsing → Module
Resolution → Macro Expansion → Region Inference → Monomorphization →
Type Inference → Contract Injection → ICNF Generation → Optimization →
Code Generation → Linking.

## Features

- **S-expression syntax** — homoiconic Lisp with S-expressions targeting x86_64 native code
- **Region-based memory** — Stack, Heap, Global, Circular, Pin regions with escape analysis and promotion
- **Capability types** — TCap (shared immutable) and TMut (exclusive mutable) with compile-time aliasing enforcement
- **Hindley-Milner type inference** — full HM with trait resolution and derive validation
- **Deterministic compilation** — same source + same inputs → identical binaries
- **SSA IR (ICNF)** — custom intermediate representation with region annotations
- **Actor concurrency** — pthread-based actor runtime with spawn/send/send-closure, mailbox, wait_all
- **Hygienic macros** — innermost-first expansion with gensym hygiene
- **FFI with pinning** — FFI calls require Pin region + timeout parameters
- **Struct/ADT system** — immutable structs by default, exhaustive pattern matching, deftype/match
- **Safe-only optimizations** — constant folding and dead code elimination
- **Float64 support** — full IEEE-754 arithmetic, SSE code generation, comparisons, print
- **Closures** — fn/lambda syntax with capture analysis and env struct allocation
- **Try/catch** — error handling with catch variable binding
- **I/O** — read-line via sys_read syscall
- **Contract Injection (Phase 10)** — optional overlay for requires/ensures/invariant/recover/checkpoint

## Compilation Pipeline

| Phase | Status | Description |
|-------|--------|-------------|
| 1. Parsing | ✅ | Lexer + Parser → AST (no-dispatch) |
| 2. Post-Processing | ✅ | Raw Call/Apply → specialized ExprInner |
| 3. Macro Expansion | ✅ | Gensym hygiene, innermost-first |
| 4. Region Inference | ✅ | Two-pass algorithm, escape analysis |
| 5. Type Inference | ✅ | HM inference + trait resolution (Zyl) |
| 6. Monomorphization | ✅ | Canonical naming, trait bounds (Zyl) |
| 7. ICNF Generation | ✅ | SSA IR with region annotations (Zyl) |
| 8. Optimization | ✅ | Constant folding, DCE |
| 9. Code Generation | ✅ | x86_64, System V AMD64 ABI (Zyl) |
| 10. Linking | ✅ | cc + actor_runtime.c + pthread |
| 11. Contract Injection | ✅ | Optional overlay (Zyl) |

## Project Structure

```
archive/rust-bootstrap-2026/  # Archived Rust bootstrap — NOT part of the
│                              # active build; see its own README and
│                              # docs/rust-eviction-plan.md
├── Cargo.toml
└── src/
    ├── main.rs                # Compiler entry point, pipeline orchestration
    ├── repl.rs                # REPL entry point
    ├── ast.rs                 # AST definitions + PostProcessor
    ├── lexer.rs                # Tokenizer
    ├── parser.rs               # Recursive descent parser
    ├── macro_expander.rs       # Macro expansion with gensym hygiene
    ├── type_system.rs          # Type definitions
    ├── type_inference.rs       # HM type inference + trait resolution
    ├── region_inference.rs     # Region inference + capture analysis
    ├── monomorphization.rs     # Generic type instantiation
    ├── icnf.rs                 # SSA IR (ICNF)
    ├── optimization.rs         # IR optimizations
    ├── codegen.rs               # x86_64 code generation
    ├── error.rs                 # Error model
    └── runtime.rs                # Embeds runtime/actor_runtime.{c,h}

runtime/                       # Actor runtime, used by every compiled binary
├── actor_runtime.c            # pthread-based actor runtime
└── actor_runtime.h            # Actor runtime header

stdlib/compiler/              # Zyl-written compiler (self-hosted, active)
├── lexer.zyl
├── parser.zyl
├── ast.zyl
├── expr_inner.zyl
├── macro_expand.zyl
├── type_system.zyl           # Type ADT, Subst, TypeEnv, TraitContext, TypeInferer
├── type_inference.zyl        # Full HM inference engine
├── region_inference.zyl      # Region inference + capture analysis
├── monomorphization.zyl      # Full monomorphization pipeline
├── icnf.zyl                  # ICNF lowering from ExprInner
├── codegen.zyl               # x86_64 code generation
├── contract_injection.zyl    # Phase 10 contract overlay
├── trait_dispatch.zyl        # Trait method dispatch
├── closure_inline.zyl        # Closure inlining
├── assert_lowering.zyl       # Assert lowering
├── module_resolver.zyl       # Module resolution
└── resolver.zyl              # Name resolution

selfhost/                     # Self-hosting driver
├── driver.zyl                # Boot pipeline entry point
└── zyl_selfhost_compiler.zyl # Assembled self-hosted compiler

tests/                        # Regression test suite
├── smoke/                    # Basic smoke tests
├── regression/               # Feature regression tests
├── stress/                   # Stress tests (deep recursion, balanced parens)
└── integration/              # Integration tests (selfhost-codegen)
```

## Requirements

- `cc` (a C compiler) and `pthread` — that's it; no Rust, no Cargo
- Linux x86_64 (other platforms may work)
- Rust 1.70+ (edition 2021) only if you need `archive/rust-bootstrap-2026`'s
  fallback reseed path — see its README

## Examples

See `tests/regression/` for example Zyl programs covering all language features.

## Specification

The canonical language specification is `zyl_specification.txt` (v4.2). Structured reference copies are in `spec/`. Historical specification versions are in `specifications/`.

## Resources

- [Architecture Decisions](docs/architecture-decisions.md)
- [Compiler Pipeline](docs/compiler-pipeline.md)
- [Implementation Status](docs/implementation-status.md)
- [Regression Tests](docs/regression-tests.md)

## License

MIT