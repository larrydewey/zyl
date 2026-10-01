# Zyl Progress Tracker

The project as it stands and what is still open. Keep it current: when
work lands, change the section it touches rather than appending a log.
The session-by-session log that used to follow this file's summary is in
git history (`git show 9ffde56:PROGRESS.md`), as is every deleted plan
document.

## Current State (verified 2026-09-28)

Every claim here was checked against the tree, the suite, or a probe
compile with `build/boot/zyl-self` on 2026-09-28.

### Build and verification

- The compiler is self-hosted: `stdlib/compiler/*.zyl` (46 modules,
  about 29,700 lines) plus `selfhost/` (`driver.zyl`, `lsp_main.zyl`).
  The runtime is Zyl too: `runtime/rt/*.zyl` (35 modules, about 5,600
  lines), compiled with `--runtime-module`. There is no C and no Rust in
  the build; the only C in the tree is `bench/*.c` and one package-test
  fixture.
- `./boot.sh` links the committed seeds (`build/boot/stage2.s`,
  `build/boot/rt.s`) with `cc`, checks that stage1 reproduces both and
  that stage2 == stage3, builds `rt.zo`, `zyl-self` and `zyl-lsp`, and
  refreshes an existing install. `./boot.sh --bootstrap-from-self`
  reseeds; see `docs/self-hosting.md`. A self-compile takes about 2.2 s.
- `./run_regression_tests.sh --full --no-boot` passes **377/377** in
  about 25 s: 106 regression, 87 interpreter (compiled vs interpreted
  output, the interpreter in its tag-checking mode), 4 sched (actor
  tests under `ZYL_SCHED=deterministic` and chaos seeds), 138
  compile-fail, 7 integration, 4 stress, 2 packages, 9 packages-fail, 1
  packages-build, 17 scripts, the LSP protocol test (126 checks) and the
  unit test. A compile-fail test may pin its code (`; expect-error:
  CODE`) and location (`; expect-at: FILE:LINE:COL`).
- The specification is `zyl_specification.txt` **v5.0** (§0–§31);
  `spec/` is the structured copy.

### Compiler

- Phase order (`stdlib/compiler/pipeline.zyl`): balance check, parse
  (with the `desugar.zyl` rewrites), test-compile resolution after macro expansion,
  module resolution and qualification, macro expansion, the checks
  (capability, duplicate definition, arity, malformed forms, restricted
  FFI entries, mutability/aliasing, release linearity, exhaustiveness,
  unused, secret),
  derive expansion, impl lifting, closure inlining (an identity step),
  type checking, ICNF lowering, optimization, region inference, in-place
  reuse, code generation, linking.
- Types are sound (`docs/sound-types-design.md`, spec §4.8–§4.10): every
  type error is reported, then the compile fails. Unit is a type,
  conditions are Bool, arithmetic is Int or Float with no conversion,
  traits resolve statically with per-type specialization, runtime
  entries are typed by `ffi_sigs.zyl` and foreign functions by
  `(extern ...)`, and there is no cast form. The `receive` hole is gone
  with the mailboxes.
- Regions are real (`docs/regions-design.md`): each call that allocates
  short-lived values gets a frame region, results go into the region the
  caller chose, and only values that escape untracked go to the process
  heap. `(bytebuf Stack N)` is frame-local, and an escaping one is
  `E_REGION_ESCAPE`, labelled where it escapes. `with-region` opens an
  explicit `arena` or `fixed` region. `ZYL_REGIONS=0` turns inference
  off.
- **A program cannot obtain an `Arena`** (spec G2). The collections
  (`Vec`, `IntMap`, `Set`, `Slice`) allocate from the region the
  allocating call runs in, and `stdlib/math` takes no arena parameter at
  all -- a hash's message schedule, a cipher's state and a bignum's limbs
  are reclaimed with their frame. The arena entries are in `ffi-raw-p`,
  and the `allocator/allocator` wrappers are refused by name at the call
  site, so `E_FFI_RESTRICTED` answers all three routes (raw `ffi-call`,
  the wrapper, reading an `Arena` field, which is nominal and will not
  unify with `Int`). What still holds an arena is the compiler, the LSP,
  the REPL and their tests: the parse tree and the REPL scratch outlive
  any single frame, so they cannot use a frame region. Those entries are
  recognized by source and compiled in an internal mode. `StringBuffer`
  is the one user-facing type that keeps an `Arena`, and it is a
  resource rather than scratch: it is released through `with-resource`
  (G11), a read after release is `E_USE_AFTER_FREE`, and a second
  release is a no-op (`zyl_arena_destroy` keeps its 72-byte handle so a
  stale one is never dereferenced).
