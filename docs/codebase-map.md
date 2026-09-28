# Codebase Map

## Overview

Where things live in the active tree. The original Rust bootstrap
(`archive/rust-bootstrap-2026/`) has been removed; it is in git history
at commit `b8bc283`.

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

                         There is no bundling step: boot.sh compiles
                         driver.zyl directly, and its (use ...) tree is
                         resolved from stdlib/ like any program's.

stdlib/compiler/         The compiler itself (46 files, ~29,800 lines)
stdlib/repl/             The REPL and its ICNF interpreter (8 files, ~4,200 lines)
stdlib/lsp/              The language server (20 files, ~5,600 lines)
stdlib/math/             Cryptography and number libraries (28 files, ~7,700 lines)
stdlib/core/             core (facade), list, option, result, map, show
                         (the derivable traits and their primitive impls),
                         resource (Drop), property (test-property samples)
stdlib/collections/      collections (Assoc + list utilities), vec, map, set,
                         slice (zero-copy Vec slices)
stdlib/text/             view: StrView (zero-copy substrings) and Cursor
stdlib/simd/             I64x2, I32x4, U8x16 lane vectors (portable SWAR)
stdlib/allocator/        Raw memory arenas
stdlib/actor/            actor-spawn, actor-wait, actor-is-alive (channels
                         are builtins)
stdlib/ffi/              FFI pinning helpers
stdlib/io/               File I/O, stdin/stdout helpers, OutputStream trait
stdlib/atomic/           Atomic load/store/add/sub/max/min/cas
stdlib/testing/          The test harness (`test`, `run-tests`, asserts)
stdlib/mlib/             deep.zyl: a small deep-call fixture module

runtime/rt/              The Zyl runtime every compiled binary links against
                         (rt.zyl + 34 modules, ~5,600 lines; seed build/boot/rt.s)
tools/repl.zyl           Standalone REPL entry point (a thin `main`)
editors/vscode/          VS Code extension (0.5.0)
book/                    The book (mdBook: book.toml, src/, examples/)
tests/                   smoke, regression, compile-fail, integration,
                         stress, packages, packages-fail, packages-build,
                         scripts, lsp, manual, debug; plus unit_test.zyl
site/                    The website (landing page; site/build.sh adds the book)
bench/                   The benchmark matrix against C, C++, Rust and Go
                         (matrix.py; see docs/native-backend-design.md)
