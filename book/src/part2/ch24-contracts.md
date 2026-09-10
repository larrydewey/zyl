# Chapter 24: Contracts and Recovery

Complete reference for Zyl's optional contract system: preconditions, postconditions, invariants, recovery, and checkpoints.

## 24.1 Contract System Overview

Contracts are an **optional overlay** (Phase 10) that never affect core semantics (Spec §23, P8).

### Profiles

```
Profile ::= "strict" | "debug" | "warn" | "off" | "production"
```

- **strict**: All contracts enforced, abort on violation
- **debug**: Enabled in development, may log
- **warn**: Log violations, continue execution
- **off**: Contracts completely removed (zero overhead)
- **production**: Optimized subset (invariants only)

### Contract Placement

```lisp
;; Function preconditions
(defn sqrt (x)
  (requires (>= x 0))
  ...)

;; Function postconditions
(defn sqrt (x)
  (ensures (>= (result) 0))
  ...)

;; Loop invariants
(while condition
  (invariant (>= i 0))
  body)

;; Module-level
(contracts strict)
(defn foo () ...)
```

## 24.2 Preconditions: `requires`

```
requires ::= "requires" Expression
```

```lisp
(defn divide (a b)
  (requires (!= b 0))
  (/ a b))

(defn sqrt (x)
  (requires (>= x 0))
  ...)
```

- Checked **before** function body executes
- Violation → `E_CONTRACT_VIOLATION` (or log/warn per profile)
- Can reference parameters only

## 24.3 Postconditions: `ensures`

```
ensures ::= "ensures" Expression
```

```lisp
(defn sqrt (x)
  (requires (>= x 0))
  (ensures (>= (result) 0))
  (ensures (<= (abs (- (* (result) (result)) x)) 0.0001))
  ...)
```

- `result` binds to return value
- Checked **after** function body, before return
- Can reference parameters and `result`

## 24.4 Invariants: `invariant`

```
invariant ::= "invariant" Expression
```

```lisp
(while (< i n)
  (invariant (<= 0 i n))
  (invariant (== (sum 0 i) (fold + 0 (slice arr 0 i))))
  body)
```

- Checked **at loop entry** and **after each iteration**
- Can reference loop variables and outer scope
- Must hold initially and be preserved

## 24.5 Recovery Blocks: `recover`

```
recover ::= "recover" "(" RecoveryCase* ")"

RecoveryCase ::= "(" ErrorType Expression ")"
```

```lisp
(defn read-config (path)
  (recover
    ((FileNotFound) (default-config))
    ((ParseError msg) (log-error msg) (default-config))
    ((IOError) (retry-read path)))
  (read-file path))
```

- Catches specific error types from `try`/`Result`
- First matching handler executes
- If no match, error propagates

## 24.6 Checkpoint Scopes: `checkpoint`

```
checkpoint ::= "checkpoint" Expression
```

```lisp
(defn transactional-update (db key value)
  (checkpoint
    (begin
      (db-begin-transaction db)
      (db-set db key value)
      (db-commit db))))
```

- **On error**: Reverts state to checkpoint entry
- **On success**: Commits changes
- Works with: memory, actor state, FFI resources (if registered)

## 24.7 Local Overrides

```
contracts ::= "contracts" Profile
```

```lisp
(contracts off)
(defn fast-path (x) ...)  ; No contracts

(contracts strict)
(defn safe-path (x) ...)  ; Full contracts
```

## 24.8 Contract Non-Interference (Normative)

> **Contracts NEVER affect:**
> - Type inference
> - Ownership / regions
> - Concurrency model
> - Monomorphization
> - Code generation (except check insertion)

This is **guaranteed by phase isolation** — contracts run in Phase 10, after all core phases.

## 24.9 Implementation

### Phase 10: Contract Injection

1. **Parse contracts** from AST (after macro expansion)
2. **Generate check code** for each contract
3. **Inject** at appropriate points:
   - `requires`: Function entry
   - `ensures`: Before return
   - `invariant`: Loop header + after body
   - `recover`: Wrap `try` expression
   - `checkpoint`: Save/restore state
4. **Profile filtering**: Omit checks per profile

### Code Generation Example

```lisp
;; Source:
(defn sqrt (x)
  (requires (>= x 0))
  (ensures (>= (result) 0))
  ...)

;; Injected (simplified):
(defn sqrt (x)
  (if (not (>= x 0)) (contract-violation "precondition"))
  (let result (...)
    (if (not (>= result 0)) (contract-violation "postcondition"))
    result))
```

## 24.10 Recovery and Checkpoints Implementation

### Recovery

```lisp
;; Source:
(recover ((FileNotFound) default) (read-file path))

;; Compiles to:
(try (read-file path)
  (catch err
    (match err
      (FileNotFound default)
      (d1 (error err)))))
```

### Checkpoint

```lisp
;; Source:
(checkpoint (transactional-work))

;; Compiles to:
(let snapshot (save-state)
  (try (transactional-work)
    (catch err
      (restore-state snapshot)
      (error err))))
```

## 24.11 Contract Errors

| Error | Cause |
|-------|-------|
| `E_CONTRACT_VIOLATION` | Pre/post/invariant failed |
| `E_RECOVERY_EXHAUSTED` | No matching recovery handler |
| `E_CHECKPOINT_FAILED` | State save/restore failed |

## 24.12 Best Practices

1. **Use `requires`** for input validation (public APIs)
2. **Use `ensures`** for documenting return guarantees
3. **Use `invariant`** for complex loop correctness
4. **Use `recover`** for expected error categories
5. **Use `checkpoint`** for multi-step operations needing atomicity
6. **Profile appropriately** — `strict` for testing, `production` for release

## 24.13 Comparison with Other Systems

| Feature | Eiffel | SPARK | Rust (contracts) | Zyl |
|---------|--------|-------|------------------|-----|
| Preconditions | `require` | `Pre` | `requires!` macro | `requires` |
| Postconditions | `ensure` | `Post` | `ensures!` macro | `ensures` |
| Invariants | `invariant` | `Loop_Invariant` | ❌ | `invariant` |
| Recovery | `rescue` | ❌ | `catch_unwind` | `recover` |
| Checkpoints | ❌ | ❌ | ❌ | `checkpoint` |
| Profiles | ❌ | ❌ | ❌ | `strict`/`debug`/etc. |
| Non-interference | ❌ | ✅ | ❌ | ✅ (phase isolation) |