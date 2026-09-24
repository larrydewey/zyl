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

The compiler reads `((x) (* x x))` as a call whose head `(x)` is itself a call to `x`, so unless `x` is a function in scope it reports a located error:

```
PANIC: error[E_UNBOUND_VARIABLE]: call to undefined function `x`
  --> sq.zyl:1:24
   = help: define it, or bind it with `let`; an anonymous function is written (fn (params) body) -- ((params) body) is not lambda syntax (spec 7.1)
```

A head that is an expression computing a function is ordinary application, not shorthand: `((make-adder 10) 5)` calls the closure `make-adder` returns.

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

**A closure cannot `set!` a captured variable.** Because the closure holds a copy, a `set!` inside it could only change the copy, never the binding the program named. The compiler rejects it:

```lisp
(defn main ()
  (let-mut count 0
    (let bump (fn () (set! count (+ count 1)))
      (begin
        (bump)
        (print count)))))
```

```
PANIC: error[E_MUT_CONFLICT]: set! target `count` is a let-mut of an enclosing scope, captured by value by this closure
  --> bump.zyl:3:22
   = help: closures capture by value (spec 7); return the new value from the closure and set! it at the binding's own scope
```

A closure may `set!` its own `let-mut` locals freely. Pitfall 2 in §8.10 shows the rewrite.

Across an actor boundary, the check does exist: a spawned closure that captures a `let-mut` variable is rejected at compile time with `E_CAPABILITY_LEAK` (see §8.6).

## 8.4 What Works Today

A closure is a first-class value. Any lambda body the compiler accepts elsewhere is accepted in a lambda, including `match`, `try`, nested lambdas and calls to captured function values, and a lambda may take any number of parameters.

| Shape | Status |
|-------|--------|
| Non-capturing lambda: bind, call, pass as argument, store in a data structure | Works |
| Capturing lambda: call where bound, pass as an argument, store, return, capture in another lambda | Works |
| Lambda that calls a captured function value (`compose`, `partial`) | Works |
| Lambda whose body contains `match` | Works |
| Call through a computed function value, `((make-adder 10) 5)` | Works |
| Lambda that `set!`s a captured variable | Compile error, `E_MUT_CONFLICT` (§8.3) |
| Recursive lambda | Not supported; use `defn` |
| Capturing lambda handed to `spawn` | Works for immutable captures; a `let-mut` capture is `E_CAPABILITY_LEAK` (§8.6) |

One code-generation gap remains, and it is not specific to closures: the code generator picks string or float handling for `print`, `=` and arithmetic from annotations and literals only. An unannotated parameter, a captured variable and the result of a call through a function value are all treated as integers there, so `(let s "hi" (let g (fn () (print s)) (g)))` prints the string's address, and a captured `Float` in arithmetic is added as an integer. Passing such values to functions (`str-concat`, a `defn` with a `String` parameter) works; print or compare them where their kind is known.

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

`core/core` ships exactly this `compose`, and a user program can define `partial` the same way:

```lisp
(defn partial2 (f x)
  (fn (y) (f x y)))

(defn main ()
  (let add1 (fn (x) (+ x 1))
  (let mul2 (fn (x) (* x 2))
  (let sub (fn (a b) (- a b))
    (begin
      (print ((compose mul2 add1) 5))       ; 12 = (5+1)*2
      (print ((partial2 sub 10) 3))         ; 7  = 10 - 3
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
PANIC: error[E_CAPABILITY_LEAK]: spawned closure captures let-mut (TMut) variable `count` from the enclosing scope
```

The error is located at the `spawn`, with a second label at the `let-mut` (Appendix A, §A.1). Immutable captures are fine: the actor gets its own copies, as any closure does. Chapter 9 covers actors in detail.

## 8.7 Closure Types

The type checker gives every closure a function type (internally `TFun`, built from the parameter and result types) and infers it from use; closure types never need to be written. There is no surface syntax for function types in parameter annotations: leave closure parameters such as `f` unannotated, as every example in this chapter does.

## 8.8 Recursive Closures

A lambda cannot refer to itself, and there is no `TBox` or named-`let` form for building one. Write recursive helpers as top-level `defn` functions:

```lisp
(defn fact (n)
  (if (<= n 1) 1 (* n (fact (- n 1)))))
```

## 8.9 Closure Inlining

Earlier compilers beta-reduced a let-bound capturing lambda into its call sites (`stdlib/compiler/closure_inline.zyl`), a stopgap from before closures were values. The pass is now an identity step: splicing a lambda body into its callers is not hygienic in general, and every lambda is compiled as described in §8.4.

## 8.10 Common Pitfalls

### Pitfall 1: Expecting a Capture to Track Later Changes

Captures are copied when the closure is created. A closure built inside a loop sees the value the variable had at that moment, not a shared, changing variable. If you need shared, changing state between closures, keep it in a data structure you pass explicitly (or, across actors, an atomic location from `atomic/atomic`) rather than in a captured `let-mut`.

### Pitfall 2: Mutating a Captured Variable

Spec §10 allows exactly one `TMut` reference, and a closure's capture is a copy, so a closure that `set!`s a captured variable is rejected with `E_MUT_CONFLICT` (§8.3). Restructure the code so the closure returns a new value and the caller rebinds it:

```lisp
(defn main ()
  (let-mut count 0
    (let inc (fn (c) (+ c 1))
      (begin
        (set! count (inc count))
        (set! count (inc count))
        (print count)))))         ; 2
```

## 8.11 Performance Notes

| Aspect | Cost |
|--------|------|
| Non-capturing lambda | Lifted to an ordinary top-level function; its value is the function's address |
| Capturing closure | One allocation for the closure and one for its environment at creation |
| Call through a function value | Indirect call plus a tag test that tells a closure from a plain address |
| Capture | Copied by value into the environment |

**Tip**: prefer non-capturing lambdas passed as arguments, and named `defn` helpers for anything larger than a line.

---

## For Experts: Under the Hood

### Closure Representation

Lowering (`ic-lambda` in `stdlib/compiler/icnf.zyl`) lowers the lambda body first, then reads its free variables off the lowered ICNF tree (`ic-lambda-free`): every name it loads or calls that is not a parameter, not bound inside the body, and not a top-level function.

- **No free variables**: the lambda is hoisted to a plain top-level function, and the closure value is that function's address.
- **Free variables**: the compiler builds a `[tag, code, env]` triple (the same layout as an ADT variant) whose tag is a fixed marker (`ic-closure-magic`). `code` is the hoisted function; `env` is a second block holding one field per captured name, evaluated in the enclosing scope, which makes captures by value. The hoisted function gets one extra trailing parameter, `_clos_env`, and its body starts with a `let` per captured name that reads the field back out.

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

A call to a top-level function is a direct call. A call through a local holding a function value (a parameter, a `let`, a captured name, or the temporary holding a computed callee) goes through `cg-call-indirect` in `stdlib/compiler/codegen.zyl`, which reads the value's first word: the closure tag means "load the code and the environment from the triple", anything else is a plain code address. The call always passes one argument more than the source wrote, the environment or 0; a plain function ignores it, because in the SysV convention the caller owns every argument slot. So the callee never needs to know which kind of function value it was handed.

---

**Next:** [Chapter 9: Concurrency with Actors](ch09-actors.md) covers spawn, send, and actor lifecycles.
