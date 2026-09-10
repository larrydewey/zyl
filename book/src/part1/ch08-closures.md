# Chapter 8: Closures and Higher-Order Functions

Closures are first-class functions that capture their environment. Zyl requires **explicit closure syntax** — no implicit lambdas.

## 8.1 Closure Syntax

```lisp
(fn (params) body)
```

```lisp
(lambda (params) body)   ; Synonym — identical to fn
```

**No shorthand** — `((x) (* x x))` is a **syntax error**. You must write:
```lisp
(fn (x) (* x x))         ; ✅ Correct
(lambda (x) (* x x))     ; ✅ Correct
```

## 8.2 Basic Usage

```lisp
;; Assign to variable
(def square (fn (x) (* x x)))
(square 5)        ; 25

;; Pass as argument
(defn apply-twice (f x)
  (f (f x)))

(apply-twice square 3)        ; 81 (3² = 9, 9² = 81)
(apply-twice (fn (x) (+ x 1)) 5)  ; 7

;; Return from function
(defn make-adder (n)
  (fn (x) (+ x n)))

(def add5 (make-adder 5))
(add5 10)       ; 15
```

## 8.3 Capture Inference

The compiler analyzes what variables a closure uses and assigns **capabilities + regions**:

| Capture Kind | Capability | Region |
|--------------|------------|--------|
| Read-only | `TCap` | Stack (if non-escaping) / Heap (if escaping) |
| Mutated (`set!`) | `TMut` | Heap (must escape) |
| Sent to actor / FFI | `TCap`/`TAtomic` | Heap / Pin |

### Examples

```lisp
;; Read-only capture → TCap, Stack (non-escaping)
(defn apply-twice (f x)
  (f (f x)))    ; f doesn't escape

;; Read-only capture → TCap, Heap (escaping)
(defn make-adder (n)
  (fn (x) (+ x n)))    ; n captured, closure returned

;; Mutated capture → TMut, Heap
(defn make-counter ()
  (let-mut (count 0)
    (fn () (set! count (+ count 1)) count)))

;; Multiple captures
(defn make-multiplier (factor offset)
  (fn (x) (+ (* x factor) offset)))  ; factor, offset: TCap
```

## 8.4 Escaping vs Non-Escaping Closures

### Non-Escaping (Stack-Allocated)

```lisp
(defn map ((T) (U) f xs)
  (match xs
    Nil Nil
    (Cons x rest (Cons (f x) (map f rest)))))
```

- `f` called directly, doesn't outlive `map`
- Stack-allocated environment
- Direct call (no indirection)

### Escaping (Heap-Allocated, `TBox`)

```lisp
(defn make-adder (n)
  (fn (x) (+ x n)))    ; Returned → escapes
```

- Environment heap-allocated (`TBox<Env>`)
- Closure represented as `{ fn_ptr, env_ptr }`
- Indirect call via function pointer

### Forcing Heap Allocation

```lisp
;; Explicit box for recursive closures
(defn make-recursive ()
  (let (rec (TBox (fn (n) (if (== n 0) 1 (* n (rec (- n 1)))))))
    rec))
```

## 8.5 Higher-Order Function Patterns

### Map / Filter / Fold (on List ADT)

```lisp
(deftype List (Cons T (List T)) Nil)

(defn map ((T) (U) f xs)
  (match xs
    Nil Nil
    (Cons x rest (Cons (f x) (map f rest)))))

(defn filter ((T) pred xs)
  (match xs
    Nil Nil
    (Cons x rest
      (if (pred x)
        (Cons x (filter pred rest))
        (filter pred rest)))))

(defn fold ((T) (U) f acc xs)
  (match xs
    Nil acc
    (Cons x rest (fold f (f acc x) rest))))
```

### Function Composition

```lisp
(defn compose ((T) (U) (V) f g)
  (fn (x) (f (g x))))

(def add1 (fn (x) (+ x 1)))
(def mul2 (fn (x) (* x 2)))

(def add1-then-mul2 (compose mul2 add1))
(add1-then-mul2 5)    ; 12 = (5+1)*2
```

### Partial Application

```lisp
(defn partial ((T) (U) (V) f x)
  (fn (y) (f x y)))

(def add (fn (a b) (+ a b)))
(def add5 (partial add 5))
(add5 10)    ; 15
```

### Flip (Swap Arguments)

```lisp
(defn flip ((T) (U) (V) f)
  (fn (a b) (f b a)))

(def sub (fn (a b) (- a b)))
(def sub-from (flip sub))
(sub-from 10 3)    ; 7 = 10 - 3
```

## 8.6 Closures and Actors

Closures sent to actors must be **Send-capable** (capture only `TCap`/`TAtomic`):

