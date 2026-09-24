<div align="center">
  <img src="assets/logo.png" alt="Zyl Logo" width="150px"></img>
  <p><strong>Deterministic Power. Expressive Safety.</strong></p>
</div>


A deterministic Lisp systems language with region-based memory, capability types, actor concurrency, SSA IR, and native x86_64 code generation.

## Installation

Zyl is self-hosting and builds with nothing but `cc` — no Rust, no
Cargo, no other toolchain:

```bash
git clone https://github.com/larrydewey/zyl.git
cd zyl
./boot.sh
```

This links the committed compiler seed (`build/boot/stage2.s`) with
`cc`, verifies the self-hosting fixed point (the compiler reproduces
its own committed output, byte for byte, when compiling itself), and
writes `build/boot/zyl-self` — a wrapper you can invoke from anywhere —
plus the language server, `build/boot/zyl-lsp`.

## Usage

```bash
# Compile a Zyl source file
build/boot/zyl-self hello.zyl -o hello
./hello

# Run a program without producing a binary (ICNF interpreter)
build/boot/zyl-self eval hello.zyl

# Emit x86_64 assembly instead of linking
build/boot/zyl-self hello.zyl -o hello.s --emit-asm
```

`zyl-self help` (or any other unrecognized subcommand) prints the full
list of subcommands.

`zyl-self` looks for its standard library and runtime in `$ZYL_HOME`,
then `~/.zyl`, then its own directory (`build/boot/`) — never your
current working directory — so it works the same regardless of where
you invoke it from (see "Installing" below for why the order matters). Core
facilities (`Option`, `Result`, `List`, and core helpers) are available
automatically; additional libraries remain opt-in, for example:

```lisp
(use testing/testing)
```

Project-local modules are resolved relative to the source file being
compiled, so applications can keep their own libraries alongside their
source.

### Packages

A directory with a `zyl.pkg` is a package, and `zyl` builds it as one
(spec v5.0 §31):

```bash
build/boot/zyl-self new acme/json   # a manifest and a root module
cd json
build/boot/zyl-self build           # compile this package
build/boot/zyl-self test            # compile it and run its tests
build/boot/zyl-self audit           # what the graph is allowed to do
```

```lisp
(package
  (name "acme/json") (version "1.4.0")
  (zyl "5.0") (edition "2026")
  (capabilities io)
  (deps (dep "core/bytes" "2.1.0")
        (dep "acme/dev" "0.3.0" (path "../dev"))))
```

Dependencies resolve by Minimal Version Selection: every requirement is
a minimum, the selection is the greatest minimum, and there is no
solver — so adding one dependency never silently moves another. A
package declares the capabilities it may use (`io`, `ffi`, `actor`,
`secret`, `native`, `unsafe`) and the compiler enforces that declaration.
Definitions are package-private unless marked `pub`, and two packages may
define the same name without colliding.

`zyl fetch` is the only command that touches the network; builds read a
content-addressed store under `~/.zyl/store` and verify every package's
Ed25519 signature against a key pinned on first use. The remaining
subcommands are `add`, `update` (re-resolve and rewrite `zyl.lock`),
`vendor`, `publish` and `key`; `build --locked` fails unless `zyl.lock`
already describes exactly the resolved graph. See
`docs/package-management-design.md` and spec §31.

## Installing (optional)

`./boot.sh` only builds and verifies the compiler for this checkout —
`build/boot/zyl-self` depends on the checkout staying where it is. To get a
`zyl`, `zyl-repl` and `zyl-lsp` that work from any directory, with no
repo checkout nearby, install them into a standard per-user location:

```bash
./install.sh
export PATH="$HOME/.zyl/bin:$PATH"   # or: source ~/.zyl/env (env.fish for fish)
```

This copies the stdlib and runtime support files to `~/.zyl` (or
`$ZYL_HOME`, if set), builds the REPL and the language server with the
compiler it just installed, writes `zyl`, `zyl-repl` and `zyl-lsp`
wrapper scripts into `~/.zyl/bin`, and checks that the installed server
answers an LSP `initialize` request. The installed `zyl` with no
arguments starts the REPL.

