# Chapter 28: ICNF — The Intermediate Representation

ICNF (Intermediate Canonical Normal Form) is Zyl's custom SSA-based IR with region annotations. This chapter documents its structure, instructions, and lowering.

## 28.1 ICNF Overview

- **SSA form**: Each value assigned exactly once
- **Region annotations**: Every value carries region (Stack/Heap/Pin/...)
- **Explicit control flow**: Basic blocks with explicit jumps
- **Typed**: Every value has a type
- **Phase 6 output**: Consumed by optimizer (Phase 7) and codegen (Phase 8)

## 28.2 ICNF Structure

### Module

```lisp
Module ::= (module
  (functions Function*)
  (globals Global*)
  (types TypeDef*))
```

### Function

```lisp
Function ::= (function
  name: String
  params: (Param*)
  return_type: Type
  region: Region
  blocks: (Block*))
```

### Block

```lisp
Block ::= (block
  label: Label
  instructions: (Instruction*)
  terminator: Terminator)
```

### Instruction (Value Definition)

```lisp
Instruction ::= (let (ssa_id Type Region) Value)
```

Every instruction defines a new SSA value.

## 28.3 Value Kinds

| Kind | Syntax | Description |
|------|--------|-------------|
| Constant | `(const Int 42)` | Integer constant |
| | `(const Float 3.14)` | Float constant |
| | `(const Bool true)` | Boolean |
| | `(const String "hi")` | String constant |
| | `(const Unit)` | Unit |
| Variable | `(var ssa_id)` | Reference to SSA value |
| Function | `(fn_ref "name")` | Function pointer |
| Closure | `(closure "name" (captured_ssa*))` | Closure creation |
| BinOp | `(binop Op Value Value)` | Arithmetic/comparison |
| Call | `(call "fn_name" (args...))` | Direct function call |
| CallIndirect | `(call_indirect fn_ssa (args...))` | Indirect (closure) call |
| MakeStruct | `(make_struct "StructName" (fields...))` | Struct construction |
| StructGet | `(struct_get struct_ssa "field")` | Field access |
| MakeVariant | `(make_variant "ADT" "Variant" (args...))` | ADT construction |
| Match | `(match scrutinee_ssa (arms...))` | Pattern match |
| Phi | `(phi (pred_ssa*) (labels*))` | SSA phi node |
| Alloc | `(alloc Type Region)` | Heap allocation |
| FFI | `(ffi "symbol" (args...) timeout)` | FFI call |

## 28.4 Terminators

```lisp
Terminator ::= (ret Value)           ; Return
             | (jmp Label)           ; Unconditional jump
             | (br Cond Label Label) ; Conditional branch
             | (switch Value (cases...)) ; Switch on tag
             | (unreachable)         ; Unreachable
```

## 28.5 Regions in ICNF

Every value annotated with region:

```lisp
(let (v1 Int Stack) (const Int 42))
(let (v2 (TCap Point) Heap) (make_struct "Point" ...))
(let (v3 (TMut Int) Stack) (var v1))  ; Promoted?
```

Region lattice: `Stack ≤ Heap ≤ Circular`, `Pin` and `Global` incomparable.

## 28.6 Lowering from ExprInner (Phase 6)

Key lowering rules:

### Let Binding

```lisp
;; ExprInner: (Let (name expr) body)
;; ICNF:
(let (v1 Type Region) expr_lowered)
...body_lowered with name → v1...
```

### Function Call

```lisp
;; Direct call
(let (v1 RetType Region) (call "fn_name" (args...)))

;; Indirect call (closure)
(let (v1 RetType Region) (call_indirect fn_ssa (args...)))
```

### Match

```lisp
;; ExprInner: (Match scrutinee (Variant pattern body)...)
;; ICNF:
(let (scrut_ssa Type Region) scrutinee_lowered)
(switch scrut_ssa
  (0 Label_None)      ; None tag
  (1 Label_Some))     ; Some tag

Label_Some:
  (let (v1 Type Region) (struct_get scrut_ssa "field"))
  ...body_lowered...
  (jmp Join)

Label_None:
  ...body_lowered...
  (jmp Join)

Join:
  (phi (v_some v_none) (Label_Some Label_None))
```

### Closure

```lisp
;; ExprInner: (Closure (params) body captures)
;; ICNF:
(let (closure_ssa (TFun(...) Ret) Heap)
  (closure "fn_name" (captured_ssa*)))
```

## 28.7 ICNF Optimizations (Phase 7)

### Constant Folding

```lisp
;; Before:
(let (v1 Int Stack) (const Int 1))
(let (v2 Int Stack) (const Int 2))
(let (v3 Int Stack) (binop Add (var v1) (var v2)))

;; After:
(let (v3 Int Stack) (const Int 3))
```

### Dead Code Elimination

```lisp
;; Unused let removed
(let (v1 Int Stack) (const Int 42))
;; If v1 never used → removed
```

### Copy Propagation

```lisp
;; Before:
(let (v1 Int Stack) (const Int 42))
(let (v2 Int Stack) (var v1))
... (var v2) ...

;; After:
... (var v1) ...  (v2 removed)
```

## 28.8 ICNF Verification

Validator checks:
- **SSA form**: Each SSA ID defined once, used after definition
- **Region consistency**: Value region compatible with uses
- **Type consistency**: Operations match operand types
- **Control flow**: All blocks reachable, phi nodes correct
- **Terminator**: Every block ends with terminator

## 28.9 ICNF Errors

| Error | Cause |
|-------|-------|
| `E_ICNF_SSA_VIOLATION` | SSA ID used before defined or defined twice |
| `E_ICNF_REGION_MISMATCH` | Value used in incompatible region |
| `E_ICNF_TYPE_MISMATCH` | Operation operand types incompatible |
| `E_ICNF_UNREACHABLE_BLOCK` | Block not reachable from entry |
| `E_ICNF_MISSING_PHI` | Join point missing phi for live value |

## 28.10 Comparison with LLVM IR

| Feature | LLVM IR | ICNF |
|---------|---------|------|
| SSA | ✅ | ✅ |
| Regions | ❌ (metadata) | ✅ (first-class) |
| Capabilities | ❌ | ✅ (on types) |
| Target | Multi-arch | x86_64 only |
| Optimizations | Many | Safe only (const fold, DCE) |
| Verification | ✅ | ✅ |
| Determinism | Configurable | Mandatory |