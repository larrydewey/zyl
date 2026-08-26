# Zyl Progress Tracker

## Current State (2026-08-25)

**Self-hosting: COMPLETE, deterministic, verified.**

```
./boot.sh    # stage1 -> stage2 -> stage3; stage2 output == stage3 output
```

The Zyl compiler written in Zyl compiles itself end-to-end with a strict
byte-identical fixed point. Programs compiled by stage2/stage3 run correctly
(ADTs + match, HOF calls, FFI, recursion, arithmetic, floats). Regression
suite 24/24.

How the last two gaps were closed:
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
- [ ] **For-loop supply-node leak corrupts return values** *(diagnosed
      2026-08-25; LAST remaining failure class — now the only thing between
      us and 27/27)*. For/While cond+body supply nodes AND For init-binding
      nodes leak into the function's top-level ICNF body via global_stmts
      during conversion. Codegen's trailing-pure emission re-emits them
      AFTER the function's result load — `mov eax, 0` from a leaked Const
      clobbers the return value (map-remove hit path then dereferences a
      garbage handle -> SIGSEGV in unit_test AND collections). Repro:
      `(let-mut d 0 (begin (for (j 0) (< j 3) ...) d))` returns 0 not 3;
      inserting any statement before the tail read masks it.
      ATTEMPTS REVERTED (both regressed control-flow/for-loop-early-exit):
      (a) codegen skip-nonfinal-pure rule — skipped the real tail load when
      leaks followed it; (b) central ICNF prune of embedded duplicates —
      early-exit depends on placement/mutation ordering of loop-var nodes
      shared between init and body. PROPER FIX requires dependency-ordered
      emission: build func.body so every node appears exactly once, ordered
      after its operands and before its consumers, with loop-carried vars
      (i set! inside the body that the cond reads) kept as slot writes —
      i.e. SSA-with-loops semantics, not list dedup. Suggest tackling with
      an explicit pass over convert_expr_to_stmts output at Defn
      finalization, walking the embedded subtrees as the backbone.
- [x] **Float ABI fixes (Rust bootstrap, 2026-08-25)**: several
      pre-existing codegen bugs fixed and verified end-to-end:
    - rodata collectors did not recurse into `Match` arm bodies —
      float/string literals inside arms referenced labels that were never
      emitted (undefined `.flt_N` at link time). Both collectors now walk
      arm bodies.
    - `(print <float>)` printed garbage ints: Print's type detection
      relied on ICNF `typ`, which is almost always `None`.
      `node_looks_float` is now a method that follows Assign/Load chains,
      recognizes Float-typed params (`float_params`) and Float-returning
      calls (`func_returns`); the Print handler uses it as a fallback.
    - printf with `al != 0` spills xmm args via aligned SSE stores →
      segfault on this codegen's unaligned frames. The float print path
      now dynamically aligns rsp to 16 around printf and restores it via
      `lea rsp, [rbp-frame]`.
    - Float arguments across calls silently arrived as 0: caller passed
      64-bit bit patterns in GPRs but the callee prologue read xmm regs.
      Convention is now uniform: floats travel as GPR bit patterns
      end-to-end (prologue stores the GPR directly).
    - Verified: constant/bound/param/call-result floats print correctly;
      24/24 regression + boot fixed point still hold.
- [x] **Float/match codegen sweep, round 2 (2026-08-25)**: match-in-value-
      position as a call argument no longer crashes; a cluster of related
      float bugs fixed:
    - `emit_float_load_into` gained Call/UnOp cases (GPR bit-pattern
      convention); its stale xmm-args call convention removed.
    - `MatchArmICNF.field_types` (from adt_defs, with monomorphized-name
      fallback) feeds a new `float_locals` set so BinOp/UnOp inside match
      arms pick SSE paths (`(* side side)` was an integer `imul`).
    - Float BinOp/UnOp results now land in **both** xmm0 and rax (bit
      pattern): downstream consumers (match joins, result slots) read
      GPRs. `emit_binop_direct` and `emit_node_inner` both fixed.
    - Float negation: `neg` on xmm registers (assembler error) replaced
      with `0 - x`; xmm0/xmm-src register collision guarded.
    - **Float comparisons were vacuous**: emit_binop_direct's float Eq/
      Lt/Gt... arms had `xor eax,eax` between `ucomisd` and `setcc`,
      clobbering the flags so every comparison returned true. Fixed.
      This had been masking that `(/ 1.0 2.0 3.0)` ≠ `0.166667`
      bit-exactly.
    - assert-equal on floats is now approximate (|a-b| ≤ 1e-5 via new
      `.flt_abs_mask`/`.flt_epsilon` rodata), matching %.6f printing
      precision. Exact `==` remains exact.
    - Verified: 24/24 regression + boot fixed point hold.
- [ ] **Remaining known gaps**: TCO tail-call path does not handle float
      args; catch-all (wildcard) arms work — Int discriminants verified,
      float-arm + catch-all combinations now work end-to-end.
