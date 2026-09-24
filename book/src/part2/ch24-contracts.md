# Chapter 24: Contracts and Recovery

Complete reference for Zyl's contract and recovery system: preconditions, postconditions, invariants, recovery blocks, checkpoints and profiles. It covers what the specification defines and what the compiler does with each form today.

The normative text is spec v5.0 §23, with §0 P8 (optional layers do not interfere) and §22 phase 10 (contract injection).

**Implementation status, in one sentence: contracts are parsed, and not enforced.** The forms are accepted by the parser and lowered to plain expressions. No check is ever injected, no profile exists, and `E_CONTRACT_VIOLATION` is never raised. A contract-injection pass exists in `stdlib/compiler/contract_injection.zyl`, but it is not part of the compiler. `pipeline.zyl` explains why: its accessors do not match the real AST, and it clashed with a name in `closure_inline.zyl`. Everything below states the specified meaning first and the implemented behaviour second.

## 24.1 Contract System Overview

Spec §23: contracts are an **optional overlay** that never affects type inference, ownership, regions or the concurrency model (P8, G8). They are applied at phase 10, after code generation and linking in the §22 ordering.

### Profiles (specified)

```
Profile ::= "strict" | "debug" | "warn" | "off" | "production"
```

§23 names the five profiles but does not define their behaviour.

**Implemented:** none. There is no profile setting, no compiler flag and no directive that selects one. `(contracts strict)` is accepted and ignored (§24.7).

### The forms

| Form | Spec | Implemented as |
|------|------|----------------|
| `(requires C)` | §23.1 precondition | `C`, evaluated for its side effects; the result is discarded |
| `(ensures C)` | §23.2 postcondition | same as `requires` |
| `(invariant C)` | §23.3 invariant | **not recognised**: an ordinary call to an undefined function `invariant` |
| `(recover BODY arms...)` | §23.4 recovery | `BODY`; the arms are discarded |
| `(checkpoint E)` | §23.5 checkpoint | `E` |
| `(contracts off FORM)` | §23.6 local override | `FORM` |

## 24.2 Preconditions: `requires`

```
requires ::= "(" "requires" Expression ")"
```

Specified: a condition that must hold on entry to a function.

A `requires` form may be written as an extra leading form in a `defn` body or inside a `begin`; both parse:

```lisp
(defn safe-div (a b)
  (requires (> b 0))
  (/ a b))

(defn main ()
  (begin
    (print (safe-div 10 2))
    (print (safe-div 10 -1))
    0))
```

Output:

```
5
-10
```

The violated precondition is not reported. The condition **is evaluated**, so a condition with side effects (a `print`, a call) runs every time. Contracts are therefore not zero-cost: keep conditions pure and cheap.

## 24.3 Postconditions: `ensures`

```
ensures ::= "(" "ensures" Expression ")"
```

Specified: a condition that must hold on return.

Implemented: exactly like `requires`, the condition is evaluated where it is written and its result is discarded. There is **no binding for the return value**. `(ensures (>= (result) 0))` fails with `E_UNBOUND_VARIABLE: call to undefined function `result``, and `(ensures (>= result 0))` fails with `E_UNBOUND_VARIABLE`. A postcondition can therefore refer only to parameters and other bindings in scope.

## 24.4 Invariants: `invariant`

```
invariant ::= "(" "invariant" Expression ")"
```

Specified: a condition that must hold as an invariant.

Implemented: `invariant` has no handling. Inside a function body, `(invariant (>= i 0))` is compiled as a call to a function named `invariant`, which is rejected with `E_UNBOUND_VARIABLE: call to undefined function `invariant``. Do not use it.

## 24.5 Recovery Blocks: `recover`

```
recover ::= "(" "recover" Expression RecoveryCase* ")"
RecoveryCase ::= "(" "(" ErrorType ")" Expression ")"
```

Specified (§23.4): fallback values for errors of the named types.

Implemented: `recover` evaluates its first operand and ignores the recovery cases:

```lisp
(result-is-ok (recover (result-err "boom") ((String) (result-ok 1))))
;; → 0: the fallback is never used
```

Handle errors explicitly with `try`/`catch` (§12.2) or `match` on the `Result` instead:

```lisp
(try (read-config path)
  (catch e (default-config)))
```

## 24.6 Checkpoint Scopes: `checkpoint`

```
checkpoint ::= "(" "checkpoint" Expression ")"
```

Specified (§23.5, §28): runtime errors revert state when a checkpoint is active.

Implemented: `(checkpoint E)` is `E`. Nothing is saved and nothing is rolled back:

```lisp
(let-mut x 10
  (begin
    (try (checkpoint (begin (set! x 20) (result-err "fail")))
      (catch e 0))
    (print x)))
;; prints 20
```

## 24.7 Local Overrides

```
contracts ::= "(" "contracts" Profile Form? ")"
```

Specified (§23.6): `(contracts off) (defun foo () ...)` switches contracts off for the definition that follows.

Implemented:

- `(contracts off FORM)`, wrapping one form, compiles as `FORM`.
- Every other shape, including a bare `(contracts off)` directive before a definition and `(contracts strict)`, compiles to nothing and is ignored silently.

```lisp
(print (contracts off (* 4 3)))   ; 12
```

## 24.8 Contract Non-Interference (Normative)

> **Contracts NEVER affect:** type inference, ownership, regions, or the concurrency model. (§23, P8, G8)

Because no checks are injected, contracts cannot alter program semantics beyond what their conditions do when evaluated. Two consequences follow from the parse-only implementation:

- **Conditions are type-checked and executed** like any other expression. A condition that fails to type-check, or that performs I/O, affects the program.
- **A condition is not isolated from ownership and capability checks**: it is ordinary code in the function body, subject to every static check.

## 24.9 Implementation

Specified pipeline (§22): contract injection is phase 10, an optional pass over the linked program.

Implemented: the forms are handled in the parser only (`stdlib/compiler/expr_inner.zyl`, the special-form dispatch), as the table in §24.1 shows. `stdlib/compiler/contract_injection.zyl` sketches the intended lowering:

- `requires`/`ensures` become `(if cond Unit (error "precondition failed"))`.
- `recover` becomes `try`/`catch`.
- `checkpoint` passes its body through.

No part of the compiler imports that module, and nothing calls it. `tests/regression/contracts.zyl` pins down the current pass-through behaviour.

## 24.10 Contract Errors

| Error | Status |
|-------|--------|
| `E_CONTRACT_VIOLATION` | specified in §28; defined in the error catalogue; never raised |
| `E_UNBOUND_VARIABLE` | what `result` in an `ensures` produces |
| link-time `undefined reference` | what `(result)` or `(invariant ...)` produces |

The specification defines no other contract error codes.

## 24.11 Best Practices

Until contracts are enforced:

1. **Use `assert-true` for checks that must hold.** `(assert-true cond)` aborts with `PANIC: assert-true failed` and exit status 1 when `cond` is false. Plain `(assert cond)` (§12.4, `E_ASSERT_FAIL`) is parsed but currently not lowered to any check, so it does nothing.
2. **Return `Result` for recoverable failures**, and handle them with `try`/`catch` or `match`, rather than relying on `recover`.
3. **Write `requires` and `ensures` as documentation** if you like, but keep their conditions pure and cheap, since they are evaluated and their failures are ignored.
4. **Do not use `invariant`, `(result)`, profiles or `checkpoint` rollback.** They are unimplemented, and the first two do not even compile.

## 24.12 Comparison with Other Systems

| Feature | Eiffel | SPARK | Zyl (spec) | Zyl (implemented) |
|---------|--------|-------|------------|-------------------|
| Preconditions | `require` | `Pre` | `requires` | parsed; condition evaluated, not checked |
| Postconditions | `ensure` | `Post` | `ensures` | parsed; no result binding |
| Invariants | `invariant` | `Loop_Invariant` | `invariant` | not recognised |
| Recovery | `rescue` | ❌ | `recover` | first operand only |
| Checkpoints | ❌ | ❌ | `checkpoint` | identity |
| Profiles | assertion levels | ❌ | five named | none |
| Enforced checks | ✅ | ✅ (static proof) | ✅ | ❌ (use `assert-true`) |
