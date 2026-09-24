# Chapter 6: Pattern Matching and Error Handling

Pattern matching is Zyl's primary control flow for structured data.
Combined with ADTs and the `Result`/`Option` types, it replaces null
checks and most `if` chains. This chapter covers `match` in depth, then
the two ways a Zyl program deals with failure: `Result` values, and
`error` with `try`.

## 6.1 The `match` Expression

```lisp
(match scrutinee
  (Variant1 binders... body1)
  (Variant2 binders... body2)
  ...)
```

- **Scrutinee**: the value being matched, evaluated once
- **Arms**: tried in source order; the first one that matches runs
- **Binders**: one name (or `_`) per field of the variant
- **Bodies**: expressions; the value of the chosen body is the value of
  the `match`
- **Exhaustiveness**: mandatory — a missing variant is a compile-time
  error (§6.3)

### Basic Example

```lisp
(defn describe (opt)
  (match opt
    (Some x (* x 10))
    (None 0)))

(defn main ()
  (begin
    (print (describe (Some 4)))   ; 40
    (print (describe None))       ; 0
    0))
```

`Option`, `Result` and `List` come from the core library, which every
program gets without a `use` (Chapter 4, §4.4). Don't redeclare them.

An arm can also be written with its pattern in its own parentheses:
`((Some x) (* x 10))` means the same as `(Some x (* x 10))`.

### Match as an Expression

`match` produces a value, so it can go anywhere an expression can:

```lisp
(defn label ((s String)) (print-string (str-concat "result: " s)))

(defn main ()
  (let r (Err "disk full")
    (begin
      (label (match r
               (Ok _ "fine")
               (Err msg msg)))                 ; result: disk full
      (let n (match (Some 4) (Some x (* x 10)) (None 0))
        (print (+ n 2)))                       ; 42
      0)))
```

Every arm should produce the same type. The type checker infers the
types but does not currently reject arms that disagree, so this is on
you.

## 6.2 Patterns in Detail

### Constructor Patterns

An arm names a variant and then gives one binder per field:

| Arm | Matches | Binds |
|-----|---------|-------|
| `(Some x body)` | `Some` | `x` to the field |
| `(None body)` | `None` | nothing |
| `(Ok v body)` / `(Err e body)` | `Ok` / `Err` | the field |
| `(Cons h t body)` | `Cons` | `h` = head, `t` = tail |
| `(Cons h _ body)` | `Cons` | only `h`; the tail is discarded |
| `(_ body)` | anything | nothing |

A struct is a one-variant ADT named after the struct, so a struct can be
matched too:

```lisp
(defstruct Point (x) (y))

(defn manhattan (p)
  (match p
    (Point x y (+ x y))))

(defn main ()
  (print (manhattan (make-Point 3 4))))   ; 7
```

### The Discard `_`

`_` discards a value. It is the only discard, and it can appear any
number of times in one arm: `(Triangle _ _ _ 0)`. A name that starts
with `_`, such as `_rest`, is an ordinary binder that is exempt from the
unused-variable warning.

### Catch-All Arms

`(_ body)` matches anything. It must be the last arm: an arm after a
catch-all could never run, and is a compile-time error
(`E_UNREACHABLE_MATCH_ARM`).

Be careful with spelling. The compiler treats any arm head that is not a
known constructor as a catch-all, and such an arm binds nothing. A
misspelled constructor in the *last* arm therefore silently matches
everything the earlier arms did not; a misspelled one anywhere else is
caught as `E_UNREACHABLE_MATCH_ARM`.

### One Level at a Time

A binder position holds a name or `_`, not another pattern. A nested
pattern such as `(Some (Cons x _) body)` is accepted, but only the outer
variant is tested; the inner constructor is not checked (Chapter 4,
§4.2). Match the field in the body instead:

```lisp
(deftype Expr
  (Num Int)
  (Add Expr Expr))

;; Fold (Add (Num a) (Num b)) into (Num (+ a b)); leave anything else alone.
(defn fold-add (e)
  (match e
    (Add a b
      (match a
        (Num x (match b
                 (Num y (Num (+ x y)))
                 (_ e)))
        (_ e)))
    (_ e)))

(defn value-of (e)
  (match e
    (Num n n)
    (_ -1)))

(defn main ()
  (begin
    (print (value-of (fold-add (Add (Num 2) (Num 3)))))            ; 5
    (print (value-of (fold-add (Add (Num 2) (Add (Num 1) (Num 1)))))) ; -1
    0))
```

