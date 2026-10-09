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
- **The numeric model is implemented (spec §20, `docs/soundness.md` L8).**
  Int arithmetic is checked by default. A package opts out once with
  `(numeric wrapping)` or `(numeric saturating)` (a top-level form of a
  lone file, a line of `zyl.pkg`); `(numeric checked)` is legal and is
  the default spelled out. Checked `+ - *` trap with `E_OVERFLOW`
  (`add`/`sub`/`imul` then `jo` to a runtime stub) on every emission
  path, wrapping is modulo 2^64, saturating clamps; `wrapping+ - *` and
  `saturating+ - *` are explicit operators for any policy (a derived
  `Hash` uses `wrapping*`). A `/` or `%` whose divisor is not a nonzero
  literal is `E_PARTIAL_OPERATION`; `div!`/`rem!` stop with
  `E_DIVISION_BY_ZERO`, `div?`/`rem?` give `(Option Int)`, `INT_MIN / -1`
  is `E_OVERFLOW`, and no `idiv` can raise `#DE`. The folder and the REPL
  interpreter decide overflow before operating (`int_arith.zyl`); the
  accumulator transformation, speculative `if` arms and `lea` are limited
  to wrapping arithmetic. The compiler and runtime run under checked.
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
  release is a no-op: an Arena value carries its handle's generation, a
  destroy bumps it and reuses the handle, and a stale value is detected
  without being dereferenced (generational handles, 2026-10-09; they
  replaced keeping every destroyed 72-byte handle until exit).
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
  `--filter poison`: released region blocks refilled with `0xDE`, 131/131
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
- **Generated code is verified, and the verification is a phase.**
  `stdlib/compiler/verify.zyl` runs inside `compile-to-asm` on the emitted
  assembly, so every path to a binary — driver, LSP, REPL, package build —
  passes through it, and a violation aborts before any assembly is returned.
  It checks what the compiler's own reference scan validated: a write
  through `[rbp-M]` must have `M <= frame + 8` and be 8-aligned, where the
  frame is the bound code generation states in a `# frame N` annotation. On
  the compiler's own output that is 24,774 writes covered, zero violations,
  zero writes against an unstated bound, and 118,515 dynamic accesses
  *counted but not checked* — the census is reported as such, not as a pass.
  V3 (provenance and bounds) and V4 (region liveness) are not implemented
  and the evidence says so. Scanning stage2.s takes 0.14 s (faster than a Python reference of the same rules, at 0.26-0.32 s); `./boot.sh` runs
  in 14 s and the full suite in 56 s with the pass in it.
  `tests/verify_test.zyl` plants faults in hand-written assembly and is
  wired into the quick suite: a verifier run only on the compiler's own
  output cannot be told apart from one that does nothing, and that test is
  what found five real defects in the verifier itself, each of which had
  been producing a *passing* build with the check quietly not running
  (digits read backwards, `cmp` detection inverted, any `[r…` mistaken for a
  frame slot, the annotation read at the space before its digits, and local
  jump labels counted as functions). See `docs/verifier-design.md`.
- **The verifier's verdict is cross-checked against a second
  implementation.** `verify/frame_oracle.py` re-derives the same rules in
  Python — a language this compiler does not emit, so a miscompilation cannot
  hide from it — and `verify/frame_oracle.sh` requires the two to agree field
  for field on the committed seeds, operand counts included: a scan that stops
  early reports fewer operands and still reports zero violations. It runs on
  every `--quick` and `--full`, and the oracle has its own selftest of eleven
  planted cases, so a rule that stops firing fails there first. The two checks
  have different targets and the distinction is the point:
  `tests/verify_test.zyl` catches bugs in the verifier, the oracle catches
  bugs in the compiler. Self-consistency is not evidence, because a subtly
  wrong rule is wrong consistently.
- **The region core is machine-checked, not just observed.**
  `verify/model.py` encodes the region allocator and the scope discipline
  from `runtime/rt/alloc.zyl` as a finite transition system and enumerates the
  reachable state space exhaustively (255,983 states at depth 10), proving
  no block is both owned and free, none is released while owned, a scope's
  blocks are all free once it exits, block counts balance, and the
  transition relation is a function — the point determinism bottoms out at.
  It re-reads the runtime source to confirm the model has not drifted, and
  `verify/model_selftest.sh` injects a double free to prove the checker
  fails when it should. `--filter determinism` runs it plus 120 programs
  compiled twice byte-for-byte.
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
- Structs: `(defstruct T ... (f ...))` (and `defstruct+`) generates a typed
  accessor `T.f` per field, `(defn T.f ((p T)) (struct-get p "f"))`, before
  type checking (`struct-accessor-forms`, `expr_inner.zyl`); a program defn of
  that name is `E_DUPLICATE_DEFINITION` naming the defstruct; in a package it
  is visible as its struct is. The LSP resolves hover and definition of `T.f`
  to the field and completes accessors after `T.`.
