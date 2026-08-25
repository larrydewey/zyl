# Zyl Progress Tracker

## Current State (2026-08-25)

**Self-hosting: COMPLETE and deterministic.** The Zyl compiler written in Zyl
compiles itself end-to-end with a byte-identical fixed point:

```
stage1 (Rust bootstrap compiles selfhost/zyl_selfhost_compiler.zyl)
  -> stage2 (compiles itself -> stage3, output == stage2's, byte-for-byte)
```

Programs compiled by stage2/stage3 run correctly (ADTs + match, HOF calls,
FFI, recursion, arithmetic, floats verified). All 9 core compilation phases
plus linking are complete and tested; full regression suite 24/24.

**Details:** `docs/implementation-status.md`, `docs/self-hosting-phase1.md`
(historical), `docs/regression-tests.md`.

---

## Roadmap (prioritized)

### P0 — Consolidate the self-hosted toolchain
- [ ] **Boot build automation**: `boot.sh` / make target running the full
      loop (Rust `zyl` → stage1 → stage2) and installing stage2 as the
      canonical binary; triple-compile + diff fixed-point check added to
      `run_regression_tests.sh` so self-compile regressions fail loudly.
- [x] **Compile errors for known-fragile shapes** instead of silent
      miscompiles *(done 2026-08-25, commit c9b5c69)*:
    - `E_UNBALANCED_PARENS` — whole-token-stream balance check in
      `zyl-parse` (parser.zyl).
    - `E_TOO_MANY_PARAMS` — defns with >6 params rejected at lowering.
    - `E_DUPLICATE_VARIANT` — variant names shared across deftypes
      rejected in `vt-from-variants` (icnf.zyl).
- [ ] **Growable codegen buffer**: replace the fixed 8MB buffer in `cg-new`
      with arena growth sized from `icnf-size`.
- [x] **AI language skill** (`skills/zyl/SKILL.md`): expert-level Zyl
      knowledge for AI agents — syntax, the bootstrap constraint list
      (arity≤6, match-as-body, paren discipline, buf-append append
      semantics, FFI patterns, tag/match pitfalls), idioms, debugging
      recipes. Higher priority than most items: a robust skill file
      multiplies the effectiveness of every subsequent AI-assisted task.
      **(created 2026-08-25; keep updated as constraints are lifted)**

### P1 — Developer experience: diagnostics & editing
- [ ] **Compiler error system overhaul** — target Rust-class diagnostics:
    - primary span + labeled secondary spans ("borrowed here", "moved
      here" analogues for capability types TMut/TCap and regions);
    - machine-applicable suggestion snippets (`did you mean`, missing
      arm, wrong arity with expected/found);
    - error codes stable per spec §28, documented in an errors.md index;
    - structured (JSON) error output so the LSP and tools can consume it.
- [ ] **VS Code language definition**: TextMate grammar, brackets/
      commenting/comment-toggling config, file association for `.zyl`,
      snippet library. *(grammar created this session)*
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