```lisp
;; ✅ OK — captures immutable data
(spawn (fn (msg)
  (print "Received: " msg)))

;; ✅ OK — captures TAtomic counter
(let (counter (atomic-new 0))
  (spawn (fn ()
    (atomic-add counter 1))))

;; ❌ ERROR — captures TMut
(let-mut (count 0)
  (spawn (fn () (set! count (+ count 1)))))
```

## 8.7 Closure Types

Closure type: `TFun([ParamTypes...], ReturnType)` with capability:

```lisp
;; Inferred types:
(fn (x) (* x 2))           ; TFun([Int], Int)  (if x: Int)
(fn (x) (+ x n))           ; TFun([Int], Int)  (n captured)
(fn () (atomic-add c 1))   ; TFun([], Unit)    (c captured)
```

In type signatures:
```lisp
(defn apply-twice ((T) f TFun([T], T) x T) T
  (f (f x)))
```

## 8.8 Recursive Closures

Direct recursion in closures requires `TBox` (self-reference):

```lisp
;; Using TBox for self-reference
(let (fact (TBox (fn (n) (if (<= n 1) 1 (* n (fact (- n 1)))))))
  (fact 5))    ; 120
```

Or use named `let` (preferred for tail recursion):

```lisp
(let fact ((n) (if (<= n 1) 1 (* n (fact (- n 1)))))
  (fact 5))
```

## 8.9 Closure Inlining Optimization

The optimizer (Phase 7) can inline small closures:

```lisp
;; Before optimization:
(defn map (f xs) ...)

;; After inlining (if f is small and known):
(defn map (xs)
  (match xs
    Nil Nil
    (Cons x rest (Cons (* x 2) (map rest)))))
```

Conditions:
- Closure is non-escaping
- Body is small (configurable threshold)
- No recursion in closure

## 8.10 Common Pitfalls

### Pitfall 1: Capturing Loop Variable

```lisp
;; ❌ WRONG — all closures capture same variable
(let-mut (i 0)
  (for (i 0) (< i 3)
    (let fns (Cons (fn () i) fns)  ; All capture same i!
      (set! i (+ i 1)))))

;; ✅ CORRECT — bind loop variable in inner scope
(let fns Nil)
(for (i 0) (< i 3)
  (let (captured i)  ; New binding each iteration
    (set! fns (Cons (fn () captured) fns))))
```

### Pitfall 2: Mutating Captured Variable from Multiple Closures

```lisp
;; ❌ ERROR — TMut cannot be shared
(let-mut (count 0)
  (let inc (fn () (set! count (+ count 1))))
  (let dec (fn () (set! count (- count 1))))
  ...)

;; ✅ Use TAtomic for shared mutation
(let (count (atomic-new 0))
  (let inc (fn () (atomic-add count 1)))
  (let dec (fn () (atomic-sub count 1))))
```

## 8.11 Performance Notes

| Aspect | Cost |
|--------|------|
| Non-escaping closure call | Direct call (like function) |
| Escaping closure call | Indirect call (load fn_ptr, call) |
| Heap allocation | One `TBox` per escaping closure creation |
| Capture copy | By reference (Stack) or by value (Heap promotion) |

**Tip**: Prefer non-escaping closures (pass as args, don't return/store). Use `fn` at call sites, not stored in data structures.

---

## For Experts: Under the Hood

### Closure Representation

```c
// Non-escaping: stack-allocated env, direct call
struct StackClosure {
    void (*fn_ptr)(StackClosure*, Args...);
    // Captured vars follow
};

// Escaping: heap-allocated (TBox)
struct HeapClosure {
    void (*fn_ptr)(HeapClosure*, Args...);
    Env* env;          // Heap-allocated, ref-counted
};
```

### Capture Analysis Algorithm (Phase 4)

1. **Free variable analysis**: For each `fn`, find vars used but not bound inside
2. **Mutability analysis**: For each free var, check if `set!` applied
3. **Escape analysis**: Does closure outlive defining scope?
4. **Assign capability + region**:
   - Read-only + non-escaping → `TCap`, Stack
   - Read-only + escaping → `TCap`, Heap (`TBox`)
   - Mutated → `TMut`, Heap (must escape)
   - Actor/FFI → `TCap`/`TAtomic`, Heap/Pin

### Call Sites

```asm
; Non-escaping (direct call)
call map_Int_Int_fn_1    ; Known function

; Escaping (indirect call)
mov rax, [rdi + 0]       ; Load fn_ptr from closure
call rax                 ; Indirect call
```

---

**Next:** [Chapter 9: Concurrency with Actors](ch09-actors.md) — spawn, send, mailboxes, and deterministic actor concurrency.