# Zyl Developer Guide

A practical, example-driven introduction to Zyl — a deterministic Lisp
systems language that compiles to native x86_64. This is not the full
language reference (see [`book/`](../book/src/SUMMARY.md) for that);
it's a fast on-ramp with real, working examples for the parts of the
language you'll reach for most often.

Every example below is written in the same style as the project's own
test suite (`tests/regression/*.zyl`) and uses real, verified syntax.

## Table of contents

1. [Hello, World](#1-hello-world)
2. [Variables](#2-variables)
3. [Functions](#3-functions)
4. [Control flow](#4-control-flow)
5. [Structs](#5-structs)
6. [Algebraic data types and pattern matching](#6-algebraic-data-types-and-pattern-matching)
7. [Generic ADTs](#7-generic-adts)
8. [Option and Result](#8-option-and-result)
9. [Closures and higher-order functions](#9-closures-and-higher-order-functions)
10. [Collections](#10-collections)
11. [Traits and derive](#11-traits-and-derive)
12. [Modules](#12-modules)
13. [Testing](#13-testing)
14. [Actors](#14-actors)
15. [FFI](#15-ffi)
16. [Where to go next](#16-where-to-go-next)

---

## 1. Hello, World

```zyl
(defn main ()
  (print "Hello, World!"))
```

Compile and run it:

```sh
./build/boot/zyl-self hello.zyl -o hello
./hello
```

`print` is polymorphic — it works on ints, floats, strings, and bools.

## 2. Variables

`let` binds an immutable name; `let-mut` binds a mutable one that
`set!` can update. Both take a body expression (or several — see the
note below) whose value the whole `let` evaluates to:

```zyl
(defn main ()
  (let x 10
    (let y (+ x 5)
      (print y))))              ; => 15
```

```zyl
(defn main ()
  (let-mut total 0
    (begin
      (set! total (+ total 5))
      (set! total (+ total 10))
      (print total))))          ; => 15
```

**Multiple body statements.** `(let name val stmt1 stmt2 ...)` runs
every trailing statement in sequence, returning the last one's value.
A `let`/`let-mut` used as one of those statements (not the final one)
stays in scope for the rest of the sequence — you don't need to nest
manually:

```zyl
(defn main ()
  (let-mut i 0
    (let-mut acc 0
      (begin
        (while (< i 5)
          (begin
            (set! acc (+ acc i))
            (set! i (+ i 1))))
        acc)
      (print acc))))            ; acc is still in scope here => 10
```

There's also a binding-pair form, useful when generated or when it
reads better with the name and value grouped: `(let (name value) body)`.

## 3. Functions

```zyl
(defn add (a b)
  (+ a b))

(defn factorial (n)
  (if (<= n 1)
    1
    (* n (factorial (- n 1)))))

(defn main ()
  (print (add 2 3))          ; => 5
  (print (factorial 5)))     ; => 120
```

Arithmetic: `+ - * / %`. Comparisons: `< > <= >= == !=` (`=` also works
as `==`). All of these work on structs and ADTs too, comparing by
structural equality/ordering rather than pointer identity — see
[Traits and derive](#11-traits-and-derive).

## 4. Control flow

```zyl
(defn sign (n)
  (if (< n 0)
    -1
    (if (== n 0)
      0
      1)))
```

`cond` for multi-way branches, with `else` as the fallback:

```zyl
(defn sign2 (n)
  (cond
    (< n 0) -1
    (== n 0) 0
    (else 1)))
```

> **Note:** prefer returning ints/bools (as above) over strings from a
> function whose result you're about to `print` directly — the current
> self-hosted compiler can't always see a function call's return kind
> at the print call site, and a string coming back from an `if`/`cond`
> branch through a plain function call can print as a raw number
> instead of its text. Printing a string *literal*, or one already
> bound to a variable in the same scope, works fine; it's specifically
> "print the string a function just handed back" that's affected. If
> you hit this, compare with `assert-equal`/`assert-true` in a
> [`test`](#13-testing) instead of `print`ing the result — those don't
> go through the same path.

`while` and `for` loops. `for` supports single or multi-variable
bindings:

```zyl
(defn sum-to (n)
  (let-mut acc 0
    (let-mut i 0
      (begin
        (while (< i n)
          (begin
            (set! acc (+ acc i))
            (set! i (+ i 1))))
        acc))))

(defn sum-pairs ()
  (let-mut acc 0
    (begin
      (for ((i 0) (j 10)) (< i 3)
        (begin
          (set! acc (+ acc i j))
          (set! i (+ i 1))
          (set! j (+ j 1))))
      acc)))                  ; => (0+10) + (1+11) + (2+12) = 36
```

## 5. Structs

```zyl
(defstruct Point (x) (y))

(defn main ()
  (let p (make-Point 3 4)
    (print (struct-get p "x"))     ; => 3
    (print (struct-get p "y"))))   ; => 4
```

`defstruct` generates a constructor (`make-<Name>`); fields are read
back with `(struct-get value "field-name")` rather than a per-field
accessor function.

## 6. Algebraic data types and pattern matching

`deftype` declares a sum type (an ADT): a name followed by one or more
variants, each with its own fields.

```zyl
(deftype Shape
  (Circle Int)
  (Rect Int Int)
  (Triangle Int Int Int))

(defn area (s)
  (match s
    (Circle r (* r r))
    (Rect w h (* w h))
    (Triangle a b c 0)))       ; placeholder — not a real formula
```

`match` dispatches on which variant a value was constructed with,
binding each variant's fields by position. It also works on lists,
recursively:

```zyl
(deftype IntList
  (Cons Int IntList)
  (Nil))

(defn sum (xs)
  (match xs
    (Cons h t (+ h (sum t)))
    (Nil 0)))

(defn main ()
  (print (sum (Cons 1 (Cons 2 (Cons 3 Nil))))))   ; => 6
```

A match must be exhaustive — every variant needs an arm.

## 7. Generic ADTs

Type parameters on a `deftype` let one declaration work over any
concrete type:

```zyl
(deftype Opt (Some T) (None))

(defn unwrap-or (o default)
  (match o
    (Some v v)
    (None default)))

(defn main ()
  (print (unwrap-or (Some 42) 0))        ; => 42
  (print (unwrap-or (None) 0)))          ; => 0
```

The same `Opt` type works whether `T` ends up being an `Int`, a
`String`, or another struct — each concrete instantiation is
monomorphized at compile time.

## 8. Option and Result

The standard library ships `Option` and `Result` so you don't have to
declare your own for the common case:

```zyl
(use core/option)
(use core/result)

(defn safe-div (a b)
  (if (== b 0)
    (result-err "divide by zero")
    (result-ok (/ a b))))

(defn main ()
  (let r (safe-div 10 2)
    (print (result-unwrap r 0)))         ; => 5
  (let r2 (safe-div 10 0)
    (print (result-unwrap r2 -1))))      ; => -1 (fallback, since r2 is Err)
```

Useful combinators: `option-map`, `option-unwrap-or`, `option-and`,
`option-or`, `result-map`, `result-and-then`, `result-unwrap-or`,
`result-to-option`, `option-to-result`. `assert-true`/`assert-equal`
pair naturally with `result-is-ok`/`result-is-err` in tests.

## 9. Closures and higher-order functions

`fn` creates an anonymous function value. Closures can be passed
around, returned, and nested:

```zyl
(defn main ()
  (let add-one (fn (x) (+ x 1))
    (print (add-one 10)))                ; => 11

  (let apply (fn (f x) (f x))
    (print (apply (fn (y) (* y 2)) 5)))  ; => 10

  (let outer (fn (x)
    (let inner (fn (y) (+ x y))
      (inner 10)))
    (print (outer 5))))                  ; => 15
```

## 10. Collections

```zyl
(use collections/collections)
(use collections/vec)

(defn main ()
  (let v (vec-push (vec-push (vec-create 0 10) 1) 2)
    (print (vec-len v))                  ; => 2
    (print (vec-get v 0)))               ; => 1

  (let m (map-put (map-create 0 10) 1 42)
    (print (map-get m 1 0))              ; => 42
    (print (map-has m 1)))               ; => 1 (bools print as 1/0)

  (let s (set-add (set-create 0 10) 42)
    (print (set-contains s 42))))        ; => 1
```

`Vec`/`Map`/`Set` are created with an initial length and capacity
(`vec-create 0 10` = length 0, capacity 10) and grow as needed. For
simple linked lists, the built-in `Cons`/`Nil` ADT (section 6) plus
`core/list`'s helpers (`list-length`, `list-append`, `list-map`, ...)
are usually simpler than reaching for `Vec`.

## 11. Traits and derive

```zyl
(defstruct Box (w) (h))
(derive Box Eq Ord)

(defn main ()
  (let a (make-Box 2 3)
    (let b (make-Box 2 3)
      (print (== a b))                   ; => 1 (structural, not pointer, equality)
      (print (< a b)))))                 ; => 0
```

`derive` on a struct or ADT gives you `==`/`!=` (`Eq`) and ordering
comparisons (`Ord`) without writing them by hand. `derive ... Debug`
is also accepted, but printing a derived-Debug value directly is
affected by the same print-dispatch limitation noted in
[Control flow](#4-control-flow) — safest for now to compare its fields
individually via `struct-get` if you need to check its contents.

`trait`/`impl` declare and implement a shared interface:

```zyl
(trait Printable
  (describe self))

(impl Printable Int
  (defn describe (self) (print self)))
```

At the time of writing, trait *dispatch* (actually calling `describe`
through the trait rather than a concrete type's function directly) is
still a work in progress in the self-hosted compiler — declaring and
implementing traits works, but see `tests/regression/traits.zyl`'s own
header comment for the current state before relying on dynamic
dispatch in real code.

## 12. Modules

`(use module/name)` imports a stdlib module, resolved relative to
`stdlib/`:

```zyl
(use core/core)
(use core/list)
(use core/option)
(use core/result)
(use collections/vec)
(use actor/actor)
```

Within a single file, everything after the imports is just ordinary
top-level code — `use` only controls what names are in scope.

## 13. Testing

Zyl has a built-in test framework: `test` declares a named test case,
and `run-tests` executes everything registered so far.

```zyl
(use core/core)

(test "add-works"
  (assert-equal (+ 2 3) 5))

(test "option-round-trips"
  (assert-true (option-is-some (Some 1))))

(run-tests)
```

`assert-equal`, `assert-true`, and `assert-false` are the workhorses;
a failing assertion reports the test as failed without stopping the
rest of the suite.

## 14. Actors

Lightweight, isolated concurrency: `spawn` starts an actor running a
closure, `send` delivers a message to its mailbox, and `actor-wait`
blocks until it finishes.

```zyl
(use actor/actor)

(defn main ()
  (let a (spawn (fn () (+ 1 2 3)))
    (send a 42)
    (actor-wait a)))
```

Actors don't share mutable state with each other or the spawning code
— everything they touch is either captured by value or communicated
through messages.

## 15. FFI

`ffi-call` invokes a C runtime function directly, passing arguments and
a timeout:

```zyl
(defn main ()
  (print (ffi-call "strlen" "hello" 1000)))     ; => 5
```

This is the same mechanism the standard library itself is built on —
`str-length`, `str-concat`, arena allocation, and file I/O are all thin
Zyl wrappers over `ffi-call`s into `runtime/actor_runtime.c`.

## 16. Where to go next

This guide covers the everyday 80%. For the rest:

- **[`book/src/SUMMARY.md`](../book/src/SUMMARY.md)** — the full
  language book: memory regions and capability types, the macro
  system, contracts, exhaustiveness checking, the compiler's own
  internals, and self-hosting.
- **`tests/regression/*.zyl`** — real, compiling examples of nearly
  every language feature, including the ones this guide only touched
  on (`with-resource`, `contracts`/`requires`/`ensures`, aliasing,
  region annotations).
- **`docs/rust-eviction-plan.md`** — current state of the self-hosted
  compiler, including any features with known gaps at the time you're
  reading this.
