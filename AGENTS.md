# Zyl — Agent Instructions

## Project Identity

**Zyl** is a deterministic Lisp systems language with region-based memory, Hindley-Milner type inference with capability types, actor concurrency, SSA IR (ICNF), FFI safety via pinning/timeout enforcement, hygienic macros, and full determinism. S-expression syntax targeting x86_64 native code. The compiler is self-hosting: it is written in Zyl and reproduces itself byte for byte (`./boot.sh`).

## Authoritative Sources (in order)

1. **`zyl_specification.txt`** — Canonical language specification (v5.0; §31 is the package system)
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
This is spec §22's order:

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

The implementation's order is defined in `stdlib/compiler/pipeline.zyl`
and differs from the list above: balance check → parse → module
resolution → macro expansion → capability/duplicate/arity (also
`E_MALFORMED_FORM`, `E_FFI_RESTRICTED`)/mutability/exhaustiveness/
unused/secret checks → derive expansion → impl lifting → closure
lifting → type checking (`type_annotate.zyl`: sound HM, spec §4.8–§4.10;
every type error is reported, then the compile fails; static trait
resolution, per-type specialization of calls and function values,
generated structural `T.==`) → ICNF lowering →
optimization → region inference (the stack-variant rewrite, then
`rg-regions`: escape analysis over ICNF that places every allocation and
call site in the frame's own region, the caller's result region, or the
heap, and raises `E_REGION_ESCAPE`; see `docs/regions-design.md`) →
codegen → `cc` link. Contracts are lowered where forms are recognized
(`convert-ast`, `expr_inner.zyl`): `requires`/`ensures`/`invariant`
become checks raising `E_CONTRACT_VIOLATION`, `ensures` binds `result`,
`recover` is `try`/`catch` with arms by error code, `checkpoint` rolls
back `let-mut` state, and the profile (`--contracts=P`, `(contracts P)`)
picks panic, warn or strip. Hash finalization exists only for
package builds: `zyl build` writes `<out>.buildinfo` (compiler, graph,
native-object and ICNF hashes, the resolved graph, the assembly hash,
and the final hash of spec §31.12's four inputs, which the binary
carries as `zyl_build_hash`).

## Non-Negotiable Constraints

### Determinism
- Same source + same inputs → identical binaries and observable outputs
- Every iterated collection has a defined order (association lists, insertion-ordered arrays); a hash table, such as the runtime's source-span table, may only be probed by key, never iterated
- No randomness, no timestamps, no scheduling-dependent behavior

### Evaluation Order
- Strict left-to-right evaluation. Never reorder side effects.
- Function application: evaluate function, then arguments sequentially.

### Region System
- Regions: Stack, Heap, Global, Circular, Pin. Region placement is decided
  at compile time by escape analysis (`region_inference.zyl`) over
  union-find object classes, with per-function parameter summaries joined
  to a whole-program fixpoint
- Each call that allocates short-lived values gets a frame region,
  released on return, before a tail jump, or when a caught panic unwinds
  it; results go into the region the caller chose (`zyl_cur_region`);
  values that escape untracked go to the process heap, which still lives
  until exit. `ZYL_REGIONS=0` at compile time turns this off
- `(bytebuf Stack N)` lives in the frame region; `with-region` opens an
  explicit `arena` or `fixed` region (`E_REGION_SPEC`,
  `E_REGION_EXHAUSTED`)
- No value may escape its assigned region: a Stack bytebuf or a
  `with-region` value that would outlive its region is `E_REGION_ESCAPE`
- Global and Circular are names only (Global = top-level `def` values,
  which are heap); the interpreter ignores regions

### Capability Types
- TCap: shared immutable access (any number of references)
- TMut: exclusive mutable ownership (exactly one reference)
- TMut/TCap aliasing invariant enforced at compile time

### FFI Safety
- FFI calls require Pin region + timeout parameter
- FFI_Pinnable types: Int, Float, Bool, String, Vec<T>, composed types
- Current enforcement: `(ffi-call "sym" args... timeout)` — the symbol
  must be a string literal (`E_FFI_SYMBOL_REQUIRED`) and the timeout a
  positive integer literal in milliseconds (`E_FFI_TIMEOUT_REQUIRED`).
  A foreign call runs on a per-thread worker through the runtime's
  `zyl_ffi_timed`; overrunning raises `E_FFI_TIMEOUT` and the call is
  abandoned, not killed. `zyl_*` runtime symbols are called directly.
  `ffi-call`/`ffi-pin` need the `ffi` capability in a package, and a
  `Secret` argument must be passed through `ffi-pin`
  (`E_FFI_PIN_REQUIRED`)

### Struct Immutability
- Struct fields are immutable by default
- Mutation via `let-mut` rebinding only; `set!` on anything else is `E_MUT_CONFLICT`
- Direct field mutation (`set! (struct-get p "x") 5`) is forbidden (`E_MUT_CONFLICT`)

### Match Exhaustiveness
- Exhaustiveness is a compile-time error if not satisfied (`E_NON_EXHAUSTIVE_MATCH`); an arm after a catch-all is `E_UNREACHABLE_MATCH_ARM`
- `_` is the discard in patterns, parameters and bindings; `_`-prefixed names are exempt from unused-binding warnings. Do not introduce `d1`-style dummy names
- An arm head that is not a known constructor is a catch-all binding, so a misspelled constructor in the LAST arm silently matches everything

### Contracts
- Contracts never alter core semantics (type inference, ownership, regions, concurrency)
- Contracts are an optional overlay: runtime checks under a profile (strict/debug panic, warn reports, off/production strip — see above)

## Architecture Decisions (Do Not Reverse)

