# Chapter 3: Functions and Control Flow

Functions are the core building blocks of Zyl programs. This chapter covers function definition, control flow constructs, and Zyl's approach to error handling.

## 3.1 Function Definition

### Named Functions (`defn`)

```lisp
(defn name (param1 param2 ...) body)
```

```lisp
(defn add (a b)
  (+ a b))

(defn greet ((name String))
  (print (str-concat "Hello, " name)))

(defn main ()
  (print (add 2 3))       ; 5
  (greet "Zyl")           ; Hello, Zyl
  0)
```

**Parameters are immutable** — they behave like `let` bindings. A `set!` on a parameter is a compile error (`E_MUT_CONFLICT`).

### Parameter Type Annotations

```lisp
;; Types are inferred; an annotation is written (name Type)
(defn add-ints ((a Int) (b Int))
  (+ a b))
```

Annotations are optional, and type inference works without them:
`greet` would print `name` as text unannotated too, because every call
passes a String. An annotation documents intent and constrains
inference. Either way the program is checked: a call whose argument
clashes with a parameter's type, annotated or inferred, such as
`(add-ints 1.5 2)`, is `E_TYPE_MISMATCH` (Chapter 15), and the compile
stops.

There is no return-type annotation. Anything after the parameter list
is the body, so `(defn add ((a Int) (b Int)) Int (+ a b))` treats `Int`
as an expression and fails with `E_UNBOUND_VARIABLE`.

### Multiple Expressions in Body

A body may contain several forms. They run in order, as if wrapped in
`begin`, and you can also write the `begin` yourself:

```lisp
(defn compute (x y)
  (begin
    (print "Computing...")
    (let sum (+ x y)
      (* sum 2))))
```

The **last expression's value is returned** — no explicit `return` keyword exists.

Either way, a `let` among the forms is in scope only inside itself, not
in the forms that follow it (Chapter 2, §2.5).

### `defun` Is Not a Synonym

The specification lists `defun` as a synonym for `defn`, but the
compiler does not recognize it: `(defun square (x) (* x x))` is read as
an ordinary call, so `square` is never defined and a call to it is
`E_UNBOUND_VARIABLE`. Write `defn`. (`defun` is still a reserved word, so
it cannot name a binding either.)

## 3.2 Recursion

Zyl supports full recursion:

```lisp
(defn factorial (n)
  (if (== n 0)
    1
    (* n (factorial (- n 1)))))

;; Accumulator style
(defn sum-to (n acc)
  (if (== n 0)
    acc
    (sum-to (- n 1) (+ acc n))))

(defn main ()
  (print (factorial 10))          ; 3628800
  (print (sum-to 1000000 0))      ; 500000500000
  0)
```

**Tail calls.** The specification calls for guaranteed TCO. A call in
tail position (an `if` branch, a `let` body, the last form of a `begin`,
a `match` arm body) becomes a jump, whether it names a function or goes
through a function value, so `sum-to` above runs in constant stack, and
so does mutual recursion. Two cases still push a frame: a tail call that
needs more stack arguments (beyond the sixth) than its caller received,
and any call inside `try`/`catch`, a `while` body, or a function that
handles secrets (Chapter 33). The REPL interpreter also runs tail calls
in constant stack, except ones returning a String or Float.

### Mutual Recursion

```lisp
(defn even? (n)
  (if (== n 0) true (odd? (- n 1))))

(defn odd? (n)
  (if (== n 0) false (even? (- n 1))))

(defn main ()
  (print (even? 10))    ; 1
  (print (odd? 7))      ; 1
  0)
```

Forward references work — all functions are collected before type inference.

### Local Helpers

The specification's *named let* (`(let loop ((n 10) (acc 1)) ...)`) is
not supported — don't use it. Write the helper as a top-level function
instead, as `sum-to` does above. Naming the loop and rebinding its state
with `set!` inside a `let-mut` is also not a way around it: a closure that
assigns to a captured `let-mut` is `E_MUT_CONFLICT`. Threading the state
through parameters, as `sum-to` does, is the idiom.

For a chain of bindings where each is in scope for the next, `let*` is
sugar for nested `let`:

```lisp
(let* ((a 1) (b (+ a 10)) (c (* b 2))) (print c))   ; prints 22
```

## 3.3 Anonymous Functions (`fn` / `lambda`)

```lisp
(fn (x) (* x x))           ; Square function
(lambda (x y) (+ x y))     ; Same as fn — synonym
```

A function literal is always introduced by `fn` or `lambda`; there is
no shorter syntax. To call one, bind it first:

