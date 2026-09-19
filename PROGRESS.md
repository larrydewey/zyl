# Zyl Progress Tracker

## Current Session (2026-09-19)

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

## Current Session (2026-09-15, final)

**Stage2 segfault FIXED. CLI working. Self-hosted fixed point blocked by pre-existing codegen bug.**

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

**Files changed:** `stdlib/compiler/type_inference.zyl`, `stdlib/compiler/region_inference.zyl`, `stdlib/compiler/icnf.zyl`, `selfhost/driver.zyl`, `stdlib/compiler/codegen.zyl`, `stdlib/compiler/icnf.zyl`, `runtime/actor_runtime.c`, `build/boot/stage2.s` (reseeded), `PROGRESS.md`.

## Current Session (2026-09-15, continued further)
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

## Current Session (2026-09-15, continued)

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

Verified after every fix in this follow-up: `./target/release/zyl
selfhost/zyl_selfhost_compiler.zyl --emit-asm` still completes cleanly
(takes ~2 minutes now — this is pre-existing Rust-bootstrap slowness on
the ~690KB self-host source, not a regression; see the already-documented
"Rust bootstrap too slow for test runner" note elsewhere in this file),
and `./run_regression_tests.sh --full --no-boot` is still green through
every test up to the already-known-slow `integration/selfhost-codegen`.

## Current Session (2026-09-15)

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

## Current Session (2026-09-13)

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

## Current Session (2026-09-13)

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

## Current Session (2026-09-12)

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

## Current Session (2026-09-11)

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

## Current State (2026-09-06)

**Self-hosting: COMPLETE, deterministic, verified. Regression suite: 27/27**
**in `--full` (all tests pass; `integration/selfhost-codegen` passes when**
**compiled with the self-hosted compiler — Rust bootstrap is too slow to**
**compile it within test timeout).**

```
./boot.sh    # stage1 -> stage2 -> stage3; stage2 output == stage3 output
```

**Latest session (2026-09-06): two Rust-compiler codegen fixes, two tests green.**

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

**Latest session (2026-09-10): Book documentation verity pass.**

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

**Self-hosting: COMPLETE, deterministic, verified. Regression suite 182/182 (unit_test) + 6/6 smoke.**

```
./boot.sh    # stage1 -> stage2 -> stage3; stage2 output == stage3 output
```

The Zyl compiler written in Zyl compiles itself end-to-end with a strict
byte-identical fixed point. Generic ADTs instantiate correctly with any
concrete type (per-site instantiation, positional instance naming);
per-site polymorphic functions work cross-module (shared list helpers
replacing per-module duplicates).

**Latest session (2026-08-27):**
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

## Roadmap (prioritized)

### P0 — Consolidate the self-hosted toolchain
- [x] **Boot build automation**: `boot.sh` runs the full loop (Rust `zyl`
      → stage1 → stage2 → stage3) and verifies the fixed point. *(done
      2026-08-25 — it immediately exposed that the earlier determinism
      check was vacuous; see Current State.)* Still to do: wire it into
      `run_regression_tests.sh --full`.
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
      Rust-class diagnostics:
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
- [ ] **Doc comments → documentation**: standardize `;|`/`;;` doc-comment
      convention already used across stdlib, then a `zyl doc` generator
      (modules → variants/functions → params/results/examples) emitting
      Markdown. The stdlib is already consistently documented — formalize
      it.

### P2 — Language services
- [ ] **LSP server** (depends on P1 structured diagnostics): initialize /
      hover (types from inference) / go-to-definition / document symbols /
      diagnostics publish / completion over env + module exports.
      Incremental plan: JSON-RPC stdio loop in Rust reusing src/parser.rs,
      then a Zyl-written LSP once the self-hosted one is trusted.

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
- [x] Contract injection overlay (spec §23, Phase 10) — implemented
      in Rust → Zyl; integrated into selfhost driver.
- [ ] Fix top-level `(def Name Expr)` misprint noted in REPL limitations.
- [ ] Warnings sweep (~160 → 0).
- [ ] Boot-binary CLI parity (`-o`, `--emit-asm`) and error messages with
      spans from the Zyl front end.

---

## Bootstrap Constraints (for code written in Zyl — see skills/zyl/SKILL.md)

1. ~~Keep function arities <=6~~ LIFTED (2026-08-25): stack-passed args work.
2. ~~A `match` may appear only as the entire body of a defn~~ LIFTED
   (2026-08-25): match works in value position; keep nesting moderate.
