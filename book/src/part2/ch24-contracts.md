# Chapter 24: Contracts and Recovery

Complete reference for Zyl's contract and recovery system: preconditions, postconditions, invariants, recovery blocks, checkpoints and profiles. It covers what the specification defines and what the compiler does with each form today.

The normative text is spec v5.0 §23, with §0 P8 (optional layers do not interfere) and §22 phase 10 (contract injection).

**Implementation status, in one sentence: `requires`, `ensures` and `invariant` are checked at run time under the build's profile, `recover` supplies fallbacks by error code, and `checkpoint` rolls back `let-mut` state when its body fails.** A failed check raises `E_CONTRACT_VIOLATION`, which `try`/`catch` can intercept like any other error.

## 24.1 Contract System Overview

Spec §23: contracts are an **optional overlay** that never affects type inference, ownership, regions or the concurrency model (P8, G8).

### Profiles (specified)

```
Profile ::= "strict" | "debug" | "warn" | "off" | "production"
```

§23 names the five profiles but does not define their behaviour. The implementation gives them this meaning:

| Profile | A failed check |
|---------|----------------|
| `strict` (default), `debug` | raises `E_CONTRACT_VIOLATION` |
| `warn` | prints `warning: E_CONTRACT_VIOLATION: ...` on stderr and continues |
| `off`, `production` | is not compiled: the condition is never evaluated |

The build's profile is `--contracts=P` on the command line; a directive overrides it for one form (§24.7).

### The forms

| Form | Spec | Implemented as |
|------|------|----------------|
| `(requires C)` | §23.1 precondition | a check where it is written |
| `(ensures C)` | §23.2 postcondition | a check after the function body, with `result` bound to its value |
| `(invariant C)` | §23.3 invariant | a check where it is written |
| `(recover BODY arms...)` | §23.4 recovery | `BODY`, or the fallback of the first arm matching the error |
| `(checkpoint E)` | §23.5 checkpoint | `E`; if it raises, its `set!`s to outer `let-mut` variables are undone, then the error propagates |
| `(contracts P FORM)` | §23.6 local override | `FORM` under profile `P` |

## 24.2 Preconditions: `requires`

```
requires ::= "(" "requires" Expression ")"
```

A condition that must hold on entry. Write it as a leading form of a `defn` body, directly or inside the body's `begin`. A `defn` body of several forms is an implicit `begin`, so the clause and the code after it need no wrapper:

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
PANIC: E_CONTRACT_VIOLATION: precondition of safe-div failed: (> b 0)
```

The message names the function and repeats the clause as written. A `requires` outside a `defn` body (inside a nested `let`, say) is checked the same way, without the function name.

The condition is ordinary code, evaluated every time the function runs: keep it pure and cheap. It is a `Bool`, like every condition in Zyl; write `(> n 0)`, not `n`.

## 24.3 Postconditions: `ensures`

```
ensures ::= "(" "ensures" Expression ")"
```

A condition that must hold on return. The function's `ensures` clauses are moved after its body, which runs first; its value is bound to `result` while they are checked, and is then returned:

```lisp
(defn abs-val (x)
  (ensures (>= result 0))
  (if (< x 0) (- 0 x) x))
```

A failure reports `postcondition of abs-val failed: (>= result 0)`. `result` shadows any other binding of that name inside the clause. A call in tail position in a body that has an `ensures` is no longer a tail call, since the check runs after it.

## 24.4 Invariants: `invariant`

```
invariant ::= "(" "invariant" Expression ")"
```

Checked where it is written, exactly like `requires`, and reported as `invariant of f failed: ...`. Put it at the top of a recursive function's body to check it on every step:

```lisp
(defn countdown (i)
  (begin
    (invariant (>= i 0))
    (if (= i 0) 0 (countdown (- i 1)))))
```

A top-level `invariant` (beside a `defstruct`, for example) is accepted and not checked; put the check inside the functions that must keep it.

## 24.5 Recovery Blocks: `recover`

```
recover ::= "(" "recover" Expression RecoveryCase* ")"
RecoveryCase ::= "(" "(" ErrorType ")" Expression ")"
```

Specified (§23.4): fallback values for errors of the named types.

Implemented: `(recover BODY arm...)` runs `BODY`; if it raises, the arms are tried in order. An arm naming an error code, `((E_CONTRACT_VIOLATION) fallback)`, matches an error whose message starts with that code; an arm naming a type (`(String)`, `(Error)`) or `_` matches any error. With no matching arm the error propagates.

```lisp
(defn div-or-code (a b)
  (recover (safe-div a b)
    ((E_CONTRACT_VIOLATION) -1)    ; the precondition failed
    ((String) -2)))                ; anything else
