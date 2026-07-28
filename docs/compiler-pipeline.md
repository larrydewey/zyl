# Compiler Pipeline

## Overview

The Zyl compiler is a deterministic, multi-phase compiler from S-expression source to x86_64 native binary. All phases execute in strict order; no phase may depend on output from a later phase.

**Canonical reference:** `zyl_specification.txt` §22
**Navigation:** `spec/11-icnf-ir.md`, `spec/13-code-generation.md`

**Note on type inference ordering:** The actual implementation runs monomorphization (Phase 6) before full type inference (Phase 5), while type inference's `collect()` phase runs first to gather function definitions. This preserves AST structure for monomorphization. The canonical phase order is preserved in documentation.

---

## Phase 1: Parsing

**Input:** `.zyl` source file (UTF-8 text)
**Output:** AST (Expr tree)
**Implementation:** `src/lexer.rs`, `src/parser.rs`, `src/ast.rs`

**Process:**
1. Lexer tokenizes source into tokens (IDENTIFIER, INTEGER, FLOAT, STRING, BOOLEAN, SYMBOL, KEYWORD, parentheses, brackets)
2. Strips line comments (`;`)
3. Parser produces raw S-expressions as Call/Apply nodes (no-dispatch mode)
4. PostProcessor converts raw nodes to specialized ExprInner variants

**Invariants:**
- All expressions are strict left-to-right
- Reserved keywords cannot be used as identifiers (E_RESERVED_KEYWORD)
- Location tracking for all syntax errors

**Files:**
| File | Lines | Description |
|------|-------|-------------|
| `src/lexer.rs` | ~457 | Tokenizer |
| `src/parser.rs` | ~1823 | Recursive descent parser |
| `src/ast.rs` | ~2005 | AST + PostProcessor |

---

## Phase 2: Macro Expansion

**Input:** AST from Phase 1
**Output:** Expanded AST (macros replaced with their templates)
**Implementation:** `src/macro_expander.rs`

**Process:**
1. Macro registration: Collect all defmacro definitions
2. Post-order traversal (innermost-first): Expand macros recursively
3. Gensym hygiene: All macro-introduced variables renamed to unique symbols
4. `___skip_` placeholder: Omitted if branches produce Unit type

**Invariants:**
- Expansion is deterministic (innermost-first order)
- Hygiene prevents variable capture
- Macros cannot access runtime values (E_MACRO_ILLEGAL_ACCESS)

**Files:**
| File | Lines | Description |
|------|-------|-------------|
| `src/macro_expander.rs` | ~1427 | Macro expansion engine |

---

## Phase 3: Region Inference + Capture Analysis

**Input:** Expanded AST
**Output:** Region-annotated AST
**Implementation:** `src/region_inference.rs`

**Process:**
1. Two-pass algorithm with region lattice:
   - Pass 1: Collect region constraints from expression structure
   - Pass 2: Solve constraints via region lattice (least fixed point)
2. Capture analysis for closures
3. Escape promotion (Stack → Heap) for values that outlive scope

**Region rules (R1–R8):**
| Rule | Condition | Region |
|------|-----------|--------|
| R1 | Local, no escape | Stack |
| R2 | Escapes (returned, captured by escaping closure, sent to actor) | Heap |
| R3 | Actor transfer (spawn/send) | Heap |
| R4 | FFI | Pin |
| R5 | Closure capture promotion | Heap |
| R6 | Cyclic structures | Circular |
| R7 | Global constant | Global |
| R8 | Explicit pin | Pin |

**Invariants:**
- No value escapes its region
- Struct instances default to Heap
- FFI values pinned for non-moving access

**Files:**
| File | Lines | Description |
|------|-------|-------------|
| `src/region_inference.rs` | ~1132 | Region inference engine |

---

## Phase 4: Type Inference + Trait Resolution

