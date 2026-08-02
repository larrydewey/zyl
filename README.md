<div align="center">
  <img src="assets/logo.png" alt="Zyl Logo" width="150px"></img>
  <p><strong>Deterministic Power. Expressive Safety.</strong></p>
</div>


A deterministic Lisp systems language with region-based memory, capability types, actor concurrency, SSA IR, and native x86_64 code generation.

## Installation

```bash
cargo install --path .
```

Or build from source:

```bash
git clone https://github.com/your-org/zyl.git
cd zyl
cargo build --release
```

## Usage

```bash
# Compile a Zyl source file
zyl hello.zyl

# Run the REPL
zyl-repl
```

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

## Compilation Pipeline

| Phase | Status | Description |
|-------|--------|-------------|
| 1. Parsing | ✅ | Lexer + Parser → AST (no-dispatch) |
| 2. Post-Processing | ✅ | Raw Call/Apply → specialized ExprInner |
| 3. Macro Expansion | ✅ | Gensym hygiene, innermost-first |
| 4. Region Inference | ✅ | Two-pass algorithm, escape analysis |
| 5. Type Inference | ✅ | HM inference, trait resolution |
| 6. Monomorphization | ✅ | Canonical naming, trait bounds |
| 7. ICNF Generation | ✅ | SSA IR with region annotations |
| 8. Optimization | ✅ | Constant folding, DCE |
| 9. Code Generation | ✅ | x86_64, System V AMD64 ABI |
| 10. Linking | ✅ | cc + actor_runtime.c + pthread |

## Project Structure

```
src/
├── main.rs            # Compiler entry point, pipeline orchestration
├── repl.rs            # REPL entry point
├── ast.rs             # AST definitions + PostProcessor
├── lexer.rs           # Tokenizer
├── parser.rs          # Recursive descent parser
├── macro_expander.rs  # Macro expansion with gensym hygiene
├── type_system.rs     # Type definitions
├── type_inference.rs  # HM type inference + trait resolution
├── region_inference.rs# Region inference + capture analysis
├── monomorphization.rs# Generic type instantiation
├── icnf.rs            # SSA IR (ICNF)
├── optimization.rs    # IR optimizations
├── codegen.rs         # x86_64 code generation
├── error.rs           # Error model
├── runtime.rs         # Actor runtime path re-export
└── runtime/
    ├── actor_runtime.c  # pthread-based actor runtime
    └── actor_runtime.h  # Actor runtime header
```

## Requirements

- Rust 1.70+ (edition 2021)
- Linux x86_64 (other platforms may work)

## Examples

See `stdlib_test.zyl` and source files in the root for example Zyl programs.

## Specification

The canonical language specification is `zyl_specification.txt` (v4.2). Structured reference copies are in `spec/`. Historical specification versions are in `specifications/`.

## Resources

- [Architecture Decisions](docs/architecture-decisions.md)
- [Compiler Pipeline](docs/compiler-pipeline.md)
- [Implementation Status](docs/implementation-status.md)
- [Regression Tests](docs/regression-tests.md)

## License

MIT
