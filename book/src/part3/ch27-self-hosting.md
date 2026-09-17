# Chapter 27: Self-Hosting and the Compiler

Zyl's compiler is written in Zyl and compiles itself. This chapter explains the self-hosting architecture, the bootstrapping process, and the fixed point verification.

## 27.1 Self-Hosting Overview

**Self-hosting**: The Zyl compiler (`stdlib/compiler/*.zyl`, `selfhost/`) is written in Zyl and compiles itself end-to-end.

```
build/boot/stage2.s (committed) → Stage 1 (cc) → Stage 2 (Zyl) → Stage 3 (Zyl)
                                                                     ↓
                                                        stage2.asm == stage3.asm
```

Rust is no longer part of this at all — `./boot.sh` (default, no args)
builds and verifies the whole thing with nothing but `cc`, starting
from the committed seed `build/boot/stage2.s`. The original Rust
bootstrap that produced the very first seed is archived at
`archive/rust-bootstrap-2026/` and kept only as a fallback for
reseeding across a language change so large the previous seed's
compiler can't even parse the new source — see §27.8.

## 27.2 Compiler Architecture

### Rust Bootstrap (archived: `archive/rust-bootstrap-2026/src/`)

Not part of the active build — see `archive/rust-bootstrap-2026/README.md`.

| File | Purpose |
|------|---------|
| `main.rs` | Compiler entry point, pipeline orchestration |
| `repl.rs` | REPL entry point |
| `ast.rs` | AST definitions + PostProcessor |
| `lexer.rs` | Tokenizer |
| `parser.rs` | Recursive descent parser |
| `macro_expander.rs` | Macro expansion with gensym hygiene |
| `type_system.rs` | Type definitions (Rust-side) |
| `type_inference.rs` | HM inference + trait resolution |
| `region_inference.rs` | Region inference + capture analysis |
| `monomorphization.rs` | Generic instantiation |
| `icnf.rs` | SSA IR (ICNF) |
| `optimization.rs` | IR optimizations |
| `codegen.rs` | x86_64 code generation |
| `error.rs` | Error model |
| `runtime/` | Actor runtime (C) |

### Zyl Compiler (`stdlib/compiler/`)

| File | Phase | Description |
|------|-------|-------------|
| `lexer.zyl` | 1 | Tokenizer |
| `parser.zyl` | 1 | Parser + AST |
| `ast.zyl` | 1 | AST definitions |
| `expr_inner.zyl` | 1 | ExprInner ADT |
| `macro_expand.zyl` | 2 | Macro expansion |
| `type_system.zyl` | 3 | Type ADT, Subst, TypeEnv, TraitContext |
| `type_inference.zyl` | 3 | Full HM inference engine |
| `region_inference.zyl` | 4 | Region inference + capture analysis |
| `monomorphization.zyl` | 5 | Full monomorphization pipeline |
| `icnf.zyl` | 6 | ICNF lowering from ExprInner |
| `codegen.zyl` | 8 | x86_64 code generation |
| `contract_injection.zyl` | 10 | Contract overlay |
| `trait_dispatch.zyl` | 3 | Trait method dispatch |
| `closure_inline.zyl` | 7 | Closure inlining |
| `assert_lowering.zyl` | 7 | Assert lowering |
| `module_resolver.zyl` | 1 | Module resolution |
| `resolver.zyl` | 1 | Name resolution |

### Self-Host Driver (`selfhost/`)

| File | Purpose |
|------|---------|
| `driver.zyl` | Boot pipeline entry point |
| `zyl_selfhost_compiler.zyl` | Assembled self-hosted compiler |

## 27.3 Bootstrapping Process (`boot.sh`)

Default flow — verifies the fixed point, no Rust anywhere:

```bash
./boot.sh
# 1. cc-links the committed seed build/boot/stage2.s -> stage1.bin
# 2. stage1 compiles selfhost/zyl_selfhost_compiler.zyl -> stage2.s
#    (must byte-match the committed seed)
# 3. stage2 compiles the same source -> stage3.s
# 4. stage3.s must be byte-identical to stage2.s (fixed point)
# 5. CLI smoke-test + build/boot/zyl-self wrapper
```

