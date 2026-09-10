# Chapter 10: Macros and Metaprogramming

Macros let you write code that writes code. Zyl's macros are **hygienic** (no variable capture), **innermost-first** expansion, and **deterministic**.

## 10.1 What Are Macros?

A macro is a compile-time function that transforms syntax:

```lisp
(defmacro name (pattern...) template)
```

When you write `(name args...)`, the compiler:
1. Matches `args` against `pattern`
2. Binds pattern variables
3. Substitutes into `template`
4. Expands the result (recursively, innermost-first)

## 10.2 Defining Macros

### Basic Syntax

```lisp
(defmacro unless (cond body)
  `(if (not ,cond) ,body))

(defmacro when (cond body)
  `(if ,cond ,body))
```

### Backquote and Unquote

| Syntax | Meaning |
|--------|---------|
| `` `expr `` | **Quasiquote** — template, mostly literal |
| `,expr` | **Unquote** — evaluate and splice in |
| `,@expr` | **Unquote-splicing** — splice list elements |

```lisp
;; Example:
(defmacro log-and-return (expr)
  `(begin
     (print "Evaluating: " ',expr)   ; ',expr = quoted expression
     ,expr))                          ; ,expr = evaluate and use value

(log-and-return (+ 1 2))
;; Expands to:
(begin
  (print "Evaluating: " '(+ 1 2))
  (+ 1 2))
```

### Pattern Matching in Macros

```lisp
(defmacro let* ((bindings...) body)
  (match bindings
    Nil body
    (Cons (name val) rest
      `(let (,name ,val)
         (let* ,rest ,body)))))

(let* ((x 1) (y 2) (z 3))
  (+ x y z))
;; Expands to nested lets
```

## 10.3 Hygiene — No Variable Capture

Zyl uses **gensym-based hygiene**. Macro-introduced variables are renamed to unique symbols.

```lisp
(defmacro swap (a b)
  `(let (tmp ,a)
     (set! ,a ,b)
     (set! ,b tmp)))

(let (tmp 100)
  (swap tmp 200)
  tmp)
;; Expands to something like:
(let (tmp 100)
  (let (gensym_123 tmp)
    (set! tmp 200)
    (set! 200 gensym_123))
  tmp)
;; Result: tmp = 100 (unchanged!)
```

The `tmp` in the macro becomes `gensym_123` — no collision with user's `tmp`.

### How Hygiene Works

1. **Macro definition scope**: Variables in template are marked as "macro-introduced"
2. **Expansion time**: Each macro-introduced variable gets a unique gensym
3. **User variables**: Variables from macro call site keep their identity
4. **Result**: No accidental capture in either direction

## 10.4 Innermost-First Expansion

Macros expand from the inside out:

```lisp
(defmacro m1 (x) `(m2 ,x))
(defmacro m2 (x) `(+ ,x 1))

(m1 (m1 5))
;; Expansion order:
;; 1. Innermost (m1 5) → (m2 5)
;; 2. (m2 5) → (+ 5 1) → 6
;; 3. Outer (m1 6) → (m2 6)
;; 4. (m2 6) → (+ 6 1) → 7
```

This ensures:
- Inner macros see fully expanded arguments
- No "macro expansion order" bugs
- Deterministic expansion

## 10.5 Macro Registration

Macros are collected **before expansion** (Phase 2):
- All `defmacro` forms found in source
- Registered in macro environment
- Then expansion pass runs

```lisp
;; This works — macro defined before use
(defmacro double (x) `(+ ,x ,x))
(double 5)  ; 10

;; This also works — macro collected before expansion pass
(double 5)
(defmacro double (x) `(+ ,x ,x))
```

## 10.6 Common Macro Patterns

### Pattern: Conditional Compilation

```lisp
(defmacro debug (body)
  `(if *debug-enabled* ,body))

