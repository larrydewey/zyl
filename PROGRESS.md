# Zyl Progress Tracker

This file has two parts. The sections down to **Session log** describe the
project as it stands and what is still open; they are kept current. The
session log below them is history, newest first: each entry records what
was true when it was written. Where a later session changed something an
entry reports as open, the entry carries a short *Status (date)* note
rather than a rewrite.

## Current State (verified 2026-09-23, HEAD `3e65944`; build section updated 2026-09-24)

Every claim in this section was checked against the source tree, the git
history, or a probe compile with `build/boot/zyl-self` on 2026-09-23.

### Build and verification

- The compiler is self-hosted: `stdlib/compiler/*.zyl` (37 modules) plus
  `selfhost/` (`driver.zyl`, `lsp_main.zyl`). Every boot stage compiles
  `selfhost/driver.zyl` through module resolution, like any program;
  the single-file bundle and `assemble.py` were retired on 2026-09-24.
  `./boot.sh` builds with nothing but `cc`, caps each stage at 2 GB
  (`ZYL_STAGE_MEMORY`), and verifies the stage2 == stage3 fixed point;
  `./boot.sh --bootstrap-from-self` reseeds. The Rust implementation is
  frozen in `archive/rust-bootstrap-2026/` for the record only: it cannot
  lex the current source, and `--bootstrap-from-rust` is retired.
- `./boot.sh` produces `build/boot/{zyl-self, stage2.bin, zyl-lsp,
  zyl-repl, stdlib/, actor_runtime.c, actor_runtime.h}`. The self-build
  prints no warnings (swept 2026-09-24).
- `./run_regression_tests.sh --full --no-boot` passes **168/168**
  (updated 2026-09-24): regression 64, interpreter 43, compile-fail 35,
  integration 7, packages-fail 7, stress 4, scripts 6, packages 2,
  packages-build 1, lsp 1, unit_test 1. The interpreter category runs the regression and smoke
  tests both through the ICNF interpreter and as compiled binaries and
  diffs the output.
- The specification is `zyl_specification.txt` **v5.0** (§0–§31, §31 being
  the package system); `spec/` is the structured copy, including
  `spec/16-package-system.md`.

### Compiler

- Phase order (`stdlib/compiler/pipeline.zyl`): balance check, parse,
  module resolution and qualification, macro expansion, the checks
  (capability, duplicate definition, arity, mutability/aliasing,
  exhaustiveness, unused, secret), derive expansion, type inference,
  monomorphization (impl lifting), closure lifting, assert lowering,
  type annotation (HM, static trait resolution, per-type
  specialization), ICNF lowering,
  optimization (constant folding and dead-branch elimination), region
  inference (a provably non-escaping variant becomes `IStackVariant`),
  x86_64 code generation, and linking with `cc`.
- Covered by the suite: structs, ADTs with per-ADT exhaustiveness
  checking, literal/OR/range/guard patterns, `_` and `_`-prefixed names
  as discards, generics through monomorphization, traits and derive,
  closures with free-variable capture, `try`/`catch`, macros, actors
  (`spawn`, `send`, `actor-wait`), FFI with pinning and timeouts, the
  bitwise operators, 8-bit byte loads and stores, byte slices, atomics,
  `align-check`, and the `Secret` capability's constant-time checks.
- Macro expansion (`macro_expand.zyl`) implements spec §19: gensym
  hygiene (template binders renamed to `name__hygN` from a source-order
  counter; a free template name that is a call-site local is
  `E_UNBOUND_VARIABLE`), expansion in every form, parameters substituted
  in binder and `set!`-target positions, `E_MACRO_NON_TERMINATION` for a
  macro reached during its own expansion, `E_MACRO_ILLEGAL_ACCESS` for a
  non-top-level `defmacro`, `E_ARITY_MISMATCH` for a wrong argument
  count, `E_DUPLICATE_DEFINITION` for a repeated macro name. Parameters
  are still plain names (no patterns or rest parameters).
- Located diagnostics (`error[CODE]`, `--> file:line:col`, the source
  line, a caret and a `= help:` line) for the four balance errors,
  `E_MALFORMED_PARAMETER`, `E_ARITY_MISMATCH`, `E_NON_EXHAUSTIVE_MATCH`,
  `E_UNREACHABLE_MATCH_ARM`, `E_DUPLICATE_DEFINITION` and
  `E_UNBOUND_VARIABLE`.
- An allocation failure reports `E_OUT_OF_MEMORY`; the budget is
  `ZYL_MAX_MEMORY` when set, otherwise 80% of available memory.

### Package system (spec §31)

- Implemented: manifests (`zyl.pkg`), canonical symbol keys with
  injective mangling, `pub` visibility, Minimal Version Selection,
  `zyl.lock`, the content-addressed store, the index with mandatory
  Ed25519 verification, capabilities, features, native dependencies,
  workspaces, and `zyl new/add/fetch/build/test/update/vendor/audit/
  publish/key`. Modules: `stdlib/compiler/{package,qualify,store,
  workspace,lock,index,mvs,cli,capability_check,module_resolver}.zyl`.
- A git dependency is cloned, archived into the store, locked by hash and
  built: verified with a local `file://` repository (`zyl fetch`, then
  `zyl build --locked`, then running the binary).
- The standard library is the implicit package `zyl/std` and has no
  manifest; a lone file compiles as `local/main`@0.

### Tools

- `zyl` CLI: `zyl <file.zyl> [-o out] [--emit-asm]`, the package
  subcommands above, `zyl repl`, and `zyl eval <file.zyl>`, which runs a
  program through the ICNF interpreter without linking. The installed
  `zyl` wrapper (`install.sh`) starts the REPL when given no arguments;
  `build/boot/zyl-self` with no arguments still runs the legacy
  `/tmp/zyl_boot_in.zyl` boot path.
- REPL (`stdlib/repl/`, documented in `docs/repl.md`): raw-mode line
  editor, persistent history with reverse search, highlighting,
  completion, an ICNF interpreter that keeps `def` bindings as live
  values, structural value printing, `:type`, `:time`, `:load`, `:save`,
  `:reset`, and a per-directory `.zyl-session` file. `tools/repl.zyl` is a
  thin `main` over these modules.
- Language server: `stdlib/lsp/`, entry `selfhost/lsp_main.zyl`, binary
  `build/boot/zyl-lsp`. VS Code extension 0.3.0 in `editors/vscode/`.
  `install.sh` installs the compiler, REPL and server into `~/.zyl` (or
  `$ZYL_HOME`); `--with-vscode` adds the extension; `uninstall.sh`
  removes what it installed and keeps the store, keys and REPL files
  (`--purge` removes everything).
- Standard library directories: actor, allocator, atomic, collections,
  compiler, core, ffi, io, lsp, math (bits, words, bignum, hashes,
  symmetric and asymmetric cryptography, KDFs, RNG, secret), mlib, repl,
  testing.
- Book: `book/` (mdBook), with a runnable example project in
  `book/examples/log-processor/`.

### Open limitations (each confirmed still open on 2026-09-23)

Compiler:

- Several name lookups in `type_inference.zyl` compare strings with `=`,
  which is a pointer comparison when the operand kinds are unknown, so a
  builtin operator is never recognized by name. REPL `:type (+ 1 2)`
  answers *unresolved*. The fix is a type-inference change; see the
  header of `stdlib/lsp/compiler_bridge.zyl`.
- Codegen kinds (String/Float) come from `compiler/type_annotate.zyl`, an
  HM pass over the final Expr program, as well as from literals and
  annotations. Values read from `Vec`, `Map`, ADT fields, struct fields,
  generic returns and closure captures print and compare correctly.
  Trait calls resolve statically from the receiver's type, and a
  function that uses a trait method or `print` on a type variable is
  specialized per concrete call (`f~T`). The prelude trait `Show`
  (`core/show`) has impls for the primitives, `List`, `Option`,
  `Result`, `Vec` and `Map`; `(derive T Show)` writes one for an ADT or
  struct; `print` of a value with a Show impl prints its text.
  `==`/`=`/`!=` on ADT and struct values compare by content, deeply,
  through a generated per-type equality function (2026-09-24). An
  argument that definitely clashes with a parameter annotation or a
  declared constructor field type is `E_TYPE_MISMATCH`; every other
  unification failure still fails open (`(+ 1 "a")` compiles).
  Still open: `derive` of anything but `Show` generates nothing;
  `(defstruct ... (:derive ...))` is not parsed; ADT `<`/`>` order by
  raw field words (`zyl_variant_cmp`); constructor calls are not
  arity-checked.
- Call targets are resolved only in codegen (`cg-call-user`): a call to
  an undefined function, including the unimplemented `(list ...)`
  literal, is a located `E_UNBOUND_VARIABLE` there, not a linker error,
  but no earlier phase (type inference) reports it.
- Diagnostics still reported as a bare `PANIC:` with no location:
  `E_INVALID_CAPABILITY` and the remaining errors in
  `expr_inner`. Warnings carry spans, parameter warnings included (qualification
  and macro expansion copy the parameter's span since 2026-09-24).
- Contracts (spec §23) are lowered during parsing under a profile
  (`--contracts=P`, `(contracts P)`); `checkpoint` rolls back `let-mut`
  state (not byte-buffer writes); `recover` arms match error codes.
- Hash finalization: `zyl.buildinfo` records the compiler, graph,
  native-object and ICNF hashes (spec order), the resolved graph, the
  assembly hash, and the final hash, which the binary carries as
  `zyl_build_hash`.
- `Secret`: frames holding secrets are zeroed on return, heap erasure is
  explicit (`zeroize`, `wipe`); Secret fields/types redact as `<secret>`;
  `set!` of a secret into a `let-mut` is not tracked. Taint crosses a call
  boundary only where the callee's parameters are annotated.
- Tail calls are jumps (`cg-tail`), direct or through a function value;
  exceptions: stack arguments beyond the caller's own, calls inside
  `try`/`catch` or `while`, and frame-wiping (secret) functions. The REPL
  interpreter runs tail calls in constant stack unless the result has a
  String/Float kind (retagged).

Package system:

- The default index URL `https://github.com/zyl-lang/index` is not hosted
  yet. `ZYL_INDEX` selects any git index (URL or local path), and `zyl
  publish --index DIR` adds signed versions to one;
  `tests/scripts/package-index.sh` covers publish, fetch and build.
- Build cache (§31.4): `~/.zyl/cache/<key>`, keyed by every build input
  (`drv-cache-key`); `ZYL_NO_BUILD_CACHE=1` bypasses it.
- `deny-capabilities` and the capability pass apply only to packages that
  have a manifest.
- Paths and URLs containing characters outside `store-safe`'s set (a
  space or a quote, for example) are refused rather than quoted.
- A nested `feature-gate` is not rejected; it is treated as an ordinary
  form.
- Ed25519 still ships inside the compiler rather than the runtime.
  The boot cost that motivated moving it went away when the
  type-inference exponential was fixed (`./boot.sh` now takes about 23 s).

REPL and interpreter:

- Actors are compile-only; the interpreter reports
  `E_UNSUPPORTED_INTERPRETED`.
- Heavy numeric work allocates per operation and is slow and
  memory-hungry when interpreted.
- A definition entered at the prompt cannot refer to a `def` binding:
  after `(def k 5)`, `(defn f (x) (+ x k))` is accepted but `(f 1)` fails
  with `E_UNBOUND_VARIABLE`.

Tooling and library:

- The language server does not run `unused_check` or type inference's
  `collect-definitions`, and reports one diagnostic at a time.
- The VS Code extension is not bundled (no esbuild step) and has no
  problem matcher, although CLI diagnostics now carry `file:line:col`.
- BLAKE3 uses the portable compression function (no SIMD). There is no
  ctgrind or valgrind instrumentation; `verify/timing.py` is the
  statistical substitute.

## Open Work (prioritized)

Drawn from the old roadmap, the deferred-work list, and the gaps recorded
by recent sessions. The completed roadmap items are kept, annotated, under
**Roadmap history** near the end of this file.

### P1: Diagnostics

- [ ] Locate the remaining diagnostics (the checks listed above): thread
      the offending node to the failure and call `err-at`. Done
      2026-09-24 for `mutability_check`, `capability_check` and
      `unused_check`.
- [x] Resolve call targets before linking, so an undefined function is a
      located error (codegen's `cg-call-user`, 2026-09-23; an earlier
      phase would be better still).
- [x] Fix the `=`-on-strings name comparisons in `type_inference.zyl`
      (`f6ea129`; made allocation-free on 2026-09-24).
- [x] Labelled secondary spans (`err-at-labels`) on `E_MUT_CONFLICT`,
      `E_CAPABILITY_LEAK` and `E_PKG_CAPABILITY_VIOLATION`. No region
      diagnostic exists yet to label (`E_REGION_ESCAPE` is never raised).
- [x] "Did you mean" (edit distance over in-scope names) on unbound
      identifiers and undefined functions.
- [x] `--error-format=json`: one JSON object per diagnostic on stderr.
- [ ] Sweep the warnings `./boot.sh` prints.

### P2: Code generation correctness

- [x] Field and return kinds in codegen, so compiled `print` and `==`
      agree with the interpreter; then derivable `Show`.
- [x] Tail-call optimization in `codegen.zyl` (direct calls, at most six
      arguments; indirect and stack-argument tail calls still open).
- [x] `print` on `Result`/`Option`/`List` whose payload has no `Show`
      printed garbage or crashed; it now prints raw. Open: explicit
      `Show.show` on a type without an impl still hits the runtime tag
      dispatch (`ic-trait-dispatch`) instead of `E_TRAIT_NOT_FOUND`.
- [x] ~~A per-file paren-depth check in `assemble.py`~~: obsolete, every
      module is compiled and balance-checked as its own file.

### P3: Language features

- [x] Contract injection (spec §23), lowered in `expr_inner.zyl`;
      open: profiles, `checkpoint` rollback, typed `recover` arms.
- [x] 16-, 32- and 64-bit byte loads and stores; `ByteBuf`/`ByteSlice`
      handle types.
- [x] `Secret`: frame zeroization on return, `print` redaction, a `Secret`
      trait, Secret-field taint, `impl-not`; heap erasure stays explicit.
- [x] A `receive` form and a runnable structured-message actor example.
- [x] Top-level `def` in compiled programs (immutable globals, eager init).
- [x] Hash finalization that mixes the graph hash into the binary.

### P4: Tooling and packages

- [x] A `zyl doc` generator over the stdlib's doc-comment convention (`;|` takes precedence).
- [x] A package index (`ZYL_INDEX`, `zyl publish --index`), a build cache keyed by content hash, and nested `feature-gate` rejected.
- [x] Unused-binding warnings in the language server.
- [ ] Bundle the VS Code extension; add a problem matcher.
- [ ] REPL: let a definition entered at the prompt capture a `def`
      binding.

### Deferred design work (not started unless noted)

- **Byte-level primitives:** partly done. 8-bit `load`/`store` with
  explicit endianness, `bytebuf`, `byteslice`/`byteslice-sub`, the atomic
  family and `align-check` landed on 2026-09-19 (commits `44bb05f`,
  `88ba6e4`). Still open: the wider widths, and views that provably
  cannot outlive their backing buffer.
- **Deterministic region extension:** a closed registry of additional
  audited region kinds (fixed growth, alignment, policy) that user code
  selects among, with no raw alloc/free function pointers; any kind that
  touches the OS must be deterministic for a given request sequence.
- **Capability-mediated sharing:** a shared region holding only TCap or
  atomic values, mutation only through atomics or a temporary exclusive
  upgrade, typed bounded channels with explicit ownership transfer,
  read-only pages shared between actors. The `TCAtomic` and
  `TCAtomicByte` capability kinds and the atomic byte-buffer operations
  exist; the sharing model does not.
- **Inline assembly:** a capability- and region-aware interface in which
  pointer-carrying registers respect the type and region rules.
- **Ergonomic zero-copy views:** short-lived region views over
  longer-lived data (parsing, substrings, array slices) without
  Rust-style lifetime parameters. `byteslice` is the only form so far.

## Constraints for Compiler Source Written in Zyl

The full list, with examples, is `rules/boot-lifted-constraints.md` in the zyl-skill repository (`~/git/larry/zyl-skill`; formerly `skills/zyl/SKILL.md` §2). Its constraint
3 still tells you to name wildcards `d1`, `d2`, ...; that is superseded,
as recorded below.

1. ~~Keep function arities <= 6~~ Lifted 2026-08-25: stack-passed
   arguments work.
2. ~~A `match` may appear only as the entire body of a defn~~ Lifted
   2026-08-25.
3. Exhaustiveness is checked per ADT (`E_NON_EXHAUSTIVE_MATCH`, since
   2026-09-17). A catch-all arm is allowed and must come last
   (`E_UNREACHABLE_MATCH_ARM`). An arm head that names no constructor is
   a catch-all binding, so a misspelled constructor is not reported as
   unknown; it becomes a catch-all, which is an error only if more arms
   follow it.
4. ~~Pattern wildcards must be named dummies (`dN`), never bare `_`~~
   Reversed 2026-09-23: `_` is the discard, may repeat, and `_`-prefixed
   names are exempt from the unused, shadowing and duplicate-parameter
   checks.
5. Prefer flat `begin` sequences and recursion over deep nesting.
6. `buf-append` appends at `strlen(dst)` (true append); start from fresh
   buffers.
7. Parens must balance per top-level form. The compiler rejects
   unbalanced source with a located error (`sexp_balance.zyl`), and
   since 2026-09-24 every compiler module is checked as its own file.
8. Binops with two call operands: the skill file still says these compute
   0 in stage >= 2 binaries. On 2026-09-23 `(+ (f 1) (g 3))`,
   `(- (f a) (g b))` and an arm body `(+ (f r) (g r))` all computed the
   right values with the current compiler; the shape in which an arm body
   combines a constant with two or more calls is still rejected with
   `E_MATCH_ARM_COMPLEX`. Binding calls to `let`s first remains the safe
   style in compiler source.

## Pointers

- Self-hosting history and the fixed-point invariant:
  `docs/rust-eviction-plan.md`
- Architecture decisions: `docs/architecture-decisions.md`
- Design rationale: `docs/design-rationale.md`
- Codebase map: `docs/codebase-map.md`; pipeline:
  `docs/compiler-pipeline.md`; developer guide: `docs/developer-guide.md`
- Regression infrastructure: `docs/regression-tests.md`
- Error codes: `docs/errors.md`, `docs/error-system-architecture.md`
- Package system: `docs/package-management-design.md`
- REPL: `docs/repl.md`; cryptography library: `docs/math-crypto.md`
- Historical phase details: `docs/implementation-status.md`
- Specifications: `zyl_specification.txt` (v5.0, canonical), `spec/`
  (structured copy), `specifications/` (v1.0 to v4.1, historical)

## Milestone History

| Milestone | Date | Notes |
|-----------|------|-------|
| All 9 phases + linking | 2026-08 | structs, ADTs, floats, actors, closures, FFI, try/catch, I/O |
| Clean-room self-host front end | 2026-08-24 | recursive ADTs + structural match end-to-end |
| stage1 compiles own source | 2026-08-24 | first boot build |
| **Self-hosting fixed point** | **2026-08-25** | **stage1→stage2→stage3, deterministic** (stage1 built by the Rust bootstrap) |
| r15-align SIGSEGV fix (codegen) | 2026-09-06 | rsp-stash frame slot replaces r15 save/restore; option-flatmap green |
| `_t_` constructor lowering fix (ast) | 2026-09-06 | underscore-prefixed ADT variants lower to MakeVariant; regression/types green |
| **selfhost-codegen test fixed** | **2026-09-06** | **passes with self-hosted compiler; Rust bootstrap too slow for test runner** |
| Contract injection (Phase 10) | 2026-09-09 | parser + contract_injection.rs + pipeline integration complete (Rust bootstrap) |
| Contract injection (Zyl) | 2026-09-09 | stdlib/compiler/contract_injection.zyl written; taken out of the self-hosted pipeline on 2026-09-15 because it did not match the real AST shapes |
| **Type inference ported to Zyl** | **2026-09-10** | **Hindley-Milner + capability types + trait resolution + occurs-check** |
| **Monomorphization ported to Zyl** | **2026-09-10** | **Full monomorphization using type inference data; all regression tests pass** |
| **P3.5 complete: Zyl self-hosts all phases** | **2026-09-10** | **boot.sh fixed point holds; Zyl compiler compiles itself end-to-end** |
| Book documentation verity pass | 2026-09-10 | ch13 rewritten from runtime-verified constructs; appendix B braces fixed; ch11 §11.3 corrected; book.toml builds with zero warnings |
| stage2.bin fixed point from self-generated code | 2026-09-15 | stage2 == stage3 with the self-hosted codegen; real argv CLI |
| **Rust evicted** | **2026-09-17** | feature-parity survey closed at 43/43; `--bootstrap-from-self`; Rust archived |
| Language server | 2026-09-19 | `stdlib/lsp/`, `zyl-lsp` |
| `stdlib/math` and the `Secret` capability | 2026-09-22 | cryptography library; constant-time checker |
| **Package system (spec §31)** | **2026-09-23** | MVS, lock, store, signed index, capabilities, `zyl` subcommands |
| Located diagnostics; type-inference exponential fixed | 2026-09-23 | `./boot.sh` from about ten minutes per stage to 23 s total |
| REPL with an ICNF interpreter | 2026-09-23 | live bindings, structural printing, per-project sessions; interpreter checked against codegen by the suite |
| Compiler built through module resolution | 2026-09-24 | bundle and `assemble.py` retired; memory regression fixed; per-stage memory ceiling |

---

# Session log (newest first)

## Session (2026-09-24, latest) — LSP warnings and located diagnostics

The language server runs `unused_check` with warning capture on
(`dm-unused-warnings`) and publishes each `warning[...]` block as a
Warning diagnostic (`diagnostics-from-warnings`). Every diagnostic now
takes its range from the message's `--> file:line:col` line when it has
one (`bridge-location`), instead of searching the text for the first
backticked name, and shows the headline and help line rather than the
rendered excerpt (`bridge-short-message`). LSP test extended.

## Session (2026-09-24, earlier) — build cache

`drv-compile-file` (package builds) now checks `~/.zyl/cache/<key>`, the
key a BLAKE3 over the compiler hash, contract profile, lock graph hash and
a tree hash (`drv-tree-hash`: every `.zyl`/`.c`/`.h`/`zyl.pkg` file, via
the new runtime `zyl_list_files`) of the package, each graph node's root
and the stdlib. A hit copies the binary and `.buildinfo`; a miss compiles
and stores them. `ZYL_NO_BUILD_CACHE=1` bypasses it. Test:
`tests/scripts/build-cache.sh`.