**Input:** Region-annotated AST
**Output:** Typed AST (types assigned to all expressions)
**Implementation:** `src/type_system.rs`, `src/type_inference.rs`

**Process:**
1. Two-pass algorithm:
   - Pass 1: `collect_definitions()` — register all def/defn/defstruct definitions
   - Pass 2: `infer_expr()` — infer types for all expressions
2. Hindley-Milner unification with occurs check
3. Trait resolution with transitive bound checking
4. Derive validation (Eq, Ord, Debug, Clone, Hash)
5. Struct field type lookup from struct_defs
6. Capability type inference (TCap/TMut)

**Invariants:**
- All expressions are well-typed or produce a type error
- TMut/TCap aliasing constraints enforced
- Capability types govern aliasing (TMut exclusive, TCap shared)

**Files:**
| File | Lines | Description |
|------|-------|-------------|
| `src/type_system.rs` | ~612 | Type definitions |
| `src/type_inference.rs` | ~1836 | HM inference engine |

---

## Phase 5: Monomorphization

**Input:** Region-annotated typed AST
**Output:** Monomorphized AST (no generic types)
**Implementation:** `src/monomorphization.rs`

**Process:**
1. Detect generic functions (uppercase parameter convention)
2. For each concrete type instantiation:
   - Sort type parameters alphabetically (canonical naming)
   - Generate specialization name
   - Substitute type variables
3. Verify trait bounds for each instantiation
4. Instantiate generic ADTs

**Invariants:**
- Naming is deterministic (alphabetical sort of types)
- No generic types remain in output
- Trait bounds verified before instantiation

**Files:**
| File | Lines | Description |
|------|-------|-------------|
| `src/monomorphization.rs` | ~1459 | Monomorphization engine |

---

## Phase 6: ICNF Generation (SSA IR)

**Input:** Monomorphized AST
**Output:** ICNFProgram (SSA IR with region annotations)
**Implementation:** `src/icnf.rs`

**IR structure:**
```
ICNFProgram {
  functions: [ICNFFuncSig, ...]
  statements: [ICNFNode, ...]
  closure_bodies: HashMap<usize, [ICNFNode]>
  closures: HashMap<usize, (String, Vec<CaptureField>)>
}

ICNFFuncSig {
  name: String,
  params: [(String, Type)],
  body: [ICNFNode, ...]
}

ICNFNode {
  id: SSA_ID,
  region: Region,
  node: ICNFInner
}
```

**ICNFInner operations:**
- Constant, Load, Store, BinOp, UnOp
- If, While, For, Match (embedded branch bodies)
- Call, Return
- MakeStruct, StructGet
- Phi (join points)
- FFI, Spawn, Send, SendClosure
- ReadLine

**Invariants:**
- Each variable assigned exactly once (SSA)
- Region annotations preserved from Phase 3
- Control flow embedded (not labeled jumps)
- Phi nodes at join points for values with multiple definitions

**Files:**
| File | Lines | Description |
|------|-------|-------------|
| `src/icnf.rs` | ~2862 | SSA IR generation |

---

## Phase 7: Optimization

**Input:** ICNFProgram
**Output:** Optimized ICNFProgram (safe optimizations only)
**Implementation:** `src/optimization.rs`

**Optimizations:**
1. **Constant Folding (CF):** Fold BinOp/UnOp with compile-time constants. Fixed-point iteration until no more folds.
2. **Dead Code Elimination (DCE):** BFS-based transitive dependency collection from function returns.

**Invariants:**
- Only safe optimizations (no reordering, no spec-breaking transforms)
- Control flow structures (If/While/For/Match) preserved in DCE
- Struct nodes preserved
- Evaluation order never changed
- Spawn/Send/ReadLine exempt from reordering

**Files:**
| File | Lines | Description |
|------|-------|-------------|
| `src/optimization.rs` | ~514 | ICNF optimizer |

---

## Phase 8: Code Generation

