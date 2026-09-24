# Codebase Map

## Overview

Where things live in the active tree. The section `## Archived Rust
bootstrap` at the end describes `archive/rust-bootstrap-2026/`, which
is kept only as a last-resort reseed path and is not part of the build,
the tests, or the use path.

**Related:** `docs/compiler-pipeline.md` (phase-to-file mapping),
`AGENTS.md` (build commands), `docs/regression-tests.md` (the test
runner), `docs/repl.md` (the REPL).

---

## The active tree

```
boot.sh                  Build + verify the self-hosting fixed point
                         (stage1 -> stage2 -> stage3), then build zyl-lsp;
                         --bootstrap-from-self reseeds without Rust
install.sh               Install compiler, REPL and language server into
                         ~/.zyl (or $ZYL_HOME); --with-vscode also installs
                         the VS Code extension
uninstall.sh             Remove what install.sh installed
run_regression_tests.sh  The test runner (--quick, --full, --filter, ...)

selfhost/
  driver.zyl             CLI entry point: argument handling, bundle-dir
                         resolution, linking, `zyl build`/`test`/`eval`/
                         `repl` and the package subcommands
  lsp_main.zyl           Language server entry point (zyl-lsp)
  assemble.py            Bundles the compiler, the stdlib modules it needs
                         and the REPL into one source file
  zyl_selfhost_compiler.zyl   The assembled bundle boot.sh compiles

stdlib/compiler/         The compiler itself (37 files, ~21,200 lines)
stdlib/repl/             The REPL and its ICNF interpreter (8 files, ~4,000 lines)
stdlib/lsp/              The language server (20 files, ~5,400 lines)
stdlib/math/             Cryptography and number libraries (28 files, ~7,600 lines)
stdlib/core/             core (facade), list, option, result, map
stdlib/collections/      collections (Assoc + list utilities), vec, map, set
stdlib/allocator/        Raw memory arenas
stdlib/actor/            spawn/send and actor lifecycle over the C runtime
stdlib/ffi/              FFI pinning helpers
stdlib/io/               File I/O, stdin/stdout helpers, OutputStream trait
stdlib/atomic/           Atomic load/store/add/sub/max/min/cas
stdlib/testing/          The test harness (`test`, `run-tests`, asserts)
stdlib/mlib/             deep.zyl: a small deep-call fixture module

runtime/actor_runtime.c  The C runtime every compiled binary links against
runtime/actor_runtime.h  Its header
tools/repl.zyl           Standalone REPL entry point (a thin `main`)
editors/vscode/          VS Code extension (0.3.0)
book/                    The book (mdBook: book.toml, src/, examples/)
tests/                   smoke, regression, compile-fail, integration,
                         stress, packages, packages-fail, packages-build,
                         lsp, manual, debug; plus unit_test.zyl
verify/                  Python cross-checks for stdlib/math
spec/                    The specification, split by domain
zyl_specification.txt    The canonical specification (v5.0)
archive/rust-bootstrap-2026/   The frozen Rust bootstrap
```

`boot.sh` writes its outputs to `build/boot/`: `stage2.bin` and
`stage2.s` (the committed seed), `zyl-self` (a wrapper that execs
`stage2.bin`), `zyl-lsp`, and a copy of `stdlib/` and the runtime next
to them so the compiler finds both relative to its own location.

### Compiler, file by file

Every file in `stdlib/compiler/`. The order of the pipeline stages is
in `docs/compiler-pipeline.md`.

**Front end**

| File | Responsibility |
|---|---|
| `lexer.zyl` | Tokenizer; every token carries its source byte offset |
| `sexp_balance.zyl` | Delimiter balance check with the location of the first fault |
| `parser.zyl` | Dispatch-free reader: tokens to nested `Ast` lists |
| `ast.zyl` | `Token`, `Ast`, and the immutable `Env`/`VTable` chains |
| `expr_inner.zyl` | `Ast` to `ExprInner`: recognizes every special form (`convert-ast`, `dispatch-special`) |
| `module_resolver.zyl` | Resolves the `use` graph into one compilation unit (discovery, then qualification) |
| `qualify.zyl` | Rewrites identifiers to canonical keys `<pkg>@<major>::<module>::<symbol>` (§31.2) |
| `resolver.zyl` | Two list helpers (`shd`/`stl`) that codegen uses; the old resolver is gone |
| `macro_expand.zyl` | Collects top-level `defmacro`/`macro` forms and expands their call sites |

**Checks** (run in this order, after macro expansion)

| File | Responsibility |
|---|---|
| `capability_check.zyl` | Package capability enforcement (§31.9) |
| `duplicate_check.zyl` | `E_DUPLICATE_DEFINITION` for repeated top-level `defn`/`deftype` |
| `arity_check.zyl` | `E_ARITY_MISMATCH` for direct calls to known top-level functions |
| `mutability_check.zyl` | `E_MUT_CONFLICT`: `set!` only on a `let-mut` binding in scope |
| `exhaustiveness_check.zyl` | `E_NON_EXHAUSTIVE_MATCH` and `E_UNREACHABLE_MATCH_ARM` for ADT matches |
| `unused_check.zyl` | Unused function/parameter/variable and shadowing warnings; `E_DUPLICATE_PARAMETER` |
| `secret_check.zyl` | The `Secret` capability's constant-time obligations (`E_CT_VIOLATION`, `E_SECRET_DEBUG`, `E_SECRET_ESCAPE`, `E_FFI_PIN_REQUIRED`) |

