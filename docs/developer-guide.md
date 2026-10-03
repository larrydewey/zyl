# Zyl Developer Guide

A practical, example-driven introduction to Zyl — a deterministic Lisp
systems language that compiles to native x86_64. This is not the full
language reference (see [`book/`](../book/src/SUMMARY.md) for that);
it's a fast on-ramp with real, working examples for the parts of the
language you'll reach for most often.

Every example below is written in the same style as the project's own
test suite (`tests/regression/*.zyl`), and every complete program in it
compiles and prints what its comments say (checked 2026-10-02).

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
  (print "Hello, World!")
  0)
```

Compile and run it:

```sh
./build/boot/zyl-self hello.zyl -o hello
./hello
```

`main` takes no arguments and returns an Int, the exit status, so it
ends with `0`. A `defn` body may hold several forms; they run in order
and the last one is the result.

`print` works on ints, floats, strings and bools (a Bool prints as `1`
or `0`, a Float with six decimals), and on any value whose type has a
`Show` impl (section 11).

Types are inferred and checked (Hindley–Milner, spec §4.8): nothing
needs an annotation, but a program that does not type-check does not
compile. Conditions must be Bool, arithmetic does not mix Int and Float,
and every type error in the program is reported before the compile
fails.

## 2. Variables

`let` binds an immutable name; `let-mut` binds a mutable one that
`set!` can update. Both take a body expression (or several — see the
note below) whose value the whole `let` evaluates to:

```zyl
(defn main ()
  (let x 10
    (let y (+ x 5)
      (print y)))              ; => 15
  0)
```

```zyl
(defn main ()
  (let-mut total 0
    (begin
      (set! total (+ total 5))
      (set! total (+ total 10))
      (print total)))          ; => 15
  0)
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
      (print acc)))            ; acc is still in scope here => 10
  0)
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
  (print (factorial 5))      ; => 120
  0)
```

Arithmetic: `+ - * / %`, on two Ints or two Floats (never one of each).
Comparisons: `< > <= >= == !=` (`=` also works as `==`). `==` and `!=`
also compare structs and ADTs, by content rather than by address; the
orderings `<`, `>`, `<=`, `>=` take Int, Float and String only (order an
ADT with `Ord.compare`, see [Traits and derive](#11-traits-and-derive)).
Integers also have `bit-and`, `bit-or`, `bit-xor`, `bit-not`, `shl`,
`shr` and `ashr`. The intrinsics `bit-popcount`, `bit-clz`, `bit-ctz`,
`bit-bswap`, `bit-rotl`, `bit-rotr` (and `32` forms), `mul-hi`, `mul-hi-u`,
`crc32c` and `crc32c-u8` are spec §21.13; `simd/simd` has lane vectors.

## 4. Control flow

```zyl
(defn sign (n)
  (if (< n 0)
    -1
    (if (== n 0)
      0
      1)))
```

`cond` for multi-way branches: each clause is a `(test value)` pair,
with `else` as the fallback:

```zyl
(defn sign2 (n)
  (cond
    ((< n 0) -1)
    ((== n 0) 0)
    (else 1)))
```

`while` and `for` loops. `for` takes a binding section, a condition
and a body, and you update the loop variables yourself with `set!`.
The binding section is either one binding, `(i 0)`, or a list of them,
`((i 0) (j 10))`:

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
    (begin
      (print (struct-get p "x"))     ; => 3
      (print p.y)))                  ; => 4
  0)
```

`defstruct` generates a constructor (`make-<Name>`); a field is read
back with `(struct-get value "field-name")` or the dot syntax `p.y`,
rather than a per-field accessor function. A field may carry a type,
`(x Int)`; an untyped field is a type parameter of the struct.

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
    (Circle r (* 3 (* r r)))       ; a rough area: 3r²
    (Rect w h (* w h))
    (Triangle b h _ (/ (* b h) 2))))
```

`match` dispatches on which variant a value was constructed with,
binding each variant's fields by position (`_` discards one). It also
works on the built-in list type, whose constructors are `Cons` and
`Nil`; `[1 2 3]` and `(list 1 2 3)` build the same list:

```zyl
(defn sum (xs)
  (match xs
    (Cons h t (+ h (sum t)))
    (Nil 0)))