- **Release is checked statically** (`linearity.zyl`, `E_MOVE_VALUE`). The
  rule is affine: a value that owns a resource is consumed by the release,
  and any use after it is an error. This closes a hole that was neither
  hypothetical nor a crash. A file handle is an `Int`, and an `Int` is a
  copyable scalar, so this compiled clean and wrote into the wrong file:

  ```scheme
  (let fd (file-open "a.txt" "w")
    (file-close fd)
    (let other (file-open "secret.txt" "w")   ; the OS hands `fd` back
      (file-write fd "leaked")))              ; lands in secret.txt
  ```

  I ran it; the bytes were in `secret.txt`. A stale descriptor aliasing an
  unrelated file is a confused deputy, and no test caught it. Covered:
  descriptors, `StringBuffer`, and any type the program gives a `Drop`
  impl -- which the pass discovers from the program's own `impl` forms, so
  a user resource needs nothing from the compiler. Consumption is tracked
  per alias class, because `with-resource` binds the resource to a fresh
  name and `(let copy fd)` is how one gets passed around; a release
  reaches every name for the resource. A release inside an exception
  handler is conditional and does not consume, which is what makes the
  `with-resource` desugar sound. Regions made all of this *defined*; this
  makes it *prevented*, which is the difference G2 asks for.
- **Memory safety is stated, not asserted.** `docs/soundness.md` gives the
  claim as lemmas and marks each for how it is established — *enforced* by
  a compiler check, *measured* by a dynamic run, or *argued* from those.
  The weakest link is named there: escape analysis under-approximation
  (L2), which now has a dynamic gate of its own (`verify/poison.sh`,
  `--filter poison`: released region blocks refilled with `0xDE`, 125/125
  unchanged) with its limits stated — it catches only a stale read that
  reaches output, and it has no positive control, because the violation it
  looks for is what the static checks already prevent. The stronger gate
  rebuilds the entire compiler with regions poisoned and requires
  byte-identical seeds (`--filter poison-selfhost`), and an attempt to
  manufacture the violation using a scratch compiler with the escape
  diagnostic suppressed did not produce a dangling read, because the escape
  path promotes the allocation rather than leaving it dead. It also records
  the honest comparison with Rust — Zyl's guarantee is
  unconditional where Rust's is conditional, and Zyl's is far less tested.