**Middle and back end**

| File | Responsibility |
|---|---|
| `type_system.zyl` | Type ADT, substitutions, environments, trait context, `TypeInferer` record |
| `type_inference.zyl` | Best-effort HM inference: `collect-definitions` records signatures and return types |
| `monomorphization.zyl` | Generic instantiation with sorted canonical names; lifts impl bodies to `Trait.method_Type` |
| `trait_dispatch.zyl` | Rewrites `(Trait.method recv ...)` into a match on the receiver's runtime tag |
| `closure_inline.zyl` | Retired closure-inlining pass, now an identity step (closures are real values) |
| `assert_lowering.zyl` | Rewrites `assert-equal` on ADT/struct values to a `zyl_variant_eq` call |
| `icnf.zyl` | Lowers `ExprInner` to the tree-shaped `Icnf` IR |
| `optimization.zyl` | Integer constant folding and dead-branch elimination on `Icnf` |
| `region_inference.zyl` | Escape analysis: a non-escaping variant becomes `IStackVariant` |
| `codegen.zyl` | `Icnf` to x86_64 GAS Intel-syntax assembly |
| `pipeline.zyl` | The one implementation of the phase order (`compile-to-fns`, `compile-to-asm`) |
| `contract_injection.zyl` | Written but not compiled: not in the bundle, not called (see below) |

**Diagnostics**

| File | Responsibility |
|---|---|
| `error_codes.zyl` | The error-code catalog: code, phase, severity, default message |
| `error_report.zyl` | Located rendering: `error[CODE]`, `--> file:line:col`, source line, caret, `= help:` |

**Package system** (spec §31)

| File | Responsibility |
|---|---|
| `package.zyl` | `zyl.pkg` reader and SemVer arithmetic |
| `mvs.zyl` | Minimal Version Selection and feature unification |
| `lock.zyl` | `zyl.lock` reading and canonical writing |
| `store.zyl` | Content-addressed store and canonical archives |
| `index.zyl` | The package index and mandatory Ed25519 verification |
| `workspace.zyl` | `zyl-workspace.zyl` and member checks |
| `cli.zyl` | `zyl new`, `add`, `fetch`, `update`, `vendor`, `audit`, `publish`, `key` |

`pipeline.zyl` is the one implementation of the phase order:
`compile-to-fns` runs everything from the balance check through region
inference, and `compile-to-asm` is that plus code generation. The CLI
(`selfhost/driver.zyl`), `zyl eval` and the REPL all call it, which is
what keeps a compile and a REPL entry running the same compiler.

`contract_injection.zyl` is not in `selfhost/assemble.py`'s file list
and nothing calls it: its accessors do not match the real `ExprInner`
shapes. The comment above `lower-exprs` in `pipeline.zyl` explains why.
`requires`, `ensures`, `checkpoint` and `recover` are parsed by
`expr_inner.zyl` and lower to their inner expression; nothing checks
them.

### REPL, file by file

| Concern | File |
|---|---|
| Raw mode, window size, key decoding | `stdlib/repl/terminal.zyl` |
| Editor state, multi-line layout, redraw | `stdlib/repl/line_editor.zyl` |
| The key loop, completion, reverse search | `stdlib/repl/reader.zyl` |
| Syntax highlighting as you type | `stdlib/repl/highlight.zyl` |
| Persistent history (`~/.zyl/repl_history`) | `stdlib/repl/history.zyl` |
| ICNF interpreter | `stdlib/repl/interp.zyl` |
| Session, entries, `def` bindings, `:type` | `stdlib/repl/eval.zyl` |
| Prompt, meta commands, session file, scripted mode | `stdlib/repl/repl.zyl` |

`zyl repl` and the standalone binary built from `tools/repl.zyl` (by
`install.sh`, as `zyl-repl`) are two entry points onto the same
modules. `zyl eval <file>` runs a program through the interpreter with
no binary; the regression suite uses it to check that the interpreter
and the code generator agree. See `docs/repl.md`.

### Language server, file by file

| Concern | File |
|---|---|
| Protocol types | `stdlib/lsp/lsp_types.zyl` |
| Transport | `stdlib/lsp/json_rpc.zyl` |
| Document text and edits | `stdlib/lsp/vfs.zyl` |
| Analysis cache and diagnostics | `stdlib/lsp/document_manager.zyl` |
| Symbol table, hover text, diagnostic mapping | `stdlib/lsp/compiler_bridge.zyl` |
| Positions, occurrences, call context | `stdlib/lsp/source_index.zyl` |
| Built-in and special-form table | `stdlib/lsp/builtins.zyl` |
| Advertised capabilities | `stdlib/lsp/capability_registry.zyl` |
| Workspace folders and symbols | `stdlib/lsp/workspace.zyl` |
| Run-a-file support (marked known broken in its header) | `stdlib/lsp/repl_integration.zyl` |
| Request loop | `stdlib/lsp/lsp_server.zyl` |
| Features: call hierarchy, code actions, completion, document symbols, go-to-definition and references, hover, inlay hints, semantic tokens, signature help | `stdlib/lsp/services/*.zyl` |