```lisp
(defn main ()
  (let square (fn (x) (* x x))
    (print (square 7)))       ; 49
  0)
```

### Closures Capture Their Environment

```lisp
(defn make-adder (n)
  (fn (x) (+ x n)))        ; Captures n from the enclosing scope

(defn main ()
  (let add5 (make-adder 5)
    (print (add5 10)))     ; 15
  0)
```

`make-adder` returns a closure that carries `n` with it; `add5` is then
called like any function.

A closure, capturing or not, is an ordinary value: it can be passed to
another function and called there, stored, or returned again (§3.9).
Chapter 8 covers closures in depth.

## 3.4 Conditionals

### `if`

```lisp
(if condition then-branch else-branch)
```

The condition must be a `Bool`, and the two branches must have the
same type, which is the type of the `if`.

```lisp
(defn max-of (a b)
  (if (> a b) a b))

(defn sign (n)
  (if (> n 0) 1
    (if (< n 0) -1
      0)))
```

The else branch may be left out. An `if` without an else is a
statement: its type is `Unit`, so its one branch must be `Unit` too,
and the `if` can only be used for its effect:

```lisp
(defn log-if-positive (n)
  (if (> n 0)
    (print n)))            ; nothing printed for n <= 0
```

There is no truthiness: a condition is a comparison, a Bool, or a call
that returns one. An Int is not a condition — `(if n ...)` is
`E_TYPE_MISMATCH` (`` `if` needs a Bool condition, but this is `Int` ``); write `(if (!= n 0) ...)`.
The same holds for `cond`, `when`, `while` and `for`.

### `cond` — Multi-Branch

```lisp
(cond
  (test1 body1)
  (test2 body2)
  (else fallback-body))
```

Evaluates the tests in order; the first true one wins, and `cond`
returns its body's value. A clause's body may be several forms, run in
order. A clause whose test is `else` or the literal `true` catches
everything and ends the `cond`. Without one, a `cond` may run no clause
at all, so it is a statement of type `Unit`, like an `if` without an
else: every body must be `Unit`. To return a value from a `cond`, end
it with an `else` clause.

```lisp
(defn classify (n)
  (cond
    ((< n 0) "negative")
    ((== n 0) "zero")
    ((< n 10) "small positive")
    (else "large positive")))

(defn main ()
  (print (classify -1))    ; negative
  (print (classify 5))     ; small positive
  (print (classify 50))    ; large positive
  0)
```

## 3.5 Loops

### `while` — Condition-First Loop

```lisp
(while condition body...)
```

```lisp
(defn main ()
  (let-mut i 0
    (while (< i 3)
      (print i)
      (set! i (+ i 1))))
  0)
;; Output: 0, 1, 2 (one per line)
```

- Condition evaluated before each iteration
- The body may be several forms; they run in order
- Body typically uses `let-mut` + `set!` to update loop variables
- `while` is a statement: its type is `Unit`, and so is `set!`

### `for` — Loop With Its Own Variables

```lisp
(for (bindings) condition body)
```

Each binding is `(name init)`. `for` creates the variables, then runs
the body for as long as the condition holds. There is no separate step
clause: the body updates the variables with `set!`.

```lisp
(defn main ()
  ;; Count 0 to 2
  (for ((i 0)) (< i 3)
    (begin
      (print i)
      (set! i (+ i 1))))

  ;; Two variables
  (for ((i 0) (j 100)) (< i 3)
    (begin
      (print (+ i j))
      (set! i (+ i 1))
      (set! j (- j 10))))
  0)
;; Output: 0 1 2, then 100 91 82 (one per line)
```

The accepted binding forms:

```lisp
(for ((i 0)) cond body)            ; one variable
(for ((i 0) (j 10)) cond body)     ; several variables
(for (i 0) cond body)              ; one variable, short form
(for () cond body)                 ; no variables — a while loop
```

**Semantics:**
1. Create each loop variable with its initial value.
2. Evaluate the condition. If false, exit the loop.
3. Execute the body.
4. Go to step 2.

**No iterator protocol yet** — `for` doesn't iterate over collections.
Use an index with `vec-get!`, or recursion over a `List`.

## 3.6 Errors

Zyl has two mechanisms, and they are for different things:

- **Expected failures are values.** A function that can fail returns a
  `Result`: `(Ok value)` or `(Err reason)`. The caller decides what to
  do with it, usually with `match` (Chapter 6).
