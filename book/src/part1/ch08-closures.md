# Chapter 8: Closures and Higher-Order Functions

Closures are first-class functions that can capture values from the scope they are created in. Zyl requires **explicit closure syntax**; there are no implicit lambdas (Spec §7).

This chapter describes both the language design and what the current self-hosted compiler actually supports. Closures are one of the areas where the two still differ, so §8.4 spells out exactly which shapes work today. Every runnable example in this chapter was compiled with `zyl` and run; the output shown is what the binary prints.

## 8.1 Closure Syntax

```lisp
(fn (params) body)
```

```lisp
(lambda (params) body)   ; synonym, identical to fn
```

There is **no shorthand**. The spec rejects `((x) (* x x))`; you must write:

```lisp
(fn (x) (* x x))         ; correct
(lambda (x) (* x x))     ; correct
```

> **Current compiler:** instead of reporting a diagnostic for the `((x) body)` shorthand, the compiler currently crashes. Treat it as an error either way.

## 8.2 Basic Usage

Closures are ordinary values: bind them with `let`, call them like functions, pass them as arguments, and return them from functions.

```lisp
(defn apply-twice (f x)
  (f (f x)))

(defn make-adder (n)
  (fn (x) (+ x n)))

(defn main ()
  (let square (fn (x) (* x x))
  (let add5 (make-adder 5)
  (let triple (lambda (x) (* x 3))
    (begin
      (print (square 5))                      ; 25
      (print (apply-twice square 3))          ; 81  (3² = 9, 9² = 81)
      (print (apply-twice (fn (x) (+ x 1)) 5)) ; 7
      (print (add5 10))                       ; 15
      (print (triple 4)))))))                 ; 12
```

Output:

```
25
81
7
15
12
```

Bind closures inside a function body. A top-level `(def name value)` is accepted by the REPL, but a compiled program cannot refer to a top-level `def` yet; use `defn` for named functions and `let` for closure values.

## 8.3 Capture Inference

The compiler finds the variables a closure uses but does not bind itself (its **free variables**) and captures them. The specification (Spec §7.2, §9) assigns each capture a capability and a region:

| Capture Kind | Capability | Region |
|--------------|------------|--------|
| Read-only | `TCap` | Stack if the closure does not escape, Heap if it does |
| Mutated (`set!`) | `TMut` | Heap |
| Sent to an actor | must be Send-capable (`TCap`/`TAtomic`) | Heap |

In the current compiler, captures are **by value**: when the closure is created, the current value of each captured variable is copied into a heap-allocated environment. Changing the original binding afterward does not affect the closure.

```lisp
;; Read-only capture of a parameter; the closure escapes (it is returned)
(defn make-adder (n)
  (fn (x) (+ x n)))

;; Several captures
(defn make-multiplier (factor offset)
  (fn (x) (+ (* x factor) offset)))

(defn main ()
  (let m (make-multiplier 3 1)
    (print (m 4))))        ; 13
```

**Mutated captures are not supported yet.** A closure that `set!`s a captured `let-mut` variable compiles, but crashes when it is called:

```lisp
;; Compiles today, but segfaults at run time: do not rely on it yet
(defn main ()
  (let-mut count 0
    (let bump (fn () (set! count (+ count 1)))
      (begin
        (bump)
        (print count)))))
```

Across an actor boundary, the check does exist: a spawned closure that captures a `let-mut` variable is rejected at compile time with `E_CAPABILITY_LEAK` (see §8.6).

## 8.4 What Works Today

The code generator builds a real closure (a heap-allocated code-plus-environment pair) only for lambda bodies made of a limited set of forms: literals, the lambda's own parameters, captured variables, calls to top-level `defn` functions and constructors, operators, `let`, `let-mut`, `if`, `while`, `begin`, `print`, `struct-get`, the `assert-*` forms, nested `fn`, and `set!` on the lambda's own locals. A lambda whose body uses anything else, such as `match` or a call to a captured function value, is silently compiled to a null function and crashes when called.

| Shape | Status |
|-------|--------|
| Non-capturing lambda: bind, call, pass as argument, store in a list | Works |
| Capturing lambda, called directly where it is bound | Works |
| Capturing lambda returned from a function (`make-adder`) and called through a `let` | Works |
| Capturing lambda **passed as an argument** to another function | Crashes |
| Lambda that **calls a captured function value** (`compose`, `partial`) | Crashes |
| Lambda that `set!`s a captured variable | Crashes |
| Lambda whose body contains `match` | Crashes; move the `match` into a `defn` |
| Recursive lambda | Not supported; use `defn` |

