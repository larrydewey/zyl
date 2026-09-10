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

(defn greet (name)
  (print "Hello, " name "!"))
```

**Parameters are always immutable** — they behave like `let` bindings. You cannot use `set!` on parameters.

### Function with Optional Type Annotations

```lisp
;; Types are inferred; annotations are optional documentation
(defn add ((a Int) (b Int)) Int
  (+ a b))
```

Syntax: `(param-name Type)` for parameters, final type after params for return type. The compiler ignores these for inference — they're checked for consistency.

### Multiple Expressions in Body

Use `begin` for multi-expression bodies:

```lisp
(defn compute (x y)
  (begin
    (print "Computing...")
    (let (sum (+ x y))
      (* sum 2))))
```

The **last expression's value is returned** — no explicit `return` keyword exists.

### `defun` — Synonym for `defn`

```lisp
(defun square (x) (* x x))    ; Same as defn
```

Both are accepted. `defn` is more common in the codebase.

## 3.2 Recursion

Zyl supports full recursion with **guaranteed tail-call optimization (TCO)**:

```lisp
(defn factorial (n)
  (if (== n 0)
    1
    (* n (factorial (- n 1)))))

;; Tail-recursive version (optimized to a loop, no stack growth)
(defn factorial-tr (n)
  (let loop ((n n) (acc 1))    ; Named let for recursion
    (if (== n 0)
      acc
      (loop (- n 1) (* acc n)))))
```

**TCO guarantee:** A call in *tail position* (last action of a function) never grows the stack. The compiler converts it to a jump.

### Mutual Recursion

```lisp
(defn even? (n)
  (if (== n 0) true (odd? (- n 1))))

(defn odd? (n)
  (if (== n 0) false (even? (- n 1))))
```

Forward references work — all functions are collected before type inference.

### Named `let` for Local Recursion

```lisp
(let loop ((n 10) (acc 1))
  (if (== n 0)
    acc
    (loop (- n 1) (* acc n))))
```

The name `loop` binds a local function — useful for tail-recursive helpers without polluting the top-level namespace.

## 3.3 Anonymous Functions (`fn` / `lambda`)

```lisp
(fn (x) (* x x))           ; Square function
(lambda (x y) (+ x y))     ; Same as fn — synonym
```

**No implicit lambda syntax** — `((x) (* x x))` is a **syntax error**. You must write `(fn (x) (* x x))` or `(lambda (x) (* x x))`.

### Closures Capture Their Environment

```lisp
(defn make-adder (n)
  (fn (x) (+ x n)))        ; Captures n from enclosing scope

(def add5 (make-adder 5))
(add5 10)                  ; 15
```

**Capture inference** (done in Phase 4):
- Read-only capture → `TCap` (shared immutable)
- Mutated capture → `TMut` (exclusive mutable)
- Escaping capture (returned, sent to actor) → Heap region

## 3.4 Conditionals

### `if` — Three-Armed Mandatory

```lisp
(if condition then-branch else-branch)
```

**Both branches required** — no two-armed `if`. If you don't need an else, use `unit`:

```lisp
(defn log-if-positive (n)
  (if (> n 0)
    (print "Positive: " n)
    unit))                 ; Else branch does nothing
```

```lisp
(defn max (a b)
  (if (> a b) a b))

(defn sign (n)
  (if (> n 0) 1
    (if (< n 0) -1
      0)))
```

### `cond` — Multi-Branch

```lisp
(cond
  (cond1 body1)
  (cond2 body2)
  (else fallback-body))
```

Evaluates conditions in order; first true wins. `else` is optional but recommended.

```lisp
(defn classify (n)
  (cond
    ((< n 0) "negative")
    ((== n 0) "zero")
    ((< n 10) "small positive")
    (else "large positive")))