## Session (2026-09-24, earlier) — a working package index

`ZYL_INDEX` (`idx-url`) selects the index: a git URL or a local path
(cloned as `file://`). `zyl publish --index DIR [--url-base URL]`
(`cli-publish-into`) copies the signed archive to `DIR/archives/`, merges
the version into the sharded entry (`idx-publish`, `idx-entry-text`; a
repeated version is `E_PKG_VERSION_EXISTS`, new code) and commits in a git
index. `store-fetch-url` copies `file://` archives (HTTPS only otherwise);
hashes and signatures are verified either way. End to end in
`tests/scripts/package-index.sh`: publish, fetch, build, run, graph in
`.buildinfo`, republish rejected. The default hosted index still has to
be created.

## Session (2026-09-24, earlier) — fixes from the skill review

- A user type named `T` or `E` hid the prelude's type parameter of the
  same spelling (short-name aliases in `ta-types`), so `Option`/`Result`
  lost their genericity: aliases are now marked (`ta-put2`), never shadow a
  type parameter, and a parameter in scope wins in `ta-conv-name`.
- Two written impls, or two derives, of one trait for one type failed in
  the assembler; they are `E_DUPLICATE_IMPL` (`dv-check-dup-impls`,
  `dv-impl-count`).
- `(defstruct+ Name ... (:derive [T ...]))` is split into the struct and a
  `(derive Name T ...)` before qualification (`inline-derive-of`), so it
  derives (and `impl-not` sees it).
- `feature-gate` below top level is `E_PKG_FEATURE_NESTED`.
Tests: `derive-traits.zyl`, `compile-fail/duplicate-{impl,derive}.zyl`,
`packages-fail/feature-nested`.

## Session (2026-09-24, earlier) — zyl doc

`zyl doc [file.zyl | dir] [-o out.md]` (`drv-doc`, new `compiler/doc.zyl`)
writes Markdown: the file's leading comment block as the module doc
(`; === Title ===` as the title), then each top-level definition in source
order with its signature and the contiguous comment block above it (a
blank line or a `; ===` separator ends it; `;|` lines take precedence when
present). In a package (a `zyl.pkg` beside it) only `pub` definitions are
listed. A directory is walked with the new runtime `zyl_list_zyl_files`
(recursive, sorted). Test: `tests/scripts/zyl-doc.sh`.

## Session (2026-09-24, earlier) — arena documentation

Book §4.3 gains *Arenas: where collections keep their elements*: what an
arena is, the `allocator/allocator` API, exactly which values the `arena`
argument of `vec-create`/`map-create`/`set-create` accepts (a handle from
`arena-create`, or any value <= 0 for a new private arena that is never
freed), what `cap` means, and the rules that follow (collections die with
their arena, updates may share storage, sending shares, ADTs use the
runtime heap). A negative `cap` used to end in a null write and a lost
element; it now means 0, and growth from a capacity <= 0 starts at 16.
`*-create-default` delegate to `*-create 0`. Test added to
`collections.zyl`.

## Session (2026-09-24, earlier) — ICNF hash and recorded graph

New `compiler/icnf_print.zyl` (`icnf-text`) prints lowered ICNF as
canonical s-expressions with each node's codegen kind. `drv-compile-file`
now lowers (`compile-to-fns`), hashes that text for `icnf-hash`, then
generates code, so the final hash covers spec 31.12's four inputs
exactly (the assembly hash stays in `.buildinfo` for information). The
buildinfo also records the resolved graph from the lock
(`lk-graph-text`, `lock.zyl`), tested in `package-system.zyl`. That
closes the last recorded hash-finalization deviation.

## Session (2026-09-24, earlier) — contract profiles, checkpoint, recover arms

Profiles (`expr_inner.zyl`, `contract-profile`): strict/debug panic, warn
checks become `(if C 0 (zyl-contract-warn msg))` (stderr, continue),
off/production drop the clauses. `--contracts=P` sets the build's profile
(global map 6, `driver.zyl`); `(contracts P FORM)` or a bare
`(contracts P)` before a top-level form overrides it for that form.
`checkpoint` saves the outer `let-mut` variables its body `set!`s and
restores them before re-raising (`zyl-reraise` = `zyl_panic`). `recover`
arms are tried in order: an `E_` code matches by message prefix
(`zyl_err_is`), a type-named or `_` arm matches anything, no match
re-raises. Tests added to `contracts.zyl`.

## Session (2026-09-24, earlier) — derivable traits

`derive.zyl` now derives all six traits of spec 5.6: Show, Debug (strings
quoted), Eq (`==`), Ord (`compare`: variant order, then fields
lexicographically), Hash (FNV-style fold, deterministic) and Clone
(identity). The prelude (`core/show.zyl`) declares Debug/Eq/Ord/Hash/Clone
with impls for the primitives, and `core/list`, `core/option`,
`core/result` implement them; Vec and Map implement only Show. Every
derive checks its fields (`dv-check-fields`): a field type without the
trait, a Secret field under Eq/Ord/Hash, or an underivable trait is a
located `E_TRAIT_NOT_DERIVABLE`. Secret types keep compiler-made
`<secret>` Show and Debug; the prelude adds `(impl-not Debug/Eq/Ord/Hash
Secret)`. Tests: `derive-traits.zyl`, three compile-fail cases.

## Session (2026-09-24, earlier) — open follow-ups from P1-P3

- Lexer: a byte it cannot tokenize is `E_INVALID_CHAR` (`check-lexed-to-end`,
  `parser.zyl`); an open string is `E_UNTERMINATED_STRING`. It used to end
  the file silently.
- A trait call on a concrete receiver type without an impl is a located
  `E_TRAIT_NOT_FOUND` (`ta-check-no-impl`), not runtime-dispatch garbage.
- A `let-mut` ever `set!` to a secret is secret for its whole scope
  (`sc-sets-secret`, guarded to skip secret-free code).
- `(expr).field` reads fields of any expression's value; `((expr).f.m)`
  calls `m` on a field (`dot-rewrite-list`).
- Secret-checker and impl-not flow diagnostics are located (`sc-fail-at`).

## Session (2026-09-24, earlier) — hash finalization

`zyl build`/`zyl test` (`drv-compile-file`, `driver.zyl`) now compute the
§31.12 inputs in order (compiler, lock graph, native objects, assembly),
their final BLAKE3 (`drv-build-hashes`), and append it to the assembly as
`zyl_build_hash` in a `.zyl_build` section before linking; `.buildinfo`
records each native object (package-relative path and hash, which used to
be an empty list) and `final-hash`. `cli-native-objs`/`cli-native-args`
split object compilation from link arguments. The same package built in
another directory gives a byte-identical binary. The packages-build runner
checks the final hash is in the binary. Remaining deviations: assembly
hash for the ICNF hash, no recorded resolved graph.

## Session (2026-09-24, earlier) — receive and structured actor messages

`(receive)` and `(actor-self)` lower (ICNF, `ic-global-sym`) to the new
runtime `zyl_actor_receive` / `zyl_actor_self`. `receive` pops the next
data message of the running actor (thread-local id), running closure
messages queued ahead of it; waiting counts as parked for `wait_all`, and
an actor stopped while waiting ends its thread there. `main` gets a
thread-less mailbox slot on first use, which `wait_all` skips, so actors
can reply to main. Example: `book/examples/actor-counter/counter.zyl`;
test: `tests/regression/actor-receive.zyl` (skipped by the interpreter
differential run). `actor-self` needs the `actor` capability.

## Session (2026-09-24, earlier) — Secret fields/types, redaction, frame wipe, impl-not

**Secret shapes** (`secret_check.zyl`, global map 4): a field declared
`Secret`, or of a type implementing the new prelude trait `Secret`
(`core/show.zyl`, method `wipe`), taints what is read from it (struct-get,
dot access, match binders); constructors of a Secret type produce
secrets; a secret in a Secret field does not taint the record; a
single-arm `match` on a secret is allowed (binders secret); a secret in
an `error` message or in a `show` result is `E_SECRET_DEBUG`; impl method
bodies are now checked at all. **Redaction** (`derive.zyl`): Secret
fields and Secret types show as `<secret>`, fields/types under
`(impl-not Show X)` as `<hidden>`, through compiler-made Show impls.
**Frame wipe** (`codegen.zyl`, `cg-wipe-frame`): functions secret_check
marks (Secret params, secret-returning, secret lets) zero their frame on
return and make no tail calls. **`impl-not`** (`module_resolver.zyl`,
`mr-impl-not`): `(impl-not Trait Target)` forbids the impl/derive for
Target or any implementor of trait Target (`E_IMPL_FORBIDDEN`, new code),
and a flow rule rejects impls of Trait whose result derives from a
protected value (labels "T|" in the secret_check taint engine). The
prelude declares `(impl-not Show Secret)`. Tests:
`tests/regression/secret-types.zyl`, six compile-fail cases. Open:
`set!` of a secret into a `let-mut` is not tracked; heap erasure stays
explicit.

## Session (2026-09-24, earlier) — wide byte access, handle types

**`load-u16` .. `store-i64`.** The wide forms reuse the byte-form Expr
nodes: the width rides in the `Endian` value (`EWide code width`), so no
pass changed shape. ICNF lowers them to `zyl_load_n`/`zyl_load_n_signed`/
`zyl_store_n`, which honour `:le`/`:be`, sign-extend signed loads and
bounds-check the whole width (fail closed like the byte forms).
**Handle types:** `bytebuf` is `ByteBuf`, `byteslice`/`byteslice-sub` are
`ByteSlice` (both usable as annotations); an Int, Float, Bool, String or
Unit where a handle is expected is `E_TYPE_MISMATCH` (`ta-bytes`).
`E_RESERVED_KEYWORD` is no longer raised anywhere. Tests: three new tests
in `byte-primitives.zyl`, `compile-fail/bytes-int-handle.zyl`.

## Session (2026-09-24, earlier) — dot syntax

**Fields and methods through dots.** `dot-rewrite-forms`
(`expr_inner.zyl`, called by the module resolver before qualification)
turns a name whose first segment is lowercase into `struct-get` chains
(`s.a.x`), and a list headed by one into `(zyl-method "m" recv args...)`;
`((expr).m args)` works too (the lexer now reads `.name` as a token). The
type pass (`ta-method-call`) picks the trait: the only one declaring `m`,
else the one with an impl for the receiver's known type; it then types
and resolves the call like `(Trait.m recv ...)`, and ICNF lowers it
through the chosen name. `E_TRAIT_NOT_FOUND` for an undeclared method, a
type without the impl, or an ambiguous call on an unknown-type receiver.
`struct-get` of a field a known struct lacks is now `E_TYPE_MISMATCH`
(`ta-no-field`), for both spellings. Tests: `dot-syntax.zyl` and three
compile-fail cases. Open: dot on a receiver of unknown type with several
candidate traits needs the qualified name.

## Session (2026-09-24, earlier) — top-level def

**Top-level `def` in compiled programs** (spec R7: immutable, eager).
After qualification, `convert-program` (`expr_inner.zyl`, called by the
module resolver over every unit at once) collects the `def` keys, turns
each `(def k v)` into a getter `(defn k () ...)` that computes `v` once
and caches it in a runtime cell keyed by the canonical key
(`zyl_global_ready`/`get`/`put`), and rewrites every use of `k` into a
call (a `set!` target is left alone, so `set!` on a def stays
`E_MUT_CONFLICT`). A generated `zyl-init-globals` calls the getters in
source order and ICNF lowering puts it first in `main`
(`ic-init-in-main`), so tests see initialized defs too. Types flow
through the getter, so `print` of a String, Float or ADT def works.
Tests: `tests/regression/toplevel-def.zyl`, `compile-fail/def-set.zyl`.

## Session (2026-09-24, earlier) — contracts, even-arity try, trait return types

**Contracts are enforced.** `expr_inner.zyl` lowers them where forms are
recognized (`contract-defn-body`, `contract-check`): `requires` and
`invariant` become `(assert-true C "E_CONTRACT_VIOLATION: precondition
of f failed: C")`; a `defn`'s `ensures` clauses run after the body with
its value bound to `result`; `recover` is `try`/`catch` with the first
arm's fallback; `(contracts off FORM)` and a bare top-level
`(contracts off)` strip clauses from the parse tree
(`convert-top-forms`). The dead `contract_injection.zyl` is deleted.
`assert` and `assert-true` now panic with a string-literal message
(`ic-assert-msg`).

**`try` around a call with an even number of arguments.** The try path
popped the saved frame pointer before the body, so the body's first
call-argument scratch slot overwrote it; the catch path then read a
garbage frame (segfault, or a hang). The frame pointer now lives in the
`try`'s own frame slot. Test: `tests/regression/try-catch.zyl`.

**Trait method return types.** A trait method's return type was kept as
a bare name, so `(Result Int String)` became a fresh variable and
`print` of the call printed an address. `TM` now carries the parsed
return type (`ta-add-method` converts it), extra `(p Type)` forms between
the parameter list and the return type are parameters, and a resolvable
trait call takes its impl's type before local defaulting
(`ta-pre-unify`), so a method with no declared return type works too.
Test: `trait-return-types` in `trait-static-dispatch.zyl`.

## Session (2026-09-24, earlier) — tail calls, print of non-Show payloads

**`print` of a container whose payload has no `Show`.** `Result` already
had a prelude `Show` impl (`core/result.zyl`) and `(print (Ok 5))`
printed `Ok(5)`. The failing case was `(print (Ok (make-P 1)))` with no
`Show` for `P`: `print` picked `Result`'s impl, whose inner `Show.show`
had no target and fell into `ic-trait-dispatch`, where the `String` arm
is a catch-all, so the struct was read as a string (`Ok()`, or a
segfault). `ta-print-status` now uses `Show` only when every type
argument is showable (`ta-showable`); otherwise the value prints raw,
like the payload does. Tests: `print-result` in `show-trait.zyl`,
`print-container-of-non-show` in `derive.zyl`.

**Direct tail calls are jumps.** `codegen.zyl` threads a tail flag (the
frame size, 0 outside tail position) through `if`, `let`, `begin` and
`match` emission (`cg-tail`). A tail `ICall` to a known top-level
function that is not shadowed by a local and has at most six arguments
stages its arguments as usual, loads the argument registers, restores
`rbx`/`r12`, tears down the frame and `jmp`s (`cg-tail-call`). The
callee sees the caller's return address and alignment. `try`/`catch`
and `while` bodies are never tail position. Stack-promoted variants
never reach a call (region inference), so no frame address outlives the
jump. The seed has 3061 tail jumps; `lexer.zyl`'s mutual whitespace
skip no longer costs a frame per character. New test
`tests/regression/tail-calls.zyl` (10^8-deep self and mutual recursion,
six-argument loops, tail calls from `match` arms and `begin`); it is
skipped by the interpreter differential run. 148/148 pass, fixed point
holds.

## Session (2026-09-24, earlier) — annotations enforced, structural ADT equality

**`E_TYPE_MISMATCH` from annotations.** `type_annotate.zyl` checks each
call to a top-level function (`ta-check-params`) and each constructor
call (`ta-check-fields`): an argument whose inferred type definitely
clashes with the parameter's annotation or the declared field type is a
located `E_TYPE_MISMATCH`, labelled at the parameter. `ta-clash` compares
structurally (`(List String)` against `(List Int)` is caught); a type
variable, a poisoned variable or `Unit` never clashes, so the check only
fires on a real conflict. `(add 1.5 2.0)` against `(defn add ((a Int)
(b Int)) ...)` no longer compiles. Other unification failures still fail
open, and return types are not checked (there is no return annotation).

Turning it on found real mis-declarations in the tree, all fixed:
- `(EC name String phase Int ...)`-style variants (`ErrorCode`,
  `ErrorFind`, `ErrorLocation`, `ErrorSnippet`, `ErrLabel`) declared
  twice as many fields as their constructors take (field names parse as
  field types); now plain types with the names in a comment.
- `Param`'s type slot and `EAssert`'s message hold Exprs, not Strings;
  `TList` holds one `Type`; `TypeBind` keys are Strings; `TraitInfo`,
  `AdtDef` and the inferer's ADT-instantiation slot declared the wrong
  element types; `TaVd`'s fields were out of date.
- Real code bugs in the legacy inferer/monomorphizer:
  `subst-apply-type` returned a bare list for `TFun`;
  `finalize-param-types-loop` put a parameter list in the known-functions
  slot; `infer-expr-make-variant` built a `TStruct` from field names;
  `monomorphize-push-instantiations` wrapped an `Expr` in `Expr`;
  `unify-types` built a one-field `TCap`; parameter bounds were Exprs
  where Strings were expected (`mono-param-bounds`).
- `qualify.zyl` stored Strings through `math/words`' Int-typed `w-set`
  (now `st-word`/`st-word-set`); codegen's `no-fnnames`/`fntail` returned
  `None` for a List (same representation as `Nil`); the LSP passed `1`/`0`
  for `Bool` fields (now `true`/`false`, `(Some (Left true))`).
- `tests/regression/adts.zyl` nested an `A-Int` in the String field of
  `A-Ident`; it now uses a `Boxed` wrapper type.

**Structural ADT equality.** `==`, `=` and `!=` used to compare contents
only when codegen saw a variant-kind operand (in practice a constructor
written at the comparison), and then shallowly (`zyl_variant_eq`: tag
plus raw field words, so a String or nested ADT field compared by
address). Now the type pass notes every two-operand equality (special
kind 5); when an operand's type is an ADT or struct, the node is renamed
to `T.==`, generated on first use (`ta-eq-fn`, `ta-eq-defn`): a match on
both operands that compares field pairs with `==`. Nested ADTs, Strings
and Floats therefore compare by content, recursion works, and a generic
type is specialized per element type like any trait-generic function
(`List.==~List<String>,List<String>`). ICNF lowering turns the renamed
node into a call, negated for `!=` (`ic-renamed-call`). A type with a
`Secret` field gets no equality function. `assert_lowering.zyl` now
rewrites an ADT `assert-equal` to `(assert-true (== l r))` instead of a
direct `zyl_variant_eq` call. Where the type stays unknown, codegen's
shallow `zyl_variant_eq` is still the fallback.

Tests: `tests/regression/adt-equality.zyl` (compiled and interpreted),
`tests/compile-fail/type-mismatch-{param,field,nested}.zyl`. 147/147 pass;
the fixed point holds.

Known limitation found on the way: REPL diagnostics show a stale source
line (the snippet comes from an earlier `<repl>` text); this affects
every located error in the REPL, not only the new one.

## Session (2026-09-24, later still) — Show, static traits, specialization

- `type_annotate.zyl` resolves trait calls from inferred receiver types
  (spec §5.4); the runtime-tag dispatch pass `trait_dispatch.zyl` is
  gone, and an unresolvable call falls back to the same tag match in ICNF
  lowering (`ic-trait-dispatch`). Mixed ADT/primitive impls now dispatch
  correctly.
- Functions that use a trait method or `print` on a type variable are
  specialized per call site with concrete argument types (spec §6.4),
  named `f~T1,T2`; at most 32 instances per function. Purely local
  unconstrained variables (E in `(Ok "yes")`) default to Int.
- `trait` declarations are parsed (`ETraitDecl`); method signatures type
  trait calls.
- `core/show`: `(trait Show (show (self) String))` plus impls for Int,
  Float, Bool, String; impls for List, Option, Result (core), Vec
  (collections/vec) and Map (core/map). `compiler/derive.zyl` expands
  `(derive T Show)` / `(derive T [Show])`. `print` routes through Show.
- `assert-equal` picks float comparison from inferred kinds, not only
  from a float literal anywhere in the expression.
- The REPL keeps `derive` entries as definitions.
- `=`/`<`/arithmetic on a type variable also make a function
  trait-generic, so `(defn same (a b) (= a b))` compares Strings by
  content in its String instance. String `<`/`>`/`<=`/`>=` order by bytes
  (`zyl_cstr_cmp`) in codegen and the interpreter.
- The pipeline no longer runs the legacy `collect-definitions`
  (monomorphization gets an empty inferer and only lifts impls): with
  content comparison inside its generic helpers, the old inferer's
  control flow changed and it crashed the self-compile, as its own
  header warned. The REPL's `:type` now uses `ta-type-text`.
- Uses recorded per SCC are taken as the suffix recorded since the SCC
  root's visit (no rescans).
- `./boot.sh` ends by refreshing an existing install (`uninstall.sh` +
  `install.sh`; `ZYL_INSTALL_HOME`, `ZYL_NO_INSTALL_REFRESH=1`).
- Book, `docs/compiler-pipeline.md`, `docs/repl.md`, AGENTS.md and the
  zyl skill updated for all of the above.
- Tests: `show-trait.zyl`, `trait-static-dispatch.zyl`; the REPL script
  checks a derived Show. 142/142 pass.
- Open: annotations are still not enforced (a Float passed to an
  `(a Int)` parameter compiles); `E_TYPE_MISMATCH` from annotation
  conflicts is the natural next step.

## Session (2026-09-24, later) — generic collections, type annotation pass

**Warning sweep.** Parameter spans were lost in `qf-param` and
`me-bind-params`; both now copy them. Every warning on the compiler's own
source was fixed, so the self-build is warning-free.

**Generic `Vec`/`Map` (spec §4.2, §6.3).** Storage was always one word
per value, but codegen took print/compare/float kinds only from literals
and annotations, so anything read back from a container printed as an
address. New pieces:

- `stdlib/compiler/type_annotate.zyl`: HM inference (union-find, SCCs by
  Tarjan, let-polymorphism for top-level functions) run just before ICNF
  lowering. It records each Expr's type in runtime attr table 0; a unify
  conflict poisons the variables involved, so the pass fails open.
  `ZYL_DEBUG_TYPES=1` prints every function's scheme.
- Deftype/defstruct field type expressions are recorded at parse time
  (`record-field-types`, keyed by variant name) since `ADTVariant` keeps
  only field names.
- ICNF lowering writes the kind to attr table 1 (`ic-mark-kind`);
  `ic-hoist`, the optimizer and region inference carry it across
  rebuilds (`ic-keep-kind`). Codegen's `kind-of` uses the legacy kind
  first, then the table; the REPL interpreter retags words the same way.
- Runtime: `zyl_attr_*` (node attribute tables), `zyl_smap_*` (string
  maps), `zyl_wvec_*` (word vectors), with process-wide instances.
- `collections/vec` is now a generic ADT `(Vec T)` with a phantom field;
  `vec-get`/`vec-last` return `T`. `core/map` was already generic over V;
  keys are compared with `str-eq`, so K must be String.
- Test: `tests/regression/generic-collections.zyl`. 137/137 pass.