- [x] **Stack-passed args >6 params** in selfhost codegen *(done
      2026-08-25)*: the arity<=6 restriction is LIFTED. `cg-call-args`
      now stages every argument in an 8-byte scratch slot, copy-pushes
      args >=6 in reverse (SysV stack args), loads register args from
      scratch, and cleans up pad+scratch+copies; `cg-param-spills` loads
      callee stack args from `[rbp+16+8*(i-6)]`. The E_TOO_MANY_PARAMS
      guard was removed from icnf.zyl. Verified end-to-end through
      stage2 (id8 -> 7, sum8 -> 36); boot fixed point holds; 25/25.
      Bootstrap constraint 1 lifted in skills/zyl/SKILL.md.
- [ ] **Frame sizing**: uniform ~16KB frames (`16*(64+icnf-size)`) waste
      stack; size frames from actual slot counts. Enables revisiting
      sibling TCO safely.
- [x] **Cross-module inference fragility / generic ADT system rewrite**
      *(phase 1–2 landed 2026-08-25)*. ROOT CAUSES were: (1) untyped params
      implicitly MONOMORPHIC — handle_apply wrote the first call site's arg
      types back into the shared known_functions scheme, poisoning all other
      sites; (2) ADT constructor calls lost their type-parameter
      instantiation — module-defined constructors arrive as raw Call/Apply
      (PostProcessor runs before module resolution) and fell into the
      unknown-callee branch, inferring as opaque vars; (3) instantiation
      evidence was a flat bag of type strings per ADT, unusable for
      multi-param ADTs or site resolution. LANDED:
      - `adt_instantiations` now stores positional `{generic param ->
        concrete}` records (`AdtInstantiation`), deduplicated, with full
        coverage required before recording (partial evidence minted
        inconsistent names like Assoc_Int vs Assoc_Int_String).
      - MakeVariant inference returns the instantiated name (`Opt_Int`) so
        every binding site carries its instance through match/let/call.
      - New constructor branch in handle_apply recognizes variant names via
        `variant_to_adt` index — module constructors now record
        instantiations and return instance types.
      - Per-site polymorphism: the global write-back is REMOVED; body
        inference is cached per call-site argument signature; recursive
        self-calls constrain a fresh per-site return variable instead of
        reading stale global returns; params bound with bind_param (shadow)
        so leaked pattern-var bindings can't override them.
      - `finalize_param_types`: deferred consistent-site refinement — a
        param is concretized only when EVERY observed call site agrees
        (restores param types codegen needs for struct layouts/floats,
        without first-site poisoning).
      - Monomorphization consumes merged records: non-conflicting partial
        records for one instance are unioned (Result<T,E>: `(Ok v)` gives T,
        `(Err e)` gives E → one Result_T_E deftype); per-instance Deftypes
        substitute each field by its own param's concrete type.
      - unify: two instances of the SAME base ADT unify leniently (base =
        shortest adt_defs key that prefix-matches).
      - Fixed latent stdlib bug exposed by the stricter checker:
        collections/map.zyl used `let dst 0` mutated by set! (now let-mut).
      - New test tests/regression/generics-multi-type.zyl (Opt at Int AND
        String in one program, distinct matches, through stage-Rust
        codegen). Boot fixed point holds; suite 21/27 — the 6 remaining
        failures are the pre-existing baseline set, each now failing at a
        LATER, more specific point (stricter checking exposes deeper latent
        bugs: unit_test reaches an ill-typed Result<Vec>/Int unwrap;
        collections map-remove segfaults in newly-reached let-mut-in-for
        codegen; compiler/parser-verify/selfhost-codegen pending triage).
- [x] **Match-in-value-position** *(done 2026-08-25)*: the restriction
      was already effectively lifted by earlier codegen fixes — verified
      let bindings, binop args, if branches, call args, nested arm-body
      matches, and multiple matches per defn through stage1 AND stage2
      (all produce correct values). Codified with
      tests/regression/match-value-position.zyl (7 shapes; runs in the
      Rust suite; stage>=2 verified manually since run-tests is a
      Rust-bootstrap special form). Constraint 2 lifted in the skill.
- [ ] **Scale profiling**: O(n²) suspects in str-intern scans and arena
      fragmentation when compiling very large inputs.

### P3.5 — Self-host parity (port bootstrap type-system work to Zyl)
The Rust bootstrap gained significant inference/codegen semantics during
the generic-ADT rewrite (2026-08-25) that the Zyl-written compiler
(stdlib/compiler/*.zyl) does not yet mirror:
- [ ] Positional ADT instance naming + {param -> concrete} instantiation
      records (Rust: AdtInstantiation, adt_param_order).
- [ ] Constructor recognition for raw Call/Apply forms (Rust:
      variant_to_adt index in handle_apply).
- [ ] Per-call-site polymorphism for untyped params (no shared-scheme
      mutation; per-signature body cache; finalize_param_types).
- [ ] Match pattern-var shadowing + arm-scoped env (bind_param).
- [ ] Epilogue result materialization from a declared result id.
Until then, selfhost sources must respect the stricter-of-the-two
constraints; the boot fixed point is the arbiter.

### P4 — Feature completeness & polish
- [ ] Contract injection overlay (spec §23, Phase 10) — last unimplemented
      optional phase.
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
