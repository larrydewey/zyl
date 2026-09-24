# Chapter 3: Functions and Control Flow

Functions are the core building blocks of Zyl programs. This chapter covers function definition, control flow constructs, and Zyl's approach to error handling.

## 3.1 Function Definition

### Named Functions (`defn` / `defun`)

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
  (greet "Zyl"))          ; Hello, Zyl
```

**Parameters are immutable** — they behave like `let` bindings. A `set!` on a parameter is a compile error (`E_MUT_CONFLICT`).

### Parameter Type Annotations

```lisp
;; Types are inferred; an annotation is written (name Type)
(defn add-ints ((a Int) (b Int))
  (+ a b))
```

Annotations are optional, and type inference works without them. In
the current compiler they do one more job: they tell the code generator
what a parameter holds. That is why `greet` above annotates `name` as
`String` — without the annotation, `(print name)` would print the
string's address. The same goes for `Float` parameters used in
arithmetic (Chapter 2, §2.2).

There is no return-type annotation. Anything after the parameter list
is the body, so `(defn add ((a Int) (b Int)) Int (+ a b))` treats `Int`
as an expression and fails with `E_UNBOUND_VARIABLE`.

### Multiple Expressions in Body

A body may contain several forms; wrap them in `begin`:

```lisp
(defn compute (x y)
  (begin
    (print "Computing...")
    (let sum (+ x y)
      (* sum 2))))
```

The **last expression's value is returned** — no explicit `return` keyword exists.

The compiler also accepts several forms directly after the parameter
list, but then a `let` among them stays in scope for the forms that
follow it (Chapter 2, §2.5). `begin` gives the scoping you expect.

### `defun` — Synonym for `defn`

```lisp
(defun square (x) (* x x))    ; Same as defn
```

Both are accepted. `defn` is what the standard library uses.

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
  (print (sum-to 1000000 0)))     ; 500000500000
```

**No tail-call optimization yet.** The specification calls for
guaranteed TCO; the current code generator emits every call, tail
position or not, as a real `call`. In practice deep recursion still
works: a generated program runs `main` on a large dedicated stack, so a
recursion depth in the millions (like `sum-to` above) is fine. A loop
(`while`, §3.5) is the tool for unbounded iteration.

### Mutual Recursion

```lisp
(defn even? (n)
  (if (== n 0) true (odd? (- n 1))))

(defn odd? (n)
  (if (== n 0) false (even? (- n 1))))

(defn main ()
  (print (even? 10))    ; 1
  (print (odd? 7)))     ; 1
```

Forward references work — all functions are collected before type inference.

### Local Helpers

The specification's *named let* (`(let loop ((n 10) (acc 1)) ...)`) is
not supported by the current compiler — don't use it. Write the helper
as a top-level function instead, as `sum-to` does above.

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
    (print (square 7))))      ; 49
```

### Closures Capture Their Environment

```lisp
(defn make-adder (n)
  (fn (x) (+ x n)))        ; Captures n from the enclosing scope

(defn main ()
  (let add5 (make-adder 5)
    (print (add5 10))))    ; 15
```

`make-adder` returns a closure that carries `n` with it; `add5` is then
called like any function.

**A current limitation:** a closure that *captures* variables can be
called by the function that holds it, as above, but it cannot yet be
passed as an argument to another function and called there — the
receiving function calls it as a plain function, and the program hangs
or crashes. A `fn` that captures nothing can be passed freely (§3.9).
Chapter 8 covers closures in depth.

## 3.4 Conditionals

### `if`

```lisp
(if condition then-branch else-branch)
```

```lisp
(defn max-of (a b)
  (if (> a b) a b))

(defn sign (n)
  (if (> n 0) 1
    (if (< n 0) -1
      0)))
```

The else branch may be left out. Then, when the condition is false,
the `if` evaluates to 0 — fine when the `if` is only there for its
effect:

```lisp
(defn log-if-positive (n)
  (if (> n 0)
    (print n)))            ; nothing printed for n <= 0
