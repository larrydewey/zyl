# Chapter 2: Syntax and Basic Types

Zyl's syntax is built on **S-expressions** (symbolic expressions) — parenthesized lists where the first element is an operator and the rest are operands. If you know Lisp, Scheme, or Clojure, this will feel familiar. If not, don't worry — we'll start from the ground up.

## 2.1 The Two Kinds of Expressions

Every Zyl expression is either an **atom** (a single value) or a **list** (a parenthesized sequence of expressions).

```lisp
42              ; atom (integer)
"hello"         ; atom (string)
true            ; atom (boolean)
(+ 1 2)         ; list: operator +, operands 1 and 2
(defn f (x) x)  ; list: defn, name f, params (x), body x
```

**Key rule**: *Code is data, data is code.* This is called **homoiconicity** — it enables macros (Chapter 10).

## 2.2 Atoms — The Basic Values

### Integers (`Int`)

64-bit signed integers (range: -9,223,372,036,854,775,808 to +9,223,372,036,854,775,807).

```lisp
42
-17
0
9223372036854775807    ; maximum Int
-9223372036854775808   ; minimum Int
```

**No suffixes, no octal/hex** — decimal only. For bit manipulation, use FFI.

### Floats (`Float`)

IEEE-754 binary64 (double precision). ~15-17 decimal digits of precision.

```lisp
3.14
-2.5
1.0e10      ; scientific notation: 1.0 × 10¹⁰
-0.0        ; negative zero (distinct from +0.0 in IEEE-754)
```

**No implicit conversion between Int and Float.** Use explicit coercion:
```lisp
(float 42)      ; → 42.0
(int 3.14)      ; → 3 (truncates toward zero)
```

### Booleans (`Bool`)

```lisp
true
false
```

### Strings (`String`)

UTF-8 encoded, immutable, reference-counted (Global region for constants, Heap for runtime).

```lisp
"hello"
"line 1\nline 2"          ; escape sequences: \n \t \\ \" 
"quoted \"string\""       ; escaped quote
"Unicode: 你好 🌍"        ; full Unicode support
```

**String concatenation**: Use `buf-append` (requires mutable buffer) or build via FFI. No `+` operator for strings.

### Symbols

Symbols are identifiers used *as data* (not evaluated as variables):

```lisp
'foo          ; quoted symbol
'some-name
'+            ; the symbol +, not the function
```

Used for: variant names in ADTs, field names in some contexts, macro metaprogramming.

### Keywords

Self-evaluating, colon-prefixed identifiers:

```lisp
:parallel
:filter
:expect-error
```

Used for: test options, contract profiles, module import modifiers.

### The Unit Value (`Unit`)

```lisp
unit
```

Represents "no meaningful value" — like `()` in Rust, `void` in C, `None` in Python. Returned by side-effecting operations like `print`.

```lisp
(print "hello")   ; returns unit
```

## 2.3 Lists — The Universal Structure

A list is zero or more expressions enclosed in parentheses:

```lisp
()                          ; empty list
(+ 1 2 3)                   ; function call
(defn square (x) (* x x))   ; function definition
(let (x 10) x)              ; local binding
```

**Everything is a list.** This uniformity is what makes macros possible.

### Evaluation Rule (Critical!)

> **Strict left-to-right evaluation, always.**
>
> In `(f a b c)`:
> 1. Evaluate `f` (the operator)
> 2. Evaluate `a` (first argument)
> 3. Evaluate `b` (second argument)
> 4. Evaluate `c` (third argument)
> 5. Apply the function to the arguments

```lisp
(print (begin (print "first") 1) (begin (print "second") 2))
;; Output:
;; first
;; second
;; 1 2
```

**No operator precedence.** Parentheses are never optional — they *are* the grouping.

## 2.4 Comments

```lisp
; This is a line comment
(defn foo () ; inline comment
  42)
```

Only line comments (`;`) exist. No block comments (`/* */` or `#| |#`).

## 2.5 Variables and Bindings

### Top-Level Constants (`def`)

```lisp
(def pi 3.14159)           ; Global region, immutable
(def app-name "MyApp")     ; String constant
(def max-size 1000)        ; Int constant
```

- Evaluated once at program startup
- Stored in **Global region** (immutable, eagerly initialized)
- Cannot be mutated — no `set!` on `def` bindings

### Local Immutable Bindings (`let`)

```lisp
(let (x 10)                ; Creates new binding x = 10 (Stack region)
  (print x))               ; x is immutable within this scope

;; Shadowing is allowed (new binding hides outer one)
(let (x 10)
  (let (x 20)              ; New x, shadows outer x
    (print x))             ; prints 20
  (print x))               ; prints 10 (outer x unchanged)
```

- Scope: from the `let` to the end of its body
- Value evaluated once, bound to name
- **Immutable** — cannot use `set!` on `let` bindings