- **The `TCap`/`TMut` aliasing invariant is enforced** on what the
  language can actually express. The invariant (§9.1: "either exactly one
  TMut reference OR any number of TCap references") needs two things to be
  meaningful, and Zyl has one of them. There is no reference or borrow
  type -- `TaTy` is `TaV | TaC | TaF`, with no capability dimension -- so a
  plain binding cannot be a `TMut` reference to alias with. What the
  language *does* have is mutable locations: a `bytebuf`, written through
  by `store-u8` and the atomic and `bytebuf-append` forms. Those are
  `TMut` by use, and aliasing them is reachable, so it is checked:
  **within one location, at most one name may be written.** A writer plus
  any number of readers is one `TMut` and many `TCap`, which the invariant
  permits.

  This was not hypothetical. It compiled clean, and the second write won,
  visible through the first handle:

  ```scheme
  (let b (bytebuf Stack 16)
    (let second b
      (begin (store-u8 :le second 0 65)
             (store-u8 :le b 0 66))))   ; read back through `second`: 66
  ```

  A `byteslice` joins its base's class rather than starting a new one, so
  `(let v (byteslice b 8 4))` written through both `v` and `b` is the same
  violation. Naming a location twice is *not* itself an error -- only
  writing through two names is.

  Two implementation notes, both of which looked right and were wrong
  first: alias classes must be keyed per allocation, not per name, or two
  sibling buffers that share a name inherit each other's writer and a
  legitimate store is rejected (`byte-primitives.zyl:92`); and a name only
  becomes `TMut` by being *written*, so the check belongs on the storing
  forms rather than on the binding.

  The remaining gap is the *type* rather than the check: `TCap<T>` and
  `TMut<T>` are still not written as types, so rules 3 and 4 (downgrade is
  allowed, upgrade is not) hold structurally -- there is no conversion to
  forbid -- rather than by unification. Rule 5's Send-capability and the
  `TAtomic`/`TBox` wrappers are likewise unrepresented.
  What does alias today is the collection sharing documented in
  `vec.zyl` ("versions made from the same Vec share storage until one of
  them outgrows it"). It is memory-safe by construction -- the shared
  array is region-owned and bounds-checked, and a stale handle reads the
  old array rather than freed memory -- and I verified it rather than
  assuming: 300k iterations of a handle outliving its own reallocation,
  reading every stale element under allocation pressure, returned exactly
  the predicted sum (`90000900000`, no fault, no corruption). A write
  through one handle being visible in another is that documented
  semantics, not a defect. Turning it into an error would mean making the
  collections non-persistent, which contradicts
  `docs/sound-types-design.md` and every caller in the tree.
- Optimization (all safe, none reorders effects): small-function
  inlining (`ZYL_INLINE`, `ZYL_INLINE_LIMIT`) and copy propagation,
  constant folding and dead-branch elimination, one-level unrolling of
  small tree recursion (`ZYL_UNROLL`), and in-place reuse of a unique,
  dead value's block (`reuse.zyl`, `ZYL_REUSE=0` off).
- Code generation (`docs/native-backend-design.md`): MIR with liveness
  and linear-scan register allocation (`mir.zyl`) for most functions,
  the stack machine for the rest (closures and calls through a local,
  `try`, `with-region` scopes, `print`, Float arithmetic, Secret frame
  wiping, more than six parameters); one ABI, `ZYL_MIR=0` forces the
  stack machine. Tail calls are jumps and a self tail call is a loop.
- Performance, re-verified 2026-09-30 for v0.2.0 with no regression: the
  2026-09-29/30 change batch (tuples, `let*`, `len`, the `Vec`/`Map`
  literals, `intmap`, the type predicates, the error and `panic` forms,
  the `when`/`unless` short-circuit fix, the lexer's integer-overflow
  error) leaves all seven `bench/` programs within noise of the previous
  compiler, with `list` and `vec` slightly ahead and peak memory
  unchanged. Method: both compilers on one machine (`8aaa646` built in a
  worktree), the same `bench/*.zyl` compiled by each, the binaries run
  alternately, min of 15. Ratios only compare within a single run — the
  absolute times drift 10-30% with machine load, which is what made
  `trees` look 12% worse against C when it had not changed at all.
- Linking: a program with no foreign `ffi-call` and no native objects is
  a static executable with no libc, assembled and linked by the
  compiler itself (`asm_x86.zyl`, `elf_link.zyl`) against the cached
  runtime `rt.zo` (keyed by the BLAKE3 of `rt.s` + `start.s`, rebuilt
  when stale). A hello-world links in about 26 ms. A program that calls
  foreign C links hosted over libc's crt with `cc`; `ZYL_EXTERNAL_LD=1`
  uses `cc` for everything.
- Macros (spec §19): gensym hygiene, innermost-first, `&rest` spliced
  with `,@name`, `E_MACRO_NON_TERMINATION`, `E_MACRO_ILLEGAL_ACCESS`.
  Quasiquote builds lists of data.
- Testing (spec 20.5): `test`, the assertions (`assert-fail` fails
  unless its expression raises), `test-suite` with `setup`/`teardown`
  fixtures, `test-property` over fixed `gen-int`/`gen-bool`/`gen-string`/
  `gen-float` samples (`core/property`), and `test-compile`, decided at
  compile time by a probe of the checks and the type checker
  (`pipeline.zyl`'s `tc-resolve`). `with-resource` calls the prelude
  `Drop` trait on both exits (spec 12.9, G11). The suite, property,
  `with-resource` and `assert-fail` rewrites run on the parse tree
  (`compiler/desugar.zyl`). A failing test prints `FAIL: <message>`.
- Contracts (spec §23): `requires`/`ensures`/`invariant` checks,
  `recover` arms by error code, `checkpoint` rollback of `let-mut`
  state, profiles (`--contracts=P`, `(contracts P)`).
- Delimiters (spec §1.6, `sexp_balance.zyl`): every file is checked
  before it is read, with the lexer's own rules (an agreement test
  mutates real sources and compares with the lexer's tokens), bracket
  kinds, and the column-1 layout rule that catches a missing closer
  balanced by an extra one; the fix-it names the line where the
  indentation first contradicts the nesting. Unterminated strings are
  located at their quote, a NUL byte is `E_INVALID_CHAR`, and source
  files are read whole (the 1 MiB cap is gone). `zyl balance [file | dir
  ...]` runs the check alone (text or JSON, status 1 on a fault);
  `.claude/settings.json` runs it after every agent edit.
- Reserved keywords (spec 1.3.1, `reserved_check.zyl`): a keyword as the
  name a definition introduces is `E_RESERVED_KEYWORD`, outside the
  standard library and the runtime. `alias` is transparent (the type
  checker reads the alias as its target; bad targets and cycles are
  `E_UNKNOWN_TYPE`). `run-tests` takes `(:filter "s")`, which runs only
  the tests whose names contain `s`, and `(:parallel b)`; any other
  option is `E_MALFORMED_FORM`. The REPL keeps `alias` entries as
  definitions, and `zyl-lsp` publishes all three errors.
- Diagnostics: `error[CODE]`, `--> file:line:col`, the source line, a
  caret and a `= help:` line for every diagnostic that has a source
  node; "did you mean" on unbound names; labelled secondary spans on
  `E_MUT_CONFLICT`, `E_CAPABILITY_LEAK`, `E_PKG_CAPABILITY_VIOLATION`
  and `E_REGION_ESCAPE`; `--error-format=json`. The self-build prints no
  warnings.
- Hash finalization: `zyl build` writes `<out>.buildinfo` and the binary
  carries `zyl_build_hash` (spec §31.12).

### Runtime

- `runtime/rt/` (`docs/runtime-in-zyl-design.md`): its own allocator
  (`heap.zyl`, size classes over mmap), frame regions (`alloc.zyl`),
  buffered stdout (`out.zyl`), threads on `clone` + futex
  (`thread.zyl`), TLS setup and `_start`, environment, exit and process
  spawning on syscalls (`env.zyl`, `proc.zyl`), exact float text and
  parsing (`fmt.zyl`), BLAKE3, AES-NI, SIMD string scans with an AVX2
  path behind a `cpuid` probe.
- The locked `%` primitives exist only in the runtime's own compile
  (`E_FFI_RESTRICTED` elsewhere); there is no `unsafe` for programs.
- Try frames save their rbp, rsp and rip mangled with a per-process
  getrandom guard (XOR, then rotate left 17), so a heap write cannot aim
  the unwind without the guard. The guard is never observable.
- An allocation failure is `E_OUT_OF_MEMORY`; the budget is
  `ZYL_MAX_MEMORY`, else 80% of available memory.

### Concurrency (`docs/concurrency-determinism-design.md`)

- Kahn process networks: `(chan n)`, `chan-tx`, `chan-rx`,
  `(chan-send tx v)`, `(chan-recv rx)`, typed `(Chan a)`, `(Tx a)`,
  `(Rx a)`. Single writer, single reader; an endpoint moves at `spawn`
  of a closure that captures it, or over a channel
  (`E_CHANNEL_NOT_OWNER`). Closing on the writer's exit
  (`E_CHANNEL_CLOSED`), deadlock detection (`E_DEADLOCK`), at most 1024
  actors (`E_ACTOR_LIMIT`).
- An actor's output is buffered per owner and emitted when it is joined,
  or at exit in spawn order; its panic ends only it, and `actor-wait`
  re-raises it.
- `ZYL_SCHED=deterministic` runs one actor at a time;
  `ZYL_SCHED_CHAOS=<seed>` perturbs every channel operation. The sched
  category requires identical output under both.

### Package system (spec §31)

- Manifests (`zyl.pkg`), canonical symbol keys with injective mangling,
  `pub` visibility, Minimal Version Selection, `zyl.lock`, the
  content-addressed store, the index with mandatory Ed25519
  verification, capabilities (the root package's `main` included),
  features, native dependencies, workspaces, the build cache, and `zyl
  new/add/fetch/build/test/update/vendor/audit/publish/key`.
- The standard library is the implicit package `zyl/std` and has no
  manifest; a lone file compiles as `local/main`@0.

### Tools

- CLI (`drv-usage`): `zyl <file.zyl> [-o out] [--emit-asm]`, the package
  subcommands, `repl`, `eval <file.zyl>`, `doc [file|dir] [-o out.md]`,
  `balance [file|dir ...]`.
  The installed `zyl` starts the REPL when given no arguments.
- REPL (`stdlib/repl/`, `docs/repl.md`): a line editor written in Zyl,
  history, highlighting, completion, and an ICNF interpreter that keeps
  `def` bindings live. Actors run interpreted: a spawn runs a compiled
  closure that interprets the body, the captured endpoints move with it,
  and the REPL joins an entry's actors before the prompt returns.
- Language server (`docs/lsp.md`): `zyl-lsp` runs the front end, the
  checks and the type checker and publishes every diagnostic, located.
  VS Code extension 0.5.0 (`editors/vscode/`).
- `install.sh` installs the compiler, REPL, server, `rt.zo` and the
  stdlib into `~/.zyl` (or `$ZYL_HOME`); `--with-vscode` adds the
  extension; `uninstall.sh` removes what it installed.
- Standard library: actor, allocator, atomic, collections (vec, map,
  set, slice), core (core, list, option, result, map, show), ffi, io,
  math (bits, words, bignum, hashes, symmetric and asymmetric
  cryptography, KDFs, RNG, secret), mlib, simd, testing, text (view),
  plus compiler, lsp and repl.
- Book (`book/src/`) and website (`website/`, Astro Starlight, which
  imports the book at build time), published by
  `.github/workflows/pages.yml`; `tests/scripts/site-examples.sh` runs the
  landing page's examples.

## Open Limitations (each confirmed open on 2026-09-28)

Language and compiler:

- `make-struct` is not typed (`E_CANNOT_INFER`); call the constructor.
- Match guards work only on literal arms: after a `range` a guard is
  `E_ARITY_MISMATCH`, on a constructor arm `E_NESTED_PATTERN`, and a
  guard naming a top-level `def` is `E_UNBOUND_VARIABLE` (book §6.5).
- Regions: object classes are field-insensitive, so they
  over-approximate; values that escape into the heap live until exit;
  Global and Circular are names only; the interpreter ignores regions,
  so `with-region` limits hold only in compiled code; the checker does
  not distinguish byte-buffer regions.
- Types: `<` on ADTs is a type error (use `Ord.compare`); the
  interpreter's checking mode sees Bool, Unit and ADTs as words.
- Native backend: Float arithmetic, `print`, closures, `try` and
  `with-region` scopes keep a function on the stack machine; no MIR
  optimization pass and no general bounds-check elimination; jumps are
  always rel32.
- Tail calls are not jumps for stack arguments beyond the caller's own,
  inside `try`/`catch` or `while`, or in frame-wiping (Secret)
  functions. The interpreter runs tail calls in constant stack unless
  the result is a String or Float.
- `Secret`: heap erasure is explicit (`zeroize`, `wipe`); taint crosses
  a call only where the callee's parameters are annotated.
- Diagnostics with no source node stay unlocated: `--locked` capability
  growth, `E_CODEGEN_BUFFER_FULL`, and the lock/store/index/CLI/MVS
  errors about files.

Concurrency:

- An endpoint nested inside a captured value does not move at spawn.
- Send-capability is the syntactic let-mut rule, not a type.
- Capability-mediated sharing (a shared region of TCap or atomic
  values, read-only pages between actors) is not built; the atomic
  byte-buffer operations exist.

Runtime and linking:

- Hosted programs link with `cc`; on the runtime's exit paths
  (`zyl_exit`, panic) a foreign library's own `atexit` handlers do not
  run.
- `rt.zo` is written with mode 0755 (the only write entry).
- BLAKE3 uses the portable compression function. There is no ctgrind or
  valgrind instrumentation; `verify/timing.py` is the statistical
  substitute.

Package system:

- The default index `https://github.com/zyl-lang/index` is not hosted;
  `ZYL_INDEX` selects any git index and `zyl publish --index DIR` adds
  signed versions to one.
- `deny-capabilities` and the capability pass apply only to packages
  with a manifest.
- Paths and URLs with characters outside `store-safe`'s set are refused
  rather than quoted.

REPL and language server:

- A deadlock ends the REPL session, as it ends a program. The 1024-actor
  limit counts every actor a session has spawned.
- Channels, endpoints and other opaque handles print as numbers.
- Heavy numeric work is slow and memory-hungry interpreted.
- The language server does not run the package capability check;
  checks before the type checker stop at their first problem; positions
  are byte columns, not UTF-16 code units; hover shows declared, not
  inferred, types (`docs/lsp.md`).

## Open Work (prioritized)

1. **Native backend**: Float arithmetic in `xmm` registers, `print`,
   closures and indirect calls, `try` and `with-region` on MIR, then
   remove the stack machine's expression code; MIR-level optimization
   and bounds-check elimination.
2. **Match guards** on range and constructor arms, and guards that name
   a top-level `def`.
3. **Concurrency**: move endpoints nested in captured values; a typed
   Send capability; capability-mediated sharing.
4. **Tooling**: capability check and inferred-type hover in the language
   server, UTF-16 positions; typed printing of opaque handles in the
   REPL.
5. **Packages**: host the default index.
6. **Runtime**: SIMD BLAKE3; hosted links through the Zyl linker.

Decisions already taken (do not reopen): inline assembly is rejected in
favour of the deterministic intrinsics (`bit-popcount` and friends, spec
§21.13, and `stdlib/simd`); `ffi-call` stays the escape hatch.

## Constraints for Compiler Source Written in Zyl

The full list, with examples, is `rules/boot-lifted-constraints.md` in
the zyl-skill repository (`~/git/larry/zyl-skill`).

1. Exhaustiveness is checked per ADT (`E_NON_EXHAUSTIVE_MATCH`). A
   catch-all arm must come last (`E_UNREACHABLE_MATCH_ARM`). An arm head
   that names no constructor is a catch-all binding, so a misspelled
   constructor in the last arm matches everything.
2. `_` is the discard and may repeat; `_`-prefixed names are exempt
   from the unused, shadowing and duplicate-parameter checks.
3. Prefer flat `begin` sequences and recursion over deep nesting.
4. `buf-append` appends at `strlen(dst)`; start from fresh buffers.
5. Parens must balance per file, and a nested opener never starts in
   column 1 (spec §1.6); check with `build/boot/zyl-self balance <file>`,
   which the Claude Code hook also runs, never by counting.
6. A match-arm body that combines a constant with two or more calls is
   `E_MATCH_ARM_COMPLEX`; bind the calls with `let` first.
7. New syntax, and a new runtime entry the compiler itself calls, land
   in two steps (`docs/self-hosting.md`).

## Pointers

- Self-hosting, seeds and reseeding: `docs/self-hosting.md`
- Architecture decisions: `docs/architecture-decisions.md`; rationale:
  `docs/design-rationale.md`
- Codebase map: `docs/codebase-map.md`; pipeline:
  `docs/compiler-pipeline.md`; developer guide: `docs/developer-guide.md`
- Tests: `docs/regression-tests.md`
- Errors: `docs/errors.md`, `docs/error-system-architecture.md`
- Types: `docs/sound-types-design.md`; regions: `docs/regions-design.md`;
  native backend: `docs/native-backend-design.md`; runtime:
  `docs/runtime-in-zyl-design.md`; concurrency:
  `docs/concurrency-determinism-design.md`
- Packages: `docs/package-management-design.md`
- REPL: `docs/repl.md`; language server: `docs/lsp.md`; cryptography:
  `docs/math-crypto.md`

## Milestone History

| Milestone | Date | Notes |
|-----------|------|-------|
| **Self-hosting fixed point** | 2026-08-25 | stage1 → stage2 → stage3, deterministic (stage1 built by the Rust bootstrap) |
| Zyl self-hosts every phase | 2026-09-10 | type inference and monomorphization ported to Zyl |
| stage2 fixed point from self-generated code | 2026-09-15 | real argv CLI |
| **Rust evicted** | 2026-09-17 | `--bootstrap-from-self`; Rust archived, later removed (`b8bc283`) |
| Language server | 2026-09-19 | `stdlib/lsp/`, `zyl-lsp` |
| `stdlib/math` and the `Secret` capability | 2026-09-22 | cryptography library; constant-time checker |
| **Package system (spec §31)** | 2026-09-23 | MVS, lock, store, signed index, capabilities |
| REPL with an ICNF interpreter | 2026-09-23 | live bindings, structural printing, checked against codegen |
| Compiler built through module resolution | 2026-09-24 | bundle and `assemble.py` retired |
| Real regions | 2026-09-24 | frame regions, escape analysis over ICNF, `with-region` |
| **Sound HM type checking** | 2026-09-25 | `type_annotate.zyl` |
| Native backend | 2026-09-25 | MIR + linear scan, inlining, in-place reuse |
| **The runtime is Zyl** | 2026-09-28 | `runtime/actor_runtime.c` deleted |
| **No libc** | 2026-09-28 | static programs on the runtime's own allocator, threads and `_start` |
| Deterministic concurrency | 2026-09-28 | Kahn channels, deterministic and chaos schedules |
| Deterministic intrinsics | 2026-09-28 | bit intrinsics, `stdlib/simd` |
| Zyl assembler and ELF linker | 2026-09-28 | no cc/as/ld for freestanding programs; cached `rt.zo` |
| Interpreted actors | 2026-09-28 | the REPL and `zyl eval` run `spawn` and channels |