**Input:** Optimized ICNFProgram
**Output:** x86_64 assembly (.s file)
**Implementation:** `src/codegen.rs`

**Process:**
1. Linear-scan register allocator (caller-saved registers only)
2. System V AMD64 ABI compliance:
   - Arguments: edi, esi, edx, ecx, r8d, r9d
   - Float args: XMM0–XMM5
   - Return: eax (64-bit), rax (pointer)
3. Stack frame: `[rbp - offset]` for local variables
4. String literals → .rodata section
5. hexbuf (for int-to-string) → .bss section
6. Float constants → .rodata section

**Instructions emitted:**
- `mov` (64-bit and 32-bit)
- `add`, `sub`, `imul`, `idiv`
- `cvtsi2sd`, `cvtss2sd`, `adds`, `sub`, `mul`, `div` (SSE float)
- `cmp` + `setcc` for comparisons
- `jmp`, `jl`, `jg`, `je`, `jne` etc.
- `call`, `ret`
- `malloc` for struct allocation
- `printf` for output
- `sys_read` for read-line

**Output format:** Intel syntax (`.intel_syntax noprefix`)

**Files:**
| File | Lines | Description |
|------|-------|-------------|
| `src/codegen.rs` | ~4738 | x86_64 code generator |

---

## Phase 9: Linking

**Input:** Assembly file (.s) + actor_runtime.c
**Output:** Native binary (.bin)
**Implementation:** `src/main.rs` (orchestration), `cc` (external toolchain)

**Process:**
1. Compile with `cc -no-pie -lpthread -o <bin> <asm> actor_runtime.c`
2. Actor runtime C file included for spawn/send support
3. `zyl_actor_init()` and `zyl_actor_wait_all()` linked in

**External dependency:** GNU C compiler (cc)

**Files:**
| File | Lines | Description |
|------|-------|-------------|
| `src/runtime.rs` | 2 | Runtime path re-export |
| `src/runtime/actor_runtime.c` | 156 | pthread-based actor runtime |
| `src/runtime/actor_runtime.h` | 52 | Actor runtime API header |

---

## Phases Not Yet Implemented

### Phase 10: Contract Injection (Optional)

**Spec reference:** `zyl_specification.txt` §23
**Status:** Contracts defined in spec but not implemented. Contracts are an optional overlay that never alter core semantics.

### Phase 11: Hash Finalization

**Spec reference:** `zyl_specification.txt` §27
**Status:** `sha2` crate is a dependency but hash finalization is not yet integrated into the pipeline.

---

## Pipeline Summary

```
Source (.zyl)
  → [1] Lexer → Tokens
  → [1] Parser → Raw S-expressions
  → [1] PostProcessor → AST
  → [2] Macro Expansion → Expanded AST
  → [3] Region Inference → Region-annotated AST
  → [4] Type Inference → Typed AST
  → [5] Monomorphization → Monomorphized AST
  → [6] ICNF Generation → ICNFProgram
  → [7] Optimization → Optimized ICNFProgram
  → [8] Code Generation → x86_64 assembly (.s)
  → [9] Linking → Native binary (.bin)
  → [10] Contract Injection (optional, not yet implemented)
  → [11] Hash Finalization (not yet implemented)
```

---

## Phase Ordering Constraints

| Phase | Depends On | Must Not Depend On |
|-------|-----------|-------------------|
| 1 (Parsing) | — | 2–11 |
| 2 (Macro Expansion) | 1 | 3–11 |
| 3 (Region Inference) | 2 | 4–11 |
| 4 (Type Inference) | 3 | 5–11 |
| 5 (Monomorphization) | 4 | 6–11 |
| 6 (ICNF) | 5 | 7–11 |
| 7 (Optimization) | 6 | 8–11 |
| 8 (Code Generation) | 7 | 9–11 |
| 9 (Linking) | 8 | — |

**Rule:** No phase may depend on a later phase. Determinism is required at every step.