### Local Mutable Bindings (`let-mut`)

```lisp
(let-mut (counter 0)       ; Creates mutable binding
  (set! counter (+ counter 1))  ; Rebinding (not in-place mutation!)
  (print counter))         ; prints 1
```

- `set!` **rebinds** the name to a new value — it does *not* mutate the old value in place
- The old value becomes unreachable (region system reclaims it)
- Use sparingly — prefer immutable `let` and recursion

### Multiple Bindings

```lisp
;; Sequential let (each can refer to previous)
(let (x 10)
  (let (y (+ x 5))
    (+ x y)))               ; 25

;; Parallel let (all evaluated in outer scope)
(let (x 10 y 20 z 30)      ; All three evaluated before any binding
  (+ x y z))               ; 60
```

**Zyl uses parallel let semantics** — all initializers evaluate in the *outer* scope, then bindings are created simultaneously. This avoids ordering dependencies.

## 2.6 Function Calls and Core Operations

### Arithmetic (n-ary, left-associative)

```lisp
(+ 1 2 3 4)        ; 10     (1 + 2 + 3 + 4)
(- 10 3 2)         ; 5      (10 - 3 - 2)
(* 2 3 4)          ; 24     (2 * 3 * 4)
(/ 20 2 2)         ; 5      (20 / 2 / 2)
(% 17 5)           ; 2      (remainder, sign follows dividend)
```

**Unary forms** (single argument):
```lisp
(+ 5)       ; 5   (identity)
(- 5)       ; -5  (negation)
(* 5)       ; 5   (identity)
(/ 5)       ; Error — division requires at least 2 args
```

### Comparison (return `Bool`)

```lisp
(== 1 1)           ; true   (structural equality)
(!= 1 2)           ; true
(< 1 2)            ; true
(> 2 1)            ; true
(<= 1 1)           ; true
(>= 1 2)           ; false
```

Works on: `Int`, `Float`, `Bool`, `String`, and **structurally** on `Vec`, `Map`, `Struct`, `ADT`, `Tuple`.

### Boolean Logic (short-circuiting)

```lisp
(and true false true)     ; false  (stops at first false)
(or false true false)     ; true   (stops at first true)
(not true)                ; false
```

`and`/`or` are **macros** that expand to `if` — they don't evaluate all arguments.

### Type Predicates (runtime checks)

```lisp
(int? 42)           ; true
(float? 3.14)       ; true
(bool? true)        ; true
(string? "hi")      ; true
(struct? (make-Point 1 2))  ; true (requires struct in scope)
(alias? (MyAlias 42))        ; true (requires alias in scope)
```

## 2.7 Core Data Structures

### Vectors (`Vec<T>`) — via `stdlib/collections/vec.zyl`

Growable contiguous arrays. O(1) indexing (bounds-checked at runtime).

```lisp
(use collections/vec { vec-create vec-push vec-get vec-len vec-cap })

(def v (vec-create 0 10))   ; Create empty vec with capacity 10
(vec-push v 42)             ; Add element, returns new vec
(vec-get v 0)               ; Get element at index (returns -1 if OOB)
(vec-len v)                 ; Number of elements
(vec-cap v)                 ; Allocated capacity
```

**No literal syntax** — build programmatically. Literal syntax is planned.

### Maps (`Map<K,V>`) — via `stdlib/collections/map.zyl`

Hash maps with **deterministic iteration order** (sorted by key hash).

```lisp
(use collections/map { map-create map-put map-get map-len map-has map-remove })

(def m (map-create 0 10))   ; Create empty map with capacity 10
(map-put m "key" 42)        ; Insert, returns new map
(map-get m "key" 0)         ; Get value (returns default 0 if missing)
(map-has m "key")           ; true if key exists
(map-remove m "key")        ; Remove key, returns new map
```

### Tuples (`Tuple<T...>`)

Anonymous fixed-size product types.

```lisp
(tuple 1 "hello" 3.14)     ; Tuple<Int, String, Float>
(tuple)                    ; Same as unit
```

Access via pattern matching (Chapter 6).

### Result Type — `Result<T, E>`

Error handling without exceptions. Defined in `stdlib/core/result.zyl`:

```lisp
(Ok 42)                 ; Success containing 42
(Err "file not found")  ; Failure containing error message
```

Built-ins that can fail return `Result`:
- `read-line` → `Result<String, String>`
- `file-open` → `Result<Handle, String>`

Handle with `try/catch` (Chapter 3) or `match` (Chapter 6).

### Option Type — `Option<T>`

Represents optional values. Defined in `stdlib/core/option.zyl`:

```lisp
(Some 42)    ; Value present
None        ; No value
```

## 2.8 The `begin` Form — Sequencing

```lisp
(begin
  (print "Step 1")
  (print "Step 2")
  42)                    ; Returns value of LAST expression
```