(defn main ()
  (print (sum (Cons 1 (Cons 2 (Cons 3 Nil)))))   ; => 6
  (print (sum [1 2 3]))                          ; => 6
  0)
```

`Cons`, `Nil`, `Some`, `None`, `Ok` and `Err` belong to the standard
library's prelude; a program's own `deftype` may not reuse those
constructor names (`E_DUPLICATE_VARIANT`).

A match must be exhaustive: every variant needs an arm, or the match
needs a `_` catch-all. A missing variant is the compile-time error
`E_NON_EXHAUSTIVE_MATCH`. A catch-all is lowercase: an arm head spelled
like a constructor that no type declares is `E_UNKNOWN_CONSTRUCTOR`, with
the nearest constructor suggested, so `(Nnoe 0)` cannot stand in for
`(None 0)`. Patterns do not nest: a constructor's fields
are bound to names (`E_NESTED_PATTERN` otherwise).

`match` also takes literal patterns. A literal match must end with a
`_` arm; an arm can list several literals, and `(range lo hi)` matches
an inclusive range:

```zyl
(defn classify (n)
  (match n
    (1 2 "low")
    ((range 3 9) "mid")
    (_ "other")))
```

## 7. Generic ADTs

Type parameters on a `deftype` let one declaration work over any
concrete type:

```zyl
(deftype Maybe (Just T) (Nothing))

(defn unwrap-or (m default)
  (match m
    (Just v v)
    (Nothing default)))

(defn main ()
  (print (unwrap-or (Just 42) 0))        ; => 42
  (print (unwrap-or Nothing 0))          ; => 0
  (print (unwrap-or (Just "yes") "no"))  ; => yes
  0)
```

The same `Maybe` type works whether `T` ends up being an `Int`, a
`String`, or another struct. Generic functions are generalized by
Hindley–Milner inference; one that prints, compares or calls a trait
method at a type parameter is specialized per concrete argument type at
compile time.

## 8. Option and Result

The standard library ships `Option` and `Result` so you don't have to
declare your own for the common case:

```zyl
(use core/option)
(use core/result)

(defn safe-div (a b)
  (if (== b 0)
    (result-err "divide by zero")
    (result-ok (div! a b))))

(defn main ()
  (print (result-unwrap (safe-div 10 2) 0))     ; => 5
  (print (result-unwrap (safe-div 10 0) -1))    ; => -1 (the fallback: it is an Err)
  (print (option-unwrap-or (Some 3) 0))         ; => 3
  0)
```

Note `div!`, not `/`. Division is only total when the divisor is a
nonzero literal, so `/` with a variable divisor is `E_PARTIAL_OPERATION`
— the `!` is the spelling that says *you* have already checked.
(`div? a b` gives `(Option Int)` instead, and `rem!`/`rem?` are the
modulo pair.)

Useful combinators: `option-map`, `option-unwrap-or`, `option-and`,
`option-or`, `result-map`, `result-and-then`, `result-unwrap-or`, and,
from `core/core`, `result-to-option` and `option-to-result`. `assert-true`/`assert-equal`
pair naturally with `result-is-ok`/`result-is-err` in tests.

## 9. Closures and higher-order functions

`fn` creates an anonymous function value. Closures can be passed
around, returned, and nested, and a closure can capture variables from
the scope it was created in:

```zyl
(defn main ()
  (let add-one (fn (x) (+ x 1))
    (print (add-one 10)))                ; => 11

  (let apply (fn (f x) (f x))
    (print (apply (fn (y) (* y 2)) 5)))  ; => 10

  (let outer (fn (x)
    (let inner (fn (y) (+ x y))
      (inner 10)))
    (print (outer 5)))                   ; => 15
  0)
```

A closure that captures a variable can also outlive the function that
made it:

```zyl
(defn make-adder (x)
  (fn (y) (+ x y)))

(defn main ()
  (let add5 (make-adder 5)
    (print (add5 10)))                   ; => 15
  0)
```

## 10. Collections

```zyl
(use collections/vec)
(use collections/intmap)
(use collections/set)

