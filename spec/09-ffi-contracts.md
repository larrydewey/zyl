# Zyl Specification — FFI and Contracts

**Canonical authority:** `zyl_specification.txt` §16, §23 (also §9.1 R4/R8, §31.9 `ffi`, §31.10 native dependencies)
**Related:** `spec/07-region-memory-model.md`, `spec/06-capability-types.md`, `spec/16-package-system.md`
**Implementation:** `stdlib/compiler/type_inference.zyl` (pinnability), `stdlib/compiler/icnf.zyl` (`ic-ffi`), `stdlib/compiler/codegen.zyl` (`cg-fire-ext`), `runtime/actor_runtime.c` (pin arena); contracts: `stdlib/compiler/expr_inner.zyl`, `stdlib/compiler/contract_injection.zyl` (not wired in)

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

## Implementation Notes

Not normative.

### FFI

- `(ffi-call "symbol" arg... timeout)` calls any C symbol by name. The
  symbol must be a string literal; it is passed through
  `zyl_cstr_sanitize` before it reaches the assembly, so a crafted name
  cannot inject assembly text. A C call with up to six arguments is
  made with the stack realigned to 16 bytes.
- Type inference requires every argument to be FFI_Pinnable
  (`is-ffi-pinnable`) and raises `E_INVALID_CAPABILITY` otherwise; a
  closure argument is rejected the same way by `mutability_check.zyl`.
  The result of `ffi-call` is typed `Int`. `E_FFI_TYPE_NOT_PINNABLE` is
  catalogued but not the code actually raised.
- **The timeout is not enforced.** ICNF lowering drops the trailing
  argument, and `E_FFI_TIMEOUT` is never raised.
- **The Pin region is not required for ordinary arguments.** Only a
  `Secret` argument must go through `ffi-pin` (`E_FFI_PIN_REQUIRED`, from
  `secret_check.zyl`); any other pinnable value is passed directly.
- `ffi-pin` copies an 8-byte value into the pin arena and returns its
  address, typed `TCap TCPin T`; `ffi-unpin` checks that the pointer came
  from the pin arena.
- In a package, `ffi-call`, `ffi-pin` and `ffi-unpin` need the `ffi`
  capability (§31.9).

### Contracts

The overlay is lowered while the parse tree is converted
(`expr_inner.zyl`, `contract-defn-body`):

- `(requires c)` and `(invariant c)` are checks: a false `c` raises
  `E_CONTRACT_VIOLATION: precondition of f failed: c` (or `invariant of
  f`), catchable with `try`.
- A `defn`'s `(ensures c)` clauses run after the body with its value bound
  to `result`; `postcondition of f failed: c` on failure.
- `(recover body ((Type) fallback) ...)` is `try`/`catch`; an arm naming an
  error code (`E_...`) matches by message prefix, a type-named or `_` arm
  matches anything, and an unmatched error propagates.
- Profiles: strict/debug panic, warn prints and continues, off/production
  compile the clauses out; the build's profile is `--contracts=P`, and
  `(contracts P form)` or a bare `(contracts P)` before a top-level form
  overrides it for that form.
- `(checkpoint e)`: if `e` raises, the outer `let-mut` variables it
  `set!`s are restored before the error propagates.

A check is ordinary code: its condition is typed and evaluated like any
other expression, so keep conditions pure (P8, G8).