The compiler checks `$ZYL_HOME`, then `$HOME/.zyl`, before falling back
to its own directory — the same resolution order used by every real
compiler toolchain (`RUST_SYSROOT`, `PYTHONHOME`, ...), chosen so it
works correctly the moment this is ever packaged for a real Linux
distro: package managers install executables into `/usr/bin/` and
never let a package drop support files right next to them there, so
"look next to argv0" (this repo's own `build/boot/zyl-self` convention)
can't be the only mechanism long-term. A consequence worth knowing: once
`~/.zyl` exists, a compiler run outside `./boot.sh` and
`./run_regression_tests.sh` (which both pin `ZYL_HOME` to `build/boot`)
reads the *installed* stdlib, so re-run `./install.sh` after editing
`stdlib/`.

```bash
cd /anywhere
zyl hello.zyl -o hello && ./hello
```

To remove it, `./uninstall.sh` — `install.sh` only ever writes inside
that one directory, so this is a plain `rm -rf` of it and nothing else
(any `PATH` line you added yourself is left for you to remove by hand).

## REPL

`zyl repl` starts an interactive session (so does `zyl-repl`, or the
installed `zyl` with no arguments). Every entry goes through the real
compiler front end and middle — parsing, macro expansion, every check,
type inference, monomorphization, ICNF lowering — and the lowered ICNF
is then evaluated in-process by an interpreter
(`stdlib/repl/interp.zyl`) instead of being compiled and linked, so an
entry costs milliseconds and a binding survives from one entry to the
next.

```
$ build/boot/zyl-self repl
zyl> (defn double (n) (* n 2))
defined double
zyl> (def x 21)
x = 21
zyl> (double x)
=> 42
zyl> (Some "hi")
=> (Some "hi")
```

- Results print structurally: variants and structs show as
  `(Cons 1 (Cons 2 Nil))` or `(P 3 4)`, not as addresses.
- Meta commands include `:help`, `:type EXPR`, `:time EXPR`, `:doc NAME`,
  `:defs`, `:load PATH`, `:save PATH`, `:reset` and `:history`.
- The line editor is written in Zyl: multi-line entries with automatic
  indentation, history search (`Ctrl-R`), tab completion, kill/yank and
  live syntax highlighting. History is kept in `~/.zyl/repl_history`.
- A session in a terminal starts from the default modules, then
  `~/.zyl/replrc` (or `$ZYL_REPLRC`), then `.zyl-session` in the
  directory it was started in, which is rewritten after every entry that
  changes the session. Piped input restores and saves nothing.
- `zyl eval FILE.zyl` runs a whole program through the same interpreter
  without producing a binary.

Known limitations: `:type` often answers *unresolved* for applications
(several of type inference's own name lookups compare strings by
pointer), and a compiled program still prints a struct as an address —
the REPL's structural printing is not spec §5.6's `Show`, which is not
implemented. The full reference is [`docs/repl.md`](docs/repl.md).

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
hierarchy, inlay hints (parameter names), quick fixes for unbalanced
delimiters, and whole-document and range formatting. The VS Code
extension in `editors/vscode` (version 0.3.0) adds TextMate grammars for
`.zyl` files and `zyl.pkg` manifests, snippets, build/test/fetch tasks,
and a **Run Current File** command that compiles and runs the unsaved
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
--full`) — 121/121 as of this writing, covering regression, interpreter
(differential REPL-vs-codegen), compile-fail, integration, stress,
package and language-server protocol tests.

The original Rust bootstrap compiler is archived at
`archive/rust-bootstrap-2026/` (see its own README). The normal reseed
path, `./boot.sh --bootstrap-from-self`, needs no Rust: it iterates the
self-hosted compiler against its own new output until two consecutive
rounds match. The archived compiler can no longer read the current
compiler source (its lexer rejects the `\e` string escape the REPL
uses), so it is a historical record rather than a working fallback.

The Zyl-written compiler runs, in order (`stdlib/compiler/pipeline.zyl`):
delimiter-balance check → parsing → module resolution (canonical
symbol keys, spec §31) → macro expansion → capability, duplicate,
arity, mutability, exhaustiveness, unused-binding and `Secret` checks →
type inference → monomorphization → trait dispatch → closure lifting →
assert lowering → ICNF generation → optimization → region inference
(escape analysis) → x86_64 code generation → linking with `cc`.

## Features

- **S-expression syntax** — homoiconic Lisp with S-expressions targeting x86_64 native code
- **Region-based memory** — Stack, Heap, Global, Circular and Pin regions in the type system; escape analysis stack-allocates provably non-escaping values
- **Capability types** — TCap (shared immutable) and TMut (exclusive mutable) with compile-time aliasing enforcement: only a `let-mut` binding may be `set!`, and direct field mutation is rejected
- **Hindley-Milner type inference** — HM with trait resolution and generics via monomorphization; `derive` accepts `Eq`, `Ord` and `Debug` (`Show` is not implemented)
- **Deterministic compilation** — same source + same inputs → identical binaries; the compiler reproduces itself byte for byte
- **ICNF IR** — custom intermediate representation between the AST and codegen (spec §18 describes it as SSA with region annotations; the implementation is currently a tree IR without either)
- **Actor concurrency** — pthread-based actor runtime: `spawn` a closure as an actor, `send` it messages through its mailbox, and wait for it (`actor/actor` adds send-with-timeout, liveness and termination)
- **Macros** — `defmacro` template macros, expanded innermost-first (spec §19.2's gensym hygiene is not implemented yet: a macro's binders can capture the caller's names)
- **FFI** — `ffi-call` with a trailing timeout argument, `ffi-pin` for Pin-region memory, and a `Secret` value may only cross FFI pinned
- **Structs and ADTs** — immutable structs by default, `deftype`/`match` with compile-time exhaustiveness and unreachable-arm checks; literal, OR (`(1 2 body)`), range (`(range lo hi)`) and guarded (`(when cond)`) patterns
- **`_` as the discard** — in patterns, parameter lists and bindings; `_`-prefixed names are exempt from unused-binding warnings
- **Located diagnostics** — `error[CODE]`, `--> file:line:col`, the source line, a caret and a `= help:` line for the most common errors
- **Safe-only optimizations** — constant folding and dead-branch elimination
- **Float64 support** — IEEE-754 arithmetic, SSE code generation, comparisons, print
- **Closures** — `fn`/`lambda` with free-variable capture
- **Try/catch** — `(try expr (catch e handler))`, backed by the runtime's setjmp/longjmp panic frames
- **I/O** — `read-line`, file open/read/write/close
- **Bitwise, byte and atomic operations** — `bit-and`/`bit-or`/`bit-xor`/`bit-not`, `shl`/`shr`/`ashr` (each one instruction, with defined out-of-range shift counts), byte and byte-buffer primitives with explicit endianness, and seq-cst atomics (`atomic/atomic`)
- **The `Secret` capability** — a compile-time constant-time discipline: a secret may not steer a branch, index memory, divide, print, escape to an actor, or cross FFI unpinned
- **Cryptography library** — `stdlib/math`, ~7,600 lines of pure Zyl: SHA-2/3, BLAKE2b/3, HMAC, ChaCha20-Poly1305, AES-GCM, X25519, Ed25519, ECDSA, RSA-PSS/OAEP, HKDF, PBKDF2, Argon2id, big-number arithmetic, system and seeded random numbers
- **Package system** — spec v5.0 §31: manifests, MVS, a lock file, a content-addressed store, signed index entries, declared capabilities, features, workspaces
- **Testing framework** — `(test "name" ...)` with `assert-equal` and friends, `zyl test` for packages
- **REPL** — `zyl repl`, backed by an ICNF interpreter, with a line editor written in Zyl
- **Language server** — `zyl-lsp`, written in Zyl, plus a VS Code extension
- **Contracts (parsed only)** — `requires`/`ensures`/`invariant`/`recover`/`checkpoint` are accepted, but the contract-injection pass is not wired into the pipeline, so contracts are currently not enforced

## Compilation Pipeline

| Phase | Status | Description |
|-------|--------|-------------|
| 1. Parsing | ✅ | Balance check, lexer + parser → AST (no-dispatch) |
| 2. Module Resolution | ✅ | `use` graph, canonical symbol keys, visibility (spec §31) |
| 3. Macro Expansion | ✅ | Gensym hygiene, innermost-first |
| 4. Post-Processing + Checks | ✅ | AST → ExprInner; capability, duplicate, arity, mutability, exhaustiveness, unused, `Secret` |
| 5. Type Inference | ✅ | HM inference + trait resolution |
| 6. Monomorphization | ✅ | Canonical naming, trait bounds; then trait dispatch, closure lifting, assert lowering |
| 7. ICNF Generation | ✅ | SSA IR with region annotations |
| 8. Optimization | ✅ | Constant folding, dead-branch elimination |
| 9. Region Inference | ✅ | Escape analysis over ICNF: non-escaping variants move to the stack |
| 10. Code Generation | ✅ | x86_64, System V AMD64 ABI |
| 11. Linking | ✅ | cc + actor_runtime.c + pthread |
| — Contract Injection | ❌ | `contract_injection.zyl` exists but is not wired in (see `pipeline.zyl`) |

The implementation's order differs from spec §22's (which puts region
inference before monomorphization and contract injection after
linking); `stdlib/compiler/pipeline.zyl` is the authority for what
actually runs.

## Project Structure

```
boot.sh                       # Build + verify the self-hosting fixed point
install.sh, uninstall.sh      # Per-user install into ~/.zyl (or $ZYL_HOME)
run_regression_tests.sh       # Test runner (see docs/regression-tests.md)
zyl_specification.txt         # Canonical language specification (v5.0)

selfhost/                     # Self-hosted compiler entry points
├── driver.zyl                # `zyl` CLI: compile, package subcommands, repl, eval
├── lsp_main.zyl              # Language server entry point
├── assemble.py               # Bundles stdlib + driver into one source file
└── zyl_selfhost_compiler.zyl # The assembled bundle boot.sh compiles

build/boot/                   # Committed seed (stage2.s, stage2.bin) and
                              # everything boot.sh produces (zyl-self, zyl-lsp)

runtime/                      # C runtime linked into every compiled binary
├── actor_runtime.c           # Actors, arenas, I/O, FFI helpers, panics
└── actor_runtime.h

stdlib/compiler/              # The compiler, written in Zyl (37 modules)
├── pipeline.zyl              # Phase order shared by the CLI and the REPL
├── lexer.zyl, parser.zyl, sexp_balance.zyl, ast.zyl, expr_inner.zyl
├── module_resolver.zyl, qualify.zyl, resolver.zyl, macro_expand.zyl
├── capability_check.zyl, duplicate_check.zyl, arity_check.zyl,
│   mutability_check.zyl, exhaustiveness_check.zyl, unused_check.zyl,
│   secret_check.zyl          # Pre-inference checks
├── type_system.zyl, type_inference.zyl, monomorphization.zyl,
│   trait_dispatch.zyl, closure_inline.zyl, assert_lowering.zyl
├── icnf.zyl, optimization.zyl, region_inference.zyl, codegen.zyl
├── package.zyl, workspace.zyl, lock.zyl, index.zyl, mvs.zyl, store.zyl,
│   cli.zyl                   # Package system (spec §31)
├── error_codes.zyl, error_report.zyl   # Error catalog and rendering
└── contract_injection.zyl    # Not wired into the pipeline

stdlib/                       # The implicit standard library (package zyl/std)
├── core/                     # core, list, option, result, map (auto-loaded)
├── collections/              # vec, map, set
├── allocator/, atomic/, actor/, io/, ffi/, testing/
├── math/                     # Cryptography and number libraries (pure Zyl)
│   ├── bits.zyl, words.zyl   # Word operations, byte-string representation
│   ├── secret/               # Constant-time primitives
│   ├── bignum/               # Fixed-width naturals, Montgomery, Barrett, modular
│   ├── hash/                 # SHA-2, SHA-512, SHA-3, BLAKE2b, BLAKE3, HMAC
│   ├── crypto/               # Symmetric, asymmetric, KDFs
│   └── rand/                 # System entropy and a seeded generator
├── repl/                     # REPL: reader, line editor, ICNF interpreter, history
└── lsp/                      # Language server: JSON-RPC loop, compiler bridge,
                              # services/ (hover, completion, symbols, ...)

tools/repl.zyl                # Standalone REPL `main` (install.sh builds it)
editors/vscode/               # VS Code extension (grammars, snippets, client)
book/                         # "The Zyl Programming Language" (mdBook)
spec/                         # Structured copy of the specification
specifications/               # Historical specification versions
docs/                         # Architecture, design rationale, status
archive/rust-bootstrap-2026/  # The original Rust compiler, frozen

tests/
├── smoke/                    # Quick checks (--quick)
├── regression/               # Feature regression tests
├── stress/                   # Deep recursion, balanced parens, large structs
├── integration/              # Multi-module and self-hosting programs
├── compile-fail/             # Programs that must be rejected
├── packages/, packages-fail/, packages-build/   # Package-system tests
├── lsp/                      # Language-server protocol tests
└── unit_test.zyl             # Comprehensive harness (runs in every mode)
```

## Requirements

- `cc` (a C compiler) and `pthread` — that's it; no Rust, no Cargo
- Linux x86_64 (the only target; other platforms are untested)
- `python3` only to re-bundle the compiler source after editing it
  (`selfhost/assemble.py`) and for the LSP protocol tests
- Node.js/npm only for building the VS Code extension

## Examples

See `tests/regression/` for example Zyl programs covering the language features, and `book/examples/log-processor/` for a complete example program with its tests.

## Specification

The canonical language specification is `zyl_specification.txt` (v5.0; §31 is the package system). Structured reference copies are in `spec/`. Historical specification versions are in `specifications/`.

## Resources

- [The Zyl Programming Language](book/src/SUMMARY.md) — the book
- [Architecture Decisions](docs/architecture-decisions.md)
- [Compiler Pipeline](docs/compiler-pipeline.md)
- [Implementation Status](docs/implementation-status.md)
- [Regression Tests](docs/regression-tests.md)
- [Cryptography and Number Libraries](docs/math-crypto.md)
- [Package Management Design](docs/package-management-design.md)
- [The REPL](docs/repl.md)
- [Error Codes](docs/errors.md)
- [Self-Hosting and the Rust Eviction](docs/rust-eviction-plan.md)
- [LSP Architecture](LSP_ARCHITECTURE_PLAN.md)

## License

MIT