3. Match arms must enumerate every constructor (no wildcard fallback;
   unknown arms map to discriminant 0).
4. Pattern wildcards must be named dummies (`dN`), never bare `_`.
5. Prefer flat `begin` sequences and recursion over deep nesting.
6. `buf-append` appends at strlen(dst) (true append); fresh buffers only.
7. Parens must balance per top-level form — a missing closer silently
   nests subsequent defns inside the broken form.
8. No binop may directly combine TWO call operands — anywhere, not just
   match arms (stage>=2 miscompile: computes 0). Bind calls to `let`s
   first; in arm bodies keep ONE call and nest via icnf-add2.

---

## Milestone History

| Milestone | Date | Notes |
|-----------|------|-------|
| All 9 phases + linking | 2026-08 | structs, ADTs, floats, actors, closures, FFI, try/catch, I/O |
| Clean-room self-host front end | 2026-08-24 | recursive ADTs + structural match end-to-end |
| stage1 compiles own source | 2026-08-24 | first boot build |
| **Self-hosting fixed point** | **2026-08-25** | **stage1→stage2→stage3, deterministic** |
| r15-align SIGSEGV fix (codegen) | 2026-09-06 | rsp-stash frame slot replaces r15 save/restore; option-flatmap green |
| `_t_` constructor lowering fix (ast) | 2026-09-06 | underscore-prefixed ADT variants lower to MakeVariant; regression/types green |
| **selfhost-codegen test fixed** | **2026-09-06** | **passes with self-hosted compiler; Rust bootstrap too slow for test runner** |
| Contract injection (Phase 10) | 2026-09-09 | parser + contract_injection.rs + pipeline integration complete |
| Contract injection (Zyl) | 2026-09-09 | stdlib/compiler/contract_injection.zyl in structural form; used by selfhost driver |
| **Type inference ported to Zyl** | **2026-09-10** | **Hindley-Milner + capability types + trait resolution + occurs-check** |
| **Monomorphization ported to Zyl** | **2026-09-10** | **Full monomorphization using type inference data; all regression tests pass** |
| **P3.5 complete: Zyl self-hosts all phases** | **2026-09-10** | **boot.sh fixed point holds; Zyl compiler compiles itself end-to-end** |
| Book documentation verity pass | 2026-09-10 | ch13 rewritten from runtime-verified constructs; appendix B braces fixed; ch11 §11.3 corrected; book.toml builds with zero warnings |

### Appendix: Bootstrap bug sweep that reached the fixed point (2026-08-24/25)

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

---

## Session N+1: stage1.bin now correctly self-compiles its own bundled
source end-to-end (major milestone). Full list of bugs found and fixed,
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

## Current Session (2026-09-17): feature-parity survey closed, Rust evicted

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

## Pointers

- Architecture decisions: `docs/architecture-decisions.md`
- Design rationale: `docs/design-rationale.md`
- Codebase map: `docs/codebase-map.md`
- Regression infrastructure: `docs/regression-tests.md`
- Historical phase details: `docs/implementation-status.md`
- Specifications: `specifications/` (v1.0–v4.1), `zyl_specification.txt` (v4.2)

---

## Future Work (deferred)

### Byte-level primitives (layout / zero-copy)
- `load-u8/u16/u32/u64` + `store-…` with explicit endianness
- `ByteSlice` / `ByteBuf` in tracked region
- Checked offset+length views that cannot outlive backing data
- Optional alignment assertions (static or runtime panic)
- Goal: common serialization/FFI/buffer work without general unsafe

### Deterministic region extension
- Closed registry of additional region kinds (fixed growth, alignment, policy)
- User code selects among audited kinds; no raw alloc/free function pointers
- Any OS-touching kind must be deterministic for given request sequence
- Goal: specialized allocation without breaking determinism

### Capability-mediated sharing (concurrency)
- Shared region holding only TCap (or new TAtomic) values
- Mutation only via atomics or temporary exclusive upgrade
- Typed/bounded channels with explicit ownership transfer
- Read-only shared pages for multiple actors
- Goal: high-performance patterns without unrestricted shared mutability

### Inline assembly (future)
- Capability- and region-aware asm interface
- Pointer-carrying registers respect existing type/region rules
- Goal: architecture-specific kernels that cannot manufacture illegal capabilities

### Ergonomic zero-copy views (regions)
- Short-lived region views over longer-lived data convenient
- Cover parsing, substrings, temporary array slices without full ownership transfer
- Goal: common zero-copy cases without Rust-style lifetime parameters