The workaround for the last few rows is the same: put the logic in a named top-level function and have the lambda call it, or pass the functions and their arguments together instead of returning a combined closure (§8.5).

## 8.5 Higher-Order Function Patterns

### Map / Filter / Fold

The standard `List` type (`Cons`/`Nil`, from `core/list`) is available in every program. These definitions work with any non-capturing function value:

```lisp
(defn map (f xs)
  (match xs
    (Nil Nil)
    (Cons x rest (Cons (f x) (map f rest)))))

(defn filter (pred xs)
  (match xs
    (Nil Nil)
    (Cons x rest
      (if (pred x)
        (Cons x (filter pred rest))
        (filter pred rest)))))

(defn fold (f acc xs)
  (match xs
    (Nil acc)
    (Cons x rest (fold f (f acc x) rest))))

(defn main ()
  (let xs (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil))))
  (let ys (map (fn (x) (* x 10)) xs)
  (let evens (filter (fn (x) (== (% x 2) 0)) xs)
    (begin
      (print (fold (fn (a x) (+ a x)) 0 ys))      ; 100
      (print (list-length evens))                 ; 2
      (print (fold (fn (a x) (+ a x)) 0 evens)))))))  ; 6
```

Match arms are written `(Pattern body)`, so an empty-list arm is `(Nil Nil)`, not `Nil Nil`. Generic functions need no type-parameter list: `map`, `filter`, and `fold` are inferred as polymorphic (Chapter 7).

### Composition, Partial Application, and Flip

The textbook versions of these combinators return a new closure that calls the captured functions:

```lisp
(defn compose (f g)
  (fn (x) (f (g x))))      ; the lambda calls captured f and g

(defn partial (f x)
  (fn (y) (f x y)))        ; the lambda calls captured f
```

`core/core` ships exactly this `compose`, and a user program can define `partial` the same way. Both compile, but calling the closure they return **crashes today**, because a lambda cannot yet call a captured function value (§8.4). Until that lands, apply the functions directly instead of building a combined closure:

```lisp
(defn compose-apply (f g x)
  (f (g x)))

(defn main ()
  (let add1 (fn (x) (+ x 1))
  (let mul2 (fn (x) (* x 2))
  (let sub (fn (a b) (- a b))
    (begin
      (print (compose-apply mul2 add1 5))   ; 12 = (5+1)*2
      (print (flip sub 3 10)))))))           ; 7  = 10 - 3
```

`flip` comes from `core/core`, which is loaded into every program: `(flip f a b)` calls `(f b a)`. `core/core` also provides `identity`, `const`, and `apply`. Because those names are already defined, a program that defines its own `compose` or `flip` fails with `E_DUPLICATE_DEFINITION`; pick another name.

## 8.6 Closures and Actors

Closures passed to `spawn` must be **Send-capable** (Spec §7.4): they may capture only `TCap`/`TAtomic` values. The compiler enforces the `TMut` half of that rule today:

```lisp
(use actor/actor)

(defn main ()
  (let-mut count 0
    (let a (spawn (fn () (set! count (+ count 1))))
      (actor-wait a))))
```

```
PANIC: E_CAPABILITY_LEAK: spawned closure captures a let-mut (TMut) variable from the enclosing scope -- only Send-capable (non-mut) captures may cross into another actor
```

In the current runtime a spawned closure should not capture anything at all: the actor entry point receives no environment, so even a read-only capture crashes. Have the spawned closure call a top-level function instead. Chapter 9 covers this in detail.

## 8.7 Closure Types

The type checker gives every closure a function type (internally `TFun`, built from the parameter and result types) and infers it from use; closure types never need to be written. There is no surface syntax for function types in parameter annotations: leave closure parameters such as `f` unannotated, as every example in this chapter does.

## 8.8 Recursive Closures

A lambda cannot refer to itself, and there is no `TBox` or named-`let` form for building one. Write recursive helpers as top-level `defn` functions:

```lisp
(defn fact (n)
  (if (<= n 1) 1 (* n (fact (- n 1)))))
```

## 8.9 Closure Inlining