### Float Fields

A `Float` field is stored correctly, but the code generator does not
know that a pattern-bound name holds a Float. Hand pattern-bound Floats
to a `Float`-annotated function, and print a Float result with
`print-float`:

```lisp
(deftype Shape (Circle Float) (Rect Float Float))

(defn circle-area ((r Float)) (* 3.14 r r))
(defn rect-area ((w Float) (h Float)) (* w h))

(defn area (s)
  (match s
    (Circle r (circle-area r))
    (Rect w h (rect-area w h))))

(defn main ()
  (begin
    (print-float (area (Circle 2.0)))     ; 12.560000
    (print-float (area (Rect 1.5 2.0)))   ; 3.000000
    0))
```

Writing `(* w h)` directly in the `Rect` arm multiplies the two bit
patterns as integers, and a plain `print` of the result shows the
Float's bits as an integer.

## 6.3 Exhaustiveness Checking

The compiler **requires** every variant to be covered, either by its
own arm or by a trailing `_`:

```lisp
(deftype TrafficLight (Red) (Yellow) (Green))

(defn action (light)
  (match light
    (Red "stop")))
```

```
PANIC: error[E_NON_EXHAUSTIVE_MATCH]: match over `TrafficLight` does not cover variant `Yellow`
  --> /home/you/lights.zyl:4:3
   |
 4 |   (match light
   |   ^
   = help: add an arm for that variant, or a `_` catch-all
```

The error names the first variant that is missing. The compiler prints
the full path of the source file. Either of these is accepted:

```lisp
(defn action (light)
  (match light
    (Red "stop")
    (Yellow "caution")
    (Green "go")))

(defn is-red (light)
  (match light
    (Red true)
    (_ false)))
```

There is no `default` or `otherwise` keyword; `_` is the catch-all.

Exhaustiveness matters for correctness, not only style: if no arm of a
constructor match applies, the `match` evaluates to 0.

Two limits of the current check:

- It works out the scrutinee's type from the constructors named in the
  arms. If two types share a variant name, a `match` using that name is
  not checked.
- It does not report a repeated arm: in
  `(match c (Red 1) (Red 2) (Green 3) (Yellow 4))` the second `Red` arm
  is simply dead.

The specification spells the error `E_MATCH_NONEXHAUSTIVE`. The
constructor check prints `E_NON_EXHAUSTIVE_MATCH`; the literal-pattern
check below prints `E_MATCH_NONEXHAUSTIVE`.

## 6.4 Literal, OR and Range Patterns

A `match` whose arms start with literals compares the scrutinee against
them. These patterns go beyond the specification, which defines only
constructor patterns.

```lisp
(defn status-text (code)
  (match code
    (200 "OK")
    (301 302 "Redirect")                 ; OR-pattern: either value
    (404 "Not Found")
    ((range 500 599) "Server Error")     ; inclusive at both ends
    (_ "Other")))

(defn command (s)
  (match s
    ("start" 1)                          ; strings compare by content
    ("stop" 2)
    (_ 0)))

(defn main ()
  (begin
    (print-string (status-text 200))    ; OK
    (print-string (status-text 302))    ; Redirect
    (print-string (status-text 503))    ; Server Error
    (print-string (status-text 418))    ; Other
    (print (command "stop"))            ; 2
    0))
```

- **Literals** may be integers, floats, strings or booleans.
- **OR-patterns**: several alternatives before the body; the arm
  matches if any of them does.
- **Ranges**: `(range lo hi)` matches `lo <= x <= hi`.
- **A literal match must end with `_`.** Without it:

  ```
  PANIC: E_MATCH_NONEXHAUSTIVE: a literal-pattern match must end with a `_` arm
  ```

- **Literal patterns bind nothing.** The `_` arm refers to the value
  through the scrutinee's own name (`code`, `s`).
- **Don't mix** literal arms and constructor arms in one `match`. They
  are compiled by different mechanisms, and a mixed `match` is not
  diagnosed.

## 6.5 Guards

A literal arm may end its pattern with `(when condition)`. The arm then
matches only if the pattern matches *and* the condition is true;
otherwise matching continues with the next arm.

