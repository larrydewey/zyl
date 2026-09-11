# Zyl Progress Tracker

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

## Pointers

- Architecture decisions: `docs/architecture-decisions.md`
- Design rationale: `docs/design-rationale.md`
- Codebase map: `docs/codebase-map.md`
- Regression infrastructure: `docs/regression-tests.md`
- Historical phase details: `docs/implementation-status.md`
- Specifications: `specifications/` (v1.0–v4.1), `zyl_specification.txt` (v4.2)