The compiler has a dedicated closure-inlining pass (`stdlib/compiler/closure_inline.zyl`) that runs before ICNF lowering. It handles `(let name (fn params body) rest)` when `name` is only ever called directly inside `rest` (never stored, passed, or returned): each call `(name arg ...)` is beta-reduced in place, with the parameters bound to the arguments by `let` and the body spliced in. The closure then costs nothing at run time.

```lisp
(defn main ()
  (let k 3
    (let times-k (fn (x) (* x k))
      (print (times-k 5)))))      ; 15; times-k is inlined, no closure is built
```

Anything the pass does not recognize (the lambda escapes, is passed, or is recursive) is left unchanged for the normal closure path.

## 8.10 Common Pitfalls

### Pitfall 1: Expecting a Capture to Track Later Changes

Captures are copied when the closure is created. A closure built inside a loop sees the value the variable had at that moment, not a shared, changing variable. If you need shared, changing state between closures, keep it in a data structure you pass explicitly (or, across actors, an atomic location from `atomic/atomic`) rather than in a captured `let-mut`.

### Pitfall 2: Mutating a Captured Variable

Spec §10 allows exactly one `TMut` reference, so two closures that both `set!` the same captured variable are an aliasing error by design. In the current compiler, even one closure that mutates a capture crashes (§8.3). Restructure the code so the closure returns a new value and the caller rebinds it:

```lisp
(defn main ()
  (let-mut count 0
    (let inc (fn (c) (+ c 1))
      (begin
        (set! count (inc count))
        (set! count (inc count))
        (print count)))))         ; 2
```

### Pitfall 3: Complex Lambda Bodies

A lambda whose body uses `match` (or another form outside the list in §8.4) compiles to a null function. Keep lambda bodies small and move the real logic into a `defn`:

```lisp
(defn apply1 (f x) (f x))

(defn or-zero (o)
  (match o
    (Some v v)
    (None 0)))

(defn main ()
  (print (apply1 (fn (o) (or-zero o)) (Some 7))))   ; 7
```

## 8.11 Performance Notes

| Aspect | Cost |
|--------|------|
| Let-bound lambda called directly | Inlined by `closure_inline` (no call, no allocation) |
| Non-capturing lambda | Lifted to an ordinary top-level function; direct call |
| Capturing closure | One heap allocation for the closure and one for its environment at creation; indirect call |
| Capture | Copied by value into the environment |

**Tip**: prefer non-capturing lambdas passed as arguments, and named `defn` helpers for anything larger than a line.

---

## For Experts: Under the Hood

### Closure Representation

Lowering (`ic-lambda` in `stdlib/compiler/icnf.zyl`) first checks the lambda body against the safe-form list in §8.4 (`ic-safe-expr`). A body that fails the check is lowered to the constant 0, which is why calling such a closure crashes. For a body that passes, the compiler collects its free variables (`ic-free-vars`):

- **No free variables**: the lambda is hoisted to a plain top-level function, and the closure value is that function's address.
- **Free variables**: the compiler builds a heap `[tag, code, env]` triple (the same layout as an ADT variant). `code` is the hoisted function; `env` is a second heap block holding one field per captured name, evaluated in the enclosing scope, which makes captures by value. The hoisted function gets one extra trailing parameter, `_clos_env`, and its body starts with a `let` per captured name that reads the field back out.

Because the environment takes one argument register, a capturing lambda may declare at most 5 parameters.

### Capture Analysis (Specification)

The specification's region-inference phase (Phase 4) assigns captures as follows:

1. **Free-variable analysis**: for each `fn`, find the variables it uses but does not bind.
2. **Mutability analysis**: for each free variable, check whether it is `set!`.
3. **Escape analysis**: does the closure outlive the scope that defines it?
4. **Assign capability and region**:
   - read-only, non-escaping: `TCap`, Stack
   - read-only, escaping: `TCap`, Heap
   - mutated: `TMut`, Heap
   - crossing an actor boundary: must be Send-capable

### Call Sites

A call through a value the compiler knows is a closure (for example, a `let` bound to the result of a function that returns one) is lowered to `ICallClosure`, which loads the code pointer from the triple and passes the environment as the extra argument. A call through a plain parameter is lowered as an indirect call to a bare function pointer. That mismatch is the reason a capturing closure passed as an argument crashes today: the callee has no way to know it received a triple rather than a code address.

---

**Next:** [Chapter 9: Concurrency with Actors](ch09-actors.md) covers spawn, send, and actor lifecycles.
