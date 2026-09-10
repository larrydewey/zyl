# Chapter 27: Self-Hosting and the Compiler

Zyl's compiler is written in Zyl and compiles itself. This chapter explains the self-hosting architecture, the bootstrapping process, and the fixed point verification.

## 27.1 Self-Hosting Overview

**Self-hosting**: The Zyl compiler (`stdlib/compiler/*.zyl`, `selfhost/`) is written in Zyl and compiles itself end-to-end.

```
Rust bootstrap (src/) → Stage 1 → Stage 2 (Zyl) → Stage 3 (Zyl)
                                                      ↓
                                            stage2.asm == stage3.asm
```

The Rust bootstrap (`src/`) is **only needed for the initial Stage 1 build**. After that, Zyl compiles itself.

## 27.2 Compiler Architecture

### Rust Bootstrap (`src/`)

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

```bash
#!/bin/bash
# boot.sh — Self-hosting verification

# Stage 1: Rust compiler builds Zyl compiler
cargo build --release
./target/release/zyl stdlib/compiler/*.zyl -o stage1

# Stage 2: Stage 1 compiles Zyl compiler
./stage1 stdlib/compiler/*.zyl -o stage2

# Stage 3: Stage 2 compiles Zyl compiler
./stage2 stdlib/compiler/*.zyl -o stage3

# Verify fixed point
diff stage2.asm stage3.asm
# If identical → fixed point reached
```

### Stages Explained

| Stage | Compiler | Compiles | Output |
|-------|----------|----------|--------|
| 1 | Rust (`src/`) | `stdlib/compiler/*.zyl` | `stage1` (executable) |
| 2 | `stage1` (Zyl) | `stdlib/compiler/*.zyl` | `stage2` (executable + asm) |
| 3 | `stage2` (Zyl) | `stdlib/compiler/*.zyl` | `stage3` (executable + asm) |

**Fixed point**: `stage2.asm == stage3.asm` (byte-identical assembly)

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
diff stage2.asm stage3.asm

# Run stage2 on itself
./stage2 stdlib/compiler/*.zyl -o test-stage3

# Run stage3 on itself
./stage3 stdlib/compiler/*.zyl -o test-stage4

# Compare all
diff stage2.asm stage3.asm test-stage3.asm test-stage4.asm
```

## 27.8 Future: Removing Rust Bootstrap

**Goal**: Archive `src/` entirely, Zyl compiles from source.

**Remaining work**:
1. ✅ Type inference ported to Zyl
2. ✅ Monomorphization ported to Zyl
3. 🔄 Lexer/parser in Zyl (done but needs verification)
4. 🔄 Codegen in Zyl (done but needs verification)
5. 🔄 All phases verified through fixed point

Once complete: `src/` archived, `boot.sh` starts from Zyl source only.