```

`recover` catches `error` panics and contract violations, not `(Err ...)` values (Chapter 12).

## 24.6 Checkpoint Scopes: `checkpoint`

```
checkpoint ::= "(" "checkpoint" Expression ")"
```

Specified (§23.5, §28): runtime errors revert state when a checkpoint is active.

Implemented: if `E` raises, every `let-mut` variable bound outside `E` that `E` assigns with `set!` gets its value from before `E` back, and the error then propagates. Heap data is immutable, so there is nothing else to undo, except writes into byte buffers, which are not rolled back.

```lisp
(let-mut x 10
  (begin
    (try (checkpoint (begin (set! x 20) (error "fail")))
      (catch e 0))
    (print x)))
;; prints 10
```

## 24.7 Local Overrides

```
contracts ::= "(" "contracts" Profile Form? ")"
```

Specified (§23.6): `(contracts off) (defun foo () ...)` switches contracts off for the definition that follows.

Implemented:

- `(contracts P FORM)` compiles `FORM` under profile `P`; with `off` or `production`, every `requires`, `ensures` and `invariant` inside it is removed.
- A bare `(contracts P)` at top level does the same to the next top-level form.
- Any other shape compiles to nothing.

```lisp
(contracts off)
(defn unchecked-div (a b)
  (requires (> b 0))     ; removed
  (/ a b))
```

The override is lexical: `(contracts off (f x))` does not switch off the clauses inside `f`.

## 24.8 Contract Non-Interference (Normative)

> **Contracts NEVER affect:** type inference, ownership, regions, or the concurrency model. (§23, P8, G8)

A check is ordinary code in the function body, so two consequences hold:

- **Conditions are type-checked and executed** like any other expression. A condition with side effects affects the program.
- **A condition is a `Bool`.** A clause is lowered to `assert-true`, which takes a `Bool`, so `(requires n)` makes `n` a `Bool` and an `Int` argument is `E_TYPE_MISMATCH`.
- **Conditions are subject to every static check**, including the capability and `Secret` checks: a condition that branches on a `Secret` is rejected.

## 24.9 Implementation

Specified pipeline (§22): contract injection is phase 10, an optional pass over the linked program.

Implemented: contract forms are rewritten where every form is recognized, `convert-ast` in `stdlib/compiler/expr_inner.zyl` (`contract-defn-body`, `contract-check`), so no later phase sees them:

- `requires`/`invariant` become `(assert-true C "E_CONTRACT_VIOLATION: ...")`.
- a `defn` with `ensures` clauses becomes `(let result BODY (begin checks... result))`.
- `recover` becomes `try`/`catch`; `contracts off` strips clauses from the parse tree.

`tests/regression/contracts.zyl` covers each form.

## 24.10 Contract Errors

| Error | Status |
|-------|--------|
| `E_CONTRACT_VIOLATION` | raised at run time by a failed `requires`, `ensures` or `invariant`; the message names the clause kind, the function and the clause |
| `E_UNBOUND_VARIABLE` | what `result` in a `requires` (or outside a `defn`) produces |

## 24.11 Best Practices

1. **State preconditions with `requires` and postconditions with `ensures`.** They are checked, name the failing clause, and can be stripped with `(contracts off)` where a hot path needs it.
2. **Keep conditions pure and cheap**: they run on every call.
3. **Return `Result` for recoverable failures**; use `recover` or `try`/`catch` only for panics.
4. **Build releases with `--contracts=production`** only when the checks are measured to cost too much; `warn` is the middle ground.

## 24.12 Comparison with Other Systems

| Feature | Eiffel | SPARK | Zyl (spec) | Zyl (implemented) |
|---------|--------|-------|------------|-------------------|
| Preconditions | `require` | `Pre` | `requires` | checked at run time |
| Postconditions | `ensure` | `Post` | `ensures` | checked, `result` bound |
| Invariants | `invariant` | `Loop_Invariant` | `invariant` | checked where written |
| Recovery | `rescue` | ❌ | `recover` | arms by error code |
| Checkpoints | ❌ | ❌ | `checkpoint` | `let-mut` rollback |
| Profiles | assertion levels | ❌ | five named | all five, flag or directive |
| Enforced checks | ✅ | ✅ (static proof) | ✅ | ✅ (run time) |
