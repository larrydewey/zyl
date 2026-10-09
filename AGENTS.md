# Zyl — Agent Instructions

## Project Identity

**Zyl** is a deterministic Lisp systems language with region-based memory, Hindley-Milner type inference with capability types, actor concurrency, a custom IR (ICNF; SSA in the spec, a tree IR today), FFI safety via pinning/timeout enforcement, hygienic macros, and full determinism. S-expression syntax targeting x86_64 native code. The compiler is self-hosting: it is written in Zyl and reproduces itself byte for byte (`./boot.sh`).

## Authoritative Sources (in order)

1. **`zyl_specification.txt`** — Canonical language specification (v5.0; §31 is the package system)
2. **`spec/`/** — Structured reference copy of specification, organized by semantic domain
3. **`docs/self-hosting.md`** — The bootstrap seeds, the fixed-point invariant, reseeding and two-step changes
4. **`PROGRESS.md`** — Current implementation state and next priorities
5. **`docs/`/** — Architecture decisions, implementation history, design rationale
6. **Source code** — Authority for implemented behavior (overrides specification on implementation details). The compiler is self-hosted: `stdlib/compiler/*.zyl` + `selfhost/` is the ACTIVE implementation. The original Rust implementation has been removed from the tree; it is in git history at commit `b8bc283` (`archive/rust-bootstrap-2026/`).

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
inlining (`closure_inline.zyl`, now an identity step) → type checking (`type_annotate.zyl`: sound HM, spec §4.8–§4.10;
every type error is reported, then the compile fails; static trait
resolution, per-type specialization of calls and function values,
generated structural `T.==`) → numeric check (`numeric_check.zyl`, spec
§20: Int `+ - *` is checked unless the package opts out with
`(numeric wrapping)` or `(numeric saturating)`; `E_PARTIAL_OPERATION` for a `/`
or `%` whose divisor is not a nonzero literal; `div!`/`rem!` trap on zero,
`div?`/`rem?` give `(Option Int)`) → ICNF lowering (the policy picks the
operator family; checked `+ - *` trap with `E_OVERFLOW`) →
optimization (small-function inlining and copy propagation, then
constant folding and dead-branch elimination) → region inference (the stack-variant rewrite, then
`rg-regions`: escape analysis over ICNF that places every allocation and
call site in the frame's own region, the caller's result region, or the
heap, and raises `E_REGION_ESCAPE`; see `docs/regions-design.md`) →
in-place reuse (`reuse.zyl`) → codegen (the native backend: MIR and
linear-scan register allocation in `mir.zyl`, with the stack machine
for functions it does not take; `docs/native-backend-design.md`) →
linking (the Zyl assembler and ELF linker, or `cc` for a hosted
program; see Link modes below). Contracts are lowered where forms are recognized
(`convert-ast`, `expr_inner.zyl`): `requires`/`ensures`/`invariant`
become checks raising `E_CONTRACT_VIOLATION`, `ensures` binds `result`,
`recover` is `try`/`catch` with arms by error code, `checkpoint` rolls
back `let-mut` state, and the profile (`--contracts=P`, `(contracts P)`)
picks panic, warn or strip. Hash finalization exists only for
package builds: `zyl build` writes `<out>.buildinfo` (compiler, graph,
native-object and ICNF hashes, the resolved graph, the assembly hash,
and the final hash of spec §31.12's four inputs, which the binary
carries as `zyl_build_hash`); `zyl build --sign-with <key>` also appends
a signed provenance trailer, and `zyl verify <binary>` reads it back
(`docs/build-provenance-design.md`).

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
  released on return, before a tail jump (a self tail call on the
  native path recycles it instead), or when a caught panic unwinds it; results go into the region the caller chose (`zyl_cur_region`);
  values that escape untracked go to the process heap, which still lives
  until exit. `ZYL_REGIONS=0` at compile time turns this off
- `(bytebuf Stack N)` lives in the frame region; `with-region` opens an
  explicit `arena` or `fixed` region (`E_REGION_SPEC`,
  `E_REGION_EXHAUSTED`)
- No value may escape its assigned region: a Stack bytebuf or a
  `with-region` value that would outlive its region is `E_REGION_ESCAPE`
- Memory is bounded at run time: the heap is charged to `ZYL_MAX_MEMORY`
  (default 80% of total memory or the cgroup limit, never of what is free, so
  load cannot change whether a program runs; exhausting it is
  `E_OUT_OF_MEMORY`, whose report does not allocate; arena blocks grow from
  64 KiB so a large block size is charged only as used), and main's stack is
  a quarter of the budget, charged to it; overflowing it, or an actor's
  8 MiB stack, is `E_STACK_OVERFLOW` (`zyl_segv_handler`, spec §14)
- The memory profile (spec §9.3), `(memory unbounded|reported|bounded)`
  once per program (lone-file form or `zyl.pkg` line): `reported` warns
  `W_HEAP_ESCAPE` at each allocation that goes to the process heap,
  `bounded` refuses it with `E_REGION_ESCAPE`; top-level `def` values and
  standard-library sites are exempt
- Global and Circular are names only (Global = top-level `def` values,
  which are heap); the interpreter ignores regions

### Mutability and Aliasing
- Zyl has no in-place mutation: a `let` binding is immutable and `set!`
  rebinds a `let-mut` binding, so every other binding is immutable and
  shared. This is the whole aliasing story, and it is stronger than a
  "one writer or many readers" invariant would be
- `set!` on anything but a `let-mut` binding is `E_MUT_CONFLICT`
  (`mutability_check.zyl`, a syntactic pass); moves are `E_MOVE_VALUE`
  (`linearity.zyl`); a mutable capture crossing an actor boundary is
  `E_CAPABILITY_LEAK`
- The unifier has no capability polarity — there is no `TCap`/`TMut` type
  and never was. `Secret` is the real capability type: it carries
  obligations the compiler enforces (`E_SECRET_DEBUG`, `E_ZEROIZE_MISSING`)

### FFI Safety
- FFI calls require Pin region + timeout parameter
- FFI_Pinnable types: Int, Float, Bool, String, Vec<T>, composed types
- Current enforcement: `(ffi-call "sym" args... timeout)` — the symbol
  must be a string literal (`E_FFI_SYMBOL_REQUIRED`) and the timeout a
  positive integer literal in milliseconds (`E_FFI_TIMEOUT_REQUIRED`), or
  given once on the extern, `(extern "sym" (T...) R :timeout 1000)`, for
  calls that omit it (a call-site literal wins).
  A foreign call runs on a per-thread worker through the runtime's
  `zyl_ffi_timed`; overrunning raises `E_FFI_TIMEOUT` and the call is
  abandoned, not killed. `zyl_*` runtime symbols are called directly.
  A `Float` in an `extern` crosses as C's `double`: the compiler emits
  the signature's ABI class mask in the request word the bridge takes
  (`ic-ffi-class-mask`), the worker places each argument word in the
  integer register, the `xmm` register or the stack slot the ABI names
  (`ff-place`, `zyl_rt_callmix`), sets `al`, and reads a `Float` result
  out of `xmm0`. The bits are the value, so nothing is rounded. A `Float`
  *inside* a type is `E_TYPE_MISMATCH` — the eightbyte class of an
  aggregate is not computed — as is a `Float` callback parameter.
  A foreign `ffi-call`/`ffi-pin` needs the `ffi` capability, declared in
  `zyl.pkg` by a package and by a top-level `(capabilities ffi)` form in
  a lone file (absent means none; a `zyl_*` runtime entry needs no
  grant), and a `Secret` argument must be passed through `ffi-pin`
  (`E_FFI_PIN_REQUIRED`)

### Struct Immutability
- Struct fields are immutable by default
- Mutation via `let-mut` rebinding only; `set!` on anything else is `E_MUT_CONFLICT`
- Direct field mutation (`set! (struct-get p "x") 5`) is forbidden (`E_MUT_CONFLICT`)

### Match Exhaustiveness
- Exhaustiveness is a compile-time error if not satisfied (`E_NON_EXHAUSTIVE_MATCH`); an arm after a catch-all is `E_UNREACHABLE_MATCH_ARM`
- `_` is the discard in patterns, parameters and bindings; `_`-prefixed names are exempt from unused-binding warnings. Do not introduce `d1`-style dummy names
- An arm head spelled like a constructor (first letter A-Z) that no type declares is `E_UNKNOWN_CONSTRUCTOR`, with the nearest constructor suggested; a lowercase arm head that is not a constructor is a catch-all binding

### Contracts
- Contracts never alter core semantics (type inference, ownership, regions, concurrency)
- Contracts are an optional overlay: runtime checks under a profile (strict/debug panic, warn reports, off/production strip — see above)

## Architecture Decisions (Do Not Reverse)

- **No-dispatch parsing:** the reader produces generic S-expression nodes; form recognition happens afterwards in one place (`convert-ast` in `stdlib/compiler/expr_inner.zyl`)
- **Innermost-first macro expansion** with gensym hygiene
- **ICNF as custom SSA IR** (not LLVM) for region annotation flow (today ICNF is a tree IR, not yet SSA; region annotations live in a side table keyed by node and are printed as ` @r`, so the ICNF hash covers them)
- **Region-based memory** (not GC) for deterministic reclamation
- **No in-place mutation** — immutability plus rebinding, checked on bindings rather than carried by the type system, so aliasing needs no type-level capability (see `docs/architecture-decisions.md` A7)
- **Structs immutable by default** (rebinding only)
- **Safe-only optimizations** (constant folding, DCE, small-function inlining, copy propagation, in-place reuse — no reordering)
- **The runtime is Zyl** (`runtime/rt/`), with no C and no libc under freestanding programs; the `%` primitives exist only in the runtime's own compile, and programs get no `unsafe`
- **Kahn channels** (single writer, single reader, blocking receive, no select) are the only way actors communicate
- **No inline assembly**: deterministic typed intrinsics (spec §21.13) and `stdlib/simd` instead; `ffi-call` is the escape hatch
- **The compiler assembles and links** freestanding programs itself (`asm_x86.zyl`, `elf_link.zyl`)

## Development Commands

No Rust, no Cargo — the compiler is self-hosted and builds with `cc`:

```bash
./boot.sh                       # Build + verify the self-hosting fixed point
build/boot/zyl-self hello.zyl -o hello   # Compile a program
./hello                         # Run it
```

After editing anything under `stdlib/compiler/*.zyl`, `selfhost/` or
`runtime/rt/`, re-run `./boot.sh` — a source change that
alters the compiler's own output breaks the fixed point (`FIXED POINT
BROKEN` or `reproduced asm differs from committed seed`), which needs
reseeding before anything else will trust the new `build/boot/stage2.s`:

```bash
./boot.sh --bootstrap-from-self # Reseed stage2.s and rt.s using the self-hosted compiler
./boot.sh                       # Verify the new seed reaches a clean fixed point
git add -f build/boot/stage2.s build/boot/stage2.bin build/boot/rt.s && git commit
```

`--bootstrap-from-self` fails only when a change is so large the old
seed can't even parse the new source (new syntax, not just new
behavior). There is no Rust fallback (the Rust bootstrap was removed
from the tree; it is in git history at `b8bc283`, and could not lex the
current source anyway): introduce new syntax in two steps instead —
teach the compiler to accept it, reseed, and only then use it in the
compiler's own source. See `docs/self-hosting.md`.

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
`update`, `vendor`, `audit`, `publish`, `key`, `verify <binary>`, `repl`, `eval <file.zyl>`,
`doc [file|dir] [-o out.md]`, `check [file|dir ...]`, `explain [CODE]`, `fmt [file.zyl ...] [--check]`, `balance [file|dir ...]`.

`zyl check` is the fast edit loop: every phase of a build up to code
generation — the front end, type inference, the numeric check, ICNF lowering,
optimization, region inference and reuse — then stop: no code generation, no
linking. It runs the same pipeline a build does (`compile-to-fns` is the shared
body) and requires `main` of a lone file (`E_NO_MAIN`), so a clean check means
the program builds; the compile-fail suite asserts that every program the build
rejects, `zyl check` rejects with the same code. A file under `tests/compile-fail/` is skipped and the
skip is reported. A **standard-library module cannot be checked**: it is a
module rather than a program, and compiling it as the entry makes it both at
once, so `zyl check` declines and points at `zyl build`.

## Regression Tests

```bash
./run_regression_tests.sh --quick   # unit_test + tests/smoke (the default mode)
./run_regression_tests.sh --full    # ./boot.sh, then every category
./run_regression_tests.sh --full --no-boot   # every category, skip the fixed-point check
./run_regression_tests.sh --full --no-boot --filter structs  # struct tests only
```

`--filter` is a case-insensitive substring of the test name and applies
*within* the selected mode — `--filter structs` alone runs in quick mode
and selects nothing. `--full` runs `./boot.sh` after the suites unless `--no-boot`
is given. Other flags: `--verbose`, `--timeout N`, `--boot`,
`--dry-run` (lists exactly the tests a real run with the same mode and
`--filter` would run). Categories in `--full`: regression, interpreter
(differential REPL-interpreter-vs-codegen runs), sched (actor tests
must match under `ZYL_SCHED=deterministic` and chaos seeds), compile-fail,
integration, stress, packages, packages-fail, packages-build, scripts
(shell checks of the repository's own scripts), lsp, and
the unit test.

**Trigger before modifying struct-related code** (`ast.zyl`, `codegen.zyl`, `icnf.zyl`, `type_annotate.zyl`, `parser.zyl`, `region_inference.zyl` under `stdlib/compiler/`):
```bash
./run_regression_tests.sh --full --no-boot --filter structs
```

Full test infrastructure documented in `docs/regression-tests.md`.

**`zyl fmt`** reindents to paren depth and is a no-op on already-formatted
source; `--check` reports and exits 1 without writing. It never touches a
delimiter. **`zyl balance --fix`** repairs brackets (`stdlib/text/parens.zyl`): a file
splits into top-level chunks at column-1 openers, a balanced chunk is kept
byte for byte, and an unbalanced one gets the single edit (closers inserted at
one line end, or removed from one) that balances it and best agrees with its
indentation, learning the file's flat chains (`(if` under an open `(if`) so
they are not read as siblings; failing that, Parinfer's indent mode. It writes
only a result that balances, and the language server offers the same edit as
a quick fix; a balance error names it when it can help. `tests/scripts/balance-fix.sh`
holds a mutation property (one closer deleted from or added to a real file is
restored about 98% of the time; the rest are readings the indentation cannot
decide) and that `zyl check`, `zyl balance` and the fix agree on mixed
mutations, brackets in strings and comments included. All of them -- and
`zyl fmt` and the language server's scanners -- read strings and comments
through one implementation of the lexical rules in `sexp_balance.zyl`
(`sb-string-end`, `sb-line-end`, `sb-line-info`). `tools/fmt-hook.sh` is
the git pre-commit form (`ln -sf "$PWD/tools/fmt-hook.sh"
.git/hooks/pre-commit`) and is deliberately NOT installed: the tree is not
uniformly formatted by this tool — it disagrees with hand-written styles like
the flat `(Cons` chain in `drv-subcommand`, and all 511 files would be
reformatted — so a hook that refuses unformatted source would block every
commit until the whole tree was rewritten. That is a decision to make on
purpose. The formatter lives in `stdlib/text/format.zyl`, not in the LSP
service that first needed it. It reindents only and never counts delimiters,
so it cannot rebalance a form; `zyl balance` is what tells you the form is
wrong, and running `fmt` first makes that report about a file whose only
problem is a missing paren. Its depth scan tracks strings AND comments: a
paren in a comment once left the depth permanently high for every line after
it, and formatting a file made it fail to balance.

**Memory safety.** `docs/soundness.md` states the claim as lemmas, marking
each *enforced*, *measured* or *argued`. A dynamic gate runs the regression
and smoke programs under Valgrind memcheck — not ASan, which cannot work
here because the runtime never calls malloc — and checks its own control
and its own detection path first:

```bash
./run_regression_tests.sh --full --no-boot --filter memcheck
```

It is opt-in (~50x slowdown). After changing anything under
`runtime/rt/`, `stdlib/compiler/region_inference.zyl`, or the collection
or resource code, run it: a memory error there is exactly the kind that
`--full` will not notice.

**Region lifetime** has its own gate, and it is the only dynamic check of
the premise that no value outlives its region (`docs/soundness.md` L2 —
otherwise an argued assumption):

```bash
./run_regression_tests.sh --full --no-boot --filter poison
```

It refills released region blocks with `0xDE` and requires unchanged
behaviour. The mechanism — what release does, why only pooled blocks need
help, why page protection was built and withdrawn, and what the gate can
and cannot see — is `docs/memory-poisoning-design.md`. Read it, or
`verify/poison.sh`, before trusting a green run: the gate has no positive
control, because the violation it looks for is what the static checks
already prevent, and it only catches a stale read that reaches output.

The stronger gate rebuilds the whole compiler with regions poisoned and
requires byte-identical seeds — the largest Zyl program, self-hosted:

```bash
./run_regression_tests.sh --full --no-boot --filter poison-selfhost
``` All tests use the `(test "name" (assert-equal ...))` harness defined in `stdlib/testing/testing.zyl`.

**Determinism** is the reason the language exists, and it has a gate that
checks both halves: 120 programs compiled twice in separate processes must be
byte-identical, and `verify/model.py` exhaustively enumerates the region
allocator's reachable state space, requiring its transition relation to be a
function and its block accounting to balance. The checker's own detection
path is exercised against an injected double free.

```bash
./run_regression_tests.sh --full --no-boot --filter determinism
python3 verify/model.py            # stdlib only; ZYL_MODEL_DEPTH / _STATES widen it
```

**S-expression balance** is critical. After editing any `.zyl` file, check it with
the compiler's own balancer, never by counting delimiters by hand or with a script:

```bash
build/boot/zyl-self balance path/to/file.zyl    # or a directory; exit 1 with a located report
```

It follows the lexer's rules exactly and enforces spec §1.6: a top-level form starts
in column 1 and no nested opener does, which catches a missing `)` balanced by an extra
one elsewhere. The project's Claude Code hook (`.claude/settings.json`,
`tools/hooks/balance-check.sh`) runs it after every edit and shell command that changes
a `.zyl` file and returns the report. After modifying the lexer, parser or
`sexp_balance.zyl`, run `./run_regression_tests.sh --full --no-boot --filter balance`
(the unit tests, the agreement test against the lexer, `scripts/balance-cli`) and the
compile-fail tests `unclosed-opener`, `unexpected-close`, `mismatched-bracket` and
`misplaced-paren`.

## Architecture Notes

- Runtime: written in Zyl in `runtime/rt/` (no C; `docs/runtime-in-zyl-design.md`). It is
  compiled with `--runtime-module`, which only the bundle's `runtime/rt/rt.zyl` may use;
  there the locked `%` primitives are allowed and `zyl_*` defns are exported. Its output
  `build/boot/rt.s` is a committed seed like `stage2.s`. There is no `unsafe` for programs.
- Link modes: a program with no foreign `ffi-call` and no native objects links
  freestanding with no cc/as/ld: the Zyl assembler (`asm_x86.zyl`) and static ELF linker
  (`elf_link.zyl`) link it against the cached runtime `rt.zo` (built by `zyl rt-cache`,
  keyed by the BLAKE3 of `rt.s` + `start.s`). There is no libc: the runtime's `_start`
  sets up TLS, and threads are `clone` + futex. `ZYL_EXTERNAL_LD=1` uses cc with
  `start.o` + `rt.o` instead. A program that calls foreign C links hosted
  over libc's crt (weak pthreads), with `-lm` on the line unconditionally
  (`cli-link-hosted`, `selfhost/driver.zyl`): a C library function such as `fabs` is
  the common case, and a lone file cannot ask for a library of its own. The compiler
  binaries link it too (`boot.sh`, `link_cc`), because the interpreter resolves a foreign
  symbol with `dlsym(RTLD_DEFAULT, ...)` against its own process. The compiler binaries themselves are hosted (the REPL
  interpreter's FFI uses `dlsym`).

- Entry point: `selfhost/driver.zyl`, compiled like any program (its `(use ...)` tree resolved from `stdlib/`, names qualified per module) to `build/boot/stage2.bin`/`zyl-self`. `boot.sh` caps each stage at 4 GB of allocation (`ZYL_STAGE_MEMORY`). The phase order shared by the CLI and the REPL is `stdlib/compiler/pipeline.zyl`.
- Language server: `selfhost/lsp_main.zyl` + `stdlib/lsp/` (and `services/`), built by `./boot.sh` as `build/boot/zyl-lsp`; the VS Code client is `editors/vscode/` (0.5.0, esbuild-bundled, `$zyl` problem matcher). Protocol tests: `tests/lsp/lsp_protocol_test.py`.
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
  fully visible, never capability-enforced. Do not give it a `zyl.pkg`.
  Every other program is policed: a lone file is `local/main`@0 and
  declares its capabilities with a top-level `(capabilities ...)` form,
  absent meaning none, so a test or tool that spawns, opens files, calls
  foreign code or uses `math/secret` carries that line
- All error codes from spec §28 must be defined and used consistently