### Math and cryptography

| Directory | Contents |
|---|---|
| `stdlib/math/` | `math.zyl` (re-exports everything), `words.zyl` (flat word arrays), `bits.zyl` (32/64-bit word arithmetic) |
| `stdlib/math/bignum/` | Fixed-width bignums, Montgomery and Barrett reduction, modular arithmetic |
| `stdlib/math/hash/` | SHA-256, SHA-512, SHA-3/SHAKE, BLAKE2b, BLAKE3, HMAC-SHA256 |
| `stdlib/math/crypto/symmetric/` | ChaCha20, Poly1305, ChaCha20-Poly1305, AES-GCM |
| `stdlib/math/crypto/asymmetric/` | X25519, Ed25519, ECDSA, RSA |
| `stdlib/math/crypto/kdf/` | HKDF, PBKDF2, Argon2id |
| `stdlib/math/rand/` | `SystemRng` and the seedable `ChaCha20Rng` |
| `stdlib/math/secret/` | Constant-time comparison, selection and zeroization |

`verify/crypto.py` and `verify/sha2.py` cross-check these against
Python references on random inputs; `verify/timing.py` is a
dudect-style timing-leak check. See `docs/math-crypto.md`.

### The runtime

`runtime/actor_runtime.c` is linked into every binary. Besides the
pthread actor system it holds the try/catch frame stack, closure
invocation, FFI pinning, arenas and the memory budget, string and byte
primitives, atomics, the source-span table used for located
diagnostics, AES-NI and system entropy for `stdlib/math`, the test
harness, file and process helpers (`zyl_cc_compile`, `zyl_exec_cmd`,
`zyl_run_bin`), the terminal primitives and interpreter support the
REPL uses (value headers, float helpers, dynamic C calls), and the
package system's BLAKE3 hash and canonical-key mangler
(`zyl_blake3_hex`, `zyl_mangle_key`). Ed25519 signing and verification
are Zyl code in `stdlib/math`, bundled into the compiler.

### Tests

| Directory | What it holds |
|---|---|
| `tests/smoke/` | Five minimal programs |
| `tests/regression/` | The main suite, one file per feature area |
| `tests/compile-fail/` | Programs that must be rejected with a specific error |
| `tests/integration/` | Multi-module and whole-compiler programs |
| `tests/stress/` | Deep recursion, large structs, long chains, balance |
| `tests/packages/`, `packages-fail/`, `packages-build/` | Package-system fixtures |
| `tests/lsp/` | `lsp_protocol_test.py`, the LSP protocol suite |
| `tests/manual/` | Interactive checks (`read-line`) |
| `tests/debug/` | A minimized reproduction kept for reference |
| `tests/unit_test.zyl` | The unit test the runner compiles and runs |

---

## Archived Rust bootstrap

`archive/rust-bootstrap-2026/` is frozen. It is never edited for a
language change; `./boot.sh --bootstrap-from-self` is the normal reseed
path and needs no Rust at all. `archive/rust-bootstrap-2026/README.md`
describes the one case the archive exists for, and
`docs/rust-eviction-plan.md` has the full history.

Its sources, for orientation only (line counts as archived):

| File | Lines | Role |
|---|---|---|
| `src/main.rs` | 486 | CLI and pipeline orchestration |
| `src/error.rs` | 186 | Error model |
| `src/lexer.rs` | 486 | Tokenizer |
| `src/parser.rs` | 2047 | Recursive-descent parser |
| `src/ast.rs` | 3061 | AST and the PostProcessor |
| `src/macro_expander.rs` | 1482 | Macro expansion with gensym hygiene |
| `src/module_resolver.rs` | 494 | `use` resolution |
| `src/region_inference.rs` | 1192 | Region inference |
| `src/type_system.rs` | 662 | Type definitions |
| `src/type_inference.rs` | 2837 | HM inference |
| `src/monomorphization.rs` | 1896 | Monomorphization |
| `src/icnf.rs` | 4635 | SSA-form ICNF |
| `src/optimization.rs` | 548 | Constant folding and DCE |
| `src/codegen.rs` | 9245 | x86_64 code generation |
| `src/contract_injection.rs` | 307 | Contract injection |
| `src/zyl_source_gen.rs` | 599 | Zyl source generation |
| `src/deterministic.rs` | 37 | Deterministic collections |
| `src/repl.rs` | 323 | REPL |
| `src/runtime.rs` | 17 | Runtime path |

The archive has no runtime of its own; the one in `runtime/` is shared.
