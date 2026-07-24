# Zyl

![Zyl Logo](assets/logo.jpg)
**Deterministic Power. Expressive Safety.**

A deterministic Lisp systems language with region-based memory, capability types, actor concurrency, SSA IR, and native x86_64 code generation.

![Parry the Owl](assets/parry.svg)

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
- **Actor concurrency** — type-checked actor model (runtime deferred)
- **Hygienic macros** — innermost-first expansion with gensym hygiene
- **FFI with pinning** — FFI calls require Pin region + timeout parameters
- **Struct/ADT system** — immutable structs by default, exhaustive pattern matching
- **Safe-only optimizations** — constant folding and dead code elimination
- **Self-hosting** — targeting Zyl source code generation

## Compilation Pipeline

| Phase | Status | Description |
|-------|--------|-------------|
| 1. Parsing | ✅ | Lexer + Parser → AST |
| 2. Macro Expansion | ✅ | Gensym hygiene, innermost-first |
| 3. Type Inference | ✅ | HM inference, trait resolution |
| 4. Region Inference | ✅ | Two-pass algorithm, escape analysis |
| 5. Monomorphization | ✅ | Canonical naming, trait bounds |
| 6. ICNF Generation | ✅ | SSA IR with region annotations |
| 7. Optimization | ✅ | Constant folding, DCE |
| 8. Code Generation | ✅ | x86_64, System V AMD64 ABI |
| 9. Linking | ✅ | Native binary output |

## Project Structure

```
src/
├── main.rs            # Compiler entry point
├── repl.rs            # REPL entry point
├── ast.rs             # Abstract syntax tree
├── lexer.rs           # Lexer
├── parser.rs          # Parser
├── macro_expander.rs  # Macro expansion
├── type_system.rs     # Type definitions
├── type_inference.rs  # HM type inference
├── region_inference.rs# Region inference & capture analysis
├── monomorphization.rs# Monomorphization
├── icnf.rs            # SSA IR (ICNF)
├── optimization.rs    # IR optimizations
├── codegen.rs         # x86_64 code generation
└── error.rs           # Error model
```

## Requirements

- Rust 1.70+ (edition 2021)
- Linux x86_64 (other platforms may work)

## Examples

See `stdlib_test.zyl` and source files in the root for example Zyl programs.

## Specification

The canonical language specification is `zyl_specification.txt` (v4.1). Structured reference copies are in `spec/`. Historical specification versions are in `specifications/`.

## Resources

- [Architecture Decisions](docs/architecture-decisions.md)
- [Compiler Pipeline](docs/compiler-pipeline.md)
- [Implementation Status](docs/implementation-status.md)
- [Regression Tests](docs/regression-tests.md)

## License

MIT