verify/                  Python cross-checks for stdlib/math
spec/                    The specification, split by domain
zyl_specification.txt    The canonical specification (v5.0)
```

`boot.sh` writes its outputs to `build/boot/`: `stage2.bin` and
`stage2.s` (the committed seed), `zyl-self` (a wrapper that execs
`stage2.bin`), `zyl-lsp`, and a copy of `stdlib/` and the runtime next
to them so the compiler finds both relative to its own location. The
runtime's committed seed `rt.s` and `start.s` (the `_start` stub) are
assembled into `rt.zo` for the Zyl linker, and into `rt.o`/`start.o`
for a `cc` link (hosted programs, `ZYL_EXTERNAL_LD=1`); `install.sh`
copies them to the install directory. See `docs/self-hosting.md`.

### Compiler, file by file

Every file in `stdlib/compiler/`. The order of the pipeline stages is
in `docs/compiler-pipeline.md`.

**Front end**

| File | Responsibility |
|---|---|
| `lexer.zyl` | Tokenizer; every token carries its source byte offset |
| `sexp_balance.zyl` | Delimiter check (spec §1.6): the lexer's string and comment rules, bracket kinds, the column-1 layout rule, the indentation hint, NUL detection and the whole-file reader; `zyl balance` runs it on its own |
| `parser.zyl` | Dispatch-free reader: tokens to nested `Ast` lists |
| `desugar.zyl` | Parse-tree rewrites of `with-resource`, `assert-fail`, `test-suite` (with fixtures) and `test-property` into ordinary forms |
| `ast.zyl` | `Token`, `Ast`, and the immutable `Env`/`VTable` chains |
| `expr_inner.zyl` | `Ast` to `ExprInner`: recognizes every special form (`convert-ast`, `dispatch-special`); records declared field types and `extern` signatures (`extern-table`) for the type pass; lowers contracts |
| `module_resolver.zyl` | Resolves the `use` graph into one compilation unit (discovery, then qualification) |
| `qualify.zyl` | Rewrites identifiers to canonical keys `<pkg>@<major>::<module>::<symbol>` (§31.2) |
| `resolver.zyl` | Two list helpers (`shd`/`stl`) that codegen uses; the old resolver is gone |
| `macro_expand.zyl` | Collects top-level `defmacro`/`macro` forms and expands their call sites |

**Checks** (run in this order, after macro expansion)

| File | Responsibility |
|---|---|
| `reserved_check.zyl` | `E_RESERVED_KEYWORD` (spec §1.3.1) on the raw forms of every module outside the standard library and the runtime |
| `capability_check.zyl` | Package capability enforcement (§31.9) |
| `duplicate_check.zyl` | `E_DUPLICATE_DEFINITION` for repeated top-level `defn`/`deftype`; `E_DUPLICATE_VARIANT` for a program type that reuses a prelude constructor name |
| `arity_check.zyl` | `E_ARITY_MISMATCH` for direct calls to known top-level functions; `E_MALFORMED_FORM` for a special form its parser rejected; the `ffi-call` shape checks and `E_FFI_RESTRICTED` for a raw runtime entry named outside the standard library |
| `mutability_check.zyl` | `E_MUT_CONFLICT`: `set!` only on a `let-mut` binding in scope |
| `exhaustiveness_check.zyl` | `E_NON_EXHAUSTIVE_MATCH` and `E_UNREACHABLE_MATCH_ARM` for ADT matches |
| `unused_check.zyl` | Unused function/parameter/variable and shadowing warnings; `E_DUPLICATE_PARAMETER` |
| `secret_check.zyl` | The `Secret` capability's constant-time obligations (`E_CT_VIOLATION`, `E_SECRET_DEBUG`, `E_SECRET_ESCAPE`, `E_FFI_PIN_REQUIRED`) |

**Middle and back end**

| File | Responsibility |
|---|---|
| `type_system.zyl` | 26 lines: the generic `Pair` and the `Region` family (`RStack` ... `RPin`) used by the parser and ICNF lowering |
| `derive.zyl` | Expands `(derive T Trait...)` into impl blocks for Show, Debug, Eq, Ord, Hash and Clone; `E_TRAIT_NOT_DERIVABLE`, `E_DUPLICATE_IMPL` |
| `lift_impls.zyl` | Lifts impl bodies to top-level `Trait.method_Type` functions |
| `closure_inline.zyl` | Retired closure-inlining pass, now an identity step (closures are real values) |
| `type_annotate.zyl` | The type checker (spec §4.8–§4.10): HM inference with SCC generalization, every type error reported then fatal, static trait resolution, per-type instances of trait-generic functions (generic originals dropped), generated structural `T.==`, codegen kinds and scalar marks |
| `ffi_sigs.zyl` | The type of every runtime function reached through `ffi-call` (`ffi-sig`), and the raw entries only the standard library may call (`ffi-raw-p`) |
| `node_tables.zyl` | Per-node side tables: types, renamed calls, Show functions, ICNF kinds, regions, scalar marks, ADT marks, reuse marks; also the contract-profile and secret-mark tables |
| `icnf.zyl` | Lowers `ExprInner` to the tree-shaped `Icnf` IR |
| `icnf_print.zyl` | Canonical ICNF text for the package build's ICNF hash |
| `optimization.zyl` | Inlining of small functions and copy propagation (`opt-inline-fns`), then integer constant folding and dead-branch elimination (`opt-optimize-fns`) on `Icnf` |
| `region_inference.zyl` | The stack-variant rewrite (`ri-transform-fns`) and whole-program escape analysis that places every allocation and call site in the frame region, the result region or the heap (`rg-regions`); `E_REGION_ESCAPE` |
| `reuse.zyl` | In-place reuse: marks a construction that may take the block of a unique, dead value (`ru-reuse`), with owning clones `f~own` |
| `codegen.zyl` | `Icnf` to x86_64 GAS Intel-syntax assembly: chooses per function between the native path (lowering to MIR, `ml-expr`; emission, `mb-emit-one`) and the stack-machine emitter |
| `mir.zyl` | The native backend's machine IR (`deftype MI`), liveness, and linear-scan register allocation (`mir-allocate`) |
| `asm_x86.zyl` | x86-64 assembler for every form the compiler emits; byte-identical to GNU as per instruction |
| `elf_link.zyl` | Static ELF linker (PT_TLS, non-exec stack, synthesized GOT) and the `rt.zo` runtime cache |
| `rt_mode.zyl` | `--runtime-module`: the locked `%` primitives, exported `zyl_*` labels, and the bit intrinsics' lowering |
| `pipeline.zyl` | The one implementation of the phase order (`compile-to-fns`, `compile-to-asm`) |
| `doc.zyl` | `zyl doc`: Markdown from source comments |

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
inference and in-place reuse, and `compile-to-asm` is that plus code
generation. The CLI
(`selfhost/driver.zyl`), `zyl eval` and the REPL all call it, which is
what keeps a compile and a REPL entry running the same compiler.

Contracts have no pass of their own: `expr_inner.zyl` rewrites
`requires`, `ensures`, `invariant` and `recover` into checks and
`try`/`catch` while converting the parse tree (`contract-defn-body`).

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
| Analysis cache and diagnostics (runs the checks, derive expansion, impl lifting and the type checker, and publishes every type error) | `stdlib/lsp/document_manager.zyl` |
| Symbol table, hover text, diagnostic mapping | `stdlib/lsp/compiler_bridge.zyl` |
| Positions, occurrences, call context | `stdlib/lsp/source_index.zyl` |
| Built-in and special-form table | `stdlib/lsp/builtins.zyl` |
| Advertised capabilities | `stdlib/lsp/capability_registry.zyl` |
| Workspace folders and symbols | `stdlib/lsp/workspace.zyl` |
| Run-a-file support (`zyl.evalDocument`: compiles and runs the buffer through the `zyl` CLI) | `stdlib/lsp/repl_integration.zyl` |
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

`runtime/rt/*.zyl` is linked into every binary; `docs/runtime-in-zyl-design.md`
has the design. By module:

| Module | Contents |
|---|---|
| `rt.zyl` | The entry: `use`s every module |
| `base`, `cpu`, `cstr`, `text`, `misc` | Raw word and byte helpers, `cpuid` features, C strings with SSE2/AVX2 scans, string and number text, raw memory for `stdlib/allocator` |
| `heap`, `alloc` | The allocator (size classes over mmap), the memory budget, arenas, frame regions (`zyl_ralloc`, `zyl_region_*`), the pin arena |
| `thread`, `start`, `sys`, `env`, `proc`, `os` | `clone` threads with TLS and futex locks, start-up and shutdown, syscalls, environment and the exit registry, child processes, files, directories and the terminal |
| `out`, `io`, `panic`, `source` | Buffered stdout and per-actor output; exit, `read-line` and the interpreter's test transcript; try frames (pointer-mangled) and panics in text and JSON; registered sources and diagnostic snippets |
| `chan`, `actor`, `ffitimed`, `call`, `ffitab` | Kahn channels and the schedulers, actors, the timed FFI worker and foreign calls, closure calls and division magic numbers, the interpreter's symbol table |
| `float`, `fmt` | Float arithmetic entries and exact float text and parsing |
| `tables`, `ctab`, `variant`, `uf`, `interp` | Word arrays, maps and vectors the compiler uses, variant equality and fields, union-find, the interpreter's value headers and interned names |
| `bytes`, `crc`, `crypto`, `blake3`, `mangle` | ByteBuf/ByteSlice and atomics, CRC-32C, AES-NI and entropy, BLAKE3, canonical-key mangling |

Ed25519 signing and verification are Zyl code in `stdlib/math`, bundled
into the compiler.

### Tests

| Directory | What it holds |
|---|---|
| `tests/smoke/` | Five minimal programs |
| `tests/regression/` | The main suite, one file per feature area |
| `tests/compile-fail/` | Programs that must be rejected with a specific error |
| `tests/integration/` | Multi-module and whole-compiler programs |
| `tests/stress/` | Deep recursion, large structs, long chains, balance |
| `tests/packages/`, `packages-fail/`, `packages-build/` | Package-system fixtures |
| `tests/scripts/` | Shell checks of the repository's own scripts |
| `tests/lsp/` | `lsp_protocol_test.py`, the LSP protocol suite |
| `tests/manual/` | Interactive checks (`read-line`) |
| `tests/debug/` | A minimized reproduction kept for reference |
| `tests/unit_test.zyl` | The unit test the runner compiles and runs |

---

## Removed Rust bootstrap

The original Rust compiler (`archive/rust-bootstrap-2026/`) has been
removed from the tree; retrieve it from git history at commit
`b8bc283` if needed. `./boot.sh --bootstrap-from-self` is the reseed
path and needs no Rust; `docs/self-hosting.md` describes it.