Reseeding — needed only when a compiler source change moves the fixed
point (`FIXED POINT BROKEN` or "reproduced asm differs from committed
seed"):

```bash
python3 selfhost/assemble.py     # re-bundle stdlib/compiler/*.zyl
./boot.sh --bootstrap-from-self  # reseed via the self-hosted compiler
./boot.sh                        # verify the new seed is clean
```

`--bootstrap-from-self` links the *current* committed seed and repeats
the stage1-compiles-source step, but instead of requiring the result to
match the old seed, it iterates — compiling its own output again and
again — until two consecutive rounds agree, up to 10 rounds. This works
because a compiler that just compiled a behavior change doesn't yet
exhibit that behavior itself (it was built by logic that predates the
change); the *next* round, compiled by a binary that has the change
baked in, does. Verified to converge to the exact fixed point Rust used
to produce, starting from a seed many commits stale.

### Stages Explained

| Stage | Compiler | Compiles | Output |
|-------|----------|----------|--------|
| 1 | `cc`-linked committed seed | `selfhost/zyl_selfhost_compiler.zyl` | `stage1.bin` |
| 2 | `stage1.bin` (Zyl) | same source | `stage2.s`/`.bin` |
| 3 | `stage2.bin` (Zyl) | same source | `stage3.s` |

**Fixed point**: `stage2.s == stage3.s` (byte-identical assembly)

## 27.4 Why Self-Hosting Matters

1. **Compiler correctness**: If compiler compiles itself correctly, it's likely correct for other code
2. **Language completeness**: Self-hosting exercises all language features
3. **Determinism proof**: Fixed point verifies determinism end-to-end
4. **Dogfooding**: Compiler authors use their own language daily
5. **Bootstrapping trust**: No hidden Rust dependencies in final compiler

## 27.5 Constraints for Self-Hosted Code

Code in `stdlib/compiler/` and `selfhost/` must obey **bootstrap constraints** (stricter of Rust/Zyl):

```
1. Function arities ≤ 6 (lifted 2026-08-25: stack-passed args work)
2. Match may appear only as entire body of defn (lifted 2026-08-25)
3. Match arms must enumerate every constructor (no wildcard fallback)
4. Pattern wildcards must be named dummies (d1, d2...), never bare _
5. Prefer flat begin sequences and recursion over deep nesting
6. buf-append appends at strlen(dst) (true append); fresh buffers only
7. Parens must balance per top-level form
8. No binop may directly combine TWO call operands — anywhere!
   Bind calls to lets first; in arm bodies keep ONE call and nest via icnf-add2
```

Violating these → miscompilation in Stage ≥ 2.

## 27.5 C-Style Block Formatting

To maintain paren balance visually, the compiler source uses **C-style block formatting**:

```lisp
(defn function-name
  (param1 param2)
  (begin
    (statement1)
    (statement2)
    (if condition
      (then-branch)
      (else-branch))))
```

Rules:
- Each open paren on its own line at correct indent
- Each close paren aligned with matching open
- Makes paren balance trivial to verify visually
- Eliminates entire class of boot-pipeline regressions

## 27.6 Boot Fixed Point History

| Milestone | Date | Notes |
|-----------|------|-------|
| Stage 1 compiles own source | 2026-08-24 | First boot build |
| Self-hosting fixed point | 2026-08-25 | Stage1→Stage2→Stage3 deterministic |
| Type inference ported to Zyl | 2026-09-10 | HM + capabilities + traits |
| Monomorphization ported to Zyl | 2026-09-10 | Full mono using type inference |
| P3.5 complete | 2026-09-10 | Zyl self-hosts all phases |
| Fixed point solid, cargo-free `./boot.sh` | 2026-09-16 | `stage2.s == stage3.s`, no cargo in the default flow |
| Full regression parity, Rust evicted | 2026-09-17 | 43/43 via self-hosted compiler; `src/` archived; reseeding self-hosted too (`--bootstrap-from-self`) |

## 27.7 Debugging the Bootstrap

### Common Failure Modes

| Symptom | Likely Cause |
|---------|--------------|
| Stage2 ≠ Stage3 asm | Non-determinism in compiler |
| Stage2 crashes | Miscompilation in Stage1 |
| "Unknown variant" | HashMap iteration order (fixed: deterministic.rs) |
| Match arm computes 0 | Binop combining 2+ calls (constraint 8) |
| Paren imbalance | Missing closer in assembled source |

### Debugging Commands

```bash
# Compare assembly
diff build/boot/stage2.s build/boot/stage3.s

# Run stage2 on itself again
setarch -R build/boot/stage2.bin selfhost/zyl_selfhost_compiler.zyl \
    -o /tmp/test-stage3.s --emit-asm

# Compare
diff build/boot/stage2.s /tmp/test-stage3.s
```

## 27.8 Rust Eviction: Done

This was tracked as future work in earlier drafts of this chapter; as
of `docs/rust-eviction-plan.md`'s latest survey, it's complete:

1. ✅ Every compiler phase ported to Zyl (`stdlib/compiler/*.zyl`)
2. ✅ Full regression suite passes through the self-hosted compiler
   (43/43, `./run_regression_tests.sh --full`)
3. ✅ `./boot.sh` builds and verifies with nothing but `cc`
4. ✅ Reseeding no longer needs Rust either (`--bootstrap-from-self`, §27.3)
5. ✅ `src/` archived to `archive/rust-bootstrap-2026/`, `Cargo.toml`/
   `Cargo.lock`/`target/` removed from the active tree

The archived Rust bootstrap remains available as a fallback for the one
case self-hosted reseeding can't solve on its own: a language change so
large the previous seed's compiler can't even *parse* the new source
(new syntax, not just new behavior). See
`archive/rust-bootstrap-2026/README.md`.