## Session (2026-09-24) — memory regression, module-built compiler, diagnostics

**Memory.** A self-compile had grown from about 0.6 GB to 2 GB, and a
compile that printed located warnings on the bundle ran out of its 34 GB
budget. Two causes:

- `type-name-matches` (`f6ea129`) built two strings per comparison inside
  every linear type-inference lookup, and the arena never frees. Replaced
  with the allocation-free runtime helper `zyl_cstr_key_matches`.
- `space-run` built padding one character at a time (quadratic in the
  column), and every snippet copied its whole source line; the bundle was
  one 700 KB line. `space-run` is now linear and snippets are a 120-byte
  window (`zyl_span_snippet`, `zyl_span_snippet_col`).

`f6ea129` had never been re-bundled, so `boot.sh` kept compiling the old
bundle and passing. `boot.sh` now caps each stage at 2 GB
(`ZYL_STAGE_MEMORY`, passed as `ZYL_MAX_MEMORY`); a self-compile needs
about 1.4 GB, and the leaking build was confirmed to fail under the cap.

**Module-built compiler.** Every boot stage compiles `selfhost/driver.zyl`
through module resolution. Names are qualified per module (spec §31.2),
so the bundle's flat-namespace workarounds (defn dedupe, library-`main`
stripping, whitespace collapse, a whole-bundle depth check) are gone with
`selfhost/assemble.py` and `selfhost/zyl_selfhost_compiler.zyl`.
`driver.zyl` lost an unused `(use compiler/contract_injection)`, the only
thing that stopped it compiling this way. The output does not depend on
the checkout path or the working directory. `--bootstrap-from-rust` is
retired.

**Diagnostics.** `error_report.zyl` gained `err-at-labels` (secondary
spans), `err-warn-at`, `err-suggest-help` (Levenshtein distance), and a
JSON renderer selected by `--error-format=json`
(`zyl_diag_json_set`). Warnings go through `zyl_warn_emit`, which a
caller can capture (`zyl_warn_capture`, `zyl_warn_take`) for the LSP.
`zyl_panic` wraps a bare `E_CODE: text` message as JSON in JSON mode.

Tests: 135/135 (`--full --no-boot`); fixed point holds.

## Session (2026-09-23) — closures are values

Closure conversion is rebuilt so a closure works wherever a function
value can go.

- `ic-lambda` (`icnf.zyl`) lowers the body first and reads free names
  off the lowered ICNF (`ic-lambda-free`, every node shape). The
  Expr-level `ic-safe-expr`/`ic-free-vars` gate is gone: it turned any
  lambda using `match`, a constructor call (`(fn (x) (Some x))`) or a
  captured callee (`compose`) into `IConst 0`, and capped capturing
  lambdas at 5 parameters.
- A closure is `[ic-closure-magic, code, env]`. Every call through a
  local is `cg-call-indirect` (`codegen.zyl`): it tests the tag at run
  time and always passes the env, or 0 for a plain function, as one
  extra trailing argument. The `VTClosureFn`/`VTClosureReturn` marks and
  `ICallClosure` are no longer produced; a closure passed as an argument,
  stored in a variant, captured, or returned is called correctly, and
  any arity works.
- A call with a computed head, `((make-adder 10) 5)`, binds the head to a
  fresh local and calls through it (it used to call the empty name).
- A call to a name that is neither a local nor a function is a located
  `E_UNBOUND_VARIABLE` (`cg-call-user`); `((x) (* x x))` now gets that
  instead of an undefined `_ZYL_`. Call nodes keep their span through
  `ic-hoist`, optimization and region inference (`ic-keep-span`).
- `set!` on a captured `let-mut` is `E_MUT_CONFLICT`, located
  (`mutability_check.zyl`, `mc-fn-fence`): capture is by value, so the
  assignment could only change the closure's copy.
- `closure_inline.zyl` is an identity pass; its beta reduction is not
  hygienic and is no longer needed.
- Tests: `tests/regression/closures.zyl` (15 new), new
  `tests/regression/closures-core.zyl` (compose, option-flatmap,
  result-and-then), `tests/compile-fail/closure-set-captured.zyl`,
  `tests/compile-fail/lambda-shorthand.zyl`.

## Current Session (2026-09-23) — a first-class REPL, stages 3 and 4: values, types, and state that survives

**A result prints as the value it is, `:type` and `:time` answer
questions about an expression, and a session in a directory picks up
where the last one there left off.**

### Values print structurally

```
zyl> (Cons 1 (Cons 2 Nil))
=> (Cons 1 (Cons 2 Nil))
zyl> (Some "hi")
=> (Some "hi")
zyl> (make-P 3 4)
=> (P 3 4)
```

The interpreter's blocks carry their constructor's name and the kinds of
their fields in hidden words ahead of the payload, so the payload stays
byte-identical to what compiled code builds (zyl_variant_eq and
zyl_variant_field read it unchanged) while the REPL can render the value
exactly. Names are interned in the runtime rather than copied per
construction: the name comes from an ICNF node in the arena that entry
compiled into, and the value may outlive it. Nesting is bounded at six
levels and twenty-four fields.

Spec §5.6's derivable `Show` is still not implemented, so `print` of a
struct in a *compiled* program still shows a pointer. The REPL is ahead
of the compiler here, not instead of it.

### `:type` and `:time`

`:type` runs the front end and type inference and reports what inference
knows. Literals, structs and annotated functions come back with their
type; many applications come back *unresolved*, because several of
`type_inference.zyl`'s own name lookups compare strings with `=` --
pointer comparison, so a builtin operator is never recognized by name.
That bug and why fixing it is its own project are documented in
`stdlib/lsp/compiler_bridge.zyl`'s header; `:type` reports honestly
rather than guessing around it. The REPL renders types with its own
function: `type-to-string` feeds monomorphization's specialized symbol
names, so its output is part of the fixed point and was left alone.

`:time` reads a monotonic clock either side of an entry (`zyl_now_ms`).

### State that survives

A session starts from three places, in order: the default modules,
`~/.zyl/replrc` (or `$ZYL_REPLRC`), and `.zyl-session` in the directory
it was started in. The session file is written after every entry that
changes the session, and holds the modules, the definitions as entered,
and a `(def ...)` per binding -- ordinary Zyl source, editable by hand,
loadable with `:load`. Restoring replays those entries through the
ordinary path, so nothing in a saved session can do what a typed entry
could not; `:reset` clears both the session and the file.

A binding therefore carries the text that produced it as well as its
value, and the session carries the directory it belongs to -- which is
not the working directory by the time the REPL runs, since compiling
requires being in the bundle. `zyl repl` and the standalone binary both
capture it before the chdir.

A piped session restores nothing: a script should do the same thing on
every machine, whatever is saved next to it. History stays global
(`~/.zyl/repl_history`): what you typed is worth keeping across
projects, what you defined is not.

### Also

- Meta commands work in both modes now: `:defs` typed at a prompt and
  `:defs` piped in from a file go through the same code.
- `print` of a computed String prints the pointer (codegen's `kind-of`
  has no return-type inference), so the REPL writes its own output with
  `term-write` throughout.

## Session (2026-09-23) — a first-class REPL, stage 2: the ICNF interpreter

**A binding entered at the prompt is now a live value, not a line of
text that gets recompiled: `zyl repl` evaluates each entry by running
the real compiler's phases and then interpreting the lowered ICNF in
its own process.** An entry costs about 6 ms. Nothing that already ran
ever runs again.

### What changed

`stdlib/repl/interp.zyl` is the second back end. It takes what
`compile-to-fns` produces — after parsing, macro expansion, every check,
type inference, monomorphization, trait dispatch, closure lifting, ICNF
lowering, optimization and region inference — and evaluates it. Values
use compiled layout: a variant is a `zyl_heap_alloc` block of
`[tag][field]...`, so `zyl_variant_eq` and `zyl_variant_field` read an
interpreted value exactly as they read a compiled one, and a Float is
its IEEE-754 bit pattern operated on through the runtime's double
helpers.

`stdlib/repl/eval.zyl` is the session: the modules in scope, the text of
every definition, and the values bound by `def`. A global reaches an
entry as a parameter of the function the entry is wrapped in, and only
when the entry mentions it — which is what makes `x` from three entries
ago resolve without top-level mutable state in the generated program.

`zyl eval <file.zyl>` runs a program through the same interpreter with
no binary and no linker: 12 ms for hello-world against about 600 ms to
compile, link and run it.

### Memory: flat for an ordinary session

Each entry compiles into an arena of its own and evaluates against a
heap arena of its own, both released when the entry finishes. Two things
are kept, for reasons that are not negotiable: a `def` runs against the
session's own heap (the value has to outlive the entry), and an entry
that lifts a lambda keeps its compile arena (a closure value names the
lifted function, whose body lives there). 200 entries take a session
from 17 MB to 28 MB; before the arenas were separated it was 1.6 GB.

Making that safe needed three supporting changes:

- `ic-fresh-id` was the compile arena's byte offset, which restarts
  whenever the arena does. Two entries would then name two unrelated
  lambdas `_lambda_1234`, and a closure stored by the first would call
  the second. It is now `zyl_fresh_id`, a process-lifetime counter —
  still a fixed sequence for a fresh process compiling a fixed source,
  so the fixed point is unaffected.
- A String field is copied into the heap when a variant is built: the
  string may be a literal living in the arena its entry compiled into,
  and the block outlives that arena.
- `zyl_heap_block_p` answers whether a word addresses a live block, so
  the interpreter never dereferences `(Cons 1 Nil)`'s field as a
  pointer.

### The interpreter and codegen are compared, not assumed

`./run_regression_tests.sh --full` now runs every regression and smoke
test **both ways** and diffs the output (`--filter interpreter` for just
that section). Divergences it found and what came of them:

- **Undefined call** — the front end never resolves call targets, so a
  typo reached the linker. The interpreter reports
  `E_UNDEFINED_FUNCTION` at the call.
- **A catch-all match arm** carries tag -1, which `cg-arm-match`
  special-cases; the interpreter had been comparing it like any other
  tag, so a wildcard arm never matched.
- **A loop's value** is its last iteration's body (`cg-while-body` keeps
  it in a slot); the interpreter had been returning 0, so an
  accumulating `for` evaluated to nothing.
- **`==` on Strings and on heap values** is structural (spec §7.4). The
  interpreter compares bytes and fields, through the same
  `zyl_cstr_eq`/`zyl_variant_eq`/`zyl_variant_cmp` codegen uses when its
  static kind analysis gets the type right.
- **A field read out of a variant** keeps its kind: the interpreter
  records the kinds of a block's fields in a hidden word ahead of the
  block, so `(Some "hello")` destructures to a String. Codegen binds
  every field as an Int, which is where `print` of such a field shows a
  pointer.
- **The test harness** hands `zyl_register_test` a function address; an
  interpreted function has none, so the interpreter keeps the registry
  and runs the tests itself, printing what `zyl_run_tests` prints.

Excluded from the comparison, with the reason recorded in the runner:
actors and concurrency (spawn needs a native entry point — the
interpreter reports `E_UNSUPPORTED_INTERPRETED` rather than jumping to a
number), two tests that print an address, one that assumes `malloc`
returns zeroes, and the crypto suite (minutes of interpreted arithmetic
for what the compiled suite covers in seconds).

### Known limitations (stage 2)

- Actors are compile-only.
- Heavy numeric work allocates per operation and reclaims nothing within
  a run: an Ed25519 verification that is milliseconds compiled is tens
  of seconds and gigabytes interpreted. The memory budget stops it with
  `E_OUT_OF_MEMORY` instead of taking the machine down.
- A definition entered at the prompt cannot capture a `def` binding —
  the binding reaches the entry, not the definitions.
- Values still print as `#<variant tag=N at …>`; a derivable `Show` is
  stage 3.

*Status (2026-09-23):* structural value printing landed in stages 3 and 4
(without a derivable `Show`). The other three limitations are still open.

## Session (2026-09-23) — a first-class REPL, stage 1: the line editor

**`zyl repl` is a real interactive session now: raw-mode line editing
with arrows and word motion, persistent history with reverse search,
multi-line entries that continue until the form closes, Tab completion,
syntax highlighting as you type, and meta commands.** The evaluation
model underneath is still compile-and-run (stage 2 replaces it with an
ICNF interpreter, which is what makes a *binding* — not just a
definition — survive from one entry to the next).

### What shipped

- `stdlib/repl/terminal.zyl` — raw mode, window size, and the whole
  escape-sequence grammar decoded into a `Key` type. No readline or
  libedit dependency: the four primitives it needs (raw mode, a byte
  with and without a timeout, the window size, an unbuffered write) are
  in `runtime/actor_runtime.c`, and everything above them is Zyl.
- `stdlib/repl/line_editor.zyl` — the editor state and its operations,
  including multi-line layout. Width is counted in codepoints, so a
  UTF-8 character occupies one column rather than its byte count.
- `stdlib/repl/reader.zyl` — the key loop. Enter submits only a complete
  S-expression; an unfinished one gets a newline indented to its nesting
  depth. Up and Down move between the lines of an entry and reach for
  history only from its first and last line.
- `stdlib/repl/highlight.zyl` — lexical highlighting that runs on every
  keystroke and colors half-written input without failing.
- `stdlib/repl/history.zyl` — `~/.zyl/repl_history`, appended as each
  entry is submitted rather than at exit, with newlines escaped so the
  file stays one entry per line.
- `stdlib/repl/eval.zyl` — evaluation, and the session's definitions.
- `stdlib/repl/repl.zyl` — the session itself, the meta commands
  (`:help :quit :history :defs :doc :load :save :reset :clear`), and a
  scripted mode for when stdin is not a terminal.
- `stdlib/compiler/pipeline.zyl` — the phase pipeline, moved out of
  `selfhost/driver.zyl` so the CLI and the REPL run the same phases.
  `compile-to-fns` stops at ICNF; `compile-to-asm` is that plus codegen.
- `tools/repl.zyl` is now a thin `main` over the same modules, so the
  standalone binary and `zyl repl` are the same code.

### A real ABI bug, found by the REPL

`tcsetattr` segfaulted on its **second** call and not its first. The
cause was not the terminal code: this backend never established the
SysV guarantee that rsp is 16-byte aligned at a `call`. `cg-function`
sizes a frame as 16n+8, which leaves rsp at 8 mod 16 inside every body,
and the parity pad in `cg-call-args` preserves whatever alignment
happens to hold rather than establishing one. Most C functions do not
care; one that copies a struct or an `__m128i` local compiles that copy
into `movaps`, which faults rather than merely running slower.
`cg-print` (printf with a float) and `cg-variant` (zyl_heap_alloc) had
each been patched locally with a save/AND/restore of rsp; `cg-fire-ext`
now does the same for **every** C call of arity 6 or less, which is
every `ffi-call` in this tree. Arity 7 and up passes arguments on the
stack at `[rsp]` and keeps the old behavior.

Full reseed to a new fixed point; `./run_regression_tests.sh --full`
is 88/88.

### Also

- `\e` and `\xNN` string escapes (`zyl_cstr_decode`): a program could
  not write an ANSI control sequence as a literal before this.
- `zyl_cc_compile_log`: the same compile as `zyl_cc_compile` with the
  toolchain's output captured to a file, so a linker message becomes a
  diagnostic the REPL prints rather than raw text interleaved into the
  session.
- A definition entered at the REPL is accepted only if the session still
  **links** with it. No phase before linking resolves call targets, so a
  definition that merely compiles can poison every later entry.

### Known limitations (stage 1)

- Bindings do not persist between entries; definitions do. The ICNF
  interpreter (stage 2) is what fixes this.
- Each entry recompiles the session's definitions, so entry latency
  grows with the session.
- The stdlib is not in scope at the prompt yet.
- Values print through `print`, so an ADT or struct shows as a pointer.
  A derivable `Show` is stage 3.

*Status (2026-09-23):* all four resolved by stages 2 to 4. Bindings are
live interpreter values, each entry compiles only itself, a session
starts with `core/core`, `core/list`, `core/option`, `core/result` and
`allocator/allocator` and accepts `(use ...)`, and REPL results print
structurally. Compiled `print` of a struct still shows an address.

## Session (2026-09-23) — VS Code extension 0.3.0 and package-aware LSP

**The extension is on current tooling, actually installs, and no longer
collides with its own server; the server understands the package forms.**

- **Dependencies:** vscode-languageclient 9 -> 10.1 (engine now
  `^1.91.0`), TypeScript 5 -> 6.0, ESLint 8 -> 10 with a flat
  `eslint.config.mjs` and typescript-eslint, `@types/node` 20,
  `@vscode/test-electron` 3, and `@vscode/vsce` 4 as a devDependency so
  packaging no longer downloads it. `tsconfig.json` moves to
  `module`/`moduleResolution: node16` (the client's `exports` map needs
  it) and `types: ["node"]` (TypeScript 6 no longer includes every
  `@types` package by default). TypeScript 7 is out but typescript-eslint
  does not support it yet.
- **Command collision:** the server advertises `zyl.evalDocument` as an
  executeCommand, which the client library registers as a VS Code command
  of that name; the extension then registered the same name itself, which
  throws and aborts activation. The user-facing command is now
  `zyl.runCurrentFile` (still "Zyl: Run Current File", Ctrl+Shift+Enter)
  and still sends `zyl.evalDocument` to the server.
- **Dead settings:** `zyl.lsp.trace.server` was never read (the library
  reads `<client id>.trace.server`; the id is now `zyl.lsp`), and
  `zyl.inlayHints.parameterNames` went out as an initialization option the
  server ignores; it is now applied in client middleware, live.
- **Leaks:** each restart created a new output channel and file watcher;
  both are created once. The server log is a LogOutputChannel.
- **Packaging:** `vsce package` failed on the README's relative link; the
  manifest now carries `repository` (with `directory`), a `LICENSE` and a
  `.vscodeignore`. `install.sh --with-vscode` uses the local vsce, a
  `mktemp` directory, and uninstalls the grammar-only 0.1.0
  (`zyl-lang.zyl-lang`), which claims the same language id.
- **Packages in the editor:** `zyl.pkg` is its own language (`zyl-pkg`,
  grammar `syntaxes/zyl-pkg.tmLanguage.json`) so the server never compiles
  a manifest as a program; `build`/`test`/`fetch` tasks for every
  `zyl.pkg` in the workspace; the compiler search falls back to
  `build/boot/zyl-self`. The grammar knows `pub` and `feature-gate`.
- **Server:** `lsp/builtins.zyl` gains `pub` and `feature-gate` (the two
  forms `expr_inner.zyl` dispatched that the table lacked), and
  `source_index.zyl` sees through both wrappers, so `(pub defn f ...)` and
  `(feature-gate simd (pub defn f ...))` appear in the outline and resolve
  for go-to-definition. `tests/lsp/lsp_protocol_test.py` adds a
  package-forms test (96 checks).

Known limit: the extension is not bundled (vsce warns about 182 JS files
from the client library); an esbuild step would fix that.

## Session (2026-09-23) — `_` as the only discard, located diagnostics, and the end of an exponential

**`_` is now the catch-all everywhere, a dropped `)` can no longer drive
the compiler into an allocation runaway, and every diagnostic that has a
node to point at prints `error[CODE]`, `--> file:line:col`, the source
line, a caret and a `= help:` line.**

### `_`, not `d1`

`d1`, `d2`, ... existed because `_` could not repeat inside one binding
list: `unused_check.zyl` exempted only the exact name `_`, and
`E_DUPLICATE_PARAMETER` rejected a second `_` in a parameter list. The
exemption is now `_` and any `_`-prefixed name, across the unused,
shadowing and duplicate-parameter checks alike, so `(defn f (_ _) ...)`
is legal and `_b` no longer warns. 2172 `dN` and 27 `wNx` occurrences
across 55 stdlib/selfhost/tools files and 8 test files became `_`.

Six names spelled `dN` were never discards — `pk-parse-core` and
`pk-parse-triple` (package.zyl) held two dot indices in them,
`poly1305-mul`/`poly1305-carry` held the five limbs, and
`macro_expand`/`monomorphization`/`trait_dispatch`/`repl_integration`
each read one back. A blind rewrite turned those into `_` that silently
shadowed each other rather than failing; they are now spelled for what
they are. Anything renamed to `_` was first checked to occur in no read
position anywhere in the tree.

### Type inference was exponential in a function body

`infer-expr-stmt-chain` (type_inference.zyl) documented itself as
"infer all but last" and inferred all of them; `infer-expr-begin` then
inferred the last one again. `build-sequenced-body` nests bodies to the
right, so every added statement doubled the work — 2^n. Measured on a
growing body: 0.88s, 1.35, 2.09, 3.40, 6.24, 12.58, a factor of ~1.8 per
statement.

This was not only a malformed-input bug. A stage of `./boot.sh` took
about ten minutes (the timeout in boot.sh was sized for it); the whole
two-stage fixed-point verification now takes **23 seconds**.

### A dropped `)` no longer OOMs the machine

`(defn _s-get-x (p (struct-get p "x"))` — one missing paren, file still
net-balanced, so `sexp_balance` passed it — parsed as a parameter named
`struct-get`, swallowed the rest of the file as that function's body and
sent type inference into the exponential above: ~450 MB/s until the
kernel OOM-killed the compiler. Three independent changes:

  - `parse-single-param` (expr_inner.zyl) accepts a name or `(name Type)`
    and nothing else, with `E_MALFORMED_PARAMETER`.
  - `qf-param` (qualify.zyl) used to rebuild every list-shaped parameter
    as exactly two elements and drop the rest, quietly turning
    `(+ p 1)` into the ordinary parameter `(+ p)` — so the malformed
    shape never reached the only code that judges it. It hands the
    original node back untouched now.
  - `zyl_arena_alloc`/`_zeroed` returned 0 on malloc failure and every
    caller dereferenced it. Allocation failure now reports
    `E_OUT_OF_MEMORY`, and there is a memory budget: `ZYL_MAX_MEMORY`
    when set (0 disables it), else 80% of this machine's MemAvailable,
    else 80% of RAM. It is derived from the machine rather than fixed,
    so it binds only where the kernel would have killed the process
    anyway, and it cannot change the output of a compile that succeeds.

### Diagnostics carry a location

`Token` gained a byte offset. Ast did **not** gain a span field: that
would have meant editing ~470 constructor sites, as a pattern in one
place and a construction in the next, in a compiler that then has to go
on compiling itself, where a miscounted pattern arity is a silent
miscompile rather than a build error. The reader records each node's
offset in a span table in `runtime/actor_runtime.c`, keyed by the node's
own address — sound because a variant value is its heap pointer and
arena memory is never freed or moved during a compile. The table is only
ever probed by key, never iterated, so determinism is untouched.

