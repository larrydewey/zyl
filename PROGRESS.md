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
- [ ] **Enforce the one-call rule in the compiler**: extend
      E_TOO_MANY_PARAMS-style guards to detect match-arm bodies with >1
      call at lowering time, so future sources cannot silently trip this.
- [ ] **Wire fixed-point check into default regressions**: currently
      opt-in via `--boot`; flip on once CI time budget allows.
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
- [ ] **Stack-passed args >6 params** in selfhost codegen (mirror the Rust
      fix: spill slots + reverse push + alignment), lifting the arity≤6
      restriction; keep the compile error until this lands.
- [ ] **Frame sizing**: uniform ~16KB frames (`16*(64+icnf-size)`) waste
      stack; size frames from actual slot counts. Enables revisiting
      sibling TCO safely.
- [ ] **Cross-module inference fragility**: generic list helpers mis-unify
      across element types (constraint forcing duplicated per-module
      helpers like `ih-ic`/`fh-if`). Improve unification or add explicit
      type annotations.
- [ ] **Match-in-value-position**: lift "match only as entire body"
      restriction incrementally with a regression test per unlocked shape.
- [ ] **Scale profiling**: O(n²) suspects in str-intern scans and arena
      fragmentation when compiling very large inputs.

### P4 — Feature completeness & polish
- [ ] Contract injection overlay (spec §23, Phase 10) — last unimplemented
      optional phase.
- [ ] Fix top-level `(def Name Expr)` misprint noted in REPL limitations.
- [ ] Warnings sweep (~160 → 0).
- [ ] Boot-binary CLI parity (`-o`, `--emit-asm`) and error messages with
      spans from the Zyl front end.

---

## Bootstrap Constraints (for code written in Zyl — see skills/zyl/SKILL.md)

1. Keep function arities ≤6 (no stack-passed args yet).
2. A `match` may appear only as the entire body of a defn.
3. Match arms must enumerate every constructor (no wildcard fallback;
   unknown arms map to discriminant 0).
4. Pattern wildcards must be named dummies (`dN`), never bare `_`.
5. Prefer flat `begin` sequences and recursion over deep nesting.
6. `buf-append` appends at strlen(dst) (true append); fresh buffers only.
7. Parens must balance per top-level form — a missing closer silently
   nests subsequent defns inside the broken form.

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