(defn main ()
  (let v (vec-push (vec-push (vec-new-cap 10) 1) 2)
    (begin
      (print (vec-len v))                ; => 2
      (print (vec-get! v 0))))            ; => 1
  (let m (intmap-put (intmap-new 10) 1 42)
    (begin
      (print (intmap-get m 1 0))            ; => 42
      (print (intmap-has m 1))))            ; => 1 (bools print as 1/0)
  (let s (set-add (set-create 10) 42)
    (print (set-contains s 42)))         ; => 1
  0)
```

`vec-new` makes an empty `Vec` — its storage appears on the first
push — and `vec-new-cap`, `intmap-new` and `set-create` take an initial
capacity as a hint, doubling when they fill up. No collection takes an
`Arena`: a program allocates through the region system (below) and there
is no other handle on it. `Vec` is generic over its element type, `Set`
holds Int keys, and `IntMap` holds Int keys and Int values; the generic
`Map<K, V>` in `core/map` is a different structure with its own
`map-get`/`map-insert`. Updating one returns a new collection rather than
changing one in place. For simple linked lists, the built-in
`Cons`/`Nil` list (section 6) plus `core/list`'s helpers
(`list-length`, `list-append`, `list-reverse`, ...) are usually simpler
than reaching for `Vec`.

Memory is managed by regions, not a garbage collector. The compiler
works out where each value can go: a value that does not outlive its
call lives in that call's own region and is released when the call
returns; a value that becomes part of a result is built in the region
the caller chose for it; only a value that escapes further (into a
global, an actor message, foreign code) goes to the process heap, where
it lives until exit. You do not annotate anything for this. When you
want an explicit, bounded arena, use `with-region`:

```zyl
(deftype WList (WCons Int WList) (WNil))

(defn build (n acc)
  (if (== n 0) acc (build (- n 1) (WCons n acc))))

(defn wsum (xs)
  (match xs
    (WCons h t (+ h (wsum t)))
    (WNil 0)))

(defn arena-sum (n)
  (with-region (arena :block 65536 :align 16 :limit 1048576)
    (wsum (build n WNil))))

(defn main ()
  (print (arena-sum 100))                ; => 5050
  0)
```

Everything the body allocates is released when it ends. The body's
result must not point into the region (`E_REGION_ESCAPE`); a region
that runs out raises `E_REGION_EXHAUSTED`, which `try` can catch. The
details are in `docs/regions-design.md`.

## 11. Traits and derive

```zyl
(defstruct Box (w Int) (h Int))
(derive Box Eq Show)

(deftype Size (Small) (Large))
(derive Size Eq Ord Show)

(defn main ()
  (let a (make-Box 2 3)
    (let b (make-Box 2 3)
      (begin
        (print (== a b))                 ; => 1 (by content, not by address)
        (print a))))                     ; => Box { w: 2, h: 3 }
  (print (Ord.compare Small Large))      ; => -1
  (print Large)                          ; => Large
  0)
```

`derive` generates impls of `Show`, `Debug`, `Eq`, `Ord`, `Hash` and
`Clone` for a struct or ADT; any other trait, or a field whose type
lacks the trait, is `E_TRAIT_NOT_DERIVABLE`. `print` of a value whose
type has a `Show` impl prints its `Show.show` text; without one, a
struct or ADT prints as an address. `==` compares structs and ADTs by
content with or without a derive; the orderings `<` and `>` do not take
them, so an ADT is ordered with `Ord.compare`.

`trait`/`impl` declare and implement a shared interface. A method is
declared with its parameter list and its result type, and a call
written `(Trait.method receiver args...)`, or `(receiver.method args...)`
with the dot syntax, goes to the impl for the receiver's type:

```zyl
(trait Describe
  (describe (self) Int))

(impl Describe Int
  (defn describe (self) (* self 10)))

(impl Describe String
  (defn describe (self) (str-length self)))

(defn main ()
  (print (Describe.describe 4))          ; => 40
  (print (Describe.describe "four"))     ; => 4
  (let n 5
    (print (n.describe)))                ; => 50
  0)