Every rewriting pass copies the original's span onto its replacement, one
line each: `qf-form` (qualify), `convert-ast` (expr_inner), `me-rewrite`
(macro_expand), `subst-expr` (monomorphization), `td-rewrite`,
`ci-expr`, `al-expr`, `ic-expr`. That is what carries a position from
the source text all the way to a codegen-stage error.

`error_report.zyl` renders the shape:

```
error[E_UNBOUND_VARIABLE]: unbound identifier `nosuchvar`
  --> hello.zyl:3:16
   |
 3 |     (print-int nosuchvar)
   |                ^
   = help: check the spelling, or bind it with `let` before this point
```

Located so far: `E_MALFORMED_PARAMETER`, the four balance errors,
`E_ARITY_MISMATCH`, `E_NON_EXHAUSTIVE_MATCH`, `E_UNREACHABLE_MATCH_ARM`,
`E_DUPLICATE_DEFINITION`, `E_UNBOUND_VARIABLE`. Messages print the name
the user wrote rather than its canonical symbol key (`err-name`).

Still printing bare `PANIC:` text with no location, in rough order of how
often they fire: `mutability_check` (5), `capability_check` (3),
`unused_check`'s two warnings, `secret_check`, and the remaining 24 in
`expr_inner`. Each needs the same treatment: thread the offending node to
the failure function and call `err-at`.

### Two other things

`driver.zyl`'s `dbg-log` appended to `/tmp/dbg` on every stage of every
compile — a fixed path in a shared directory, about twenty
open/write/close cycles per compile. It is off unless `ZYL_DEBUG_STAGES`
is set.

`compiler_bridge.zyl` read a diagnostic's code as everything up to the
next `:`, which returned `E_ARITY_MISMATCH]` once messages were spelled
`error[CODE]:`. It now stops at the first character that cannot be part
of a code, which handles both spellings.

### Cost

The span table roughly doubled compile time until its growth factor was
raised from 2 to 8 — a table that doubles from 4096 spends its first
seconds rehashing. Full suite: 30s before spans, 38s now. `./boot.sh`:
23s. 87/87 regression tests pass and the fixed point is clean.

---

## Session (2026-09-23) — spec v5.0 §31: the package system, implemented

**The package system is implemented, from canonical symbol keys through
Minimal Version Selection, the lock, the content store, the index and its
signatures, capabilities, features and native dependencies. Multi-package
programs build and link; two packages may define the same symbol; the
compiler enforces visibility and capabilities; `zyl` grew the subcommands
of §31.11. The self-hosting fixed point holds on a re-cut seed.**

### What the compiler does now

| Spec | Implementation |
|------|----------------|
| §31.1 identity | `stdlib/compiler/package.zyl` — strict SemVer with pre-releases, scoped names, `/vN` majors, compatibility units |
| §31.2 keys and mangling | `stdlib/compiler/qualify.zyl` + `zyl_mangle_key` in the runtime; labels are the spec's own escape, injective by construction |
| §31.3 manifest | `zyl.pkg` read by the language's own parser; every field, canonical writer for `zyl new`/`zyl add` |
| §31.4 compilation model | unchanged: whole-program splicing, now with per-package namespaces |
| §31.5 MVS | `stdlib/compiler/mvs.zyl` — greatest minimum per compatibility unit, overrides, no backtracking |
| §31.6 lock | `stdlib/compiler/lock.zyl` — canonical serialisation, BLAKE3 graph hash, `--locked` staleness and capability-growth checks |
| §31.7 store and archive | `stdlib/compiler/store.zyl` — content-addressed store, canonical tar, hash over the uncompressed archive, offline builds |
| §31.8 index and trust | `stdlib/compiler/index.zyl` — sharded git index, Ed25519 verification with no opt-out, trust-on-first-use key pinning, yank handling |
| §31.9 capabilities | `stdlib/compiler/capability_check.zyl` — declared per package, deny by default, enforced after resolution and before type inference |
| §31.10 features and native | unified additive features with `feature-gate`, optional deps, collision detection; declarative `native` blocks with a cflag allowlist and no build scripts |
| §31.11 workspaces, editions, tooling | `stdlib/compiler/workspace.zyl`, one root lock; edition `2026`; `zyl new/add/fetch/build/test/update/vendor/audit/publish/key` |
| §31.12 determinism | `zyl.buildinfo` beside every package binary |

### Three defects the package system exposed

`zyl_cstr_sanitize` maps every byte outside `[A-Za-z0-9_]` to `_`, so
`is_generic_param` and `is-generic-param` were the same assembly label.
`stdlib/compiler/type_inference.zyl` had seven call sites written with
underscores against hyphenated definitions, and they linked only because
the sanitiser merged them. The injective mangler separated them, turning
a hidden alias into an undefined reference; the call sites are now
spelled as their definitions are.

`zyl_file_read_c` returned a single static thread-local buffer, so two
live reads aliased. `zyl build` read the source, then read the manifest
for its native block, and the manifest text replaced the source in place
— the compiler then compiled the manifest, silently, since both are valid
S-expressions. Each read now owns its buffer, which also lifts the old
silent 1 MiB truncation.

`zyl_exec_cmd` ends in `execl`, replacing the process. That is right for
the link step at the end of a compile and wrong for everything the
package tooling does — `cc -c`, `tar`, `git`, `curl` all have to return —
so the toolchain uses `zyl_system_cmd` and the package link step runs cc
as a child.

### A name means what the module importing it says

Within a package, a definition is visible everywhere (§24.4), and the
standard library already had ten names defined in two modules each —
`list-map` in both `collections/collections` and
`compiler/monomorphization`, `map-get` in both `collections/map` and
`core/map`, and so on. Under the flat namespace those were link-time
hazards resolved by whichever file happened to be spliced last.

They now have distinct canonical keys, and a module's table is built
weakest-first: the rest of its package, then the modules it explicitly
`use`s, then its own definitions. So a module that imports
`collections/map` means `collections/map`'s `map-get`, a module that
defines a name means its own, and only a name nobody disambiguated falls
back to the old last-one-wins rule. The LSP build caught this before the
regression suite did: it is the one program that loads two modules
defining `st-build`, and the first version of the table gave both
definitions the same key.

### The language server had to learn the difference

Qualification changed what the compiler front end hands back: a
definition is now `zyl/std@5::compiler/parser::zyl-parse`, not
`zyl-parse`. The editor asks about names as they are written in the file,
so `lsp/compiler_bridge` keys its symbol table on the key's last segment
(`lsp-source-name`), and call hierarchy does the same on both halves of
every edge. The LSP also passes the document's own path into resolution
now — that is how the resolver knows which package the file being edited
belongs to, and therefore what its definitions are called.

### The bug the language server found

A match arm may nest a constructor inside a pattern:

```lisp
(match (lsp-obj-get params "text")
  (Some (LSPString text) ...)
  (d1 ...))
```

The qualifier rewrote the arm's own head and left the nested
`(LSPString text)` alone, so the pattern kept the source name while
`LSPString`'s definition moved to its canonical key. The arm could then
never match, and — because of how ICNF lowers an arm whose constructor it
cannot find — the whole function holding it fell out of code generation.
Twenty-seven functions vanished from `lsp_server.zyl` that way, which is
why the server advertised half its capabilities and answered nothing
about variants.

Nothing in the regression suite caught it: no test happens to nest a
constructor in a pattern AND depend on the enclosing function. The LSP
build did, because it is the largest program in the tree that is not the
compiler. Nested pattern heads are now qualified and the names they bind
are bound.

### Deliberate deviations, recorded rather than hidden

- **The standard library stays implicit.** §25 says it is implicit and
  versioned with the compiler, so it is package `zyl/std` at the
  compiler's major with no manifest: fully visible, never capability-
  enforced, and not a workspace member. The design doc's Phase 2 sketch
  of converting `stdlib/` into a manifest-bearing member is not what the
  specification says, and the specification wins.
- **A lone file is package `local/main`@0.** Compiling a file directly
  still needs a name to key its symbols by (§31.2), but a file that never
  wrote a `zyl.pkg` has declared nothing, so no capability ceiling is
  enforced against it.
- **Module layout.** §31 does not fix one. A module path `M` in package
  `P` is `<root of P>/M.zyl`, and a package's root module — what
  `(use acme/json)` names — is the module spelled by the name's last
  segment, which is the layout the standard library already uses.
- **`zyl.buildinfo`'s fourth input is the assembly hash, not the ICNF
  hash.** The ICNF has no serialised form here; assembly is a
  deterministic function of it, so the field verifies the same claim
  through a downstream artefact. A true ICNF hash needs an ICNF printer.
- **Qualified names are copied per occurrence.** `type_inference.zyl`
  compares names with `=`, which lowers to a pointer comparison when the
  operand kinds are unknown, so those comparisons have always been false
  and the per-call-site body-inference path behind them has never run.
  Handing every occurrence one shared key pointer made them true for the
  first time and the dormant path dereferenced a null parameter list.
  Copying keeps name comparison exactly as sound as it was; fixing those
  comparisons is a change to type inference, not to the module system.

### Known gaps

- `zyl fetch` downloads registry archives over HTTPS; a `git` dependency
  is recognised, pinned by revision and resolvable from the store, but
  the clone-archive-install path is not wired into `fetch` yet.
  *Status (2026-09-23):* this is out of date. `mvs-git-fetch`
  (`mvs.zyl`) clones, archives and installs a git dependency during an
  online resolution, and a probe with a local `file://` repository
  fetched, locked, built and ran correctly.
- The index URL in the examples (`github.com/zyl-lang/index`) is still a
  placeholder; no index repository exists, so the fetch path is covered
  by unit tests over its pure parts (entry parsing, signing, verification,
  sharding) rather than end to end.
- Hash finalization records §31.12's four inputs in `zyl.buildinfo` but
  does not yet mix the graph hash into the binary's own hash.
- `deny-capabilities` and the capability pass apply to manifest-bearing
  packages only, for the reason above.
- §31.4 describes build caching keyed by content hash; there is no cache
  yet, so every build recompiles the whole graph.
- Paths and URLs that reach `tar`, `zstd`, `git`, `curl` or `cc` are
  validated against a strict character set before the command is built
  (`store-safe`), so a package root containing a space or a quote is
  refused rather than escaped. Refusing the byte is a stronger guarantee
  than quoting it, but it does mean such a path cannot be published from
  or fetched into today.
- `feature-gate` is honoured at top level, where §31.10 says it is valid,
  but a nested one is not rejected — it simply never reaches the
  resolver's top-level scan and so is treated as an ordinary form.

### Cost: the boot cycle got slower

§31.8 makes signature verification mandatory, so the Ed25519 stack and
its field arithmetic now ship inside the compiler — about 2,600 lines on
top of an 18,000-line bundle. One stage of the self-hosting build went
from roughly six minutes to roughly ten, which is exactly where
`boot.sh`'s old 600-second per-stage timeout sat; the cap is now 2400
seconds (`ZYL_STAGE_TIMEOUT` overrides it), and a full reseed plus
verification is the better part of an hour.

The obvious mitigation is to move Ed25519 into the runtime beside BLAKE3
and `zyl_mangle_key`, which would take the bundle back to roughly its
previous size. That is a few hundred lines of field arithmetic in C with
RFC 8032 vectors to check it against, and it is not something to write
in the same change as the package system itself.

*Status (2026-09-23):* the slowdown was mostly the type-inference
exponential fixed in the next session; `./boot.sh` now takes about 23
seconds. Ed25519 has not moved into the runtime.

### Tests

- `tests/regression/package-system.zyl` — 37 assertions over versions,
  names, keys, mangling, manifests, locks, MVS and Ed25519 signing.
- `tests/packages/` — multi-package builds: two packages defining `parse`
  side by side with renaming imports, and feature-gated definitions.
- `tests/packages-fail/` — private import, undeclared dependency, range
  requirement, unknown edition, undeclared capability, unknown feature.
- `tests/packages-build/native/` — `zyl build` with a C source, compiled
  through the cflag allowlist and linked into the binary.

---

## Session (2026-09-23) — spec v5.0: package system design

**The specification is now v5.0. Its centrepiece, §31 Package System, is
fully specified and deliberately unimplemented; the design behind it,
including the sixteen decisions and a five-phase plan, is in
`docs/package-management-design.md`. No compiler source changed, so the
fixed point is untouched.**

### What was decided

| Axis | Choice |
|------|--------|
| Manifest | S-expression `zyl.pkg`, read by the existing lexer/parser — not TOML |
| Resolution | Minimal Version Selection: a pure function of the manifests, no solver |
| Compilation | Whole-program source splicing; no ABI in 5.0 |
| Symbol identity | `pkg@major::module::symbol`, injectively mangled |
| Fetching | `git`/`curl` into a content-addressed store; builds are offline |
| Trust | Author Ed25519 keys, TOFU pinning, verification mandatory |
| Capabilities | Declared per package, deny by default, compiler-enforced |
| Features | Additive-only, unified, recorded in the lock |
| Native deps | Declarative only; build scripts forbidden outright |
| Stdlib | Implicit, versioned with the compiler |
| Index | Git repository of S-expression metadata, scoped `org/name` |
| Compatibility | Minimum compiler version plus editions |
| Imports | `package:module`, colon-separated |
| Visibility | Package-private by default, `pub` to export |
| Workspaces | One root lock, one shared store, path deps |
| Rollout | Five phases, language before distribution |

### Three findings from reading the current implementation

`zyl_cstr_sanitize` (`runtime/actor_runtime.c:984`) maps every byte
outside `[A-Za-z0-9_]` to `_`. It is not injective: `acme/json`,
`acme.json` and `acme-json` all become `acme_json`. Any mangling scheme
layered on it would silently merge distinct functions into one label, so
§31.2 specifies its own escape and Phase 1 replaces the sanitiser on the
label path. This is the single change that has to land before any of the
rest can be trusted.

The colon import syntax needs **no lexer change**. `:` is not an
identifier-continue character (`lexer.zyl:63`), so `acme/json:parser`
already lexes as `TkIdent "acme/json"` followed by `TkKeyword "parser"`.
One consequence had to be specified: the lexer discards whitespace, so
`(use pkg :unsafe)` and `(use pkg:unsafe)` are the same token stream, and
`unsafe` is therefore a reserved module name.

`EUseModule` (`expr_inner.zyl:58`) already carries `(Option (List
String))` for the imported symbol list and a `Bool` for the unsafe flag.
The parser arm at `expr_inner.zyl:1889` passes `None` and `false`
unconditionally, so `(use m { sym })` parses and is ignored. Phase 1 is
smaller than it first appeared: the AST shape is already right.

### Files

New:
- `docs/package-management-design.md` — the design: decisions with
  rejected alternatives, grammars for the manifest, lock and index, the
  MVS algorithm, the mangling scheme, the capability model, the canonical
  archive format, 36 new error codes, and the five-phase plan.
- `spec/16-package-system.md` — structured reference copy of §31.

Modified:
- `zyl_specification.txt` — header and footer to v5.0; §20.6 rewritten
  from a roadmap to a pointer at §31; §24 rewritten (import forms,
  two-level visibility, `pub` over `export`, two-level DAG resolution,
  orphan rule); §25 notes that stdlib is implicit; §27 extends
  determinism to the resolved graph; §28 gains the 36 package codes;
  §29 gains G12 Capability Containment and G13 Supply-Chain Integrity;
  §30 restated; §31 added.
- `spec/00-language-overview.md` — v5.0 version history, G12, G13.
- `spec/15-error-model.md` — package error table, phase 19.
- `docs/implementation-status.md` — replaced the one-line v5.0 note with
  the real gap list, including the three findings above.
- `AGENTS.md` — the v5.0 line now points at the spec section and design
  doc while still saying not to build it unasked.

### Known limitations

*Status (2026-09-23):* superseded the same day; the package system was
implemented in the session above.

- Nothing here is implemented. There is no manifest reader, no lock, no
  resolver, no store, no index, no signing, no capability pass, and no
  namespacing. `module_resolver.zyl` still splices into a flat global
  namespace with no visibility enforcement.
- §31.10 has no answer for packages needing autoconf-style probing; the
  supported workaround is to vendor a pre-configured C source set.
- The index URL in the examples (`github.com/zyl-lang/index`) is a
  placeholder; no index repository exists.
- Phase 1 will change the compiler's own source and therefore requires a
  seed re-cut and fixed-point re-verification per `AGENTS.md`.

---

## Session (2026-09-23) — tooling: language server, editor support, documentation

**The language server now covers the language as it stands, the VS Code
extension is rebuilt around it, `install.sh` builds and verifies it, and
the book gained four chapters plus two rewritten appendices. One real
compiler bug was found and fixed along the way, and three more turned up
while writing this session's own documentation. Full suite 77/77
including the fixed point, on a re-cut seed.**

### The one compiler change: byte load/store argument order

`stdlib/compiler/icnf.zyl`'s four byte load/store arms bound the `Expr`
fields as `endian offset buf` when the real field order is
`(endian, buf, offset)`, then emitted them in that order to runtime
entry points declared `(endian, offset, buf)`. The runtime received the
buffer handle as its offset and the offset as its handle, so
`zyl_bytes_view` resolved a small integer as a handle, found no magic
tag, and every `load-u8`/`load-i8` returned 0 while every
`store-u8`/`store-i8` silently did nothing — all without a diagnostic.

Nothing caught it because nothing asserted a round-trip. The previous
"manual end-to-end smoke test" recorded in
`BYTE_PRIMITIVES_IMPLEMENTATION_PLAN.md` §10 ran the forms and checked
only that the program did not crash.

Fixed by binding in field order and emitting in runtime order, with a
comment recording why the two differ.
`tests/regression/byte-primitives.zyl` is new: 29 cases covering
allocation, zero-initialisation, store/load round-trips at several
offsets, offset independence, zero- against sign-extension, both endian
selectors, fail-closed behaviour past capacity and at a negative offset,
slices and sub-slices including writing through a slice, every atomic
operation, and each region.

Because this changes the compiler's own source, the seed was re-cut with
`./boot.sh --bootstrap-from-self` (converged in 2 rounds) and the fixed
point re-verified. **`build/boot/stage2.s` and `build/boot/stage2.bin`
are modified and not yet committed.**

### Language server (`stdlib/lsp/`)

New `stdlib/lsp/builtins.zyl`: one table of 143 entries — every head
symbol `dispatch-special` recognises, every operator `icnf.zyl` lowers
to an instruction (including the bitwise family and the byte and atomic
primitives), and every type, region and capability name, each with a
signature and a one-line description. It is the single source behind
hover, completion, signature help and token colouring, so a form added
to `expr_inner.zyl` and not to this table shows up in an editor as an
unresolved identifier.

Requests added: `references`, `documentHighlight`, `signatureHelp`,
`typeDefinition`, `implementation`, `semanticTokens/range`,
`rangeFormatting`, and the `didSave` notification (advertised with
`includeText`, so the document is re-analysed from the saved text). The
request table is split in two — `lsp-handle-request-2` — because one
`if` chain holding every method nested further than is readable.

Rewritten or substantially extended:

- **`source_index.zyl`** — top-level forms now record their FULL extent
  (opening paren through matching close), not just a start position, so
  symbol ranges, folding and selection ranges are exact; the def-keyword
  set grew from five to ten (`impl`, `macro`, `defmacro`, `def`,
  `alias`); new whole-word occurrence scan (skipping strings and
  comments) behind references, highlight and rename; new call-context
  scan giving the innermost open form's head and argument index, behind
  signature help and `(use ...)`-aware completion. Fixed a real bug on
  the way: `si-scan-skip-comment` passed a hard-coded depth of 0 back
  in, so any top-level form containing a comment line was treated as
  having closed.
- **`compiler_bridge.zyl`** — the symbol table gained structs and their
  fields. `defstruct` is not a node of its own (`expr_inner.zyl` lowers
  it to an `EDeftype` with the marker `(Some "struct")`), so that marker
  is what now routes a definition to the struct map rather than the ADT
  map. Hover answers for structs, fields, variants (naming the owning
  ADT) and built-ins, not just functions and ADTs. Caught panics are
  parsed for their `E_*` code and their first backticked name, and the
  name is located in the document text — so a diagnostic points at the
  offending symbol instead of line 0, and carries its code in the LSP
  `code` field.
- **`semantic_tokens.zyl`** — the legend is now the ten standard LSP
  token types with three modifiers, and identifiers are actually
  classified (built-in, function, type, variant, property) instead of
  being dropped; `st-reclassify` was a no-op returning its input.
  Unresolvable words are still left uncoloured rather than guessed at.
- **`document_manager.zyl`** — runs the same checks
  `selfhost/driver.zyl` runs, in the same order (`dc`, `ac`, `mc`, `ec`,
  `sc`). `unused_check` is deliberately excluded: it reports by printing
  to stdout, which is the server's JSON-RPC channel. The symbol table is
  now built before the checks and kept whatever they say, so a document
  that fails one still offers hover and navigation.
- **`completion.zyl`** — context-aware (module paths inside `(use ...)`),
  items carry a signature and documentation, and structs and fields are
  offered.
- **`goto_definition.zyl`** — variants resolve to their `deftype` and
  fields to their `defstruct`; type definition and implementation added;
  rename now covers every occurrence in the file rather than the
  declaration alone, and `references` honours
  `context.includeDeclaration`.
- **`signature_help.zyl`** — new.

Corrected while writing the table: `fn` and `lambda` are the same form
and neither takes a name; the `SignatureHelpOptions` type referenced a
`SignatureHelpTriggerCharacter` that no `deftype` ever defined.

### Tests

`tests/lsp/lsp_protocol_test.py` drives the real binary over real
JSON-RPC on stdio and asserts on the responses — 88 checks across
capabilities, hover, navigation, symbols, completion, semantic tokens,
rename, and one diagnostic case per compiler check. Wired into
`run_regression_tests.sh` in both quick and full mode
(`--filter lsp`).

### VS Code extension (`editors/vscode/`, v0.2.0)

Grammar rewritten to cover every special form, the bitwise family, the
byte and atomic primitives, regions, capabilities and keyword atoms,
with definition forms colouring the introduced name. Added: 17
snippets, semantic token scope mapping, a `zyl` build task, a status bar
item wired to the server log, `zyl.lsp.enable`/`arguments`/
`inlayHints`/`compiler.path` settings, restart-on-config-change, a
four-step server search (setting, `$ZYL_HOME`, `~/.zyl`, workspace
`build/boot`, `$PATH`), and **Run Current File**
(`Ctrl+Shift+Enter`). The duplicate `zyl-language-configuration.json`
was removed and the two merged. Compiles clean with `tsc`.