(debug (print "Debug info"))
;; Expands to: (if *debug-enabled* (print "Debug info"))
```

### Pattern: Code Generation

```lisp
(defmacro define-accessors (struct-name fields)
  (match fields
    Nil Nil
    (Cons field rest
      `(begin
         (defn ,(symbol-append struct-name "-" field) (s)
           (struct-get s ,(string field)))
         (define-accessors ,struct-name ,rest))))

(define-accessors Point (x y))
;; Generates:
(defn Point-x (s) (struct-get s "x"))
(defn Point-y (s) (struct-get s "y"))
```

### Pattern: DSL Embedding

```lisp
(defmacro html (elements...)
  `(string-append
    ,@(map (fn (el)
      (match el
        ((tag attrs... children...)
          `(string-append "<" ,tag ">" ,@children "</" ,tag ">"))
        (text text)))
    elements)))

(html
  (div (class "container")
    (h1 "Hello")
    (p "World")))
```

## 10.7 Macro Constraints (Spec §19.4)

| Constraint | Enforcement |
|------------|-------------|
| AST-only | Macros only receive/return syntax trees |
| No runtime access | Cannot call functions, access variables at macro time |
| Deterministic | Same input → same expansion |
| No side effects | Pure transformation |

Violating these → compile error `E_MACRO_ILLEGAL_ACCESS`.

## 10.8 Built-in Macros

Zyl provides several built-in macros:

| Macro | Expansion |
|-------|-----------|
| `and` | `(if e1 (if e2 ...))` (short-circuit) |
| `or` | `(if e1 e1 (if e2 ...))` (short-circuit) |
| `let*` | Nested `let` |
| `cond` | Nested `if` |
| `begin` | Sequencing (core form, but macro-like) |

```lisp
;; and/or are macros, not special forms
(and (print "a") (print "b") false (print "c"))
;; Only prints "a", "b" — short-circuits at false
```

## 10.9 Debugging Macros

Use compiler flags to see expansions:

```bash
zyl --emit-ast source.zyl     # After parsing
zyl --emit-expanded source.zyl # After macro expansion (if flag exists)
```

In REPL:
```lisp
zyl> :macroexpand (unless true (print "hi"))
(if (not true) (print "hi"))
```

## 10.10 Macro Best Practices

1. **Keep macros simple** — prefer functions when possible
2. **Document expansion** — show what macro expands to
3. **Use gensym for internal bindings** — though hygiene handles most
4. **Test expansions** — verify with `:macroexpand`
5. **Avoid recursive macros** — can cause `E_MACRO_NON_TERMINATION`

```lisp
;; Good: simple, clear expansion
(defmacro unless (cond body)
  `(if (not ,cond) ,body))

;; Avoid: complex recursive macro
(defmacro complicated ...)
```

---

## For Experts: Under the Hood

### Macro Expansion Algorithm

```python
def expand(expr, macro_env):
    if is_macro_call(expr, macro_env):
        macro = macro_env[expr[0]]
        # 1. Match args to pattern
        bindings = match_pattern(macro.pattern, expr[1:])
        # 2. Substitute into template
        expanded = substitute(macro.template, bindings)
        # 3. Recursively expand (innermost-first)
        return expand(expanded, macro_env)
    elif is_list(expr):
        # Expand each element
        return [expand(e, macro_env) for e in expr]
    else:
        return expr
```

### Hygiene Implementation

1. **Mark phase**: Walk template, mark all symbols as "macro-introduced" with macro ID
2. **Gensym phase**: During expansion, replace each macro-introduced symbol with `gensym_<macro_id>_<counter>`
3. **Scope preservation**: Call-site symbols keep their original identity

### Determinism

- Gensym counter is deterministic (not random)
- Expansion order fixed (innermost-first)
- Pattern matching deterministic (ordered patterns)
- Same source → identical expanded AST

---

**Next:** [Chapter 11: Testing and Property-Based Testing](ch11-testing.md) — built-in test framework, assertions, and property-based testing.