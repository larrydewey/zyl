# Chapter 6: Pattern Matching and Error Handling

Pattern matching is Zyl's primary control flow for structured data. Combined with ADTs and the `Result`/`Option` types, it replaces exceptions, null checks, and most `if` chains.

## 6.1 The `match` Expression

```lisp
(match scrutinee
  (Variant1 pattern1 body1)
  (Variant2 pattern2 body2)
  ...)
```

- **Scrutinee**: The value being matched (evaluated once)
- **Patterns**: Match against ADT variants, bind variables
- **Bodies**: Expressions — all must have the same type
- **Exhaustiveness**: **Mandatory** — missing variant = compile error `E_MATCH_NONEXHAUSTIVE`

### Basic Example

```lisp
(deftype Option (Some T) None)

(defn describe (opt)
  (match opt
    (Some x (print "Got: " x))
    (None (print "Nothing"))))
```

### Match as Expression (Returns a Value)

```lisp
(defn option-to-result (opt)
  (match opt
    (Some x (Ok x))
    (None (Err "empty"))))
```

Every arm must return the **same type** (enforced by type inference).

## 6.2 Patterns in Detail

### Variant Patterns

```lisp
(deftype Result (Ok T) (Err E))
(deftype Shape (Circle Float) (Rectangle Float Float))

(match result
  (Ok value (print "Success: " value))
  (Err msg (print "Error: " msg)))

(match shape
  (Circle r (print "Circle radius " r))
  (Rectangle w h (print "Rect " w "x" h)))
```

### Binding Patterns

```lisp
;; Bind entire variant
(match opt
  (Some x x)          ; x = inner value
  (None 0))

;; Bind with nested pattern
(match (Cons 1 (Cons 2 Nil))
  (Cons x (Cons y d1) (+ x y))  ; x=1, y=2, d1=Nil (ignored)
  (Nil 0))
```

### Wildcard Patterns (Named Dummies Only!)

```lisp
;; ✅ CORRECT — named dummy
(match opt
  (Some d1 0)    ; Ignore value, return 0
  (None 0))

;; ❌ FORBIDDEN — bare underscore
(match opt
  (Some _ 0)     ; Parse error: E_RESERVED_KEYWORD or similar
  (None 0))
```

**Rule**: Wildcards must be named (`d1`, `d2`, `ignored`, etc.). This ensures every bound name is intentional and improves error messages.

### Literal Patterns (Constants)

```lisp
(match status
  200 (print "OK")
  404 (print "Not Found")
  500 (print "Server Error")
  d1 (print "Other: " d1))  ; Catch-all (exhaustive)
```

Integers, strings, booleans can be matched directly.

## 6.3 Exhaustiveness Checking

The compiler **requires** all variants to be covered:

```lisp
(deftype TrafficLight (Red) (Yellow) (Green))

;; ❌ COMPILE ERROR: E_MATCH_NONEXHAUSTIVE — missing Yellow, Green
(match light
  (Red (print "Stop")))

;; ✅ OK — all covered
(match light
  (Red (print "Stop"))
  (Yellow (print "Caution"))
  (Green (print "Go")))

;; ✅ OK — catch-all with named dummy
(match light
  (Red (print "Stop"))
  (d1 (print "Not red")))
```

**No "default" or "otherwise" keyword** — use a named dummy as the last arm.

## 6.4 Nested Matching

```lisp
(deftype Expr
  (Add Expr Expr)
  (Mul Expr Expr)
  (Val Int))

(defn eval (e)
  (match e
    (Add (Val x) (Val y) (Val (+ x y)))        ; Constant folding
    (Add x y (Add (eval x) (eval y)))          ; Recurse
    (Mul (Val x) (Val y) (Val (* x y)))
    (Mul x y (Mul (eval x) (eval y)))
    (Val x x)))
```

Patterns can be arbitrarily nested. The compiler flattens them efficiently.

## 6.5 Match in Value Position

`match` is an expression — use it anywhere:

```lisp
(defn format-result (r)
  (print "Result: "
    (match r
      (Ok v v)
      (Err e "ERROR: " e))))

(let x (match (read-line)
      (Ok line line)
      (Err _ "default"))
  (print x))
```

## 6.6 Error Handling with `Result`

Zyl has **no exceptions**. Errors are values — `Result<T, E>`.

```lisp
(deftype Result (Ok T) (Err E))
```

### Creating Results

```lisp
(Ok 42)                 ; Success
(Err "file not found")  ; Failure
(error "msg")           ; Shorthand for (Err "msg")
```

### Handling with `match`

```lisp
(defn read-config (path)
  (match (read-file path)
    (Ok contents (parse-contents contents))
    (Err msg (default-config))))
```

### Handling with `try` / `catch` (Syntactic Sugar)

```lisp
(try expr (catch err-var handler))
```