A problem matcher was deliberately NOT added: the compiler's CLI errors
carry no file or line, so one could not locate anything.
*Status (2026-09-23):* located diagnostics now print `file:line:col`, but
no problem matcher has been added.

### install.sh

Builds the REPL and the server with `ZYL_HOME` pinned to the install
target (both were previously compiled against whatever `~/.zyl` already
held), then sends the installed server a real `initialize` request and
reports whether it answered. New `--with-vscode` builds and installs the
extension; new `--help`.

### Documentation

Book: four new chapters —

- **32, Bits, Bytes, and Buffers** — the bitwise operators, the two
  right shifts, defined out-of-range shift counts, buffers and regions,
  loads and stores, slices, atomics, and a table of what is implemented
  against what is reserved.
- **33, Secrets and Constant-Time Code** — the `Secret` capability, the
  five prohibitions, branchless idioms, declassification, erasure, and
  why the check is syntactic.
- **34, The Cryptography Library** — the two representation
  conventions, the module map, worked examples, the deliberate
  omissions, and the three verification layers.
- **35, Editors and the Language Server** — installation, VS Code,
  Neovim/Emacs/Helix, what the server provides, how it works, and its
  limits.

Appendix A (error codes) and Appendix C (built-ins) were rewritten
against the compiler rather than the specification; both had drifted.
Appendix A listed codes that do not exist and pointed at `src/error.rs`;
Appendix C claimed `int?`/`len`/`defun`/`invariant`, a `(let (x 10 y 20))`
multi-binding form, and a compiler flag list of which only `-o` and
`--emit-asm` are real. Appendix B gained the math and LSP trees and had
every `use` path corrected (`(use core)` → `(use core/core)`).
Appendix D gained entries for the new vocabulary. Chapter 1 gained
installation and editor-setup sections; Chapter 2's "parallel let"
section was corrected — `let` binds exactly one name.

`README.md`, `docs/regression-tests.md`,
`LSP_ARCHITECTURE_PLAN.md` and
`BYTE_PRIMITIVES_IMPLEMENTATION_PLAN.md` were brought up to date.

### Parameter representation: String and Float parameters

Chasing the `print-string` defect below found a single root cause behind
three separate wrong behaviours.

Codegen picks a printf format, a comparison strategy and an arithmetic
unit from a value's *kind*: 0 for a machine word, 1 for a String, 2 for
a Float. Kinds are read out of the environment, and `cg-param-env`
recorded every parameter as kind 0 no matter what its declared type
was — because `IFn`, the ICNF node for a function, carried only
parameter *names*. The declared type never reached the backend at all.

So, for any value that arrived as a parameter rather than a literal:

- `print` on a `String` printed its address.
- `=` and `!=` on two `String`s compared addresses, not contents, and
  answered "not equal" for equal strings built different ways.
- a `Float` returned from a function was recorded as returning an `Int`.

`core/core`'s `print-string` is a one-line wrapper around `print`, which
is exactly why it looked like a bug in the wrapper.

The fix gives `IFn` a fourth field, a per-parameter kind list, appended
after the body so that every existing three-binder `(IFn name params
body ...)` pattern keeps binding the same three fields. `ic-defn` fills
it from each `Param`'s declared type; a lambda, whose parameters carry
no annotation, gets an empty list, which `cg-param-env` reads as "0 for
the rest". Codegen also measures a function's return kind in an
environment holding its own parameters, so a function that returns a
`String` parameter is now recorded as returning one.

One subtlety worth recording: `Param` is declared as
`(P String (Option String))`, but `expr_inner.zyl` actually stores
`(Some (convert-ast typ))` — an `Expr`, not a `String`. Reading it as a
string compiles and silently compares a pointer against a literal, which
is exactly what the first attempt at this fix did. `secret_check.zyl`
reads the same field correctly and was the model for the second.

### printf call alignment

With Floats printing as Floats, `(print 1.5)` segfaulted — and it
segfaulted before this change too, which nothing had noticed because
nothing printed a float.

`print` on a Float sets `al` to 1, printf's signal to spill the SSE
argument registers with `movaps`, which faults unless the stack is
16-byte aligned. Every other `print` leaves `al` at 0 and never reaches
that instruction, which is why misalignment had been invisible. The
frame size `cg-function` picks leaves `rsp` at 8 mod 16 inside a body,
and staged call arguments shift it again, so the alignment at any given
call site is not something this backend predicts.

`cg-print` now wraps the call in the same `mov r12, rsp` / `and rsp,
-16` / `mov rsp, r12` idiom `cg-variant` already uses for
`zyl_heap_alloc` and `cg-trycatch` uses for `setjmp`. r12 is
callee-saved, so printf returns it intact.

The systemic version of this — a body's `rsp` being 8 mod 16 at all —
is left alone. Nothing else observably depends on it, and changing the
frame formula would shift every call site in the compiler at once.

### A String stored where an Expr belonged

Reading the declared type turned the existing representation confusion
into a crash, which is how it got found. Two places in
`monomorphization.zyl` built a `Param` from a type *name* and stored the
bare string: `subst-defn-param`, for a substituted generic parameter,
and `annotate-first-param`, for the receiver of an `impl` block's
method. Every reader of that field starts with `(Expr.inner t)`, so the
compiler read a string's bytes as a variant block. Before this session
that produced a quiet wrong answer in `secret_check.zyl`; with
`param-kind-of` reading the same field it segfaulted the compiler on
`tests/integration/trait-dispatch.zyl`. Both sites now wrap the name as
an identifier expression.

### `tests/regression/param-kinds.zyl`

14 tests: String parameters printed, returned, concatenated and
compared both ways; Float parameters through arithmetic, through a
return and through two calls; Int and unannotated parameters unchanged;
and three tests that print, which assert nothing but crash if the stack
is misaligned.

### One defect found and documented, not fixed

- **A byte-buffer handle is an integer, and passing a non-buffer where
  one is expected is not a type error.** The runtime dereferences it and
  segfaults. Noted in Chapter 32.

---

## Session (2026-09-22, continued) — Phase 0: the Secret capability

**`MATH_CRYPTO_IMPLEMENTATION_PLAN.md` Phase 0's enforcement half is
implemented and the library is annotated. Full suite 73/73, fixed point
holds.**

### `TCSecret` (`stdlib/compiler/type_system.zyl`)

A real `CapKind` variant, carrying the part the TYPE layer owns: a
Secret is NOT `Send` (a secret crossing into another actor is the leak
the capability exists to prevent), it IS FFI_Pinnable through its inner
type (a key does reach AES-NI, but only via `ffi-pin`), and
`cap-kind-compatible` lets it unify with a plain `TCCap` in either
direction — the taint itself is tracked by name in the new checker, not
carried in the unifier's substitution, because this inferer has no
capability-polarity machinery and a Secret/Cap unification failure would
reject ordinary code that passes a key through a generic helper.

### `stdlib/compiler/secret_check.zyl` (new pass)

Runs in `compile-to-asm` right after `unused-check`, over the
pre-lowering Expr tree. A parameter annotated `Secret` — `(k Secret)` or
`(k (Secret Int))` — seeds a taint propagated through lets, calls,
arithmetic, constructors and byte loads, and interprocedurally by a
fixpoint over functions whose body is tainted under their own Secret
parameters. Rejections, all newly added to `error_codes.zyl`:

| Shape | Code |
|-------|------|
| `if`/`while`/`for`/`cond` condition or `match` subject from a Secret | `E_CT_VIOLATION` |
| Secret in an index argument (`w-get`, `list-nth`, `alloc-read-int`, …) or a byte offset | `E_CT_VIOLATION` |
| Secret operand of `/` or `mod` (variable-latency divider) | `E_CT_VIOLATION` |
| Secret reaching `print` | `E_SECRET_DEBUG` |
| Secret reaching `spawn`, `send` or `file-write` | `E_SECRET_ESCAPE` |
| Secret handed to `ffi-call` without `ffi-pin` | `E_FFI_PIN_REQUIRED` |
| Secret consumed into a public result with no `zeroize` | `E_ZEROIZE_MISSING` (warning) |

`E_FFI_TYPE_NOT_PINNABLE` is also catalogued. Diagnostics name the
enclosing function (`in \`mr-check\`: E_CT_VIOLATION: …`) — the Expr
tree carries no source spans, so the function name is the only location
available; it is threaded as an `SCtx` alongside the list that was
already being passed.

Why syntactic rather than a type-level CT effect: param annotations in
this pipeline are Exprs that type inference consults only loosely, and a
real effect needs constraint machinery this inferer does not have. The
practical limit is that taint crosses a call boundary only where the
callee's parameters are annotated — an unannotated helper launders a
secret.

### `declassify` and the annotated library

`math/secret/secret` gained `declassify` (identity at runtime, the one
named way out) and its own primitives now carry `Secret` annotations, so
every caller of `ct-eq`/`ct-select`/`bn-eq` is under the checker.
`ct-eq-bool`/`ct-eq-words-bool` declassify by name, which is what lets an
AEAD act on its own tag verdict.

That immediately found **eight places in `stdlib/math` that branch on a
secret-derived value**. All eight are legitimate published verdicts
rather than leaks — Miller-Rabin's round result, ECDSA's r/s zero tests
and RFC 6979 rejection loop, ECDSA verification (public inputs
throughout), Ed25519 point decompression, X25519's RFC 7748 §6.1
all-zero check, and RSA-OAEP's single combined accept bit — so each is
now an explicit `declassify` with a comment stating why it is public.
The value is that they are greppable and that a NEW one cannot be added
silently.

### Also fixed

`run_regression_tests.sh` never pinned `ZYL_HOME`, so the suite resolved
`stdlib/` from a populated `$HOME/.zyl` left by `install.sh` rather than
from the checkout — edits to `stdlib/` in this tree were invisible to
the tests (`boot.sh` has guarded against exactly this since the Rust
eviction). It now exports the same `build/boot` path boot.sh does.

### Verification

`tests/regression/secret-capability.zyl` (9 accepting cases: branchless
arithmetic, public-condition/secret-arm selection, both declassification
routes, a public index over secret words, a pinned FFI handover) and
seven `tests/compile-fail/secret-*.zyl`, one per rejection plus an
interprocedural one. Full suite 73/73 with the fixed point holding; the
seed was re-cut twice more with `--bootstrap-from-self` (2 rounds each).

### Still open from Phase 0

Zeroization on scope exit and `print` redaction both need codegen hooks
(an epilogue and a print path) that do not exist; `Secret` annotations
on the rest of `stdlib/math`'s entry points; the `Secret` trait for
user-defined secret types, which waits on trait dispatch.

## Session (2026-09-22) — `stdlib/math`: the cryptography and number library

**Implemented `stdlib/math/` — the cryptography and number library from
`MATH_CRYPTO_IMPLEMENTATION_PLAN.md` — plus the four compiler fixes it
turned out to need. Full suite 65/65; the math group is 17/17.**

### Compiler and runtime changes (all required by the library)

1. **Bitwise operators did not exist** (`icnf.zyl`, `codegen.zyl`,
   `optimization.zyl`, `type_inference.zyl`). `bit-and`, `bit-or`,
   `bit-xor`, `bit-not`, `shl`, `shr` (logical) and `ashr` are new
   opcodes 11-17 lowering to single instructions. Shift counts outside
   0..63 are DEFINED rather than left to x86's mod-64 masking: logical
   shifts give 0, `ashr` saturates to the sign bit. Constant folding
   deliberately does not cover them — folding a `bit-and` inside the
   compiler would need the compiler's own source to use `bit-and`,
   which the previous-generation seed cannot compile — and the `op > 10`
   guard added to `opt-fold-binop` is load-bearing: without it a
   constant `bit-and` folded to an inequality test.
2. **`for` silently ignored a non-zero initializer** (`expr_inner.zyl`).
   `(for (i 16) ...)` was parsed as two bindings — `i` with no
   initializer, and an unnamed `16` — so the loop started at 0. Every
   `for` in the corpus happens to start at 0, which is why this had
   never surfaced. `parse-for-bindings` now distinguishes the
   single-binding shorthand from a real binding list by whether the
   first element is an identifier.
3. **`print` truncated every Int to 32 bits** (`codegen.zyl`): the
   format string was `"%d\n"` for a 64-bit value. Now `%lld`.
4. **AES-NI FFI needed stack realignment** (`actor_runtime.c`):
   generated code does not guarantee the SysV 16-byte alignment at a
   call, and the key expansion keeps `__m128i` on its stack, so
   reaching it through one call depth rather than another segfaulted.
   `__attribute__((force_align_arg_pointer))` on the FFI entry point.
5. Runtime additions: `zyl_zeroize` (volatile, survives dead-store
   elimination), `zyl_mlock`, `zyl_random_fill`/`zyl_random_words`
   (getrandom(2) with a /dev/urandom fallback), `zyl_cpuid_features`,
   `zyl_aesni_available`, `zyl_aes_encrypt_block`. `zyl_pin_alloc` now
   mlocks what it hands out, best-effort.
6. `--filter` in `run_regression_tests.sh` was compared backwards (the
   test name was matched against the filter text), so `--filter math`
   selected nothing. It is now a substring of the test's own name.
7. `car`/`cdr`/`cadr`/`caddr`/`cddr`/`list-rest` added to
   `core/list.zyl` as plain functions — each takes one argument and
   evaluates it once, so a macro would buy nothing, and a function can
   be passed to a higher-order function.

### The library (`stdlib/math/`, ~7,500 lines)

Hashes (SHA-256/512, SHA3-256/512, SHAKE128/256, BLAKE2b, BLAKE3,
HMAC-SHA256), symmetric (ChaCha20, Poly1305, ChaCha20-Poly1305,
AES-GCM via AES-NI), asymmetric (X25519, Ed25519, ECDSA over P-256 /
secp256k1 / P-384 with RFC 6979 nonces, RSA-PSS and RSA-OAEP), KDFs
(HKDF, PBKDF2, Argon2id), big numbers (fixed-width naturals,
Montgomery, Barrett, Miller-Rabin), RNG (getrandom, seeded ChaCha20),
and the constant-time primitives everything else is built on. See
`docs/math-crypto.md` for the representation conventions and the
deliberate omissions (no PKCS#1 v1.5, no software AES, no RSA key
generation, no randomized ECDSA nonces).

### Verification

- 16 new `tests/regression/math-*.zyl` files of published vectors
  (NIST, FIPS, RFC) plus `tests/integration/math-protocol.zyl`, a
  miniature authenticated key exchange across four modules.
- `verify/sha2.py` and `verify/crypto.py` cross-check randomized inputs
  against Python's `hashlib` and `cryptography` — 414 SHA digests over
  lengths 0..1000, plus AEAD, curve and KDF cases.
- `verify/timing.py` is a dudect-style leakage harness with a
  deliberately leaky comparison as a positive control; it fails if it
  cannot detect that control. Run it with `--filter timing`.
- Every algorithm was first mirrored in Python against its reference
  (CIOS Montgomery, Keccak's index conventions, the RCB complete
  addition formulas, Argon2's addressing, BLAKE3's tree) before being
  written in Zyl, which is why the first compile-and-run cycle found
  compiler bugs rather than algorithm bugs.

### Not done (from the plan)

- BLAKE3's SIMD backend; the portable compression function is used.
- ctgrind/valgrind instrumentation (`verify/timing.py` is the
  statistical substitute).

**The seed was re-cut twice** (`./boot.sh --bootstrap-from-self`,
converging in 2 and 3 rounds); `build/boot/stage2.s`/`stage2.bin` are
modified and not yet committed.

## Session (2026-09-19) — native balance validator wired into the compile path

**Wired the native paren/bracket balance validator into the real compile path; fixed a latent paren-deficit bug in error_codes.zyl found along the way.**