- FFI: `(extern "sym" (T...) R :timeout N)` is a default timeout; an
  `ffi-call` passing exactly the extern's parameter count takes it, one
  passing one more keeps its own (`ffi-default-timeout`, `expr_inner.zyl`).
  With neither, `E_FFI_TIMEOUT_REQUIRED` names both fixes.
- **A `Float` crosses the FFI boundary** (spec §16). An `extern` may
  declare `Float` for a parameter or the result: it is C's `double`, and
  the 64 bits move across unchanged, so an infinity, a negative zero and
  a NaN survive the trip. Nothing about the value is reinterpreted — the
  compiler emits the signature's ABI class mask in the request word the
  timed bridge takes (`ic-ffi-class-mask`), the worker places each
  argument word in the integer register, the `xmm` register or the stack
  slot the System V ABI names for it (`ff-place`, `zyl_rt_callmix` in
  `runtime/rt/ffitimed.zyl`), sets `al` so a variadic callee can spill
  the SSE registers, and reads a `Float` result out of `xmm0`. A
  signature with no `Float` masks to zero and takes the integer-only
  path, byte for byte what it took before, and the interpreter forwards
  the same word (`zyl_ffi_timed_argv`), so compiled and interpreted code
  cannot disagree. A `Float` *inside* a type is `E_TYPE_MISMATCH`: an
  aggregate is classified eightbyte by eightbyte and the compiler does
  not compute that class, which also rules out a `Float` callback
  parameter. Tests: `tests/regression/ffi-float.zyl` (compiled *and*
  interpreted), `tests/packages-build/native/app` (`double` in, `double`
  out, mixed classes past the registers), `tests/compile-fail/
  ffi-extern-float.zyl` and `ffi-callback-float.zyl`.
- Linking: a program with no foreign `ffi-call` and no native objects is
  a static executable with no libc, assembled and linked by the
  compiler itself (`asm_x86.zyl`, `elf_link.zyl`) against the cached
  runtime `rt.zo` (keyed by the BLAKE3 of `rt.s` + `start.s`, rebuilt
  when stale). A hello-world links in about 26 ms. A program that calls
  foreign C links hosted over libc's crt with `cc`, always with `-lpthread -lm`
  (`cli-link-hosted`), so `(extern "fabs" (Float) Float)` links as declared; a lone file
  has no way to pass a library of its own, and libm is what C library code reaches for.
  `boot.sh` links the compiler with `-lm` for the same reason one stage deeper: the
  interpreter's `dlsym(RTLD_DEFAULT, ...)` searches its own process. `ZYL_EXTERNAL_LD=1`
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
  node; labelled secondary spans on `E_MUT_CONFLICT`, `E_CAPABILITY_LEAK`,
  `E_PKG_CAPABILITY_VIOLATION` and `E_REGION_ESCAPE`; `--error-format=json`.
  The voice is held to `docs/diagnostics.md` (2026-10-02): an unbound name
  is reported once, with up to three close names (locals first), Zyl's
  spelling of another Lisp's name, or the `(use ...)` line that imports
  it, and nothing depending on it is reported; a type mismatch names the
  parameter, operator, condition or `main`'s result at the offending
  expression; a failed compile ends with `N errors; fix the first one
  first` (nothing after one error, nothing in JSON mode) and a located
  error prints without `PANIC:`; a standard-library warning is hidden
  while compiling a program (`ZYL_WARN_ALL=1` shows it); stdout is flushed
  before a panic or a test failure line. `tests/scripts/diagnostics-voice.sh`
  pins the probe program's output. `zyl explain CODE` gives a wrong
  program and its fix for the 30 most used codes
  (`tests/scripts/explain-examples.sh` compiles every pair); `zyl explain`
  lists every code by phase. The catalog is exactly the raised codes:
  31 dead codes were removed from it and from spec §28, and
  `verify/error-codes.sh` (`scripts/error-codes`) fails on drift either
  way. The self-build prints unused-parameter and shadowing warnings in
  the compiler's own modules.