```lisp
(defn zero-word (n verbose)
  (match n
    (0 (when verbose) "zero, exactly")
    (0 "zero")
    (_ "nonzero")))

(defn main ()
  (begin
    (print-string (zero-word 0 true))    ; zero, exactly
    (print-string (zero-word 0 false))   ; zero
    (print-string (zero-word 5 true))    ; nonzero
    0))
```

Guards currently work only in this position. Elsewhere:

- **After a `range`** a guard fails to compile, with
  ``E_ARITY_MISMATCH: `when` called with 1 argument(s), but it takes 2``
  (it is mistaken for a call to the core library's `when` function).
- **On a constructor arm** such as `(Some x (when (> x 0)) x)`, the
  guard is read as a field binder. The program compiles and then
  crashes.
- **On the trailing `_` arm** a guard is ignored.

For a condition on a constructor's field, test it in the body:

```lisp
(defn positive-or-zero (o)
  (match o
    (Some x (if (> x 0) x 0))
    (None 0)))
```

## 6.6 Error Handling with `Result`

Zyl's model for expected failures is **errors as values**. A function
that can fail returns a `Result`:

```lisp
(deftype Result (Ok T) (Err E))   ; already defined by the core library
```

```lisp
(defn parse-digit ((c String))
  (cond
    ((= c "0") (Ok 0))
    ((= c "1") (Ok 1))
    ((= c "2") (Ok 2))
    (else (Err "not a digit"))))

(defn show (r)
  (match r
    (Ok v (print v))
    (Err msg (print-string msg))))

(defn main ()
  (begin
    (show (parse-digit "2"))     ; 2
    (show (parse-digit "x"))     ; not a digit
    0))
```

Note `print-string` for the message: a String bound by a pattern prints
as its address with a plain `print` (Chapter 2, §2.2).

### Result Chaining

Nested `match` handles a sequence of steps that can each fail:

```lisp
(defn check-small (n)
  (if (< n 2) (Ok n) (Err "too big")))

(defn nested ((s String))
  (match (parse-digit s)
    (Ok n (match (check-small n)
            (Ok m (Ok (* m 10)))
            (Err e (Err e))))
    (Err e (Err e))))
```

`result-and-then` from the core library flattens this. It takes the
`Result` first and a function second, and calls the function only on an
`Ok`:

```lisp
(defn times-ten (n) (Ok (* n 10)))

(defn chained ((s String))
  (result-and-then (result-and-then (parse-digit s) check-small) times-ten))

(defn main ()
  (begin
    (show (chained "1"))    ; 10
    (show (chained "2"))    ; too big
    (show (chained "x"))    ; not a digit
    0))
```

The functions passed here are named, top-level functions. A `fn` that
captures a variable cannot yet be passed to another function (Chapter 3,
§3.3), and a `fn` whose body applies a constructor directly, such as
`(fn (x) (Ok x))`, hangs when passed; use `result-ok` there instead, or a
named function as above.

The other core helpers: `result-map`, `result-or`, `result-unwrap`
(value or a default), `result-expect` (value or `error`),
`result-is-ok`/`result-is-err`, and `result-to-option`.

## 6.7 The `Option` Type — Avoiding Null

```lisp
(deftype Option (Some T) None)    ; already defined by the core library
```

There is no null. Use `Option` for "maybe a value":

```lisp
(defn find-first-even (xs)
  (match xs
    (Nil None)
    (Cons x rest (if (is-even x) (Some x) (find-first-even rest)))))

(defn main ()
  (begin
    (print (option-unwrap (find-first-even (Cons 3 (Cons 8 Nil))) -1))   ; 8
    (print (option-unwrap (find-first-even (Cons 3 Nil)) -1))            ; -1
    0))
```

The core helpers mirror the `Result` ones: `option-map`,
`option-flatmap`, `option-or`, `option-unwrap` (value or a default),
`option-expect` (value or `error`), `option-is-some`/`option-is-none`
and `option-to-result`. As with `Result`, the `Option` comes first and
the function second: `(option-map (Some 21) (fn (x) (* x 2)))`.

## 6.8 `error`, `try` and `catch`

For a failure the program cannot sensibly continue from, `(error "message")`
stops it: it prints `PANIC: message` to standard error and exits with
status 1.

`try` intercepts an `error` raised while its expression runs, directly
or in any function it calls:

```lisp
(try expr (catch err-var handler))
```

```lisp
(defn percent-of (n)
  (if (== n 0)
    (error "division by zero")
    (/ 100 n)))

(defn report ((msg String))
  (begin
    (print-string (str-concat "caught: " msg))
    -1))

(defn main ()
  (begin
    (print (try (percent-of 4) (catch e (report e))))   ; 25
    (print (try (percent-of 0) (catch e (report e))))   ; caught: division by zero, then -1
    (print "still running")
    0))
```

What `try` is and is not:

- **It catches `error`, not `Err`.** `try` is not sugar for matching on a
  `Result`: an `(Err ...)` value is an ordinary value and passes straight
  through `try` unchanged. Use `match` or `result-and-then` for Results,
  and `result-expect` to turn an `Err` into an `error` on purpose.
- The handler is one expression, with `err-var` bound to the message
  String. Use `begin` or a function call, as `report` does, for more.

> **Known bug.** An `error` raised inside some user functions of two or
> four parameters hangs the program instead of reaching the handler. The
> function `(defn f (a b) (error "x"))` hangs under
> `(try (f 1 2) (catch e 0))`, while `(f 0 0)` or `(f "a" 1)` is caught.
> Chapter 3 (§3.6) describes it. Until it is fixed, prefer `Result`
> values for failures you expect to handle.

## 6.9 `assert` and `unwrap`

The specification defines `(assert condition "message")`, which aborts
with `E_ASSERT_FAIL` when the condition is false, and `(unwrap r)`, which
extracts an `Ok`/`Some` value or aborts. Both parse, but neither is
implemented by the current code generator:

- `(assert c "msg")` does nothing, whatever `c` is.
- `(unwrap x)` evaluates to 0.

Use an explicit check with `error` instead of `assert`, and
`result-expect`/`option-expect` (or `result-unwrap`/`option-unwrap` with
a default) instead of `unwrap`:

```lisp
(defn checked-half (n)
  (if (is-odd n)
    (error "checked-half: odd input")
    (/ n 2)))

(defn main ()
  (begin
    (print (checked-half 10))                           ; 5
    (print (result-expect (Ok 42) "expected a value"))  ; 42
    0))
```

In tests, `assert-true`, `assert-false` and `assert-equal` do work
(Chapter 11).

## 6.10 Error Handling Cheat Sheet

| Situation | Recommended approach |
|-----------|---------------------|
| Expected failure (parsing, lookup) | Return a `Result`; handle with `match` or `result-and-then` |
| Optional value | `Option` + `match` or `option-map` |
| Default on failure | `result-unwrap` / `option-unwrap` with a default |
| Unrecoverable condition | `error` |
| Recovering from an `error` | `try` / `catch` (mind the bug in §6.8) |
| Internal invariant | an `if` that calls `error` (not `assert`) |
| Several kinds of error | `Result` whose `Err` holds your own ADT |

---

## For Experts: Under the Hood

### Match Compilation

The implementation is simpler than a decision-tree compiler:

- **Constructor matches** evaluate the scrutinee once, then test its tag
  against each arm in source order. The first arm whose tag matches
  binds its fields and runs its body; a catch-all matches without a
  test. If nothing matches, the result is 0 — which is why exhaustiveness
  is enforced.
- **Literal matches** bind the scrutinee to a hidden variable and become
  a nested `if` chain. Each arm's test is its alternatives joined by
  "or", then combined with its guard by "and". String alternatives
  compare by content.

There is no jump table and no merging of arms. Chapter 18 is the full
reference, including the representation of variant values.

### No Fallthrough

Each arm is independent; control never falls from one arm into the
next.

### Where Checks Happen

| Check | Pass |
|-------|------|
| `E_NON_EXHAUSTIVE_MATCH`, `E_UNREACHABLE_MATCH_ARM` | `stdlib/compiler/exhaustiveness_check.zyl` |
| `E_MATCH_NONEXHAUSTIVE` (literal matches) | while the `match` is parsed, in `stdlib/compiler/expr_inner.zyl` |
| `E_MATCH_ARM_COMPLEX` (an arm body the code generator is known to miscompile) | ICNF lowering, in `stdlib/compiler/icnf.zyl` |

### `error` and `try`

`error` unwinds to the innermost active `try` at run time; with none
active, it prints `PANIC:` and exits with status 1. Because the output
of `print` is buffered and the panic message goes straight to standard
error, the `PANIC:` line can appear before output printed earlier.

---

**Next:** [Chapter 7: Generics and Traits](ch07-generics-and-traits.md) — polymorphic functions, generic ADTs, `impl` blocks and qualified trait calls.
