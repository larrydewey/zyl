# Zyl Specification — FFI and Contracts

**Canonical authority:** `zyl_specification.txt` §16, §23 (also §9.1 R4/R8, §31.9 `ffi`, §31.10 native dependencies)
**Related:** `spec/07-region-memory-model.md`, `spec/06-capability-types.md`, `spec/16-package-system.md`
**Implementation:** `stdlib/compiler/type_annotate.zyl` (`ta-ffi-typed`, `ta-ffi-extern`), `stdlib/compiler/ffi_sigs.zyl` (runtime signature table, `ffi-raw-p`), `stdlib/compiler/expr_inner.zyl` (`parse-extern`), `stdlib/compiler/arity_check.zyl` (`ffi-check-call`, `ffi-check-raw`), `stdlib/compiler/icnf.zyl` (`ic-ffi`), `stdlib/compiler/codegen.zyl` (`cg-fire-ext`), `runtime/actor_runtime.c` (pin arena, `zyl_ffi_timed`); contracts: `stdlib/compiler/expr_inner.zyl` (`contract-defn-body`)

---

## 16. FFI Model

### Syntax

```lisp
(ffi-call name args timeout)
(ffi-pin Expr)
(ffi-unpin Expr)
```

### Signatures

```lisp
(extern "name" (T1 ... Tn) R)
```

Declares the C signature of a foreign symbol; every `ffi-call` to it is
type-checked against it (§4.9), and an `ffi-call` to a foreign symbol
with no `extern` is a Compile Error (`E_CANNOT_INFER`). The types are
concrete (no type variables: that would be a cast) and fit a machine
word: Int, Bool, String, Ptr, the runtime's opaque handle types, and
`(Fn (A1 ... An) R)` for a C callback. Float is not allowed (the timed
call passes every argument in an integer register), nor is Float
returned. R may be Unit.

Runtime symbols (`zyl_*`) are typed by the compiler's signature table
instead, and an `extern` for one is `E_FFI_RESTRICTED`; those that read
raw memory or reinterpret a machine word may only be named by the
standard library (`E_FFI_RESTRICTED`).

### FFI_Pinnable Types

The following types are FFI_Pinnable:
- Int, Float, Bool, String
- Vec<T> (where T is FFI_Pinnable)
- Types composed solely of FFI_Pinnable types

### Pin Semantics

1. `ffi-pin` copies value to Pin Region (non-moving).
2. Returns stable pointer, typed `(Pin a)`; `ffi-unpin` returns the value.
3. Pin lifetime tied to FFI call scope unless manually managed.
4. `ffi-unpin` explicitly frees pinned memory.

### Rules

- **R4:** FFI → Pin region
- `ffi-call` requires Pin region AND FFI_Pinnable type
- Timeout parameter is mandatory on every `ffi-call`: `name` is a string
  literal and `timeout` a positive integer literal in milliseconds
  (`E_FFI_SYMBOL_REQUIRED` / `E_FFI_TIMEOUT_REQUIRED`)
- A foreign call that has not returned within `timeout` raises
  `E_FFI_TIMEOUT`; the foreign code is abandoned, never interrupted, and
  memory it was handed stays valid for the rest of the process
- A timeout is an FFI result (§27): observable external input

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

- `(ffi-call "symbol" arg... timeout)` is an application of the reserved
  name, recognised during ICNF lowering; it is not a dedicated parse
  node. The arity pass checks its shape (`ffi-check-call`,
  `arity_check.zyl`, also run by ICNF lowering): the symbol must be a
  string literal (`E_FFI_SYMBOL_REQUIRED`), the last argument a positive
  integer literal in milliseconds (`E_FFI_TIMEOUT_REQUIRED`), and at most
  16 arguments may be passed (`E_ARITY_MISMATCH`). The literal timeout is
  what stops a forgotten timeout from silently swallowing the real last
  argument. The symbol is passed through `zyl_cstr_sanitize` before it
  reaches the assembly, so a crafted name cannot inject assembly text.