- Partial operations are spelled (`docs/soundness.md`): a stdlib function
  that can panic ends in `!` (`vec-get!`, `vec-set!`, `vec-last!`,
  `slice-vec!`/`-sub!`/`-get!`, `view-slice!`/`-sub!`, the SIMD lane
  `get!`/`set!`, `option-expect!`, `result-expect!`), its total sibling in
  `?` (an Option), with no plain name. `vec-set!` at the length appends; past
  it is `E_INDEX_OUT_OF_BOUNDS` (it used to drop the write silently). String
  slicing stays total and clamps. `unused_check.zyl` makes a plain-named
  `defn` that calls `panic`/`zyl_panic` directly `E_PANIC_UNMARKED` in a
  program-facing stdlib module and `W_PANIC_UNMARKED` in a program; it sees
  direct calls only, and built-ins (division by zero, region exhaustion)
  are outside it.
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
- An uncaught panic prints a backtrace under its `PANIC:` line: the rbp
  chain, each return address named through the `zyl_syms` table codegen
  writes into every program, innermost first, 32 names at most, in both
  link modes (an actor's panic is re-raised at `actor-wait`, so it shows
  the joiner's frames); stdout is flushed first; nothing on a caught path, in JSON
  mode, or under a rendered `error[...]` diagnostic. Runtime frames,
  tail calls and inlined calls are not frames and are not listed; a
  push-only MIR function that calls now keeps rbp (fib +3%). The table
  is 113 KB (3.1%) of `zyl-self`. No source
  lines (`docs/runtime-in-zyl-design.md`, "Panic backtrace").

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
  manifest; a lone file compiles as `local/main`@0 and declares its
  capabilities with a top-level `(capabilities ...)` form (absent means
  none, enforced as a manifest's; a REPL session types the form). An
  `ffi-call` of a `zyl_*` runtime entry needs no `ffi` grant.

### Tools

- CLI (`drv-usage`): `zyl <file.zyl> [-o out] [--emit-asm]`, the package
  subcommands, `repl`, `eval <file.zyl>`, `doc [file|dir] [-o out.md]`,
  `balance [file|dir ...]`, `verify <binary>`.
  The installed `zyl` starts the REPL when given no arguments.
- Build provenance (`docs/build-provenance-design.md`, verified
  2026-10-02): `zyl build --sign-with <key>` appends a trailer -- a
  COSE_Sign1 (Ed25519) over a canonical CBOR record of §31.12's four
  inputs, the asm hash, the image hash and the verifier's census -- and an
  unsigned build is byte-identical to before. `zyl verify <binary> [--key
  k] [--package p] [--anchored]` reads it back with a bounds-checked CBOR
  reader (`encoding/cbor.zyl`) and reports EVIDENCE and ATTESTATION apart:
  re-derived are the image hash, the verifier's own compiler hash and every
  hash in `<binary>.buildinfo` with `final-hash` recomputed from its four
  input strings; the census is reported as *attested*, because the frame
  bound is not in the image and the image holds the runtime the census never
  saw. Three trust modes, each with its own verdict word -- the pinned key
  of `--package` is VERIFIED, a `--key` is ATTESTED, the record's own kid is
  SELF-ASSERTED -- and `--anchored` fails anything weaker. Tests:
  `cbor_test`, `cose_test`, `provenance_test`, `provenance_trailer_test`
  (each with a cbor2/`cryptography` cross-check script) and
  `tests/scripts/prov-sign.sh` / `prov-verify.sh` in the quick suite.
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
- Checked arithmetic costs speed where the backend used to reassociate:
  the accumulator transformation (`(+ x (self ...))` tails) applies only to
  wrapping `+ *`, so `bench/fib.zyl` under `(numeric checked)` runs about
  60% slower than the old wrapping build (0.114 s to 0.181 s); `loop` is
  +4%, `sieve` unchanged. A checked accumulator would need an overflow test
  that fails at the same operation the source order would.
- `atomic-add`/`atomic-sub` wrap like the hardware's `xadd` whatever the
  numeric policy; they are not covered by `(numeric checked)`.
- Native backend: Float arithmetic, `print`, closures, `try` and
  `with-region` scopes keep a function on the stack machine; no MIR
  optimization pass and no general bounds-check elimination; jumps are
  always rel32.
- Tail calls are not jumps for stack arguments beyond the caller's own,
  inside `try`/`catch` or `while`, or in frame-wiping (Secret)
  functions. The interpreter runs tail calls in constant stack unless
  the result is a String or Float.
- `Secret`: heap erasure is explicit (`zeroize`, `wipe`). Taint fails
  closed across a call to a top-level `defn` (`E_SECRET_UNANNOTATED`),
  but not across a call through a function value or a trait method, and
  the crypto entry points take plain `Words`, so nothing seeds taint
  there. The annotated bignum/curve mask helpers wipe their frames and
  so run on the stack machine, not the MIR backend.
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

0. **Memory profile** (done 2026-10-09, spec §9.3). `(memory reported)`
   warns `W_HEAP_ESCAPE` at each allocation in the program's own source
   that region inference sends to the process heap (where it lives until
   exit), labelled with where it escaped; `(memory bounded)` makes each an
   `E_REGION_ESCAPE`. Default `unbounded`. It is opt-in because the
   default would be noisy: across the 132 regression and smoke programs,
   27 have a heap escape under `bounded`, mostly values passed to a
   function value (the analysis gives an unknown callee's arguments H), a
   runtime ref cell, or a caught error. Top-level `def` values are exempt
   (the `zyl_global_put` escape is recognised), and so are sites inside
   the standard library. Next: the unbounded-recursion check and a
   per-function worst-case figure under `bounded`.

0a. **Stack overflow is a report, inside the budget** (done 2026-10-09,
   spec §14). main's stack was a 64 GiB lazy mapping outside the memory
   budget: 3e9-deep non-tail recursion ran to 24 GB, and overflow would
   have been a bare SIGSEGV after the machine ran out. Now, under a budget,
   the stack is a quarter of it (at least 64 MiB) and charged to it, and a
   SIGSEGV handler on an alternate stack (`zyl_segv_handler`,
   `runtime/rt/actor.zyl`) turns a fault beside the stack pointer or in the
   guard page into `PANIC: error[E_STACK_OVERFLOW]`, after flushing
   stdout; any other fault is re-raised with the default action. Every
   thread has its alternate stack in TLS, so an actor's overflow is reported
   too (its help says an actor's stack is fixed). The default budget is 80%
   of *total* memory, or of the cgroup v2 `memory.max` when smaller: it was
   80% of *available* memory, so another process's usage decided whether a
   compile passed (one did: a 47 GB process cut the budget to 186 MB). Arena
   blocks now grow geometrically from 64 KiB up to the block size, so a
   1 GiB arena is charged for what it uses, not 1 GiB at creation.

0c. **Generational arena handles** (done 2026-10-09). An `Arena` value is
   its handle's address with a 15-bit generation in bits 48..62; a destroy
   frees the blocks, bumps the generation and puts the handle on a free
   list, so a destroyed arena no longer costs 72 bytes until exit. A stale
   value is detected without being dereferenced: a second destroy is a
   no-op, `zyl_arena_live` is false, and an allocation through it is
   `E_USE_AFTER_FREE` (it used to allocate a fresh block). A handle at
   generation 32767 is retired, not reused. Region-placed handles
   (`zyl_arena_create_scoped_r`) are never pooled. The next steps for
   reclaiming memory -- defunctionalising known function values, borrowed
   parameters, FP² checking, Perceus, reachability types -- are planned in
   `docs/memory-reclamation-roadmap.md`.

0b. **Brackets repaired from indentation** (done 2026-10-09). `zyl fmt
   --infer-parens` and an LSP quick fix (`stdlib/text/parens.zyl`). A
   balanced top-level chunk is never touched; an unbalanced one gets the
   single edit that balances it and best agrees with its indentation, with
   Parinfer's indent mode as the fallback and as the reference the edit is
   scored against. Measured by mutating real files (one closer deleted or
   added at a line end): indent mode alone restored 92%, because it throws
   away the author's closers and misreads flat `(Cons`/`(if` chains and
   bodies indented from their line rather than their opener; the minimal
   edit restores about 98% (1173 of 1200), and the misses are readings the
   indentation cannot decide. The balance diagnostics' own quick fixes were
   never edits: `lsp-action-any` serialised only an action's title, so
   they did nothing when applied. It now sends the kind and the edit.

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
7. **Provenance**: a frame table in the image (a `.zyl_frames` section of
   (function offset, frame size) pairs, found by magic like the trailer)
   and the runtime's census recorded at `rt-cache` time, so `zyl verify`
   can re-derive the census it now only repeats as attested. Touches
   `codegen.zyl`, `asm_x86.zyl`, `elf_link.zyl`; one reseed. The
   `zyl_syms` table (a `.long sym - .` pair per function, found by a
   weak symbol) is the shape to copy.
8. **Backtrace source lines**: a per-call-site table (a label after
   each `call`, its offset and the ICNF node's span) looked up like
   `zyl_syms`; about 110k entries for the compiler. Not started.

9. **Secret erasure**: wipe a region block when it is released, so a
   secret is gone with the frame that held it; then have `codegen.zyl`
   zero the secret locations it alone knows about -- parameter slots,
   spill slots, temporaries, callee-saved registers -- on the return
   path; then insert erasure where escape analysis proves an escaping
   value dies. Layer 1 is sound because a released frame region holds no
   live value (results go to the caller's region), and needs no language
   change. Not started; the plan is in `docs/secret-erasure-design.md`.
   **Decided 2026-10-02: all three layers**, not a partial job — layer 1
   alone leaves heap and Global secrets unerased and would make the
   book's frame-wipe claim true only where it is least needed. The cost is
   known and is the point: layer 2 needs a Secret lattice threaded
   through monomorphization, ICNF lowering and codegen, because
   `secret_check.zyl` works on the AST and nothing downstream knows which
   MIR locations hold a Secret. Layers 2 and 3 each cost a reseed. Build
   layer 1 first and re-measure, then layer 2, then layer 3.

10. **Discussion: TCap and TMut.** Not a bug list -- an argument that has
   not been had. The aliasing rule is enforced syntactically, not by the
   type system: `mutability_check.zyl` reads `let` as TCap and `let-mut`
   as TMut and rejects `set!` on anything else (`E_MUT_CONFLICT`),
   `linearity.zyl` handles moves (`E_MOVE_VALUE`), and the unifier has
   no capability polarity (`docs/architecture-decisions.md` A7). So the
   question to settle is what the *types* should say: whether TCap/TMut
   become real annotations the checker carries (and what that costs the
   unifier), or whether the syntactic enforcement is the design and
   should be documented as such rather than described in the vocabulary
   of capabilities. Until that is answered, the book and the spec
   describe an invariant the implementation reaches by other means.
   **Decided 2026-10-02: retire the terms.** `TCap`/`TMut` leave the
   spec, the book and the docs; the invariant is stated as what it is --
   Zyl has no in-place mutation, so every `let` binding is immutable and
   rebinding is the only update -- which is stronger than an aliasing
   invariant and is true. `AGENTS.md` already says so informally. The
   reason not to make them real annotations: structs forbid field
   mutation, so TMut could never flow through a field, and the caps would
   exist only in the positions `let`/`let-mut` already cover, at the cost
   of capability polarity in the unifier and in `T.==`. What survives:
   `E_CAPABILITY_LEAK` in `mutability_check.zyl`, and the one real
   capability, `Secret`, whose obligations the compiler enforces. Also
   update the spec, where "capability" means two different things (§25
   operational, §10 fictional).
11. **Document memory poisoning properly.** Done 2026-10-02:
   `docs/memory-poisoning-design.md`. It covers what release actually does
   (big blocks are `munmap`ped and fault on their own, so only pooled
   blocks need help), the three paths that reach `rt-poison` (frame
   release, `with-region`, and `zyl_region_recycle` for self tail calls --
   one path, so a new release path cannot forget), why the fill starts
   past the 24-byte block header the free list still needs, the
   `ZYL_REGION_POISON` levels and why only the exact strings `1` and `2`
   enable anything, why page protection was built and withdrawn (18 of 125
   faulting, all ambiguous), what `poison-selfhost` adds, and both limits
   -- including that the adversarial attempt to manufacture a positive
   control produced nothing, because the escape path promotes an allocation
   to a longer-lived region rather than leaving it dangling. It also
   records the cost in a normal build: the fill is skipped, the
   environment scan that reads the level is not.
   Two falsehoods fixed on the way. A comment in `runtime/rt/misc.zyl`
   described the withdrawn `mprotect` version as the mechanism and named
   `verify/memcheck.sh` as the thing that enables it; no `mprotect` call
   exists anywhere in the tree and memcheck sets no such variable. And the
   program counts said 125 where the gate actually runs 131. Cross-linked
   from `docs/soundness.md` L2, `docs/regions-design.md`,
   `docs/secret-erasure-design.md` and `AGENTS.md`.
12. **Language server leak.** Fixed 2026-10-08. A `zyl-lsp-bin` left
   running by an editor reached 37 GB RSS in 65 minutes. Measured with a
   driver that sends N edits and reads RSS (callgrind call counts located
   the allocators): every analysis of an 8-line file cost **4.5 MB that was
   never released**, 5 MB per `didOpen`, and 9 kB per hover. The causes, in
   order of size:
   - The whole front end ran on the process heap, and the parse arena was
     one 1 GiB arena for the life of the server. Now each message is read
     and answered with the heap switched to a scratch arena (the REPL's
     `zyl_heap_swap` pattern); the document map and workspace roots are
     copied into the spare of two state arenas, and the scratch and the old
     state arena are reset. Each analysis runs in an arena of its own,
     which its `DocState` owns; replacing or closing a document retires it
     (`dm-dead`) and the loop destroys it once the message is answered.
     The handlers return an `LspStep` instead of calling the loop, so the
     server no longer recurses through a 7-argument call that was not a
     jump.
   - The type checker made about 25 malloc'd tables per run (`ta-st-new`)
     and the arity check one more (`ac-collect`); both are now
     process-wide tables emptied per run, as the checker's other tables
     already were.
   - The NUL-byte check read every module file into a malloc'd buffer to
     learn its length, on every analysis; it now asks `zyl_file_size`
     (`stat`, a new runtime entry).
   After: about 1 kB per edit and 0.5 kB per hover, from arena handles a
   destroyed arena keeps on purpose. Then (2026-10-09) a `StringBuffer`'s
   ref cells moved into its own arena (`zyl_ref_new_in`), its handle into the
   region of the value holding it (`zyl_arena_create_scoped`, placed by
   region inference like the `_r` collection entries), and "released" became
   the handle's own flag (`zyl_arena_live`); the server pools its
   per-document arenas, resetting rather than destroying them; and a closed
   document's source text is forgotten (`zyl_source_forget`). The source
   table was a fixed 256 slots that never freed, so the 257th distinct file an
   editor opened got no source id and unlocated diagnostics; it is 1024
   slots, reused when freed. `tests/lsp/lsp_memory_test.py` (in `--full`)
   holds it: edits 0.06 kB, hovers 0.00 kB, open/close settling to 0.06 kB
   per message. SIGTERM is honoured in every run; the
   original report of it being ignored did not reproduce.
   Found on the way: out of memory *reporting* allocated (`zyl_arena_oom`
   formatted its numbers on the heap it had just exhausted), so a compile
   that hit the budget recursed until it segfaulted instead of printing
   `E_OUT_OF_MEMORY`. The report is now written in pieces from a static
   buffer. Still open: the budget is 80% of *available* memory, read at
   start, so the same compile can pass or fail with the machine's load,
   and arena blocks are charged when reserved, so a 1 GiB arena costs
   1 GiB of budget before anything is written.
13. **A buffer is a valid argument to a foreign call.** The FFI
   abstraction layer this project needs already exists and is enforced --
   `ffi-raw-p`, the `E_FFI_RESTRICTED` raw-memory set, and "an extern may
   not retype a runtime entry" mean programs get a typed stdlib function
   and the raw entry behind it is unreachable. What is missing is that the
   layer leaks in one place: `(bytebuf-ptr b)` is written by hand at every
   call site, and once a program holds that address, `alloc-offset` and the
   `alloc-read-int` family let it walk off the end of the buffer. The
   typed surface over a buffer is already complete -- `load-u8`..`store-i64`
   and all six `bytebuf-atomic-*` take `(buf, offset)` -- so user code
   never needs a pointer to *manipulate* bytes. It appears in exactly two
   situations: being handed to C, and being received from C in a callback.
   The first is not fundamental. Let an extern parameter be declared as a
   buffer, `(extern "qsort" ((ByteBuf) Int Int (Fn (Ptr Ptr) Int)) Unit)`,
   and have lowering insert `bytebuf-ptr`; the address then exists only in
   generated code. No new type, no cast, no runtime feature, no new syntax
   (`ByteBuf` already names a type in that position); ~100 lines in the
   type pass and lowering plus tests, and one reseed. The reverse direction
   stays `Int`, because a pointer C hands you is a word. A `Stack` buffer
   passed to C is still `E_REGION_ESCAPE` if C could retain it.
   Deliberately *not* a generic `(c-call "sym" :buf :varargs :fn ...)`
   marshaller: it re-implements the type system as a positional
   mini-language whose surface is widest exactly where C is hardest
   (varargs, callbacks, struct-by-value), which fails at runtime in the one
   place this language claims static safety. Typed wrappers fail at
   compile time. Recorded 2026-10-02; do it after item 9's layer 1.
14. **`Ptr` is a spelling, not a type.** Done 2026-10-02, and it came out
   of item 13's prerequisites: with `alloc-malloc` restricted, the
   diagnostic names `bytebuf-ptr` as the replacement, but `bytebuf-ptr`
   was typed `Int` and could not be passed to a `Ptr` parameter, so the
   advice was false. `Ptr` now resolves to `Int` in `ta-conv-name-1` (type
   annotations) and `ta-sig-word` (extern declarations and the runtime
   signature table). The reasoning is recorded at `ta-builtin-type`: the
   runtime has no pointer representation -- `zyl_cstr_of_word` is
   literally `(defn zyl_cstr_of_word (w) w)` -- an address is a word, and
   making `Ptr` nominal would need a Ptr-to-Int coercion for the
   arithmetic every real use needs (`elf_link.zyl`), and a cast is the
   surface this language deliberately does not have. What is enforced is
   where an address may *come from*: `bytebuf-ptr`, `ffi-pin`, or a
   foreign call, never memory nothing tracks. Open question, not decided:
   `alloc-offset`, `alloc-incr`/`decr` and `alloc-read-int`/`write-int`
   still let a program do unchecked arithmetic on an address it legitimately
   obtained. Whether that is the same hole `alloc-malloc` was is the next
   question on this thread.
15. **Published documentation accuracy, beyond arenas.** Fixed 2026-10-02
   for the arena/malloc surface: `website/src/content/docs/{learn/ffi,
   learn/data-structures, learn/ownership-regions-capabilities,
   systems/cryptography, reference/ffi, reference/region-memory,
   appendix/stdlib, appendix/spec-ref, reference/modules}.md` and the
   book's `ch12-ffi`, `ch22-ffi`, `appendix-b/e/f`. Every code sample
   touched was extracted and run through `zyl check`; several could not
   compile before (`arena-create` is `E_FFI_RESTRICTED`, and
   `sha256-hex-of-string` has taken only a `String` since the arena was
   dropped from `math/`). The wider finding is not fixed: those pages also
   documented collection APIs that no longer exist under those names
   (`vec-create`, `vec-create-default`, `map-*`; the current ones are
   `vec-new`/`vec-new-cap`, `intmap-*`, `set-create`), and
   `reference/ffi.md` and `learn/ffi.md` still contain fragments that are
   not standalone programs. A periodic check that every `zyl` fenced block
   in `website/` and `book/` compiles would keep this from rotting again;
   not started.

16. **Documentation sweep** (done 2026-10-02). Thirteen agents reviewed
   all 126 tracked markdown files -- `book/src/**`, `docs/**`, `spec/**`,
   `README.md`, `zyl_specification.txt` -- in disjoint sets, against a
   shared protocol, after I had extracted every fenced Zyl block (981) and
   checked it: 296 failed, of which 114 looked like real programs. All 114
   are now either fixed or explicitly marked as deliberate demonstrations
   of a diagnostic. The structural findings were worth more than the
   individual fixes:
   - **The website is generated.** `website/src/content/docs/{learn,
     reference,internals,systems,tooling,appendix}/` is gitignored and
     written by `website/scripts/import_book.py` from `book/src/**`, which
     also rewrites inter-chapter links and turns `lisp` fences into `zyl`.
     Editing a generated page is wasted work; `book/src` is the source of
     truth, and only `index.mdx` and `404.md` are tracked. Run the importer
     after changing a chapter.
   - **`error` does not abort.** `stdlib/core/result.zyl` defines
     `(defn error (msg) (Err msg))`; `panic` is the form that raises and
     unwinds to the nearest `try`/`catch`. Several chapters had it
     backwards.
   - **`defun` is not recognised** (it is reserved): top-level
     `(defun f ...)` reads as a call and `f` is unbound. Note how this is
     easy to get wrong -- nesting it inside a `begin` fails for a different
     reason (form placement), which looks like it works.
   - The **frame wipe is real**: `secret_check.zyl`'s `sc-mark-wipe` feeds
     `codegen.zyl`'s `cg-wipes-frame`, which emits `rep stosq` over the
     frame and suppresses the tail call. That is a different mechanism from
     region release, which does not wipe. `docs/secret-erasure-design.md`
     had claimed no frame wipe existed; it was wrong and is fixed.
   - Counts in the docs were stale in several places (the regression suite
     was documented as 377 tests and is 495; the error-code catalog as
     130-133 and is 124; test counts in the README and in
     `docs/verifier-design.md`), as were several stdlib API names
     (`vec-create`, `vec-create-default`, `map-*` for the Int map).
   - **`zyl check` was weaker than a build**: it accepted `(/ 7)` (a build
     reports `E_ARITY_MISMATCH`) and a file with no `main`, and it stopped
     before region inference, missing `E_REGION_ESCAPE`. Fixed 2026-10-09:
     it runs everything but code generation and linking, a lone file
     without `main` is a located `E_NO_MAIN` (in a build too, where it was
     a `PANIC: E_LINK_UNDEFINED: _ZYL_main`), and every compile-fail and
     packages-fail test now also runs `zyl check` and requires the same
     code.
   - A `TCap`/`TMut` retirement (item 10) was carried through
     `zyl_specification.txt` §4.3/§7.2/§7.4/§10/§26/§28, `AGENTS.md`,
     `spec/06`, `spec/07` and the chapters. The terms survive only where a
     document quotes the compiler's own diagnostic strings, which still say
     "TMut"; those strings are output history and were left alone.
   - Three wrong strings in `stdlib/lsp/builtins.zyl` (editor
     completions) were fixed: `for` was documented as
     `(for (i start) limit body)`, `when` as an eager core function (it is
     a lazy special form), and `TCap`/`TMut` were offered as capability
     types. `unless` and `numeric` were missing. One reseed.
   Still open, all verified and reported: `zyl_specification.txt` §4.9
   still lists `error` among the non-returning forms;
   `stdlib/math/secret/secret.zyl` still describes `zyl_zeroize` as a C
   helper (it is Zyl now, `runtime/rt/crypto.zyl`), as does
   `book/src/part4/ch33-secrets.md`; `cli-manifest-str` drops
   `deny-capabilities`, `features`, `overrides`, `native` and `exclude`
   when `zyl add` re-serialises a manifest; `error_codes.zyl` and
   `mutability_check.zyl` still use the retired names in their messages;
   `tests/_t2.s` is a tracked generated assembly file nothing runs.
   Not done: a CI-style check that every fenced block in `book/` and the
   generated site compiles. The one-off sweep found 296 failures, so this
   rots again without one.

Decisions already taken (do not reopen): inline assembly is rejected in
favour of the deterministic intrinsics (`bit-popcount` and friends, spec
§21.13, and `stdlib/simd`); `ffi-call` stays the escape hatch. That
rule is on the *language surface* -- a program gets no `unsafe` and no
asm -- and not on the compiler, which is the assembly: compiler-emitted
erasure is ordinary. Who writes the zeros is decided by who knows where
the bytes are, not by trust in the emitter.

## Constraints for Compiler Source Written in Zyl

The full list, with examples, is `rules/boot-lifted-constraints.md` in
the zyl-skill repository (`~/git/larry/zyl-skill`).

1. Exhaustiveness is checked per ADT (`E_NON_EXHAUSTIVE_MATCH`). A
   catch-all arm must come last (`E_UNREACHABLE_MATCH_ARM`). A lowercase
   arm head that names no constructor is a catch-all binding; a
   capitalized one that no type declares is `E_UNKNOWN_CONSTRUCTOR`.
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
  `docs/math-crypto.md`; secret erasure (planned):
  `docs/secret-erasure-design.md`; region lifetime and the poison gate:
  `docs/soundness.md` L2, `docs/regions-design.md`, `verify/poison.sh`

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
| Partial operations spelled | 2026-10-02 | `!`/`?` stdlib pairs, `E_PANIC_UNMARKED` |