```

There is no truthiness beyond Bool: a condition is a comparison, a
Bool, or a call that returns one.

### `cond` — Multi-Branch

```lisp
(cond
  (test1 body1)
  (test2 body2)
  (else fallback-body))
```

Evaluates the tests in order; the first true one wins, and `cond`
returns its body's value. `else` is optional but recommended — without
it, a `cond` in which no test is true evaluates to 0.

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
  (print (classify 50)))   ; large positive
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
      (set! i (+ i 1)))))
;; Output: 0, 1, 2 (one per line)
```

- Condition evaluated before each iteration
- The body may be several forms; they run in order
- Body typically uses `let-mut` + `set!` to update loop variables
- Use `while` for its effect, not its value (the specification says it
  returns `Unit`; the current compiler leaves the last body value behind)

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
      (set! j (- j 10)))))
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
Use an index with `vec-get`, or recursion over a `List`.

## 3.6 Errors

Zyl has two mechanisms, and they are for different things:

- **Expected failures are values.** A function that can fail returns a
  `Result`: `(Ok value)` or `(Err reason)`. The caller decides what to
  do with it, usually with `match` (Chapter 6).
- **`error` aborts.** `(error "message")` stops the program with
  `PANIC: message` and exit status 1 — unless a `try` is active, in
  which case control passes to its `catch`.

### Results

```lisp
(defn divide (a b)
  (if (== b 0)
    (Err "division by zero")
    (Ok (/ a b))))

(defn show-division (a b)
  (match (divide a b)
    (Ok q (print q))
    (Err msg (print-string msg))))

(defn main ()
  (show-division 10 2)     ; 5
  (show-division 1 0))     ; division by zero
```

The core library has helpers for the common cases:
`(result-unwrap r default)` and `(option-unwrap o default)` return the
value or a default, and `(result-expect r "msg")` /
`(option-expect o "msg")` return the value or call `error` with the
message.

### `error`, `try` and `catch`

```lisp
(try expr (catch err-var handler))
```

1. Evaluate `expr`. If it finishes normally, its value is the value of the `try`.
2. If `error` is called while `expr` runs (directly or in any function it calls), control passes to the handler instead, with `err-var` bound to the message string.
3. The handler's value is the value of the `try`.

```lisp
(defn percent-of-100 (n)
  (if (== n 0)
    (error "division by zero")
    (/ 100 n)))

(defn report ((msg String))
  (begin
    (print (str-concat "caught: " msg))
    -1))

(defn safe-percent (n)
  (try (percent-of-100 n)
    (catch err (report err))))

(defn main ()
  (print (safe-percent 4))      ; 25
  (print (safe-percent 0))      ; caught: division by zero, then -1
  (print "still running"))
```

Things to know about the current implementation:

- `try` does **not** unwrap a `Result`. An `(Err ...)` value is an
  ordinary value and passes straight through; only `error` (and the
  failed `assert-` forms of Chapter 11) transfer control to `catch`.
- The catch clause uses one handler expression. Write several steps as
  a `begin`, or call a function, as `report` does.
- The message is a String; pass it to a `String`-annotated function (or
  `print-string`) to print it.
- **Known bug:** if `error` is raised inside a function that was called
  with an even number of arguments (2, 4, ...), the program can hang
  instead of reaching the handler. Whether it hangs depends on the
  argument values, not only their number: with `(defn f (a b) (error
  "x"))`, `(f 1 2)`, `(f 1 0)` and `(f 1 "a")` hang, while `(f 0 1)`,
  `(f "a" 1)` and `(f (Some 1) 2)` are caught — in these tests it hangs
  when the first argument is a nonzero plain integer. Functions of 0, 1
  or 3 arguments were unaffected. Until this is fixed, prefer `Result`
  values for failures you expect to handle.

### `unwrap` and `assert`

The specification defines `(unwrap r)` and `(assert condition "message")`.
Both parse, but neither is implemented by the current code generator:
`unwrap` evaluates to 0 and `assert` does nothing. Don't rely on them.
Use `result-expect` / `option-expect` instead of `unwrap`, and an
explicit check instead of `assert`:

```lisp
(defn checked-sqrt-floor (x)
  (if (< x 0)
    (error "sqrt requires non-negative input")
    (sqrt-floor x 0)))

(defn sqrt-floor (x r)
  (if (> (* (+ r 1) (+ r 1)) x) r (sqrt-floor x (+ r 1))))

(defn main ()
  (print (checked-sqrt-floor 17)))   ; 4
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
  (print (apply-twice (fn (x) (* x 2)) 3))) ; 12
```

A named function and a non-capturing `fn` are both fine as arguments.
(Remember the closure limitation in §3.3.)

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
      (print (list-length (my-filter (fn (x) (> x 2)) xs)))))) ; 2
```

`list-sum` and `list-length` come from the core list library. The
module `collections/collections` also has ready-made `list-map`,
`list-filter` and `list-fold`.

## 3.9 Function Types

Type inference gives every function a function type — its parameter
types and its result type (in the compiler's type representation, a
`TFun` over those types). You never write one: the checker infers them,
and they appear in type errors.

The REPL's `:type` reports the types of literals and annotated
definitions; for most function applications it currently answers
*unresolved* (a known type-inference gap, see Chapter 35).

## 3.10 Scope and Shadowing

```lisp
(defn foo (x)
  (begin
    (let x 20        ; Shadows the parameter inside this let
      (print x))     ; 20
    (print x)))      ; the parameter, unchanged

(defn main ()
  (foo 10))          ; prints 20, then 10
```

There is no global mutable state: every binding is local, and there
are no top-level variables in a compiled program (Chapter 2, §2.5).

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
evaluates to 0.

`print-string`, `print-float` and `print-int` (core library) do the
same with an annotated parameter, for values whose type the code
generator cannot see (Chapter 2, §2.2).

Reading input: `read-line` is recognized by the parser but not yet
implemented by the code generator (it evaluates to 0). File I/O is in
`stdlib/io` (Chapter 12).

## 3.12 Control Flow Cheat Sheet

| Construct | Purpose | Returns |
|-----------|---------|---------|
| `(if c t e)` | Binary choice | Value of chosen branch (0 if no else and `c` false) |
| `(cond (c1 b1) ... (else be))` | Multi-way choice | Value of first matching branch |
| `(while c b...)` | Loop while true | Use for effect only |
| `(for ((v init)...) c b)` | Loop with its own variables | Use for effect only |
| `(match v arms...)` | Case analysis (Chapter 6) | Value of the matching arm |
| `(error msg)` | Abort, or jump to the nearest `catch` | Does not return |
| `(try e (catch v h))` | Intercept `error` | Value of `e`, or of `h` after an `error` |

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
- Every argument is evaluated left to right into a scratch slot before
  any argument register is loaded, so evaluating one argument can never
  clobber another

`--emit-asm` shows all of this: `zyl file.zyl --emit-asm -o file.s`.

### No Tail Calls (Yet)

Every call, including one in tail position, is emitted as `call`. The
generated entry stub runs `main` on a large dedicated stack instead,
which is what makes deep recursion practical today.

### Closure Representation

- A `fn` that captures nothing is lifted to an ordinary top-level
  function; passing it passes the function's address.
- A `fn` bound with `let` and only called directly in that `let`'s body
  is inlined at each call site (`stdlib/compiler/closure_inline.zyl`).
- A capturing `fn` that escapes becomes a heap block holding a tag, the
  code pointer and the environment. A call through a local known to hold
  one passes the environment as an extra trailing argument. A call
  through a *parameter* does not yet know to do this — the source of the
  limitation in §3.3.

### Region Interaction

- Int, Float and Bool parameters and `let` bindings live in the stack frame
- `let-mut` bindings are ordinary frame slots; `set!` overwrites the slot
- Struct and ADT values are heap-allocated unless region inference
  proves they never escape (Chapter 5)

---

**Next:** [Chapter 4: Data Structures](ch04-data-structures.md) — Structs, ADTs, collections, and pattern matching.