- **`panic` aborts, and a function that may call it ends in `!`.** `(panic "message")` stops the program with
  `PANIC: message` and exit status 1 — unless a `try` is active, in
  which case control passes to its `catch`. `(error "message")` is the
  other half: it returns `(Err "message")` and raises nothing, for a
  failure the caller should handle.

### Results

```lisp
(defn divide (a b)
  (match (div? a b)
    (Some q (Ok q))
    (None (Err "division by zero"))))

(defn show-division (a b)
  (match (divide a b)
    (Ok q (print q))
    (Err msg (print msg))))

(defn main ()
  (show-division 10 2)     ; 5
  (show-division 1 0)      ; division by zero
  0)
```

Both arms print, so both are `Unit`, and so is the `match`. An arm that
printed while another returned a number would not type-check.

`divide` cannot be written as `(if (== b 0) (Err ...) (Ok (/ a b)))`:
`/` with a divisor that is not a nonzero literal is `E_PARTIAL_OPERATION`,
and the compiler does not look at the guard. `div?` returns
`(Some quotient)` or `None`, which is the check and the division in one
(§3.12).

The core library has helpers for the common cases:
`(result-unwrap r default)` and `(option-unwrap o default)` return the
value or a default, and `(result-expect! r "msg")` /
`(option-expect! o "msg")` return the value or stop the program with the
message. The trailing `!` is how Zyl spells a function that can stop the
program: name your own that way too (Chapter 6, §6.9).

### `error`, `panic`, `try` and `catch`

```lisp
(try expr (catch err-var handler))
```

1. Evaluate `expr`. If it finishes normally, its value is the value of the `try`.
2. If the program panics while `expr` runs (directly or in any function it calls: a `panic`, a `div!` by zero, a `vec-get!` out of range, an overflow), control passes to the handler instead, with `err-var` bound to the message string.
3. The handler's value is the value of the `try`.

```lisp
(defn percent-of-100! (n)
  (if (< n 0)
    (panic "a percentage of a negative count")
    (div! 100 n)))

(defn report ((msg String))
  (begin
    (print (str-concat "caught: " msg))
    -1))

(defn safe-percent (n)
  (try (percent-of-100! n)
    (catch err (report err))))

(defn main ()
  (print (safe-percent 4))      ; 25
  (print (safe-percent 0))      ; caught: error[E_DIVISION_BY_ZERO]: ..., then -1
  (print "still running")
  0)
```

Things to know about the current implementation:

- `try` does **not** unwrap a `Result`. An `(Err ...)` value is an
  ordinary value and passes straight through, and so does the
  `(Err msg)` that `error` returns; only a panic transfers control to
  `catch`.
- The caught message of a built-in failure is its whole diagnostic:
  ``error[E_DIVISION_BY_ZERO]: division by zero in `div!` ``, then its
  `= help:` line.
- The handler may be several forms, run in order; the last one's value
  is the value of the `try`. It must have the same type as `expr`.
- The message is a String, and prints as one.

### `unwrap` and `assert`

The specification defines `(unwrap r)` and `(assert condition "message")`.
Both work. A false `assert` panics with your message when it is a
string literal (`assert failed` otherwise). `unwrap` takes an `Option`:
of `None` it panics with `unwrap on None`, and applied to a `Result` it
is `E_TYPE_MISMATCH`. Where the message matters, or for a `Result`, use
`result-expect!` / `option-expect!` instead of `unwrap`, and an explicit
check with `panic` instead of `assert`:

```lisp
(defn checked-sqrt-floor! (x)
  (if (< x 0)
    (panic "sqrt requires non-negative input")
    (sqrt-floor x 0)))

(defn sqrt-floor (x r)
  (if (> (* (+ r 1) (+ r 1)) x) r (sqrt-floor x (+ r 1))))

(defn main ()
  (print (checked-sqrt-floor! 17))   ; 4
  0)
```

In tests, `assert-true`, `assert-false` and `assert-equal` do work
(Chapter 11).

## 3.7 No Early Returns

Zyl has **no early `return` statement**. The last expression in a function is its return value. Structure your code with:

- `if` / `cond` for branching
- `Result` values for failures
- `match` for exhaustive case analysis (Chapter 6)
- Small, focused functions

```lisp
;; Instead of early returns:
(defn process (x)
  (if (< x 0)
    (Err "negative")
    (if (== x 0)
      (Ok 0)
      (Ok (* x 2)))))
```

## 3.8 Higher-Order Functions

Functions are values. Pass them around:

```lisp
(defn apply-twice (f x)
  (f (f x)))

(defn add1 (x) (+ x 1))

(defn main ()
  (print (apply-twice add1 5))              ; 7
  (print (apply-twice (fn (x) (* x 2)) 3))  ; 12
  0)
```