```

Each clause is `(condition body)`. The condition is evaluated; if truthy, body executes and `cond` returns its value.

## 3.5 Loops

### `while` — Condition-First Loop

```lisp
(while condition body)
```

```lisp
(let-mut (i 0)
  (while (< i 10)
    (begin
      (print i)
      (set! i (+ i 1)))))
```

- Condition evaluated before each iteration
- Body typically uses `let-mut` + `set!` to update loop variables
- Returns `unit`

### `for` — Flexible Iteration with Init Bindings

```lisp
(for (init-bindings) condition body)
```

**Init bindings syntax** (from spec §12.6):

```lisp
(for () condition body)                          ; Like while (no init)
(for (i 0) (< i 10) body)                        ; Single binding with initial value
(for (i 0 j 10) (< i 10) body)                   ; Multiple bindings
(for (i) (< i 10) body)                          ; Use existing variable i (no init)
```

```lisp
;; Count 0 to 9
(for (i 0) (< i 10)
  (begin
    (print i)
    (set! i (+ i 1))))

;; Two variables
(for (i 0 j 100) (< i 10)
  (begin
    (print i " " j)
    (set! i (+ i 1))
    (set! j (- j 10))))
```

**Semantics:**
1. Evaluate init-bindings: create bindings or use existing variables
2. Evaluate condition. If false, exit loop.
3. Execute body.
4. Go to step 2.

**No iterator protocol yet** — `for` doesn't directly iterate over collections. Use recursion or `while` with index for `Vec`/`Map`. Iterator-based `for` is planned.

## 3.6 Error Handling: `try` / `catch`

Zyl uses **Result-based error handling** — no exceptions, no panic (unless `assert` fails). The `try` form is syntactic sugar for pattern matching on `Result`.

### Basic Syntax

```lisp
(try expr (catch err-var handler-expr))
```

```lisp
(defn read-number ()
  (try (read-line)
    (catch err
      (print "Read failed: " err)
      0)))        ; Returns 0 on error
```

### Semantics (Step by Step)

1. Evaluate `expr` → produces `Result<T, E>`
2. If `Ok(v)`: return `v` (the success value)
3. If `Err(e)`: bind `e` to `err-var`, evaluate `handler-expr`, return its value
4. **Both branches must have the same type** (enforced by type inference)

### Multiple Operations in Try

```lisp
(defn read-and-parse ()
  (try
    (let (line (read-line))
      (parse-int line))      ; Hypothetical parser returning Result
    (catch err
      (print "Failed: " err)
      0)))
```

The `try` body can be any expression — including `begin` with multiple statements.

### `error` — Creating Errors

```lisp
(error "something went wrong")    ; Returns (Err "something went wrong")

(defn divide (a b)
  (if (== b 0)
    (error "division by zero")
    (Ok (/ a b))))
```

### `unwrap` — Extract or Panic (Use Sparingly)

```lisp
(unwrap (Ok 42))      ; 42
(unwrap (Err "oops")) ; Runtime error: E_ASSERT_FAIL (aborts)
```

**Prefer `try/catch` or `match`** — `unwrap` is only for truly unreachable cases or quick scripts.

## 3.7 `assert` — Runtime Contracts

```lisp
(assert condition "message if false")
```

```lisp
(defn sqrt (x)
  (assert (>= x 0) "sqrt requires non-negative input")
  ;; ... implementation
)
```

Failed assertion → **runtime error `E_ASSERT_FAIL`** (program aborts unless in a `checkpoint` scope — Chapter 24).

## 3.8 No Early Returns

Zyl has **no early `return` statement**. The last expression in a function is its return value. Structure your code with:

- `if` / `cond` for branching
- `try` / `catch` for error handling
- `match` for exhaustive case analysis (Chapter 6)
- Small, focused functions

```lisp
;; Instead of early returns:
(defn process (x)
  (if (invalid? x)
    (error "invalid")
    (if (empty? x)
      default
      (compute x))))
```

## 3.9 Higher-Order Functions

Functions are first-class values. Pass them around:

```lisp
(defn apply-twice (f x)
  (f (f x)))