- `sexp_balance.zyl` and `error_codes.zyl`/`error_report.zyl` existed in
  the bundle (`selfhost/assemble.py`'s `files` list) but nothing called
  into them — the actual compile path (`selfhost/driver.zyl`'s
  `compile-to-asm`, `stdlib/compiler/parser.zyl`'s `zyl-parse`) still used
  a depth-counter (`bal-walk`) that only compared total `(` vs `)` counts,
  so `)(` and `(]` both passed straight through to the reader.
- Added a `BalanceResult` variant `UnclosedOpen` that carries the
  *opener's* position (not just EOF), added `sb-hint` (one fix-it-text
  function per `BalanceResult` variant, colocated with the type so the
  compiler's error path and any future LSP/REPL consumer read the same
  wording), and wired both `compile-to-asm` and `zyl-parse` to call
  `sb-check-string` + `report-unbalanced` instead of `bal-walk`.
  `bal-walk`/old `check-balanced` deleted (fully superseded).
- Added 3 error codes: `E_UNBALANCED_UNCLOSED`,
  `E_UNBALANCED_UNEXPECTED_CLOSE`, `E_UNBALANCED_MISMATCHED_BRACKET`
  (`error_codes.zyl`, `docs/errors.md`).
- **Found along the way**: `error_codes.zyl`'s catalog `Cons` chain was
  under-closed by 14 parens — a real instance of the skill's own
  constraint-4 warning ("a missing closer silently nests every following
  defn inside the broken one"). Never caught because nothing called
  `ec-name`/`ec-lookup`/etc. yet, and `assemble.py`'s depth check only
  verifies the WHOLE bundle nets to 0, not each file — a per-file deficit
  that happens to get absorbed by later files in the bundle is invisible
  to it. Fixed by closing the chain where `defn error-codes` actually
  ends; verified every top-level form in the file closes independently
  (script in this session's transcript, not committed — a real per-file/
  per-form checker here is exactly the gap `sexp_balance.zyl` should grow
  into next, see below).
- **Found along the way (2)**: `sexp_balance.zyl` shipped its own
  `(defn main ...)` for standalone-CLI use. Harmless while it only ever
  reached the compiler via the bundle (`assemble.py`'s `strip_named_defn`
  already special-cases stripping `main` from every non-driver bundled
  file, exactly to avoid this) — but now that `parser.zyl` genuinely
  `use`s it, the real module resolver splices that `main` verbatim into
  ANY standalone program that (transitively) uses `compiler/parser`,
  tripping `E_TOPLEVEL_STMTS_WITH_EXPLICIT_MAIN` the moment that program
  also has top-level `test`/`run-tests` forms. Renamed to
  `sb-standalone-run` (no longer named `main`).
- **Found along the way (3)**: `sexp_balance.zyl` used
  `compiler/type_system`'s generic `Pair` without declaring that `use` —
  invisible under the bundle (everything's globally available there) but
  a real undefined-reference link error (`_ZYL_Pair`) for any standalone
  `use compiler/parser` once sexp_balance became a genuine dependency
  edge. Rather than pull in the entire Hindley-Milner type_system module
  for one tuple type, gave sexp_balance.zyl its own local `SBPair`.
- **Environment gotcha hit while testing, not a source bug**: `~/.zyl`
  (a previously-installed global copy, see `install.sh`'s own docstring)
  takes precedence over `build/boot/stdlib` for any file compiled outside
  this checkout — by design, for normal end-user `zyl` usage from any
  directory. It was stale on this machine and briefly made a fixed unit
  test look like it was still failing. `./install.sh` refreshes it; worth
  remembering to re-run after any stdlib change before trusting a
  standalone (non-`run_regression_tests.sh`) manual test.
- Added regression coverage using the language's OWN test framework
  (`test`/`assert-equal`/`run-tests`), not just black-box compile-fail
  checks: 5 new `(test ...)` cases in `tests/regression/compiler.zyl`
  exercising `sb-check-string`/`sb-hint` directly (balanced, unclosed-
  open with exact opener line/col, unexpected-close, mismatched-bracket,
  and the `)(` case the old depth-counter used to let through). Plus 3
  compile-fail tests (`tests/compile-fail/{unclosed-opener,
  unexpected-close,mismatched-bracket}.zyl`) proving the compiler itself
  rejects each case. Full suite green: 46/46
  (`run_regression_tests.sh --full --no-boot`).
- Reseeded `build/boot/stage2.s`/`stage2.bin` three times as the above
  was found and fixed (`./boot.sh --bootstrap-from-self`, converged in
  1-2 rounds each time); clean `./boot.sh` confirms fixed point holds and
  the CLI smoke test still passes after the final round.

**Follow-up worth doing**: `assemble.py`'s depth check should verify each
*file's own* net depth is 0 before concatenating, not just the final
bundle — it would have caught the error_codes.zyl bug immediately instead
of it sitting latent. LSP integration (this session's validator is the
prerequisite) and the rest of `error_report.zyl` (colorized output,
snippets) are still open — see `docs/error-system-architecture.md`.

*Status (2026-09-23):* the language server landed later on 2026-09-19
(`7c25a65`); source snippets with a caret landed on 2026-09-23
(`error_report.zyl`). Still open: the per-file depth check in
`assemble.py` and colorized output.

## Session (2026-09-17) — feature-parity survey closed, Rust evicted

Picked up from the 17-item self-hosted-compiler feature-parity survey
(`docs/rust-eviction-plan.md`, added 2026-09-16 once the fixed point
above was finally solid). Fixed every remaining item:

- Cross-deftype variant shadowing, trait-dispatch compiler crash,
  contracts passthrough forms, with-resource/control-flow-ext/derive —
  fixed earlier in this arc (see rust-eviction-plan.md for each).
- **`boot.sh`'s `build/boot/stdlib` mirror was stale on every run after
  the first** (`cp -R stdlib OUT/stdlib` nests instead of updating an
  already-existing target dir) — silently froze the module-resolution
  path any program `use`-ing compiler-internal modules actually read,
  which is why `integration/selfhost-codegen` failed with a nonsensical
  `E_UNBALANCED_PARENS`. `rm -rf` before the `cp -R` fixed it; also
  found and fixed a duplicate `resolve-nominal` definition it exposed.
- **Real per-ADT match exhaustiveness**: added a `gid` field to
  `VTEntry` grouping a deftype's variants regardless of `tag` (which
  restarts at 0 per deftype); guarded against a parser surface-form
  ambiguity (`region_inference.zyl`'s nested-Cons-destructuring arms)
  that would have produced false positives.
- **Real closures (free-variable capture)**: `fn` referencing an
  enclosing name now works. Heap `[tag,code,env]` triples, a new
  `ICallClosure` call path, two independent VTable marks (`VTClosureFn`
  vs `VTClosureReturn` — "this value is a closure" vs "calling this
  hands one back" are different questions, conflating them was the
  first bug found bringing this up).
- **Real `try`/`catch`**: turned out the runtime already had a working
  panic/longjmp mechanism (built for the test harness's own panic
  recovery, never wired to anything else) — `error` needed to call it,
  and a new `ITryCatch` codegen path calls `setjmp` inline in generated
  code (not through an FFI wrapper, which would `ret` and become an
  invalid longjmp target).

**Result: `./run_regression_tests.sh --full` passes 43/43 through the
self-hosted compiler** — up from 26/43 when the survey started, 0 known
gaps left.

Then went further than the survey: verified empirically that Rust
isn't needed for **reseeding** either, not just the default build.
Took a self-hosted seed many commits stale (predating all of the above)
and fed it the current compiler source through the existing argv CLI,
iterating stage1->stage2->stage3->... — round 1 differs from round 2
(a compiler doesn't yet behave per source it JUST compiled, only source
its own compiled predecessor already reflects), but round 2 and round 3
were byte-identical, and matched what Rust had actually produced for
the same source. Added `./boot.sh --bootstrap-from-self`, which does
exactly this (up to 10 rounds), and it's now the normal reseed path.

With that proven, executed Phase D: `git mv src archive/rust-bootstrap-
2026` (with its own README explaining when it's still needed — only a
change so large the previous seed's compiler can't even PARSE the new
source, which no amount of self-iteration can solve), moved
`Cargo.toml`/`Cargo.lock` alongside it, deleted `target/`, deleted
`run_regression_tests_self.sh` (fully superseded by
`run_regression_tests.sh` since it switched to `zyl-self`), deleted a
pile of untracked/stray root junk (`a.out.*`, `--emit-*.s`,
`larry_test.*`, `test_*.zyl`, `output.zyl`, etc.), and updated
README.md/AGENTS.md/`.gitignore`/`docs/regression-tests.md` to stop
referencing Cargo/`target/release`/`src/*.rs`.

**Rust is no longer part of the active build, test, or use path.**
`./boot.sh` (verify) and `./boot.sh --bootstrap-from-self` (reseed)
both build with nothing but `cc`. `archive/rust-bootstrap-2026/` is
preserved, self-contained and (with one path fix to `runtime.rs`) still
buildable in place, purely as a fallback.

**Not done / explicitly out of scope for this session**: Phase B
(region inference's own result is still computed and discarded, never
fed into codegen; `optimization.zyl` is still never called — both
compile and are exercised by every self-hosted build, neither affects
compiled output) and Phase C (`tools/repl.zyl` compiles and links now
but has at least two known bugs — dropped `main` for trivial programs,
an arena-corruption crash — treat it as an unfinished skeleton, not a
working REPL).

*Status (2026-09-23):* both were done later the same day. Region
inference now rewrites non-escaping variants to stack allocation
(`a2649e2`) and `optimization.zyl` does real constant folding and
dead-branch elimination (`7872a63`), both wired into the pipeline. The
REPL was made to run (`25092d1`, `6221eaa`) and was later replaced by the
`stdlib/repl/` implementation (2026-09-23).

## Session (2026-09-15, final) — stage2 segfault, CLI argv, deterministic helper names

**Stage2 segfault FIXED. CLI working. Self-hosted fixed point blocked by pre-existing codegen bug.**

(This entry restates the stage2 fix from the entry below it; the
commit that added it also deleted that entry's first paragraphs,
which have been restored from `50d6b6f`.)

**Fixed (this session):**
1. **Type inference segfault** (`type_inference.zyl`): `infer-expr-if` match arm had 9 stray tokens between bind-name and body → OOB read on `UOk` (1 field). Deleted stray tokens.
2. **Region inference segfault** (`region_inference.zyl`): 7 arms (`ICall`/`IFfi`/`IPrint`/`IIf`/`IWhile`/`IVariant`/`IMatch`) wrote 2-statement bodies as bare trailing forms → grammar treated 1st stmt as extra field → OOB read on structs with 1 field. Fixed with `(begin ...)` wrappers.
3. **Non-deterministic helper names** (`icnf.zyl`): `ic-fresh-id` used raw heap pointer → run-to-run variance. Changed to `arena-used` (deterministic offset).
4. **CLI argv support** (`driver.zyl`, `codegen.zyl`, `actor_runtime.c`): Added `zyl_save_args` in entry stub, real CLI parsing (`src`, `-o`, `--emit-asm`), `chdir` to bundle dir, linking via `zyl_exec_cmd` (shell script + `exec` to avoid `fork` from 64GB-stack thread).
4b. **`system()` crash fix**: `fork()` from 64GB-stack pthread crashed in `system()`. Replaced with `execl("/bin/sh", script)` — avoids `fork` entirely.

**Verified (Rust-compiled compiler):**
- Stage2 segfault FIXED: trivial repro and full self-compile complete without crash.
- CLI works: `zyl src.zyl -o out` compiles, links, runs correctly (smoke test: `42`/`3`).
- Deterministic helper names: run-to-run identical output (fixed `ic-fresh-id`).
- Rust bootstrap compiles full self-hosted source successfully.

**Known gap (pre-existing, not fixed this session):**
- Self-hosted compiler's `codegen.zyl` has a bug: `ffi-call` in `main` (or `if` at top level) causes missing `f_main` in output → self-hosted fixed point blocked. Rust compiler works; self-hosted compiler fails. Documented in rust-eviction-plan.md Phase A as known gap.
  *Status (2026-09-23):* resolved; the fixed point holds, and `ffi-call`
  inside an `if` in `main` compiles and runs.

**Files changed:** `stdlib/compiler/type_inference.zyl`, `stdlib/compiler/region_inference.zyl`, `stdlib/compiler/icnf.zyl`, `selfhost/driver.zyl`, `stdlib/compiler/codegen.zyl`, `stdlib/compiler/icnf.zyl`, `runtime/actor_runtime.c`, `build/boot/stage2.s` (reseeded), `PROGRESS.md`.

## Session (2026-09-15, continued further) — stage2.bin segfault fixed, fixed point reached

**stage2.bin segfault FIXED — true self-hosting fixed point reached (stage1 reproduces committed seed byte-for-byte; stage2==stage3).**

Root-caused and fixed the "stage2.bin itself has a distinct bug" blocker from
the previous entry below (`Expr.inner` null-deref reached through deep
recursion in `collect-definitions`). Two separate bugs found via `gdb`
(breakpoint on the crashing instruction, inspect `rdi`, walk back through
`bt` to the miscompiled call site, then diff against the actual `deftype`
arities in `expr_inner.zyl`/`icnf.zyl`):

1. **`infer-expr-if` in `type_inference.zyl`**: its `(match unified (UOk
   new-s ...))` arm had **9 stray literal tokens** (`Nil Nil Nil Nil Nil
   (tc-new) Nil Nil Nil`) sitting between the bound name `new-s` and the
   real body — leftover corruption from some earlier edit. Per the match-arm
   grammar (`parse-match-arm` in `expr_inner.zyl`: *only the last form is the
   body; everything else is treated as an additional bound field name*),
   these 9 extra tokens were compiled as 9 *more* field-destructures off
   `UOk` — which really has exactly 1 field (`(deftype UnifyResult (UOk
   Subst) ...)` in `type_system.zyl`) — an out-of-bounds heap read every
   time an `if` got type-checked. Fixed by deleting the stray tokens.
2. **Seven arms in `region_inference.zyl`'s `ri-infer-expr`** (`ICall`,
   `IFfi`, `IPrint`, `IIf`, `IWhile`, `IVariant`, `IMatch`) wrote *correct,
   intentional* 2-statement bodies (a side-effecting call, then the real
   result) directly as two trailing forms — e.g. `(IPrint d7 (ri-infer-expr
   ri d7) (RR RStack None))` — without realizing the same grammar rule above
   applies: `d7` binds fine, but the first body statement `(ri-infer-expr ri
   d7)` (a call — i.e. "nested pattern" shaped) got treated as a *second
   bound field* of `IPrint`, which per `icnf.zyl`'s `deftype Icnf` really
   has only 1 payload field. Same OOB-read-off-the-end-of-the-struct bug,
   this time additionally **misdirecting** which value gets passed to the
   arm's (correctly, separately) lifted `_npmatch_NNN` helper — the bogus
   OOB-read value stood in for the real last-bound field. Fixed by wrapping
   each arm's 2-statement body in `(begin ...)` so the grammar sees exactly
   one trailing body form, matching the working convention used everywhere
   else in this file (`ISet`, `ILet`, etc., which already had single-body-form
   arms and were never affected).

After both fixes: `stage2.bin` (self-hosted-codegen'd machine code) compiles
the trivial `(defn main () (print "hi"))` repro to completion (no crash),
and — far more importantly — compiling its own full bundled source no
longer segfaults either.

**Bonus fix, found while verifying the actual self-hosting fixed point**:
`icnf.zyl`'s `ic-fresh-id` (used to name lifted match-arm/lambda helper
functions, e.g. `_npmatch_<id>`) returned a raw heap pointer
(`arena-alloc-zeroed arena 1`) as the "unique id". Pointers are **not**
deterministic across process runs (heap/arena base address varies), which
broke run-to-run reproducibility of `stage2.bin`'s own output — confirmed by
running the identical binary on the identical input twice and diffing
(`f__npmatch_<pointer1>` vs `f__npmatch_<pointer2>`, otherwise byte-identical).
Fixed by returning `(arena-used arena)` instead — the bump allocator's byte
offset from the arena's own base, still monotonically increasing/distinct
per call, but invariant across runs.

**Verification of the actual self-hosting fixed point** (via the legacy
`/tmp/zyl_boot_in.zyl` → `/tmp/zyl_boot_out.s` protocol, since `boot.sh`'s
argv/`-o` CLI plumbing in `driver.zyl` is still a stub — a separate,
pre-existing, unrelated gap, not touched here):
- `stage1.bin` (cc-linked from the committed `build/boot/stage2.s` seed)
  compiling `selfhost/zyl_selfhost_compiler.zyl` reproduces that seed
  **byte-for-byte**.
- `stage2.bin` (same seed, re-linked) does too — **stage2 == stage3
  confirmed, true fixed point reached**, and the same binary run twice on
  the same input is now byte-identical (the `ic-fresh-id` fix).
- Re-seeded `build/boot/stage2.s` to this actual fixed point (previously
  committed seed was only one Rust-cross-compile pass away from a stable
  fixed point, one iteration short — a pre-existing gap, since nothing
  before this session had gotten far enough for `stage2.bin` to even run
  without segfaulting).
- `run_regression_tests.sh --full --no-boot`: all green through the
  already-known-slow `integration/selfhost-codegen` cutoff (unchanged/
  pre-existing, not a new regression).
- Smoke: `(print (applyit dbl 21)) (print (+ 1 2))` compiled by `stage2.bin`
  and run → `42` / `3`, correct.

**Still open (separate, pre-existing, out of scope here)**: `driver.zyl`
has no real argv/CLI support (`-o`, positional source path, `--emit-asm` are
all silently ignored; it always reads `/tmp/zyl_boot_in.zyl` and writes
`/tmp/zyl_boot_out.s`), so `boot.sh`'s normal (non-`--bootstrap-from-rust`)
flow still can't run end-to-end yet. Worth a follow-up session — this is
purely a missing-feature gap in `driver.zyl`, not a correctness bug.
*Status:* argv CLI support landed in the next entry (`4231955`).

## Session (2026-09-15) — stage1.bin self-compiles its own bundled source

stage1.bin now correctly self-compiles its own bundled source end-to-end
(major milestone; commit `8ad47c5`). Full list of bugs found and fixed,
roughly in the order hit:

1. **`region_inference.zyl` had systematic `IFn`/`IIf`/`IWhile`/`ISet`/
   `ILet`/`ISeq`/`IMatch` arity mismatches** in `ri-infer-expr` and
   friends — off-by-one extra leading capture vars vs the real 3-field
   `Icnf.IFn`/2-field `IWhile`/etc, apparently left over from an earlier,
   richer Icnf shape that no longer exists. Reading adjacent heap memory
   as bogus extra fields. Fixed every mismatched arm to the real arities.
2. **`region_inference.zyl`'s `env-get-cur` referenced a free variable
   `env`** that wasn't one of its own parameters (only `binds`/`name`
   were) — undefined-identifier compiles to a garbage sentinel, crashing
   the moment a `let` inside any function needed to look up a parent
   scope. Fixed by threading `parents` through explicitly.
3. **`ri-infer-seq-loop`/`ri-infer-args-loop` passed recursive args in
   the wrong order** (`(ri-infer-seq-loop rest (ri-infer-expr ri ic)
   result)` instead of `(ri-infer-seq-loop ri rest (ri-infer-expr ri
   ic))`) — corrupted region-inference state for any `begin`/multi-arg
   call, in any function.
4. **`type_inference.zyl`'s `TypeInferer` struct grew from 11 to 20
   fields at some point, but ~10 constructor call sites across
   `infer-expr-let`/`infer-expr-if`/`inferer-bind-params`/
   `inferer-bind-for-vars`/`infer-expr-match-arms`/`lookup-body-cache`/
   `insert-body-cache` were never updated** — some supplied only 11 args
   (missing the last 9 fields entirely), others had stray garbage tokens
   apparently left over from a botched migration (extra `Nil`/`(tc-new)`
   args bleeding into the *next* function call's argument list). Any
   `let`, `if`, `for`, `match`, or cached function body anywhere in a
   real program triggered this — i.e. every real program. Fixed all
   call sites to supply the real 20 fields via their own accessors.
5. **`type_inference.zyl`/`monomorphization.zyl` confused `ADTVariant`/
   (`AV` name `(List String)` of raw type-display strings, from
   `expr_inner.zyl`, EDeftype's actual shape) with the unrelated, never-
   actually-produced `Variant`/`Field` (`V`/`F`, from `type_system.zyl`)
   — a same-arity (2-field) tag collision, so matching `V`/`F` against
   real `AV` values "worked" structurally but silently misread a field-
   type string's raw bytes as if it were an `F` struct's pointers,
   segfaulting the instant type inference reached a real generic ADT
   (e.g. core/list.zyl's `List T`). Fixed `extract-generic-params-loop`,
   `populate-variant-to-adt`, `infer-find-variant-fields`,
   `find-variant-fields`, `infer-constructor-args`,
   `adt-variants-to-fields` to match `AV` and treat fields as raw
   strings directly (no `F`/`fname`/`ftype` unwrap needed).
6. **Duplicate `deftype Region`** in both `type_system.zyl` (dead,
   unused) and `region_inference.zyl` (the real one) — harmless when
   Rust-compiled, but a hard `E_DUPLICATE_VARIANT` panic the moment
   stage1.bin tried to compile its own bundled source (both files
   concatenated into one namespace). Removed the dead duplicate.
7. **Rust bootstrap register-clobbering bug in `str-concat`/`str-equal`/
   `str-substring`'s special-cased intrinsic codegen** (`src/
   codegen.rs`'s `emit_call_direct`): loaded arg0 directly into its
   fixed ABI register (e.g. rdi) *before* evaluating arg1, and arg1's
   evaluation can itself contain a call (e.g. `(str-concat "stdlib/"
   (str-concat name ".zyl"))`) — every call clobbers every caller-saved
   register per the SysV ABI, silently discarding arg0's value with no
   diagnostic. This was the actual root cause of module_resolver.zyl's
   "core/core.zyl" path resolving to garbage and stage1.bin
   mysteriously re-reading its own input file for "module content".
   Fixed via a new `emit_args_into_abi_regs_safely` helper (spill every
   arg to its own scratch stack slot before loading any into a
   register), reused for all three intrinsics.
8. **`assemble.py`'s structural-form output (one paren/token per line)
   made stage1.bin crash while parsing its own ~690KB source**, purely
   from *whitespace volume* (confirmed empirically: collapsing all
   whitespace in an otherwise-identical file made the exact same crash
   disappear). Root cause not fully fixed (tracked as follow-up below):
   `stdlib/compiler/lexer.zyl`'s whitespace-skipping path bounces
   between `lex-loop` and `lex-c1` (mutual recursion, not a single
   self-tail-recursive loop), and the Rust bootstrap's TCO apparently
   only reliably eliminates a restricted set of tail-call shapes — this
   mutual hop leaks a real stack frame per whitespace character. gdb
   confirmed the crash's rbp had descended to within ~64KB of the very
   bottom of the 64GB worker-thread stack (`zyl_call_on_big_stack`) —
   genuine, enormous, whitespace-proportional recursion, not corruption.
   **Mitigation applied** (per explicit instruction: "get it working for
   now, document as needed fix for later"): `assemble.py` still
   generates structural form for its own reliable paren-balance
   verification pass, then collapses every whitespace run down to a
   single space before writing the final `zyl_selfhost_compiler.zyl` —
   same token stream, ~2.5x fewer characters, comfortably clear of
   where this was observed to crash. **Root-level fix still needed**:
   make `lexer.zyl`'s whitespace-skip genuinely O(1) stack (true self-
   tail-recursion within one function), or teach the Rust bootstrap's
   TCO to eliminate this specific mutual-hop shape.
9. **Rust bootstrap 32-bit truncation of large integers, three separate
   spots in `src/codegen.rs`**:
   - `emit_const_into`'s `Atom::Int` case only sign-extended *negative*
     literals to 64-bit (`mov r64, imm`); any positive literal ≥ 2^31
     used a 32-bit `mov r32, imm`, silently truncating (GAS just keeps
     the low 32 bits) — `123456789012` came out as `-1097262572`.
   - `emit_int_to_str` (the runtime `print`-an-integer conversion) used
     32-bit `eax`/`ebx`/`ecx`/`idiv ebx` throughout — any integer needing
     more than 32 bits printed wrong once the division loop truncated it.
   - `emit_condition_inline`'s general `BinOp` comparison case (the
     `(if (< a b) ...)` fast path) loaded both operands into 32-bit
     `ecx`/`edx` before comparing — a large value reinterpreted as
     negative 32-bit could make `(if (< n 10) ...)` wrongly take the
     "true" branch for `n` in the billions, breaking any recursive
     function that compares a large parameter against a small constant
     (e.g. int-to-string implementations, hash functions, ID counters).
   This 3rd one was the ACTUAL blocker for `icnf.zyl`'s `ic-fresh-id`
   (uses a large arena address as a "guaranteed unique" id for naming
   lifted match-arm helper functions) — large addresses' `<` comparisons
   against small thresholds elsewhere in generic numeric code were
   silently wrong, eventually producing colliding/duplicate helper
   names and an assembler "already defined" error. Fixed all three to
   use full 64-bit registers throughout.

**Result**: after all of the above, `build/boot/stage1.bin` (Rust-
bootstrapped) now runs `python3 selfhost/assemble.py` bundle
(`selfhost/zyl_selfhost_compiler.zyl`, its own full source) through
every phase — parse, bridge, modules, macros, type-infer, contract-
injection, mono, trait-dispatch, closure-inline, assert-lowering, lower,
optimize, region-infer, codegen — to completion (exit 0), and the
resulting `build/boot/stage2.s` links successfully into a runnable
`stage2.bin`. **This is the first time the self-hosted compiler has
correctly compiled its own complete bundled source.**

**Not yet fixed — stage2.bin itself has a distinct, separate bug**:
running `stage2.bin` (i.e. code generated *by* the self-hosted
`codegen.zyl`, as opposed to `stage1.bin`'s Rust-generated code) on even
a trivial input (`(defn main () (print "hi"))`, which still auto-injects
core/core same as any program with no `use` lines) segfaults inside
`Expr.inner` (a null/bad-pointer struct-field read), reached through
deep (~70-100+ frame) recursion in `collect-definitions`. Not yet root-
caused: could be an actual logic bug reached only through self-hosted-
generated code (i.e. `codegen.zyl` and `codegen.rs` don't produce
behaviorally identical output for some construct exercised along this
path), or something else entirely — the visible recursion depth (~100
frames) is nowhere near enough on its own to exhaust even a modest
stack, so this does NOT look like the "missing TCO" class of bug once
you check `codegen.zyl` for tail-call handling and find it has **none
at all** (grep for "TCO"/"tail-call" in `stdlib/compiler/codegen.zyl`:
zero hits) -- worth confirming directly whether this specific crash is
starved by that gap or is a separate, unrelated bug before doing any
deeper work here. This is the next blocker standing between "stage1
compiles itself" (now working) and full self-hosting fixed point
(stage2 producing byte-identical-behavior stage3 output, `boot.sh`'s
actual pass condition).

*Status:* the stage2.bin crash was fixed in the "continued further"
entry above (`50d6b6f`). The lexer whitespace root fix (item 8) is still
open; `assemble.py` still collapses whitespace.

## Session (2026-09-15, continued) — duplicate-symbol collisions and the IFn/IFS mismatch

**stage1.bin self-hosted segfault: root-caused two duplicate-symbol collisions and one more deep-match codegen bug; bootstrap now gets much further.**

Followed up on the "remaining blocker" from the previous entry below
(`build/boot/stage1.bin` segfaulting nondeterministically) by bisecting
with `gdb` down to a **minimal repro**: `(defn main () (print "hi"))`
segfaults `stage1.bin` deterministically and immediately (the earlier
"nondeterminism" was illusory — different inputs just die at different
points in the same broken pipeline, not true memory corruption).

Root causes found via gdb (breakpoint on the crashing call target, inspect
register/tag values, cross-reference against the source's `match` arms
and `deftype` declarations):

1. **`stdlib/compiler/contract_injection.zyl` was never added to
   `selfhost/assemble.py`'s bundle file list** (missed when the module was
   ported — commit `33235c4`). It independently defines
   `ci-expand-program(exprs)` (1-arg), which collides by name with
   `closure_inline.zyl`'s unrelated `ci-expand-program(arena, prog)`
   (2-arg). `driver.zyl`'s contract-injection pipeline step called
   `(ci-expand-program exprs)` expecting the 1-arg version, but since that
   module was never assembled in, it silently linked against
   closure_inline's 2-arg function instead — an arity-mismatched call
   feeding garbage through the unset second argument register. Worse:
   `contract_injection.zyl` itself doesn't even compile correctly if
   added — it references accessors/constructors (`d-name`, `t-name`,
   `TestNode`, ...) that don't match the real `DefnNode`/`TestDecl`/
   `TestSuiteNode` shapes in `expr_inner.zyl` (written against a stale
   data model, never finished). Fix: leave it out of the bundle, make
   `driver.zyl`'s contract-injection step an explicit identity
   pass-through (`(let ci-exprs exprs ...)`) instead of accidentally
   calling the wrong function.
2. **`populate-variant-to-adt` defined in both `monomorphization.zyl`
   (2-arg) and `type_inference.zyl` (3-arg)** — same collision class.
   Renamed monomorphization.zyl's copy to `mc-populate-variant-to-adt`.
3. **`list-nth` defined in both `type_inference.zyl` and
   `monomorphization.zyl`** with different failure semantics (silent
   `TVar` sentinel vs. loud `zyl_f_error`/`E_LIST_NTH_OOB`) — same
   collision class. Renamed type_inference.zyl's copy to `ti-list-nth`.
4. **`ic-collect-vt-run` (icnf.zyl) and `opt-optimize-fns`
   (optimization.zyl) both had a 3-level nested match** (matching one
   value, then a field of it, then a helper call's result) — the same
   Rust-bootstrap codegen hazard documented in the previous session's
   entry below (silently returns a bogus `-1` sentinel instead of the real
   result). Split both into flat top-level helper functions
   (`ic-collect-vt-inner`/`ic-collect-vt-deftype`,
   `opt-optimize-fns-ifs`) to dodge it.

**Net effect:** `build/boot/stage1.bin` used to crash inside
`ic-collect-vt-run` on essentially any input. It now progresses through
parse → bridge → modules → macros → type-infer → contract-injection →
mono → trait-dispatch → closure-inline → assert-lowering → lower →
optimize before crashing during region-infer, in a **currently
undiagnosed tag-mismatch** inside `opt-optimize-fns`'s dispatch on
`ICNFFuncSig` (a single-constructor type — its sole arm didn't match at
runtime, tag was neither the expected `Cons`/`Nil` values for the
enclosing `List` either; suspect a monomorphized `List` instantiation
getting a different tag numbering than the hardcoded `cmp` immediates
expect, but not yet confirmed). This is a new, narrower, and much better
understood problem than the vague "nondeterministic segfault" reported
previously — worth another dedicated debugging pass.

Verification after each fix: `./target/release/zyl
selfhost/zyl_selfhost_compiler.zyl --emit-asm` still completes all 9
phases cleanly, and `./run_regression_tests.sh --full --no-boot` is still
green through every test up to the already-known-slow
`integration/selfhost-codegen` (which the runner's timeout doesn't reach —
matches pre-existing documented behavior, not a new regression).

Given how many of these bugs stem from *silent* same-name/different-arity
collisions across `stdlib/compiler/*.zyl` files that only bite once every
file is bundled together, a standing lint (`grep`-based duplicate-`defn`-name
scan across `selfhost/assemble.py`'s file list, ignoring string/comment
false positives) would be worth adding to catch the next one before it
costs another multi-hour bisection.

**Follow-up (same session): two more bugs found, `stage1.bin` now runs to
completion on the minimal repro but still emits incomplete output.**

Kept bisecting past the `opt-optimize-fns`/`ICNFFuncSig` tag-mismatch
noted above:

5. **The `-1` sentinel was itself a red herring from a *third* collision**:
   `opt-optimize`'s `(match fns (IP fns2 stmts ...) (d1 ...))` dispatches
   purely on the tag byte at offset 0 with no runtime type identity. `IP`
   (`ICNFProgram`'s only constructor) always has tag 0 — which is *also*
   `List`'s `Cons` tag (`(deftype List (Cons T (List T)) Nil)` — Cons
   declared first). `driver.zyl`'s only caller of `opt-optimize` always
   passes the raw `(List IFn)` from `ic-program`, never an actual `IP`
   value, so any non-empty list was silently misinterpreted as an `IP`
   struct (its head/tail cells reinterpreted as `fns2`/`stmts`) — the real
   source of the `ic-collect-vt-run`/`opt-optimize-fns` crashes chased
   above. Fixed by always calling `opt-optimize-fns` directly (see commit
   after `b29e2c6`).
6. **`opt-optimize-fns-ifs` (the split introduced to dodge the deep-match
   codegen bug) took 7 arguments** (`os rest name params ret_type
   opt-body result_id`). The bootstrap has a documented arity <= 6 limit
   (see `lexer.zyl`'s own comments: "arity <= 6"). Exceeding it silently
   miscompiled the function — no error, but the whole functions list
   collapsed to `Nil` by the time it reached codegen. `stage1.bin` would
   run to completion and report success while emitting an assembly file
   missing every function body. Fixed by pre-building the `IFS` struct
   once in the caller and passing it as a single argument (3 args total).

After both fixes, `stage1.bin` runs the minimal `(defn main () (print
"hi"))` repro **to completion (exit 0)** instead of segfaulting, and
writes `/tmp/zyl_boot_out.s` — real forward progress. But the output is
still missing the function body (just the `main` -> `zyl_call_on_big_stack`
entry stub, no `f_main`). Root cause, confirmed via gdb inspecting the
actual heap struct tags: **`ic-program` (icnf.zyl) produces a `(List
IFn)`** — `IFn` = `(String, List String, Icnf)`, 3 fields, tag varies
(observed tag 15 in one instance) — **but `opt-optimize-fns` pattern-matches
for `IFS`/`ICNFFuncSig`** (`type_system.zyl`) — `(String, List (Pair
String Type), Option Type, List ICNFNode, Int)`, 5 fields, single
constructor always tag 0. These are two completely different, unrelated
data shapes from different modules that happen to share a superficial
"function record" role. Since a real `IFn`'s tag never equals 0, it never
matches `opt-optimize-fns`'s `IFS` pattern, so every function silently
fails to match, falls through the recursion, and the list winds up empty
by the time codegen runs. **This means `optimization.zyl`'s
`opt-optimize`/`opt-optimize-fns` has probably never correctly processed
real pipeline output** — masked all along by the tag-collision bug fixed
in item 5 above (which meant this code path was never actually reached
for non-trivial input before now). Needs a proper fix — either rewrite
`opt-optimize-fns` against the real `IFn`/`Icnf` shapes, or add an
explicit `IFn` -> `IFS` conversion step in the driver pipeline before
optimization — rather than another quick patch. This is the next concrete
blocker for a working self-hosted `stage1.bin`.
*Status (2026-09-23):* `optimization.zyl` was rewritten against the real
tree-shaped Icnf on 2026-09-17 (`7872a63`) and is in the pipeline. For
duplicate names, `assemble.py` now drops repeated `defn`s
(`deduplicate_defns`), `duplicate_check.zyl` rejects duplicates within one
program (`E_DUPLICATE_DEFINITION`), and the package system gives
same-named definitions in different modules distinct keys.

Verified after every fix in this follow-up: `./target/release/zyl
selfhost/zyl_selfhost_compiler.zyl --emit-asm` still completes cleanly
(takes ~2 minutes now — this is pre-existing Rust-bootstrap slowness on
the ~690KB self-host source, not a regression; see the already-documented
"Rust bootstrap too slow for test runner" note elsewhere in this file),
and `./run_regression_tests.sh --full --no-boot` is still green through
every test up to the already-known-slow `integration/selfhost-codegen`.

## Session (2026-09-15) — paren-imbalance corruption sweep

**Paren-imbalance corruption sweep: `--emit-asm` via Rust bootstrap now works end-to-end again.**

`./target/release/zyl selfhost/zyl_selfhost_compiler.zyl -o out --emit-asm` had
regressed to failing partway through with undefined-symbol link errors
(`_ZYL_d1`, `_ZYL_eq`, etc.). Root cause was **not** a Rust codegen
regression as first suspected, but function-level paren mis-nesting inside
several `stdlib/compiler/*.zyl` files, present since the Hindley-Milner port
(`452e016`) and invisible to `selfhost/assemble.py`'s per-file global
depth-zero check (individual function errors can cancel out file-wide).
Wrote a per-defn-boundary paren-depth-drift analyzer to find them.

Fixed in `stdlib/compiler/type_inference.zyl`, `type_system.zyl`,
`monomorphization.zyl`, `codegen.zyl`, `region_inference.zyl`,
`optimization.zyl`, `selfhost/driver.zyl` (see commit `50c6a97` for the full
list). Notable non-paren bugs found along the way:

- Duplicate hyphen/underscore-case `extract_constructor_mapping` /
  `extract_mapping_loop` definitions in `type_inference.zyl` — `sanitize_name()`
  collapses both to one symbol → dup-symbol link error.
- `/=` used as "not equal" in `optimization.zyl` BNeq const-folding (real
  operator is `!=`), 3 occurrences.
- `ri-union-regions` in `region_inference.zyl`: unwrapped match arms + wrong
  `Pair` arity — genuine logic bug.
- `opt-dce-recurse-loop` had a redundant `(if (eq inner ICBegin) ...)` wrapper
  around an already-exhaustive match; `eq` isn't a defined function here.
- **Confirmed real Rust codegen bug** in `src/icnf.rs` (near commits
  `282df18`/`a509882`): a catch-all match arm shaped `(d1 BODY)` with a bare
  literal `BODY`, nested 3+ levels deep inside other matches, miscompiles into
  `call _ZYL_<boundvar>` instead of treating the binding as unused. Not fixed
  at the source — worked around per-callsite by refactoring deep match chains
  into separate top-level helper functions (`params-equal`,
  `extract_mapping_loop`, `opt-optimize-program`). Other unaudited deep
  matches may hit this later; a real fix belongs in `src/icnf.rs`'s
  catch-all/`is_catch_all` codegen path.

Result: `--emit-asm` completes all 9 phases and links a valid ELF binary with
the Rust-built `zyl`, with no undefined-symbol errors. `cargo build --release`
confirmed clean.

**Remaining blocker (not fixed): self-hosted bootstrap still fails.**
`./boot.sh --bootstrap-from-rust` builds stage1 fine (Rust-compiled), but
running `build/boot/stage1.bin` on `selfhost/zyl_selfhost_compiler.zyl` (the
self-hosted compiler compiling itself) **segfaults nondeterministically** —
crash point varies between runs (sometimes progresses through
parse/bridge/modules/macros/type-infer/contract-injection per `/tmp/dbg`
before crashing, sometimes crashes right after "parse"). This points to
memory corruption / uninitialized memory / an allocator bug in the
self-hosted runtime, distinct from the paren-imbalance issues above and not
yet root-caused. Until this is fixed, stage2.s/stage2.bin cannot be rebuilt
via self-hosting and the self-hosting fixed point cannot be re-verified.
*Status:* resolved by the later 2026-09-15 entries above.

## Session (2026-09-13) — error system Phase 1: error codes and reports

**Native error system Phase 1 modules landed (`error_codes.zyl`, `error_report.zyl`).**

`stdlib/compiler/error_codes.zyl`: 52-code catalog (`ErrorCode` = `(EC name
String phase Int severity Int message String)`), `error-codes`, `ec-name` /
`ec-phase` / `ec-severity` / `ec-message`, `ec-contains`, `ec-lookup`
(`ErrorFind found/code`), `ec-count`. Mirrors `src/error.rs` + self-hosted
extras (`E_UNBALANCED_PARENS`, `E_MATCH_ARM_COMPLEX`, `E_DUPLICATE_VARIANT`,
`E_CODEGEN_BUFFER_LIMIT`, `E_LIST_NTH_OOB`,
`E_TOPLEVEL_STMTS_WITH_EXPLICIT_MAIN`). Verified: count 52, lookups resolve,
bogus name → found 0, phases/severities correct.

`stdlib/compiler/error_report.zyl`: `ErrorLocation` (Int-first field order),
`ErrorSnippet`, `int-to-str` (table-slice digits, zero-ffi/arena), `space-run`,
`pointer-line`, `make-loc`, `el-path`/`el-line`/`el-col`, `loc-string`,
`err-header`, `make-snippet`, `es-col`/`es-line`, `arrow-line`. Verified via
str-eq probes: `int-to-str` 0/7/52/1024, pointer-line cols 1/3, loc-string
`tests/example.zyl:12:4`, header, arrow — all correct.

Two more Rust-bootstrap codegen constraints discovered and encoded in
`error_report.zyl`:

- **Inline `zyl_cstr_concat` with a call operand (especially 2nd position)
  miscompiles**; nested concat chains too. Rule: every `str-concat` takes only
  pre-bound lets/literals; all intermediate values go through `let`. (The
  self-hosted compiler calls the real `str-concat` body, so this is
  belt-and-braces — but it keeps every result provable via `str-eq`.)
- **String-first fields in a `make-variant` record mis-layout** — reading a
  later Int field yields garbage. Put Int fields first (like `CheckState` in
  `sexp_balance.zyl`); `EL` is `(line Int col Int file-path String)`.

## Session (2026-09-13) — native S-expression balance validator

**Native S-expression balance validator works (Rust bootstrap, `stdlib/compiler/sexp_balance.zyl`).**

The phase A.8 error-system first milestone: `sexp_balance.zyl` now correctly
classifies all nine smoke cases (`(` unbalanced; `(a (b (c)))` balanced; `)`
unbalanced; `(]` mismatched; `()`/`[]{}`/`; (comment (`/`(a(b)())` balanced;
`(a (b c)` unbalanced). Compiles clean (Phases 1-9) via the Rust bootstrap and
verifies through the `/tmp/sbtest.zyl` module harness.

Root causes found and fixed in the rewrite:

- **Duplicate variant names break `match` dispatch** — all four `BalanceResult`
  variants were named `BR`, so the first arm always matched and every input
  reported "balanced". Distinct variant names (`Balanced`, `UnbalancedOpenString`,
  `UnbalancedClose`, `MismatchedPair`) required.
- **Rust-bootstrap Bool fields in record ctors mis-store** — `False`/`True`
  literals in a 9-field `CheckState` ctor compiled to non-zero box pointers, so
  every flag read back truthy (everything entered "in-string").  Flag fields
  converted to `Int` 0/1; literal `0`/`1` store correctly (line/col Ints always
  did). Rule: prefer `Int` 0/1 over `True`/`False` in record fields.
- **ffi-call results type as fresh type vars** (`src/type_inference.rs:1513`) —
  a `zyl_cstr_from_int` result is typed `Int`, so `print` emits the int path and
  prints a raw pointer. CLI reports must print string literals + Int values only.
- **`zyl_cstr_byte_at(ptr, i)`** (not `ffi-call "zyl_cstr_to_int"`) is the correct
  char-byte primitive; `zyl_cstr_from_int` segfaults with a null arena.
- **ffi-call trailing `1000`** is the FFI timeout parameter (mirrors
  `icnf.rs timeout: 1000`).

Known Rust-bootstrap gaps recorded for the driver work: `zyl_argc()` always
returns 0 (`zyl_save_args` defined in `runtime/actor_runtime.c` but never
called), so CLI `main` argument reading is dead under the Rust bootstrap; the
self-hosted driver must consume `BalanceResult` fields directly instead of
relying on `zyl_arg_str`.
*Status:* the entry stub calls `zyl_save_args` since 2026-09-15
(`4231955`), and the Rust bootstrap is no longer in the build path.

## Session (2026-09-12) — match exhaustiveness in the Rust bootstrap

**Match exhaustiveness enforced at compile time (Rust bootstrap).**

`src/icnf.rs` now checks, at ICNF generation, that every variant of the
matched ADT has an arm (`check_match_exhaustive`, called from the
`ExprInner::Match` handler). A match missing a constructor fails with
`E_MATCH_NONEXHAUSTIVE` listing the absent variant(s); a catch-all arm
(`(_ body)` wildcard, or any arm whose head names no constructor of any
deftype, e.g. the `(d2 ...)` fallback) explicitly satisfies the check.
Monomorphized scrutinee names (e.g. `Shape_Float`) fall back to whichever
deftype's variant list covers every arm. Nested-desugar matches (generated
by `desugar_arm_raw`) enumerate all variants and remain green.

New harness capability: `tests/compile-fail/*.zyl` are "must-fail"
regressions — compilation must fail or the test is marked failed
(`run_fail_test`). Added `match-non-exhaustive.zyl` (missing `Triangle`
arm) and `match-nested-non-exhaustive.zyl` (nested match omitting `Rect`).
Positive coverage in `regression/match-exhaustive.zyl` unchanged.

Full suite: **43/44** (only the pre-existing `integration/selfhost-codegen`
Rust-bootstrap timeout fails; it passes under the self-hosted compiler and
`boot/fixed-point` stays green).

Note: the earlier in-flight refactor (restructured `MatchPattern`, added
`MatchPattern::Identifier`, reworked arm parsing) was a regression against
a green baseline — combined-syntax arms like `(Circle r (* r r))` already
functioned via `decompose_match_arm`. It remains preserved in `stash@{0}`
but is not needed for exhaustiveness.

## Session (2026-09-11) — compiler library packaging

**Compiler library packaging fixed.** The Rust compiler now embeds all
stdlib modules and the actor runtime/header at build time. Installed `zyl` and
`zyl-repl` no longer depend on the repository checkout or the caller's
working directory for standard-library resolution or runtime linking. Core
(`core/core`, including Option, Result, and List) is an automatic prelude;
testing and other non-core libraries remain explicit imports.

The self-hosted `zyl-self` wrapper now packages its own `stdlib/` bundle and
actor runtime, runs from that bundle directory, and works outside the
repository. The bootstrap fixed-point check and an external self-hosted
allocator test both pass. Its resolver also injects the core prelude by
default while recognizing the bundled bootstrap marker to avoid duplicate
definitions during self-compilation.

Verified with a compiler invoked from `/tmp`, embedded `core` and
`allocator` programs, and `./run_regression_tests.sh --quick --no-boot`
(6/6).

---

## State snapshot (2026-08-27 to 2026-09-10, historical)

This was the "Current State" section until 2026-09-11. It describes the
Rust-bootstrapped build of that time; see **Current State** at the top
for today.

**Self-hosting: COMPLETE, deterministic, verified. Regression suite: 27/27**
**in `--full` (all tests pass; `integration/selfhost-codegen` passes when**
**compiled with the self-hosted compiler — Rust bootstrap is too slow to**
**compile it within test timeout).**

```
./boot.sh    # stage1 -> stage2 -> stage3; stage2 output == stage3 output
```

**Session (2026-09-06): two Rust-compiler codegen fixes, two tests green.**

1. **`unit_test` option-flatmap SIGSEGV (exit 139) fixed** — root cause:
   codegen's C-helper alignment pattern `mov r15, rsp / and rsp,-16 / call /
   mov rsp, r15` assumed r15 survives the call. It survives pure C helpers
   (SysV callee-saved) but `zyl_callN` dispatches into Zyl-generated code,
   whose own nested align block uses r15 as scratch, clobbering the outer
   save. Verified in gdb: after `zyl_call1` rsp was correct but r15 had been
   overwritten with the inner dispatch's frame offset; `mov rsp,r15` tore the
   stack and the match join's `add rsp,+pop rbp;ret` jumped to 0xa.
   Fix in `src/codegen.rs`: every align site now stashes the pre-call rsp in
   a dedicated **rsp-stash slot at the bottom of every frame**,
   `[rbp-(spill_frame.max(256)+8)]`, instead of r15. All frames (main, user
   fns, closures) extended uniformly by 8 bytes to reserve the slot — TCO's
   uniform-frame invariant is preserved. Wrapper frames (`_ZYL_actor_*`,
   spawn/send) use `wrapper_stack+8` via a temporary `spill_frame` override
   so their bodies' align sites point at their own slot. Slots are LIFO-safe
   (callee frames grow strictly below the current rsp and can never
   underflow the stash) and spill/param slots never collide with it.
2. **`regression/types` link failure (`_ZYL__t_Some` undefined) fixed** —
   constructor calls to underscore-prefixed ADT variants (`_t_Some`,
   `_t_None`) were never lowered to `MakeVariant`: the PostProcessor's
   constructor-detection guards required `is_uppercase_ident` (first char),
   which fails for `_t_*` names even though they are registered, known
   variants. Relaxed the three guards (`Call`, bare-ident unit variants,
   `Apply`) in `src/ast.rs` to also fire when `find_adt_for_variant` matches,
   matching the documented "Priority 1: known ADT variant converts regardless
   of builtin exclusion".

**Verified (with `ulimit -c 0`):** `unit_test`, all of `regression/*`,
`stress/*` (incl. deep-recursion, balanced-parens), `integration/*` (incl.
selfhost-codegen with self-hosted compiler), and `boot/fixed-point` all pass.
Selfhosted compiler unchanged (`stdlib/compiler/codegen.zyl`, `selfhost/` have
no r15 pattern).

### Known Limitations
- **`integration/selfhost-codegen` (pre-existing, now fixed)** — the test runs the
  selfhosted parser+icnf+codegen on a tiny in-memory source; it passes when
  compiled with the self-hosted compiler (`build/boot/zyl-self`) but the Rust
  bootstrap is too slow to compile it within the test runner's timeout. This
  is a Rust bootstrap performance issue, not a correctness bug.
  `boot/fixed-point` exercises the same path and remains green.

**Session (2026-09-10): Book documentation verity pass.**

1. **`book/src/part1/ch13-project-walkthrough.md` rewritten from scratch** — the
   old walkthrough used non-existent APIs (`string-split`, `vec-slice`,
   `string-join`, `list-literal`, struct-carrying `ProcessorMsg` actors) and
   would not compile. The new chapter is a single-file **log processor** built
   exclusively from constructs verified at runtime against `./target/debug/zyl`
   (recursive tokenizer over `str-substring` + arena `str-intern`, recursion
   with 4 Int accumulator args, `Stats` struct assembled once at the end,
   built-in `file-open`/`file-read`, built-in test harness). Every code block
   was re-extracted from the chapter text and recompiled, reproducing the real
   output (`Total:4 Error:2 Warn:1 Info:1` on `sample2.log`).
2. **New runnable example project**: `book/examples/log-processor/`
   (`log-processor.zyl`, `log-processor-tests.zyl` — 4/4 tests pass,
   `sample.log`).
3. **Verified current-bootstrap behaviors documented honestly** (ch13 notes):
   modules resolve relative to the compiler's CWD (build from repo root);
   user modules outside stdlib are not resolvable (single-file programs only);
   `{ }` brace blocks in `use` are invalid; `str-eq` returns `Int` 0/1;
   `print` writes each argument on its own line; `str-substring` returns
   scratch-buffer pointers (must `str-intern`); `struct-get` requires a
   pre-bound struct; structs passed through stacked recursion mis-stage
   (counts double) — use Int args; `(list ...)` literal is unimplemented
   (`_ZYL_list` link error); `vec-push` in `while`+`set!` segfaults;
   `(run-tests)` suppresses `main`; the test harness mis-stages the *first*
   token-operations run under it (order tests so simple ones run first);
   actor `spawn`/`send` value staging is broken (actor variant presented as
   a design sketch, not runnable code).
4. **`book/src/appendix/appendix-b-stdlib.md` recovered and fixed** — the
   working-tree copy (richer uncommitted revision) was accidentally reverted
   during this session (`git checkout`); no git object held it, so it was
   reconstructed from the in-session read, then re-synced. All `(use core {
   ... })` brace blocks converted to bare `(use core)` + `;` comment
   inventories (brace form is a parse error).
5. **`book/src/part1/ch11-testing.md` §11.3** — build command corrected to
   `zyl test-file.zyl -o test-file` then `./test-file.bin` (no `-o` yields
   `a.out.s` / `a.out.bin`, not `test-file.bin`); notes CWD-relative module
   resolution.
6. **`book/book.toml` fixed for the installed mdbook** — removed unknown keys
   (`copy-fonts`, `theme`, `curly-quotes`, old `[output.html.css]` section,
   `fa-github` icon) that failed the whole HTML backend; `mdbook build` now
   completes with zero warnings (also fixed `<t>`/`<mutex>` HTML-tag warnings
   in ch17/ch21 by backticking `TCap<T>` headings and `Arc<Mutex>`).

**Known limitations recorded in the book (2026-09-10):**
- Runnable actor example blocked on `spawn`/`send` message-staging fix.
- Multi-file user modules blocked (confirmed unsupported).
- Test-harness first-use token-operation mis-staging: keep harness tests free
  of token ops, or order simple tests first.

*Status (2026-09-23):* multi-file user programs are supported through the
package system (spec §31, `tests/packages/`). There is still no `receive`
form, and the `(list ...)` literal is still unimplemented (it fails at
link time). The other book notes were recorded against the Rust
bootstrap and have not been re-checked individually.

**Self-hosting: COMPLETE, deterministic, verified. Regression suite 182/182 (unit_test) + 6/6 smoke.**

```
./boot.sh    # stage1 -> stage2 -> stage3; stage2 output == stage3 output
```

The Zyl compiler written in Zyl compiles itself end-to-end with a strict
byte-identical fixed point. Generic ADTs instantiate correctly with any
concrete type (per-site instantiation, positional instance naming);
per-site polymorphic functions work cross-module (shared list helpers
replacing per-module duplicates).

**Session (2026-08-27):**
- **Phase 1: Type system ADTs + core operations ported to Zyl** (`stdlib/compiler/type_system.zyl`):
  Type ADT (TInt, TBool, TString, TFun, TList, TArray, TCap, TMut, TStruct, TVar),
  Subst map (TypeBind), TypeVarGen, TypeEnv (EnvBind), TraitContext, TypeInferer,
  UnifyResult, subst-lookup/insert/apply/union, type-free-vars, unify/unify-terms/unify-var/unify-args.
  All 15 functions compile and emit correct ICNF. Workaround applied for ICNF bug
  (see Research below): split recursive lambdas into helper functions
  (subst_apply_type/list, type_free_vars_list) to avoid the closure-in-let bug.
- **ICNF bug discovered:** `let` bindings of lambdas inside functions lose their
  Assign nodes — codegen emits direct calls (`call _ZYL_f`) instead of indirect
  calls through the closure value. Root cause in `src/icnf.rs` line 2612:
  Call handler always emits `ICNFInner::Call(func_name, ...)` without checking
  if func_name is a local variable in `current_scope`. Affects any Zyl code that
  stores lambdas in `let` bindings and invokes them. Filed as research note
  `research/icnf-closure-call-bug.md`.
- **C-style block formatting discipline** — S-expression formatting rule
  adopted for `stdlib/compiler/` and `selfhost/` files: each open paren on
  its own line at the correct indent, each close aligned with its matching
  open. This makes paren balance trivial to verify visually and eliminates
  an entire class of boot-pipeline regressions. Documented in
  `skills/zyl/SKILL.md`.
- **`not` operator fixed** — `f_not` linker errors from the ICNF generator
  treating `not` as a function call. Added explicit `(IIf ... (IConst 0)
  (IConst 1))` handling in `ic-special` for both `stdlib/compiler/icnf.zyl`
     and `selfhost/zyl_selfhost_compiler.zyl`.
- **`icnf-closure-call-bug` fixed** — `CallIndirect` emitted for non-function
  local bindings caused `rdi` to receive integer values instead of closure
  function pointers (SIGSEGV). Root cause: `current_scope` contains ALL
  bindings, but `convert_apply_call` and `ExprInner::Call` handler emitted
  `CallIndirect` for any name found in scope, without verifying the value
  is a closure. Fix: added `closure_ssa_ids: HashSet<usize>` to
  `IcnfConverter`; registered at every `ICNFInner::Closure` emission site;
  call handlers now check `closure_ssa_ids.contains(callee_ssa)` before
  emitting `CallIndirect`, falling back to `ICNFInner::Call` for non-callable
  locals. Regression: `option-map some` (closure call via let binding) now
  passes; full unit_test suite: 182/182 passed.
- **`stl` and `module-items-for` helpers** — added to both `resolver.zyl`
  and the selfhost compiler to support missing stdlib operations.
- **`cg-load-unresolved-name` fix** — emit `mov rax, 0` instead of
  `[rbp0]` for unresolved names; replaced `str-eq-cstr` with `str-eq` to
  eliminate linker errors.

### How the last two gaps were closed:
1. **Rust bootstrap runtime nondeterminism** — std HashMap/HashSet use a
   per-process random seed; iteration order leaked into compilation
   decisions (flaky "unknown variant" failures across identical runs).
   Fixed: src/deterministic.rs provides FNV-1a-hashed HashMap/HashSet;
   all of src/ uses them. Same input -> same output, every run.
2. **Match-arm multi-call miscompilation** — an arm body combining a
   constant with TWO calls loses its computation ("bind fields; store 0").
   Confirmed instance: icnf-arm-size returned 0 because its body was
   `(+ 1 (icnf-size body) (icnf-count-arms rest))`. Rule: match-arm bodies
   contain at most ONE call; sums nest through icnf-add2/add3 helpers.
   After fixing the last instance (icnf-arm-size), the fixed point holds.

**Details:** `docs/implementation-status.md`, `docs/regression-tests.md`.

---

## Roadmap history (2026-08-25 to 2026-09-10, annotated 2026-09-23)

The prioritized roadmap as it stood before the Rust eviction. Items
still open have moved to **Open Work** at the top of this file; the
annotations here record what became of the rest.

### P0 — Consolidate the self-hosted toolchain
- [x] **Boot build automation**: `boot.sh` runs the full loop (Rust `zyl`
      → stage1 → stage2 → stage3) and verifies the fixed point. *(done
      2026-08-25 — it immediately exposed that the earlier determinism
      check was vacuous; see Current State.)* Still to do: wire it into
      `run_regression_tests.sh --full`. *(Done 2026-08-25, below. Since
      2026-09-17 the loop needs no Rust: `./boot.sh` verifies from the
      committed seed and `--bootstrap-from-self` reseeds.)*
- [x] **Determinism gap CLOSED (2026-08-25)**: TWO root causes found and
      fixed:
      (a) The Zyl lowering's `ic-binop` handled only 1-2 arguments — any
      3+-argument binop (`(+ 3 x y)`) silently lowered to `(IConst 0)` in
      stage>=2 binaries, zeroing out size computations. Fixed with a
      left-associative n-ary fold (`ic-binop-fold`), matching the Rust
      bootstrap's convert_nary_fold.
      (b) `icnf-arm-size`'s `(+ 1 (sz body) (count rest))` shape needed
      icnf-add2 nesting (match-arm bodies: at most ONE call).
      `./boot.sh` reports the fixed point holds; verified end-to-end with
      nested-variant and multi-call programs through stage2.
- [x] **E_MATCH_ARM_COMPLEX guard (Rust side)**: src/icnf.rs now rejects,
      at ICNF-generation time, any match arm whose BinOp directly combines
      2+ call operands AND a constant operand — the confirmed-failing
      shape. Bare call+call sums are allowed (verified working through
      stage1->stage2). Note: the Rust n-ary fold emits chained binops so
      most multi-call sums never present this shape; the guard is
      defense-in-depth for future lowering changes.
- [x] **Lexer fix**: ';' inside string literals no longer starts a
      comment (src/lexer.rs strip_comments is now string-aware). Strings
      containing semicolons previously truncated at the ';' — this was
      corrupting boot sources that used ';' in message strings.
- [x] **Rust bootstrap nondeterminism FIXED**: src/deterministic.rs
      FNV-1a HashMap/HashSet across all of src/.
- [x] **Enforce the one-call rule in the compiler** *(done 2026-08-25)*:
      the self-hosted lowering now rejects the confirmed-failing shape at
      AST level (`ic-arm-guard` in icnf.zyl: arm-body binop combining a
      constant with 2+ calls -> E_MATCH_ARM_COMPLEX), mirroring the Rust
      ICNF-level guard. Also added `ic-binop-fold` (left-associative n-ary
      binop lowering) so 3+-argument binops no longer silently become
      `(IConst 0)`; verified `(- 10 2 3)` = 5 through stage2.
      Generalisation discovered while landing stack args: ANY binop whose
      direct operands are TWO calls miscompiles in stage>=2, not just
      match arms — code must bind calls to lets before combining. Documented
      in skills/zyl/SKILL.md constraint 8.
- [x] **Wire fixed-point check into default regressions** *(done
      2026-08-25)*: `run_regression_tests.sh --full` now runs the boot
      fixed-point check by default; opt out with `--no-boot`, force in any
      mode with `--boot`. Suite: 25/25.
- [x] **Compile errors for known-fragile shapes** instead of silent
      miscompiles *(done 2026-08-25, commit c9b5c69)*:
    - `E_UNBALANCED_PARENS` — whole-token-stream balance check in
      `zyl-parse` (parser.zyl).
    - `E_TOO_MANY_PARAMS` — defns with >6 params rejected at lowering.
    - `E_DUPLICATE_VARIANT` — variant names shared across deftypes
      rejected in `vt-from-variants` (icnf.zyl).
- [x] **Codegen buffer headroom**: `cg-new` bumped to a 64MB zeroed text
      buffer and the driver now fails loudly (E_CODEGEN_BUFFER_FULL) if
      output comes within 1MB of capacity, instead of silently corrupting
      the arena. True growth-on-demand deferred until the compiler source
      approaches ~20MB of generated asm.
- [x] **AI language skill** (`skills/zyl/SKILL.md`): expert-level Zyl
      knowledge for AI agents — syntax, the bootstrap constraint list
      (arity≤6, match-as-body, paren discipline, buf-append append
      semantics, FFI patterns, tag/match pitfalls), idioms, debugging
      recipes. Higher priority than most items: a robust skill file
      multiplies the effectiveness of every subsequent AI-assisted task.
      **(created 2026-08-25; keep updated as constraints are lifted)**

### P1 — Developer experience: diagnostics & editing
- [x] **Errors index**: docs/errors.md — all 45 ZylError variants with
      their formatted messages + the five lowering-guard diagnostics.
      *(done 2026-08-25)*
- [x] **Match-type diagnostics**: unresolved-scrutinee matches now say
      "cannot determine the type of this match's scrutinee" with
      remediation hints; unknown variants list the resolved type's known
      variants. *(done 2026-08-25)*
- [ ] **Compiler error system overhaul** — remaining items toward
      Rust-class diagnostics. *(Partly done 2026-09-23: a primary span
      with file:line:col, source line, caret and help text for the
      diagnostics listed under Current State. Secondary spans, "did you
      mean", the inference fix and JSON output are still open.)*
    - primary span + labeled secondary spans ("borrowed here", "moved
      here" analogues for capability types TMut/TCap and regions);
    - machine-applicable suggestion snippets (`did you mean` via edit
      distance over in-scope names, missing arm suggestions from the vt);
    - fix the root inference limitations behind "cannot determine the
      type of this match's scrutinee" (call-site -> defn param ADT
      unification before match lowering);
    - structured (JSON) error output so the LSP and tools can consume it.
- [x] **VS Code language definition**: TextMate grammar, language
      configuration, package manifest under editors/vscode/.*
      *(done 2026-08-25)*
- [ ] **Doc comments → documentation** *(still open: no `zyl doc`
      subcommand exists)*: standardize `;|`/`;;` doc-comment
      convention already used across stdlib, then a `zyl doc` generator
      (modules → variants/functions → params/results/examples) emitting
      Markdown. The stdlib is already consistently documented — formalize
      it.

### P2 — Language services
- [x] **LSP server** (depends on P1 structured diagnostics): initialize /
      hover (types from inference) / go-to-definition / document symbols /
      diagnostics publish / completion over env + module exports.
      Incremental plan: JSON-RPC stdio loop in Rust reusing src/parser.rs,
      then a Zyl-written LSP once the self-hosted one is trusted.
      *(Done 2026-09-19 directly in Zyl, `stdlib/lsp/` (`7c25a65`);
      extended to the whole language and to packages on 2026-09-23.)*

### P3 — Bootstrap correctness & performance
- [x] **map-remove / for-loop value corruption RESOLVED** *(2026-08-25,
      suite 27/27)*. Two independent codegen defects:
      (1) For-loop supply-node leak — fixed via ICNFFuncSig.result_id +
      epilogue re-materialization, function-wide embed-first dedup,
      recursive For-init hoisting, and branch emitters that skip past
      their final node.
      (2) MakeStruct field computation clobbered r10 — emit_load_into's
      MakeStruct path computed field values (which may contain calls whose
      arg staging uses r10) while r10 held the new struct's base pointer;
      fields landed in the wrong object (map-remove returned its input).
      Fixed by computing all fields first (push), then allocating and
      popping into place.
      Suite 27/27, boot fixed point holds.

### P3.5 — Self-host parity (port bootstrap type-system work to Zyl)
The Rust bootstrap gained significant inference/codegen semantics during
the generic-ADT rewrite (2026-08-25) that the Zyl-written compiler
(stdlib/compiler/*.zyl) does not yet mirror:
- [x] **Session 2026-08-27: Rust eviction plan defined** — goal is to port
      type inference + monomorphization to Zyl and remove Rust bootstrap
      entirely. Plan: `stdlib/compiler/type_inference.zyl` (~2000 loc),
      `stdlib/compiler/monomorphization.zyl` (~1882 loc), wire into
      `selfhost/driver.zyl`, verify fixed point, archive `src/`.
- [x] **2026-08-27: Adjacent-type duplicate deftype conflict resolved** —
      `TypeInferer` was defined in BOTH `type_system.zyl` (Phase-1 4-field)
      and `type_inference.zyl` (11-field), a duplicate-deftype violation that
      creates incompatible constructor identities and breaks the combined
      boot build. Per decision, consolidated all type-system ADTs into
      `type_system.zyl` (the single owner): the 11-field `TypeInferer` plus
      `FnSig`/`ParamType`/`FnReturn`/`AdtDef`/`Variant`/`Field`/`BodyCache`/
      `VarPair` moved from `type_inference.zyl`; the outdated 4-field
      `TypeInferer` and placeholder `infer-expr`/`infer-type` stubs removed.
      Both files remain paren-balanced (depth 0), no duplicate deftypes/defns,
      and the combined source parses, type-infers, and monomorphizes identically
      to before. Regression suite: 6/6 pass.
- [x] **2026-08-27: Type-inference stub compile blocker fixed** — the combined
      source failed Phase 6 with `match: non-exhaustive ... variant Some cannot
      be resolved`. Root cause: placeholder functions matched `Some`/`None`
      against lookups that actually return a plain `List` (`lookup-adt-def` →
      `Nil`/variants), plus `apply-to-nominal` used a fake `"___scrutinee_dummy"`
       lookup and dropped the subject type. Fixed: threaded the real match
       `subject-type` through `infer-lookup-arm-field-types`/`-scrutinee-adt`;
       replaced `apply-to-nominal` with a faithful `resolve-nominal` (mirrors Rust
       `resolve_nominal`: `subst-apply` then `TStruct` name, else `None`);
       rewrote `infer-lookup-variant-fields`/`infer-get-variant-fields` to walk
       the real `TIAdtDefs` via `lookup-adt-def` + new `infer-find-variant-fields`,
       threading the inferer. Combined source now completes Phases 1–9 (parse →
       assembly). Regression suite: 6/6 pass. Remaining non-blocking warning:
       `subst-lookup-binds` (type_system.zyl:119) codegen warning re unbound
       `None` — compiles; investigate later.
- [x] **2026-08-27: Type-ADT restructured + unification threaded + "Core" ported** —
       (a) `Type` ADT gained `TFloat`/`TUnit`/`TMap`/`TResult`; `TCap` changed from
       1-field to `(TCap CapKind Type)`; removed standalone `TMut` Type variant
       (now a CapKind). Added `CapKind` ADT: `TCCap`/`TCMut`/`TCAtomic`/`TCBox`/`TCPin`.
       (b) `subst-apply-type` and `type-free-vars` updated for all new variants.
       (c) **Unification chain fixed**: `unify` threads accumulated subst through
       `unify-terms`/`unify-var` (was restarting with `subst-empty` at every
       primitive match); `unify-var` now takes the current subst `s` and threads
       it (was creating empty subst); `unify-terms` returns `(UOk s)` instead of
       `(UOk (subst-empty))` so bindings accumulate. (d) **`collect-definitions`
       ported** — the declared "Core" that was skeleton/missing: iterates exprs,
       registers `Defn`/`Call(defn)`/`Apply(defn)` in `TIKnownFns` +
       `TIFuncReturns`, handles `Deftype`/`StructDef`. (e) `finalize-param-types`
       ported (resolves type vars from call-site evidence). (f) `infer-program`
       entry point added (collect → infer each expr → finalize). (g) Updated
       TCap/TMut/TBox/TPin → TCap/TCMut/TCBox/TCPin in all inference usages.
       Both files compile through Phases 1–9; regression suite 6/6 pass.
- [x] **2026-09-10: Type inference engine ported to Zyl** — Hindley-Milner with
      capability types (TCap/TMut), trait resolution, ADT instantiation tracking,
      occurs-check unification, struct field lookup. All regression suites pass
      (structs 34, types 46, adts 8, functions 17, control-flow 17, arithmetic
      53, collections 28, concurrency 6, ffi 4, macros 7, io 4, deep-recursion
      15, balanced-parens 6, match-value-position, generics-multi-type).
- [x] **2026-09-10: Monomorphization ported to Zyl** — full monomorphization
      pipeline using type inference data: variant_to_adt for constructor
      recognition, adt_param_order for positional instance naming, adt_defs,
      adt_instantiations, known_functions, function_returns, known_types,
      struct_defs, trait_impls. All regression suites pass.
- [x] **Per-call-site polymorphism for untyped params** — body_infer_cache keyed by
      call-site signature, inferring_functions for recursion guard, finalize_param_types
      for consistent-site refinement. Verified by generics-multi-type test.
- [x] **Match pattern-var shadowing + arm-scoped env** — env_bind_param used in
      inferer_bind_pattern_vars_atom; each arm gets fresh env snapshot.
- [x] **Epilogue result materialization** — Zyl codegen uses IFn directly; last
      expression value in rax via standard epilogue (mov rsp,rbp; pop rbp; ret).
      No separate result_id needed; verified by all regression tests.

**Self-hosting gap analysis (2026-08-27, UPDATED 2026-09-10):**

The Zyl-written compiler (`selfhost/zyl_selfhost_compiler.zyl`) now handles
Phases 1–11 (parsing → region inference → type inference → monomorphization
→ ICNF lowering → codegen → assembly) for the self-hosted compilation path.
The boot fixed point holds:

```
./boot.sh        # stage1 (Rust) -> stage2 (Zyl) -> stage3 (Zyl)
                 # stage2.asm == stage3.asm (deterministic)
```

The Zyl compiler written in Zyl compiles itself through all phases.
The Rust bootstrap is now only needed for the initial stage1 build.
All P3.5 items complete.

Until full Rust eviction, selfhost sources must respect the stricter-of-the-two
constraints; the boot fixed point is the arbiter.

### P4 — Feature completeness & polish
- [ ] Contract injection overlay (spec §23, Phase 10) — implemented
      in Rust → Zyl; integrated into selfhost driver. *(Reopened: on
      2026-09-15 the self-hosted pipeline's contract-injection step became
      an identity pass-through because `contract_injection.zyl` did not
      match the real AST shapes, and the module is not in the bundle.
      Contract forms parse as no-ops.)*
- [ ] Fix top-level `(def Name Expr)` misprint noted in REPL limitations.
      *(Superseded: the old REPL is gone, and the current REPL gives `def`
      a meaning. In a compiled file a top-level `def` still does not
      create a global.)*
- [ ] Warnings sweep (~160 → 0). *(Still open.)*
- [x] Boot-binary CLI parity (`-o`, `--emit-asm`) and error messages with
      spans from the Zyl front end. *(CLI done 2026-09-15, `4231955`;
      spans partly done 2026-09-23.)*

---

## Appendix: Bootstrap bug sweep that reached the fixed point (2026-08-24/25)

Each item below was a distinct blocker discovered by bisecting the
stage1→stage2 pipeline; kept here because the failure signatures recur
whenever new code enters the boot source.

1. **icnf `ic-ffi` never built an IFfi node** — returned a bare arg list
   and dropped the C symbol, so every `(ffi-call ...)` lowered to garbage
   constants in stage≥2 binaries. Fix: `(IFfi (atom-text sym) args)`.
   Use `atom-text`, not `ident-name` (the latter intentionally falls back
   for string atoms).
2. **codegen `cg-fn-check-head` returned instead of recursing** — only the
   first collected fn name ever matched. Plus **duplicate `FnName`
   deftypes**: duplicate deftypes create incompatible constructor
   identities and pattern matches silently fail.
3. **Call alignment pad after pushes** — odd-arg calls popped garbage.
   Pad must be emitted before pushes; unified direct/indirect fire path.
4. **HOF support added**: `lea rip+offset` loads for fn values, indirect
   `call r10` through local bindings.
5. **Rem without `cqo`** — stale rdx overflowed idiv (SIGFPE on every `%`).
6. **Arity>6 functions eliminated** (lexer merges, cg-if-parts takes CGP
   carrier, match-arm pipeline rewritten as cg-arm-one/cg-arm-match —
   mind CGP field order on construction vs destructuring).
7. **Entry stub runs f_main via zyl_call_on_big_stack** — generated
   binaries previously ran on the 8MB main thread.
8. **`buf-append` overwrite bug (final blocker)**: allocator called
   zyl_strcpy (overwrites dst from 0). Rust bootstrap treats buf-append as
   a StringBuffer special form with a cursor, hiding the discrepancy. Fix:
   `zyl_str_append` C primitive + true-append semantics.
9. **file-open `"a"` mode truncated** in both Rust codegen (syscall flags)
   and the C helper — wiped logs/output each open and masqueraded as
   "dropped statements" during debugging.
10. **Unbalanced assembled source** — cg-function missing a closer +
    cg-entry-stub extra closer silently nested 12 defns inside one form.
