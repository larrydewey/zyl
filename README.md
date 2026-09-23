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

## Installing (optional)

`./boot.sh` only builds and verifies the compiler for this checkout —
`build/boot/zyl-self` still needs to run from inside the repo. To get a
`zyl`/`zyl-repl` that work from any directory, with no repo checkout
nearby, install them into a standard per-user location:

```bash
./install.sh
export PATH="$HOME/.zyl/bin:$PATH"   # add to your shell profile
```

This copies the stdlib and runtime support files to `~/.zyl` (or
`$ZYL_HOME`, if set) and builds `zyl`/`zyl-repl` wrapper scripts there.
Both binaries check `$ZYL_HOME`, then `$HOME/.zyl`, before falling back
to their own directory — the same resolution order used by every real
compiler toolchain (`RUST_SYSROOT`, `PYTHONHOME`, ...), chosen so it
works correctly the moment this is ever packaged for a real Linux
distro: package managers install executables into `/usr/bin/` and
never let a package drop support files right next to them there, so
"look next to argv0" (this repo's own `build/boot/zyl-self` convention)
can't be the only mechanism long-term.

```bash
cd /anywhere
zyl hello.zyl -o hello && ./hello
```

To remove it, `./uninstall.sh` — `install.sh` only ever writes inside
that one directory, so this is a plain `rm -rf` of it and nothing else
(any `PATH` line you added yourself is left for you to remove by hand).

## REPL

An interactive REPL lives at `tools/repl.zyl`. `./install.sh` builds it
as `zyl-repl` automatically; to build it manually instead:

```bash
build/boot/zyl-self tools/repl.zyl -o /tmp/zyl-repl
```

A manually-built copy still needs to either sit next to a
`build/boot/`-style `actor_runtime.c` (each typed expression is
compiled and linked on the fly by shelling out to `cc`) or have
`~/.zyl`/`$ZYL_HOME` set up via `./install.sh` — `zyl-repl` from an
install works from any directory with neither requirement.

```bash
zyl-repl
```

```
Zyl REPL — type expressions, :q to quit
(+ 1 2)
3
(* 6 7)
42
:q
Goodbye!
```

Known limitations:
- No state persists between lines — each line is compiled and run as
  its own independent program, so a `let`-bound name from one prompt
  isn't visible on the next.
- A value is shown by having the compiled expression print itself
  directly, not by reading back a process exit code (see
  `tools/repl.zyl`'s `repl-wrap-expr` for why). Typing an expression
  that already contains a top-level `print` shows the intended value
  followed by an extra `0`.

## Editor Support

`./boot.sh` also builds `zyl-lsp`, a language server written in Zyl and
built from the same self-hosted compiler — so the editor and the
command line run the same parser, macro expander and checkers, and
cannot disagree about whether a program is valid.

```bash
./install.sh                 # installs zyl-lsp alongside zyl and zyl-repl
./install.sh --with-vscode   # also builds and installs the VS Code extension
```

It provides diagnostics (with the compiler's own `E_*` codes), hover,
go-to-definition, type definition and implementation, find references,
document highlight, rename, completion, signature help, document and
workspace symbols, semantic tokens, folding, selection ranges, call
hierarchy, inlay hints, and formatting. The VS Code extension in
`editors/vscode` adds a TextMate grammar, snippets, a build task, and
a **Run Current File** command that compiles and runs the unsaved
buffer.

Any LSP client works; the server takes no arguments and needs no
configuration file. See `editors/vscode/README.md` and Chapter 35 of
the book for per-editor setup.

```bash
./run_regression_tests.sh --filter lsp   # protocol tests against the real binary
```

## Self-Hosting Status

**Self-hosting: complete, no Rust in the active path.** The Zyl
compiler written in Zyl (`stdlib/compiler/*.zyl`, `selfhost/`) compiles
itself end-to-end with a strict byte-identical fixed point, verified by
`./boot.sh`, and passes the full regression suite (`./run_regression_tests.sh
--full`) — 77/77 as of this writing, including the fixed-point check and
the language-server protocol tests.

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
- **Bitwise operations** — `bit-and`/`bit-or`/`bit-xor`/`bit-not`, `shl`/`shr`/`ashr`, each one instruction, with defined out-of-range shift counts
- **The `Secret` capability** — a compile-time constant-time discipline: a secret may not steer a branch, index memory, divide, print, escape to an actor, or cross FFI unpinned
- **Cryptography library** — `stdlib/math`, ~7,500 lines of pure Zyl: SHA-2/3, BLAKE2b/3, HMAC, ChaCha20-Poly1305, AES-GCM, X25519, Ed25519, ECDSA, RSA-PSS/OAEP, HKDF, PBKDF2, Argon2id, big-number arithmetic
- **Language server** — `zyl-lsp`, written in Zyl, plus a VS Code extension

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

stdlib/math/                  # Cryptography and number libraries (pure Zyl)
├── bits.zyl, words.zyl       # Word operations, byte-string representation
├── secret/secret.zyl         # Constant-time primitives
├── bignum/                   # Fixed-width naturals, Montgomery, Barrett, modular
├── hash/                     # SHA-2, SHA-3, BLAKE2b, BLAKE3, HMAC
├── crypto/                   # Symmetric, asymmetric, KDFs
└── rand/                     # System entropy and a seeded generator

stdlib/lsp/                   # Language server (see editors/vscode)
├── lsp_server.zyl            # JSON-RPC request loop
├── compiler_bridge.zyl       # Compiler data -> LSP types, symbol table
├── source_index.zyl          # Position tracking by text scan
├── builtins.zyl              # Built-in table behind hover and completion
└── services/                 # hover, goto, completion, symbols, ...

editors/vscode/               # VS Code extension (grammar, snippets, client)

selfhost/                     # Self-hosting driver
├── driver.zyl                # Boot pipeline entry point
├── lsp_main.zyl              # Language server entry point
└── zyl_selfhost_compiler.zyl # Assembled self-hosted compiler

tests/                        # Regression test suite
├── smoke/                    # Basic smoke tests
├── regression/               # Feature regression tests
├── stress/                   # Stress tests (deep recursion, balanced parens)
├── integration/              # Integration tests (selfhost-codegen)
├── compile-fail/             # Programs that must be rejected, one per error code
└── lsp/                      # Language-server protocol tests
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

- [The Zyl Programming Language](book/src/SUMMARY.md) — the book
- [Architecture Decisions](docs/architecture-decisions.md)
- [Compiler Pipeline](docs/compiler-pipeline.md)
- [Implementation Status](docs/implementation-status.md)
- [Regression Tests](docs/regression-tests.md)
- [Cryptography and Number Libraries](docs/math-crypto.md)
- [LSP Architecture](LSP_ARCHITECTURE_PLAN.md)

## License

MIT