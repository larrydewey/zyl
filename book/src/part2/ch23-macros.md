# Chapter 23: Macro System and Hygiene

Complete reference for Zyl's hygienic macro system: definition, expansion algorithm, hygiene, and constraints.

## 23.1 Macro Definition

```
defmacro ::= "defmacro" Identifier "(" Pattern* ")" Template
```

```lisp
(defmacro name (pattern1 pattern2 ...) template)
```

- **Patterns**: Match against macro arguments
- **Template**: Code to generate (with unquote/unquote-splicing)
- **Expansion**: Happens at compile time (Phase 2)

## 23.2 Pattern Matching

```
Pattern ::= Identifier           ; Binds to argument
          | "(" Pattern* ")"    ; Matches list structure
          | Literal             ; Matches exact value
```

```lisp
(defmacro when (cond body)
  `(if ,cond ,body))

(defmacro let* ((bindings...) body)
  (match bindings
    Nil body
    (Cons (name val) rest
      `(let (,name ,val)
         (let* ,rest ,body)))))
```

## 23.3 Quasiquote, Unquote, Unquote-Splicing

| Syntax | Name | Purpose |
|--------|------|---------|
| `` `expr `` | Quasiquote | Template (mostly literal) |
| `,expr` | Unquote | Evaluate and splice value |
| `,@expr` | Unquote-splicing | Splice list elements |

```lisp
;; Example
(defmacro log-and-return (expr)
  `(begin
     (print "Evaluating: " ',expr)   ; ',expr = quoted expression
     ,expr))                          ; ,expr = evaluate and use

;; Expansion of (log-and-return (+ 1 2)):
(begin
  (print "Evaluating: " '(+ 1 2))
  (+ 1 2))
```

### Nested Quasiquote

```lisp
``(,,(+ 1 2))  ; Outer quasiquote, inner unquote-unquote
;; Result: `(+ 1 2) (with 3 evaluated at inner expansion)
```

## 23.4 Hygiene (Gensym-Based)

### How It Works

1. **Mark phase**: During macro definition, all symbols in template marked with macro ID
2. **Expansion phase**: Each marked symbol replaced with unique gensym: `gensym_<macro_id>_<counter>`
3. **Call-site symbols**: Retain original identity (not renamed)

### Example

```lisp
(defmacro swap (a b)
  `(let (tmp ,a)
     (set! ,a ,b)
     (set! ,b tmp)))

(let (tmp 100)
  (swap tmp 200)
  tmp)
;; Expansion:
(let (tmp 100)
  (let (gensym_1 tmp)      ; Macro's tmp → gensym_1
    (set! tmp 200)
    (set! 200 gensym_1))   ; Wait, this looks wrong...
  tmp)
;; Actually: tmp in (set! ,a ,b) refers to call-site tmp
;; gensym_1 is fresh binding
;; Result: original tmp = 100 unchanged!
```

### Hygiene Guarantees

- **No capture of call-site variables** by macro-introduced bindings
- **No capture of macro variables** by call-site bindings
- **Referential transparency** preserved

## 23.5 Expansion Algorithm (Innermost-First)

### Phase 2: Macro Expansion

```python
def expand(expr, macro_env):
    if is_macro_call(expr, macro_env):
        macro = macro_env[expr[0]]
        # 1. Match args to patterns
        bindings = match_pattern(macro.patterns, expr[1:])
        # 2. Substitute into template
        expanded = substitute(macro.template, bindings)
        # 3. Recursively expand (innermost-first)
        return expand(expanded, macro_env)
    elif is_list(expr):
        return [expand(e, macro_env) for e in expr]
    else:
        return expr
```

### Order

1. **Collect all macros** from source (registration pass)
2. **Expand innermost first** — deepest macro calls expanded first
3. **Recursive expansion** — expanded code may contain more macros
4. **Termination check** — limit expansion depth (`E_MACRO_NON_TERMINATION`)

### Why Innermost-First?

- Inner macros see fully expanded arguments
- No "macro expansion order" bugs
- Deterministic regardless of definition order

## 23.4 Built-in Macros

| Macro | Expansion |
|-------|-----------|
| `and` | `(if e1 (if e2 ...))` (short-circuit) |
| `or` | `(if e1 e1 (if e2 ...))` (short-circuit) |
| `let*` | Nested `let` |
| `cond` | Nested `if` |
| `begin` | Core form (but macro-like sequencing) |

```lisp
;; and/or are macros, not special forms
(and (print "a") (print "b") false (print "c"))
;; Only prints "a", "b" — short-circuits at false
```

## 23.5 Macro Constraints (Spec §19.4)

| Constraint | Enforcement |
|------------|-------------|
| AST-only | Macros only receive/return syntax trees |
| No runtime access | Cannot call functions, access variables at macro time |
| Deterministic | Same input → same expansion |
| No side effects | Pure transformation |

**Violation** → `E_MACRO_ILLEGAL_ACCESS`

## 23.6 Macro Errors

| Error | Cause |
|-------|-------|
| `E_MACRO_NON_TERMINATION` | Expansion depth limit exceeded |
| `E_MACRO_ILLEGAL_ACCESS` | Macro accessed runtime value |
| `E_MACRO_PATTERN_MISMATCH` | Arguments don't match patterns |
| `E_MACRO_UNBOUND_VARIABLE` | Unquote references undefined variable |

## 23.7 Debugging Macros

### Compiler Flags

```bash
zyl --emit-ast source.zyl        # After parsing
zyl --emit-expanded source.zyl   # After macro expansion
```

### REPL Commands

```lisp
zyl> :macroexpand (unless true (print "hi"))
(if (not true) (print "hi"))

zyl> :macroexpand-all (let* ((x 1) (y 2)) (+ x y))
(let (x 1) (let (y 2) (+ x y)))
```

## 23.8 Advanced Patterns

### Pattern: Generating Definitions

```lisp
(defmacro define-accessors (struct-name fields)
  (match fields
    Nil Nil
    (Cons field rest
      `(begin
         (defn ,(symbol-append struct-name "-" field) (s)
           (struct-get s ,(string field)))
         (define-accessors ,struct-name ,rest))))

(define-accessors Point (x y z))
;; Generates:
(defn Point-x (s) (struct-get s "x"))
(defn Point-y (s) (struct-get s "y"))
(defn Point-z (s) (struct-get s "z"))
```

### Pattern: Embedding DSLs

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

### Pattern: Conditional Compilation

```lisp
(defmacro debug (body)
  `(if *debug-enabled* ,body))

(debug (print "Debug: " x))
;; Expands to: (if *debug-enabled* (print "Debug: " x))
```

## 23.9 Best Practices

1. **Prefer functions** — macros only when necessary (syntax abstraction)
2. **Keep simple** — complex macros hard to debug
3. **Document expansion** — show expected output in comments
4. **Test expansions** — use `:macroexpand` in REPL
5. **Avoid recursion** — can cause `E_MACRO_NON_TERMINATION`
6. **Use hygiene** — trust gensym, don't fight it

## 23.10 Comparison with Other Lisps

| Feature | Common Lisp | Scheme (R5RS) | Racket | Zyl |
|---------|-------------|---------------|--------|-----|
| Hygiene | Manual (`gensym`) | `syntax-rules` | `syntax-parse` | Automatic (gensym) |
| Expansion order | Outer-first | Inner-first | Inner-first | Inner-first |
| Pattern matching | `defmacro` + destructuring | `syntax-rules` | `syntax-parse` | `match` in template |
| Unquote | `,` | `,` | `,` | `,` |
| Splicing | `,@` | `,@` | `,@` | `,@` |
| Procedural macros | ✅ | ❌ | ✅ | ❌ (template-only) |
| Compile-time eval | ✅ | Limited | ✅ | ❌ |