- **No-dispatch parsing:** the reader produces generic S-expression nodes; form recognition happens afterwards in one place (`convert-ast` in `stdlib/compiler/expr_inner.zyl`)
- **Innermost-first macro expansion** with gensym hygiene
- **ICNF as custom SSA IR** (not LLVM) for region annotation flow (today ICNF is a tree IR, not yet SSA; region annotations live in a side table keyed by node and are printed as ` @r`, so the ICNF hash covers them)
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
./boot.sh --bootstrap-from-self # Reseed using the self-hosted compiler (no Rust)
./boot.sh                       # Verify the new seed reaches a clean fixed point
git add -f build/boot/stage2.s build/boot/stage2.bin && git commit
```

`--bootstrap-from-self` fails only when a change is so large the old
seed can't even parse the new source (new syntax, not just new
behavior). The archived Rust compiler can no longer lex the current
source (it rejects the `\e` string escape), so it is not a working
fallback: introduce new syntax in two steps instead — teach the
compiler to accept it, reseed, and only then use it in the compiler's
own source. See `archive/rust-bootstrap-2026/README.md` and
`docs/rust-eviction-plan.md` for the history.

A verified `./boot.sh` ends by refreshing an existing install (`~/.zyl`,
or `$ZYL_INSTALL_HOME`) with `uninstall.sh` + `install.sh`, so the
installed `zyl` never runs a stale stdlib; `ZYL_NO_INSTALL_REFRESH=1`
skips it. `./boot.sh` also builds `build/boot/zyl-lsp`. It does not build the
REPL binary; `zyl-self repl` runs the REPL, and `./install.sh` builds a
standalone `zyl-repl` from `tools/repl.zyl`. Stage timeouts default to
2400 s (`ZYL_STAGE_TIMEOUT`); a full verification takes well under a
minute.

The CLI (`selfhost/driver.zyl`, `drv-usage`): `zyl <file.zyl> [-o out]
[--emit-asm]`, `new`, `add`, `fetch`, `build [--locked]`, `test`,
`update`, `vendor`, `audit`, `publish`, `key`, `repl`, `eval <file.zyl>`,
`doc [file|dir] [-o out.md]`.

## Regression Tests

```bash
./run_regression_tests.sh --quick   # unit_test + tests/smoke (the default mode)
./run_regression_tests.sh --full    # ./boot.sh, then every category
./run_regression_tests.sh --full --no-boot   # every category, skip the fixed-point check
./run_regression_tests.sh --full --no-boot --filter structs  # struct tests only
```

`--filter` is a case-insensitive substring of the test name and applies
*within* the selected mode — `--filter structs` alone runs in quick mode
and selects nothing. `--full` runs `./boot.sh` first unless `--no-boot`
is given. Other flags: `--verbose`, `--timeout N`, `--boot`,
`--dry-run` (lists exactly the tests a real run with the same mode and
`--filter` would run). Categories in `--full`: regression, interpreter
(differential REPL-interpreter-vs-codegen runs), compile-fail,
integration, stress, packages, packages-fail, packages-build, scripts
(shell checks of the repository's own scripts), lsp, and
the unit test.

**Trigger before modifying struct-related code** (`ast.zyl`, `codegen.zyl`, `icnf.zyl`, `type_annotate.zyl`, `parser.zyl`, `region_inference.zyl` under `stdlib/compiler/`):
```bash
./run_regression_tests.sh --full --no-boot --filter structs
```

Full test infrastructure documented in `docs/regression-tests.md`. All tests use the `(test "name" (assert-equal ...))` harness defined in `stdlib/testing/testing.zyl`.

**S-expression balance** is critical — always run `./run_regression_tests.sh --full --no-boot --filter balanced-parens` after modifying parser/lexer (the delimiter compile-fail tests are `unclosed-opener`, `unexpected-close` and `mismatched-bracket`).

## Architecture Notes

- Entry point: `selfhost/driver.zyl`, compiled like any program (its `(use ...)` tree resolved from `stdlib/`, names qualified per module) to `build/boot/stage2.bin`/`zyl-self`. `boot.sh` caps each stage at 4 GB of allocation (`ZYL_STAGE_MEMORY`). The phase order shared by the CLI and the REPL is `stdlib/compiler/pipeline.zyl`.
- Language server: `selfhost/lsp_main.zyl` + `stdlib/lsp/` (and `services/`), built by `./boot.sh` as `build/boot/zyl-lsp`; the VS Code client is `editors/vscode/` (0.4.0, esbuild-bundled, `$zyl` problem matcher). Protocol tests: `tests/lsp/lsp_protocol_test.py`.
- REPL: `stdlib/repl/` (reader, line editor, highlighting, history, ICNF interpreter `interp.zyl`, session `eval.zyl`/`repl.zyl`), reached through `zyl repl`; `tools/repl.zyl` is only the standalone `main`. It is a working tool — see `docs/repl.md`.
- Single binary — no workspace, no crates, no Cargo anywhere in the active path
- The package system (spec v5.0 §31) IS implemented: manifests, canonical
  symbol keys, visibility, MVS, the lock, the content store, the index with
  mandatory Ed25519 verification, capabilities, features, native
  dependencies, workspaces and the `zyl` subcommands. Its modules are
  `stdlib/compiler/{package,qualify,store,workspace,lock,index,mvs,cli,
  capability_check,module_resolver}.zyl`; `docs/package-management-design.md`
  holds the rationale and `PROGRESS.md` records the deviations and gaps
- The standard library is IMPLICIT (§25): package `zyl/std`, no manifest,
  fully visible, never capability-enforced. Do not give it a `zyl.pkg`
- All error codes from spec §28 must be defined and used consistently