A named function, a non-capturing `fn` and a capturing closure are all
fine as arguments.

### Common Patterns

```lisp
;; Map over a list (List is an ADT, Chapter 4)
(defn my-map (f xs)
  (match xs
    (Nil Nil)
    (Cons x rest (Cons (f x) (my-map f rest)))))

;; Filter a list
(defn my-filter (pred xs)
  (match xs
    (Nil Nil)
    (Cons x rest
      (if (pred x)
        (Cons x (my-filter pred rest))
        (my-filter pred rest)))))

(defn main ()
  (let xs (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil))))
    (begin
      (print (list-sum (my-map (fn (x) (* x 10)) xs)))       ; 100
      (print (list-length (my-filter (fn (x) (> x 2)) xs)))))  ; 2
  0)
```

`list-sum` and `list-length` come from the core list library. The
module `collections/collections` also has ready-made `list-map`,
`list-filter` and `list-fold`.

## 3.9 Function Types

Type inference gives every function a function type — its parameter
types and its result type (in the compiler's type representation, a
`TFun` over those types). You never write one: the checker infers them,
and they appear in type errors.

The REPL's `:type` shows them: after `(defn add1 (x) (+ x 1))`,
`:type add1` answers `add1 : (Int -> Int)` and `:type (add1 2)`
answers `(add1 2) : Int`.

## 3.10 Scope and Shadowing

```lisp
(defn foo (x)
  (begin
    (let x 20        ; Shadows the parameter inside this let
      (print x))     ; 20
    (print x)))      ; the parameter, unchanged

(defn main ()
  (foo 10)           ; prints 20, then 10
  0)
```

There is no global mutable state: every mutable binding is local, and
a top-level `def` is an immutable constant (Chapter 2, §2.5).

## 3.11 I/O Basics

```lisp
(print "Hello")           ; writes Hello and a newline
(print 42)                ; 42
(print 3.14)              ; 3.140000
(print true)              ; 1
```

`print` writes one value followed by a newline. Given several
arguments, `(print a b)` prints each on its own line. To put text and
a value on one line, build the string first with `str-concat`. `print`
is a statement: its type is `Unit`.

`print` follows the value's inferred type (Chapter 2, §2.2), and a value
whose type has a `Show` impl prints as its `show` text: `(print (Some 1))`
prints `Some(1)`. `print-string`, `print-float` and `print-int` (core
library) are the same with a fixed argument type; like `print`, they
return `Unit`.

Reading input: `(read-line)` returns the next line of standard input
as a String, without its newline. It needs the `io` capability, so a
file that reads input starts with `(capabilities io)`. File I/O is in
`stdlib/io` (Chapter 12).

## 3.12 Numbers: Overflow and Division

Zyl's rule for arithmetic is that a program may only stop where its
source said it could. `Int` is a 64-bit signed integer, and three things
follow from the rule.

**`+`, `-` and `*` are checked.** A result that does not fit stops the
program with `E_OVERFLOW` — it does not wrap to a plausible wrong
number. A literal computation is folded at compile time, and one that
overflows stays an operation, so it stops the program too:

```lisp
(defn grow ((n Int)) (* n 4611686018427387904))

(defn main ()
  (print (grow 1))    ; 4611686018427387904
  (print (grow 3))    ; stops: error[E_OVERFLOW]: integer overflow in `*`
  0)
```

A file that wants other arithmetic declares it once, among its
top-level forms (a package writes the same line in `zyl.pkg`) —
exactly one of these three lines:

```lisp
(numeric wrapping)      ; + - * wrap modulo 2^64
(numeric saturating)    ; + - * clamp to the largest or smallest Int
(numeric checked)       ; the default, spelled out
```

The policy covers the whole package. For one operation, whatever the
policy, use `wrapping+`, `wrapping-`, `wrapping*`, `saturating+`,
`saturating-` or `saturating*` — a hash function's mixing step is the
usual case. Unary minus is `(- 0 x)` under the policy, so `(- x)` of the
smallest `Int` is an overflow. Shifts and the `bit-` operations never
trap.

**`/` and `%` need a divisor that cannot be zero.** A nonzero integer
literal is one: `(/ n 2)` and `(% n 10)` compile. Any other divisor is a
compile error, located at the divisor:

```text
error[E_PARTIAL_OPERATION]: `/` has a divisor that may be zero
  --> avg.zyl:1:34
   |
 1 | (defn avg ((a Int) (n Int)) (/ a n))
   |                                  ^
   = help: write `(div! a b)` to stop the program on a zero divisor, `(div? a b)` to get None, or divide by a nonzero literal
```

No guard is recognised, so an `if` around the division does not help.
Choose the behaviour instead:

| Form | Zero divisor | Otherwise |
|------|--------------|-----------|
| `(div! a b)`, `(rem! a b)` | Stops with `E_DIVISION_BY_ZERO` (catchable by `try`) | The quotient / remainder |
| `(div? a b)`, `(rem? a b)` | `None` | `(Some quotient)` / `(Some remainder)` |

Quotients truncate toward zero, and a remainder takes the sign of the
dividend: `(rem! -7 2)` is -1. The smallest `Int` divided by -1 has no
`Int` answer and is `E_OVERFLOW` under every policy.

**Floats are outside the policy.** IEEE-754 arithmetic does not trap:
overflow is `inf`, and `(/ 1.0 0.0)` is `inf`.

The `!` in `div!` is the same `!` as in `vec-get!` and
`option-expect!`: every library operation that can stop the program
says so in its name, and its total sibling ends in `?` and returns an
`Option` (Chapter 6, §6.9).

## 3.13 Control Flow Cheat Sheet

| Construct | Purpose | Returns |
|-----------|---------|---------|
| `(if c t e)` | Binary choice | Value of chosen branch (`Unit` if there is no else) |
| `(cond (c1 b1) ... (else be))` | Multi-way choice | Value of first matching branch (`Unit` without `else`/`true`) |
| `(while c b...)` | Loop while true | `Unit` |
| `(for ((v init)...) c b)` | Loop with its own variables | `Unit` |
| `(match v arms...)` | Case analysis (Chapter 6) | Value of the matching arm |
| `(error msg)` | Report a failure as a value | `(Err msg)` |
| `(panic msg)` | Abort, or jump to the nearest `catch` | Does not return |
| `(try e (catch v h))` | Intercept a `panic` | Value of `e`, or of `h` after a `panic` |
| `(div! a b)` / `(div? a b)` | Int division by a value that may be zero | The quotient / an `Option` |

---

## For Experts: Under the Hood

### Calling Convention (System V AMD64 ABI)

| Argument | Register |
|----------|----------|
| 1st | `rdi` |
| 2nd | `rsi` |
| 3rd | `rdx` |
| 4th | `rcx` |
| 5th | `r8` |
| 6th | `r9` |
| 7th+ | Stack |

- Return value: `rax` (every value is one 64-bit word)
- Callee-saved: `rbx`, `rbp`, `r12`-`r15`
- Stack alignment: 16-byte before `call`
- Arguments are evaluated left to right, each into its own place before
  any argument register is loaded, so evaluating one argument can never
  clobber another. A function the native backend handles (integers,
  control flow, variants, `match`, direct calls; see
  `docs/native-backend-design.md`) keeps its values in virtual
  registers, assigned to machine registers by linear scan, and saves
  only the callee-saved registers it uses; any other function goes
  through the older stack-machine generator, which stages arguments in
  scratch stack slots. Both use this ABI, so they call each other freely

`--emit-asm` shows all of this: `zyl file.zyl --emit-asm -o file.s`.

### Tail Calls

A call in tail position restores the callee-saved registers, tears down
the frame and `jmp`s to the callee (through `r10` for a function value);
arguments beyond the sixth are written into the caller's own incoming
stack-argument slots, so they must fit there. Every other call is a `call`; the
generated entry stub runs `main` on a large dedicated stack, which
keeps deep non-tail recursion practical.

### Closure Representation

- A `fn` that captures nothing is lifted to an ordinary top-level
  function; passing it passes the function's address.
- A capturing `fn` becomes a block holding a tag, the code pointer and
  the environment (its captured values, copied when it is created).
- A call through any local holding a function value tests the tag: for
  a closure it calls the code with the environment as an extra trailing
  argument, for a plain address it calls the address (with a 0 in that
  slot, which the function ignores).

### Region Interaction

- Int, Float and Bool parameters and `let` bindings live in registers
  or stack-frame slots
- A `let-mut` binding is a register or frame slot like any other;
  `set!` overwrites it
- Struct and ADT values are placed by region inference: in the call's
  own frame region when they do not outlive the call, in the region the
  caller chose when they are returned, and on the heap only when they
  escape further (Chapter 5)

---

**Next:** [Chapter 4: Data Structures](ch04-data-structures.md) — Structs, ADTs, collections, and pattern matching.