Use `begin` whenever you need multiple expressions where only one is allowed (function body, `if` branch, `let` body, etc.).

## 2.9 Quoting — Data vs Code

```lisp
'(+ 1 2)        ; List data: three elements [symbol '+, int 1, int 2]
(+ 1 2)         ; Code: evaluates to 3
```

Quoting prevents evaluation. Essential for macros (Chapter 10).

## 2.10 Reserved Keywords (Cannot Be Used as Identifiers)

These words are reserved and cause **compile error `E_RESERVED_KEYWORD`** if used as variable names, function names, or type names:

```
def, defn, defun, let, let-mut, if, try, catch, spawn, send,
ffi-call, ffi-pin, ffi-unpin, assert, trait, impl, fn, lambda,
while, for, cond, begin, pub, use, export, requires, ensures,
invariant, recover, checkpoint, contracts, defmacro, alias,
defstruct, defstruct+, with-resource, derive, unwrap, error,
Ok, Err, match, struct-get, make-, test-suite, test,
assert-equal, assert-fail, assert-true, assert-false,
test-property, setup, teardown, run-tests, test-compile
```

## 2.11 Style Conventions

| Category | Convention | Example |
|----------|------------|---------|
| Functions | `kebab-case` | `factorial`, `read-file` |
| Types (structs, ADTs) | `PascalCase` | `Point`, `Result`, `MyType` |
| ADT Variants | `PascalCase` | `Some`, `None`, `Ok`, `Err` |
| Constants | `UPPER_SNAKE` | `MAX_SIZE`, `DEFAULT_TIMEOUT` |
| Variables/params | `kebab-case` | `user-count`, `file-handle` |
| Type parameters | `UpperCase` | `T`, `K`, `V`, `Element` |

**Indentation**: 2 spaces. For complex forms, put each open paren on its own line at the correct indent (C-style block formatting — see `skills/zyl/SKILL.md`).

## 2.12 Quick Reference Card

```lisp
;; Literals
42              ; Int
3.14            ; Float
true / false    ; Bool
"hello"         ; String
unit            ; Unit

;; Bindings
(def name expr)                 ; Top-level constant (Global)
(let (name expr) body)          ; Local immutable (Stack)
(let-mut (name expr) body)      ; Local mutable (Stack, use set!)

;; Control (details in Chapter 3)
(if cond then else)
(cond (cond1 body1) (cond2 body2) (else body))
(while cond body)
(for (bindings) cond body)

;; Functions (details in Chapter 3)
(defn name (params) body)
(fn (params) body)              ; Anonymous closure
(lambda (params) body)          ; Same as fn

;; Data structures
(vec-create init cap)           ; Vec (via collections/vec)
(map-create init cap)           ; Map (via collections/map)
(tuple elem...)                 ; Tuple
(Ok val) / (Err err)            ; Result
(Some val) / None               ; Option

;; Operations
(+ - * / %)                     ; Arithmetic
(== != < > <= >=)               ; Comparison
(and or not)                    ; Boolean
(set! var value)                ; Rebinding (let-mut only)
(print expr...)                 ; Output to stdout
(struct-get struct "field")     ; Struct field access
```

---

## For Experts: Under the Hood

### Representation

| Type | Representation | Region |
|------|----------------|--------|
| `Int` | 64-bit tagged (LSB=1) | Stack/Heap |
| `Float` | 64-bit IEEE-754 (boxed) | Stack/Heap |
| `Bool` | Tagged immediate | Stack/Heap |
| `String` | Ref-counted ptr to UTF-8 bytes | Global (const) / Heap |
| `Vec<T>` | `{ ptr, len, cap }` | Heap |
| `Map<K,V>` | Hash array + metadata | Heap |
| `Struct` | Contiguous fields | Stack/Heap |
| `ADT` | Tag + payload (variant-dependent) | Stack/Heap |
| `Closure` | `{ fn_ptr, env_ptr, capture_map }` | Heap (if escaping) |

### Determinism Guarantees

- All collections use **FNV-1a hashed ordered maps** (`deterministic.rs`)
- Map iteration: sorted by key hash (not insertion order)
- No `HashMap`/`HashSet` with random seeds — ever
- Same source → identical memory layout → identical binary

### Region Assignment (Preview)

| Value | Default Region | Can Escape To |
|-------|----------------|---------------|
| Local `let` | Stack | Heap (if captured/returned) |
| `def` constant | Global | Never |
| `vec-create` | Heap | Heap |
| Closure | Stack (if non-escaping) | Heap (if escaping) |
| FFI arg | Pin (via `ffi-pin`) | Pin only |

Details in [Chapter 5](ch05-ownership-regions-capabilities.md).

---

**Next:** [Chapter 3: Functions and Control Flow](ch03-functions-and-control-flow.md) — defining functions, recursion, conditionals, loops, and error handling.