(defn add1 (x) (+ x 1))

(apply-twice add1 5)              ; 7
(apply-twice (fn (x) (* x 2)) 3)  ; 12
```

### Common Patterns

```lisp
;; Map over a list (List is an ADT, Chapter 4)
(defn map (f xs)
  (match xs
    Nil Nil
    (Cons x rest) (Cons (f x) (map f rest))))

;; Filter a list
(defn filter (pred xs)
  (match xs
    Nil Nil
    (Cons x rest)
      (if (pred x)
        (Cons x (filter pred rest))
        (filter pred rest))))
```

## 3.10 Function Types

Function types are written `TFun([ParamTypes...], ReturnType)` in type signatures (shown by `:type` in REPL or in error messages):

```lisp
;; Inferred type of add: TFun([Int, Int], Int)
;; Inferred type of map: TFun([TFun([T], U), List<T>], List<U>)
```

Higher-order functions work naturally with type inference.

## 3.11 Scope and Shadowing

```lisp
(def x 10)           ; Top-level constant (Global region)

(defn foo ()
  (let (x 20)        ; Shadows top-level x (new Stack binding)
    (print x)))      ; 20

(foo)
(print x)            ; 10 (top-level unchanged)
```

**No global mutation** — top-level `def` bindings are immutable constants (Global region).

## 3.12 I/O Basics

```lisp
(print "Hello")           ; Print without newline
(print "Hello" "\n")      ; Print with newline
(print 42 " " 3.14)       ; Multiple args, space-separated

(read-line)               ; Read line from stdin → Result<String, String>
```

`print` returns `unit`. `read-line` returns `Result` — handle with `try` or `match`.

## 3.13 Control Flow Cheat Sheet

| Construct | Purpose | Returns |
|-----------|---------|---------|
| `(if c t e)` | Binary choice | Value of chosen branch |
| `(cond (c1 b1) ... (else be))` | Multi-way choice | Value of first matching branch |
| `(while c b)` | Loop while true | `unit` |
| `(for (init) c b)` | Loop with init bindings | `unit` |
| `(try e (catch v h))` | Error handling | Value of `e` (if Ok) or `h` (if Err) |
| `(assert c msg)` | Runtime check | `unit` (aborts if false) |
| `(error msg)` | Create error value | `(Err msg)` |
| `(unwrap r)` | Extract or panic | Inner value of `Ok` |

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
| 7th+ | Stack (right-to-left) |

- Return value: `rax` (Int/Float/pointer), `rax`+`rdx` for 128-bit
- Callee-saved: `rbx`, `rbp`, `r12`-`r15`
- Stack alignment: 16-byte before `call`

### Tail Call Implementation

TCO is implemented as:
1. Pop caller's stack frame
2. Reuse caller's stack space for callee
3. `jmp` to callee (not `call`)

This works for:
- Direct recursive calls: `(factorial (- n 1))`
- Mutual recursion: `(even? (- n 1))` → `(odd? ...)`
- Higher-order tail calls: `(apply f args)` when `apply` is in tail position

**Limitation**: Closure calls in tail position require the closure to be in a known register — currently only direct calls and known function values are optimized.

### Closure Representation

```c
struct Closure {
    void* fn_ptr;           // Code pointer
    void* env_ptr;          // Captured environment (struct)
    CaptureMap* captures;   // Compile-time only (erased at runtime)
};
```

- Non-escaping closures: Stack-allocated env, direct call
- Escaping closures: Heap-allocated env, indirect call via `fn_ptr`

### Region Interaction

- Function parameters: Region inferred from call site
- `let-mut` bindings: Stack region (promoted to Heap if captured by escaping closure)
- Return values: Region determined by escape analysis

---

**Next:** [Chapter 4: Data Structures](ch04-data-structures.md) — Structs, ADTs, collections, and pattern matching.