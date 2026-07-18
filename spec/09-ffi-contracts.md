# Zyl Specification — FFI and Contracts

**Canonical authority:** `zyl_specification.txt` §16, §23
**Related:** `spec/07-region-memory-model.md`, `spec/06-capability-types.md`
**Implementation:** `src/type_inference.rs` (type checking); code generation deferred

---

## 16. FFI Model

### Syntax

```lisp
(ffi-call name args timeout)
(ffi-pin Expr)
(ffi-unpin Expr)
```

### FFI_Pinnable Types

The following types are FFI_Pinnable:
- Int, Float, Bool, String
- Vec<T> (where T is FFI_Pinnable)
- Types composed solely of FFI_Pinnable types

### Pin Semantics

1. `ffi-pin` copies value to Pin Region (non-moving).
2. Returns stable pointer.
3. Pin lifetime tied to FFI call scope unless manually managed.
4. `ffi-unpin` explicitly frees pinned memory.

### Rules

- **R4:** FFI → Pin region
- `ffi-call` requires Pin region AND FFI_Pinnable type
- Timeout parameter is mandatory on every `ffi-call`

---

## 23. Contract and Recovery System (Optional Overlay)

### Profiles

```
strict | debug | warn | off | production
```

### 23.1 Preconditions

```lisp
(requires Condition)
```

### 23.2 Postconditions

```lisp
(ensures Condition)
```

### 23.3 Invariants

```lisp
(invariant Condition)
```

### 23.4 Recover Blocks

```lisp
(recover ((ErrorType) fallback) ...)
```

### 23.5 Checkpoint Scopes

```lisp
(checkpoint expr)
```

### 23.6 Local Overrides

```lisp
(contracts off)
(defun foo () ...)
```

### Contract Non-Interference

Contracts NEVER affect:
- Type inference
- Ownership
- Regions
- Concurrency model

---

## Implementation Status

- FFI type checking: implemented
- FFI code generation: deferred
- Contract system: defined in spec but not implemented