- **Typing** (`ta-ffi-typed`, `type_annotate.zyl`). A runtime symbol with
  an entry in `ffi_sigs.zyl` is typed by it: the argument count must
  match and each argument unifies with its parameter type (the timeout
  is not an argument). A signature is text such as `"(SMap v) String v
  -> v"`: capitalised names are types, a parenthesised name applies a
  type constructor, lowercase names are type variables shared across the
  signature, and a missing `->` means a Unit result. A runtime symbol
  with no entry has no type (`E_CANNOT_INFER`), except eleven
  string-producing entries (`ta-ffi-str`) whose result is String. Any
  other symbol is foreign and is typed by its `extern` declaration; with
  none, `E_CANNOT_INFER` (`ffi-call to `strlen`, which has no (extern
  ...) declaration`).
- **`extern`** (`parse-extern`, `expr_inner.zyl`) records the signature
  by symbol in `extern-table`, emptied per compile; the form itself is
  Unit and emits no code. A malformed one is `E_MALFORMED_FORM`. When a
  call is typed, every parameter and the result must be concrete and
  contain no Float (`ta-extern-ok`); a type variable or Float is
  `E_TYPE_MISMATCH` ("cannot cross the C boundary"). The check does not
  otherwise restrict which types appear, so a declared struct or ADT type
  is accepted (it crosses as its pointer). A declaration is trusted: the
  compiler cannot see the C side.
- **Raw entries.** `ffi-raw-p` lists the runtime entries that read raw
  memory or reinterpret a machine word (`zyl_cstr_of_word`,
  `zyl_word_of_cstr`, `zyl_word_load`, `zyl_word_store`, `zyl_ptr_add`,
  `zyl_ptr_cstr`, `zyl_mem_read`, `zyl_mem_write`, `zyl_ffi_addr`,
  `zyl_call_argv`, `zyl_ffi_timed_argv`, the interpreter's `zyl_val_*`
  and `zyl_itest_*` entries and `zyl_repl_global_set`). They have
  signatures, but an `ffi-call` naming one from a definition outside the
  standard library (whose keys start `zyl/std@`) is `E_FFI_RESTRICTED`
  (`ffi-check-raw`, run by the arity pass).
- **Runtime entries are not declarable.** An `ffi-call` to a symbol the
  runtime exports (`zyl_runtime_export_p`) that also has an `extern` is
  `E_FFI_RESTRICTED` (`ta-extern-on-runtime`, reported with the other
  type errors): runtime entries are typed only by `ffi_sigs.zyl`.
- A foreign symbol is called through the runtime's `zyl_ffi_timed`
  bridge: the call runs on a worker thread owned by the calling thread
  (kept between calls, so thread-local C state such as `errno` stays
  consistent), and the caller waits on a monotonic clock. When the
  timeout expires first the caller raises `E_FFI_TIMEOUT` (catchable
  with `try`, matchable with `recover`). The C function cannot be
  stopped safely, so it is abandoned: its worker finishes and frees
  itself, and nothing it was handed is reclaimed (Pin slots are never
  freed individually, and the exit-time arena teardown is skipped once
  any call has been abandoned).
- Whether a timeout fires depends on how long foreign code runs. Under
  §27 FFI results are observable external input, and a timeout is one
  of them; it does not make the program itself nondeterministic.
- Symbols of this runtime (`zyl_` prefix) are part of the trusted
  implementation: they are called directly and the timeout is unused.
  A C call with up to six arguments is made with the stack realigned to
  16 bytes.
- A C callback into Zyl (for example a `qsort` comparator, declared with
  an `(Fn (A B) R)` parameter) runs on the worker thread. It sees the
  caller's `actor-self`; a panic inside it that no `try` in the callback
  catches ends the process.
- **Pinning.** The Pin region is not required for ordinary arguments.
  Only a `Secret` argument must go through `ffi-pin`
  (`E_FFI_PIN_REQUIRED`, from `secret_check.zyl`); any other value is
  passed directly. A closure (`fn`/`lambda`) written as an `ffi-call`
  argument is `E_INVALID_CAPABILITY` (`mutability_check.zyl`).
- `ffi-pin` lowers to the runtime's `ffi_pin`, which copies the value's
  8-byte word into a Pin-arena slot and returns the slot's address,
  typed `(Pin a)` for a value of type `a` (§4.9); `Pin` is an opaque
  handle type, so an `extern` can take one for an out-parameter.
  `ffi-unpin` is `(Pin a) -> a`: the runtime's `ffi_unpin` checks that
  the pointer came from the Pin arena and returns the slot's current
  word (possibly updated by C). Pinning a function is
  `E_FFI_TYPE_NOT_PINNABLE`; no other FFI_Pinnable check is made.
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