```

The impl is chosen at compile time from the receiver's inferred type;
there is no run-time dispatch. A receiver whose type the program does
not determine is `E_CANNOT_INFER`, and one with no impl is
`E_TRAIT_NOT_FOUND`.

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

A directory with a `zyl.pkg` manifest is a package. `zyl new <name>`
creates one, `zyl add` adds a dependency, and `zyl build` and
`zyl test` compile it; see `docs/package-management-design.md` and
spec §31.

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
a failing assertion reports the test as `FAIL` without stopping the
rest of the suite, and `run-tests` prints a pass/fail summary.

## 14. Actors

`spawn` starts an actor running a closure, and actors talk over typed
channels. `(chan n)` makes a channel with room for `n` values;
`chan-tx` and `chan-rx` are its two ends, each owned by one actor at a
time. A closure that captures an end takes it along to the new actor.
`chan-send` blocks while the channel is full and `chan-recv` while it is
empty, and there is no way to ask which channel is ready, so the output
is the same under every schedule. `actor-wait` joins an actor and
re-raises its panic.

Spawning needs the capability, which a lone file declares at the top:

```zyl
(capabilities actor)

(use actor/actor)

(defn main ()
  (let c (chan 2)
    (let tx (chan-tx c)
      (let rx (chan-rx c)
        (let a (spawn (fn () (begin (chan-send tx 20) (chan-send tx 22))))
          (let x (chan-recv rx)
            (let y (chan-recv rx)
              (begin
                (actor-wait a)
                (print (+ x y))
                0))))))))
```

This prints `42`. Using an end the actor does not own is
`E_CHANNEL_NOT_OWNER`, receiving from a closed and drained channel is
`E_CHANNEL_CLOSED`, and when every live actor is blocked the program
stops with `E_DEADLOCK`. A `spawn` body may capture immutable values;
capturing a `let-mut` variable is `E_CAPABILITY_LEAK`. Actors also run
in the REPL and under `zyl eval`.

## 15. FFI

`ffi-call` calls a C function, passing arguments and a timeout. A
foreign symbol needs an `extern` declaration giving its parameter and
result types, which must be concrete and fit a machine word (no Float):

```zyl
(capabilities ffi)

(extern "strlen" (String) Int)

(defn main ()
  (print (ffi-call "strlen" "hello" 1000))     ; => 5
  0)
```

Without the `extern`, the call is `E_CANNOT_INFER`. The runtime's own
`zyl_*` entries are typed by the compiler (`compiler/ffi_sigs.zyl`) and
need no `extern`; the raw ones among them may only be called by the
standard library (`E_FFI_RESTRICTED`).

The last argument is the timeout, in milliseconds. It must be a
positive integer literal, or the compiler rejects the call with
`E_FFI_TIMEOUT_REQUIRED`; the symbol must be a string literal
(`E_FFI_SYMBOL_REQUIRED`). A call to a C function outside the Zyl
runtime runs on a worker thread, and if it has not returned when the
timeout expires, the caller raises `E_FFI_TIMEOUT`, which `try` can
catch. The C function is abandoned rather than killed. `ffi-pin` is
required only for `Secret` values.

This is the same mechanism the standard library itself is built on —
`str-length`, `str-concat`, arena allocation, and file I/O are all thin
Zyl wrappers over `ffi-call`s into the runtime (`runtime/rt/`).

## 16. Where to go next

This guide covers the everyday 80%. For the rest:

- **[`book/src/SUMMARY.md`](../book/src/SUMMARY.md)** — the full
  language book: memory regions and capability types, the macro
  system, contracts, exhaustiveness checking, the compiler's own
  internals, and self-hosting.
- **`tests/regression/*.zyl`** — real, compiling examples of nearly
  every language feature, including the ones this guide only touched
  on (`with-resource`, `contracts`/`requires`/`ensures`, aliasing,
  regions, macros, quasiquote, views).
- **`PROGRESS.md`** — what works today and the known gaps.
- **`docs/repl.md`** — `zyl repl` and `zyl eval`.
- **`docs/self-hosting.md`** — the bootstrap seeds and the fixed-point
  invariant.