Expands to:
```lisp
(match expr
  (Ok v v)
  (Err err-var handler))
```

**Use `try/catch` for simple cases, `match` for complex logic.**

```lisp
;; Simple: try/catch
(defn read-number ()
  (try (read-line)
    (catch err
      (print "Read failed: " err)
      0)))

;; Complex: match
(defn read-number-detailed ()
  (match (read-line)
    (Ok line (match (parse-int line)
      (Ok n n)
      (Err _ 0)))
    (Err err
      (print "Read failed: " err)
      0)))
```

## 6.7 The `Option` Type — Avoiding Null

```lisp
(deftype Option (Some T) None)
```

**No null in Zyl.** Use `Option` for "maybe a value."

```lisp
(defn find-user (id)
  (match (db-query id)
    (Some user user)
    (None (error "not found"))))
```

### Common Option Patterns

```lisp
;; Map: transform if present
(map (fn (x) (* x 2)) (Some 21))  ; (Some 42)
(map (fn (x) (* x 2)) None)       ; None

;; Default value
(match opt
  (Some x x)
  (None default))

;; Chain operations
(defn process (opt)
  (match opt
    (Some x (Some (+ x 1)))
    (None None)))
```

## 6.8 `Result` Chaining Patterns

```lisp
;; Sequential operations that can fail
(defn read-and-validate (path)
  (match (read-file path)
    (Ok content (match (parse content)
      (Ok data (match (validate data)
        (Ok _ (Ok data))
        (Err e (Err e))))
      (Err e (Err e)))
    (Err e (Err e))))
```

**Flatten with helper** (stdlib `result.zyl`):
```lisp
(use result { bind })  ; bind : Result<T,E> → (T → Result<U,E>) → Result<U,E>

(defn read-and-validate (path)
  (bind (read-file path) (fn (content)
    (bind (parse content) (fn (data)
      (validate data))))))
```

## 6.9 `assert` — Runtime Contracts

```lisp
(assert condition "message if false")
```

```lisp
(defn sqrt (x)
  (assert (>= x 0) "sqrt requires non-negative input")
  ;; ... implementation
)
```

- Failed assertion → **runtime error `E_ASSERT_FAIL`** (aborts)
- Use for **internal invariants**, not expected errors
- Expected errors → `Result`/`Option`

## 6.10 `unwrap` — Extract or Panic

```lisp
(unwrap (Ok 42))      ; 42
(unwrap (Err "oops")) ; Runtime error: E_ASSERT_FAIL
```

**Use only when:**
- You have a proof the error is impossible
- Quick scripts / REPL exploration
- Test code

**Prefer** `match`, `try/catch`, or `bind`.

## 6.11 Error Handling Cheat Sheet

| Situation | Recommended Approach |
|-----------|---------------------|
| Expected failure (I/O, parsing) | `Result` + `match`/`try` |
| Optional value | `Option` + `match`/`map` |
| Internal invariant violation | `assert` |
| Truly impossible case (proven) | `unwrap` |
| Multiple error types | `Result` with ADT error enum |
| Resource cleanup | `with-resource` (Chapter 12) |

## 6.12 Matching on Structs and Tuples

Structs and tuples can be matched via their fields:

```lisp
(defstruct Point (x) (y))

(match p
  (Point 0 0 (print "Origin"))
  (Point x y (print "Point " x " " y)))

(match (tuple 1 2 3)
  (Tuple a b c (+ a b c)))
```

## 6.13 Guards (Not Yet Implemented)

Pattern guards (`when` clauses) are **not yet implemented**. Use nested `match` or `if` in the arm body:

```lisp
;; Instead of: (match x (Some y when (> y 0) ...))
(match x
  (Some y (if (> y 0) ... (match x (Some _ ...)))))
```

---

## For Experts: Under the Hood

### Match Compilation

1. **Pattern matrix** — rows = arms, columns = pattern positions
2. **Decision tree** — compiles to efficient jump table
3. **Discriminant-based** — ADTs have single-byte tag
4. **Exhaustiveness** — verified by checking matrix coverage

```lisp
;; Compiles roughly to:
;; load tag from scrutinee
;; jump table on tag
;; for each variant: extract fields, jump to arm body
```

### No Fallthrough

Each arm is independent — no implicit fallthrough. This eliminates a class of bugs.

### Type Refinement

Inside each arm, the scrutinee type is refined to that variant:

```lisp
(match opt
  (Some x 
    ;; Here: opt : Option<T>, x : T
    ;; opt is known to be Some
    x)
  (None 
    ;; Here: opt : Option<T>, known to be None
    0))
```

### Region Interaction

- Matched value: region preserved
- Bound variables: inherit region from matched fields
- `match` itself: region of the returned value (join of arm regions)

---

**Next:** [Chapter 7: Generics and Traits](ch07-generics-and-traits.md) — parametric polymorphism, trait system, and derivation.