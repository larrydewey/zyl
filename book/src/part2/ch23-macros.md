# Chapter 23: Macro System and Hygiene

Complete reference for Zyl's macro system: definition, substitution, expansion order, and the hygiene and termination rules the specification requires.

The normative text is spec v5.0 §19. The implementation is `stdlib/compiler/macro_expand.zyl`, which runs after module resolution and before the static checks and type inference (see Chapter 26). This chapter documents the implementation and marks where it is narrower than §19: parameters are plain names, not patterns.

## 23.1 Macro Definition

```
defmacro ::= "(" "defmacro" Identifier "(" Identifier* ")" Body ")"
```

```lisp
(defmacro name (param1 param2 ...) body)
```

`(macro name ...)` is accepted as a synonym.

- **Parameters** are plain identifiers. Spec §19.1 calls them patterns; the implementation has no destructuring, literal or rest parameters. A parameter that is not an identifier is `E_MALFORMED_PARAMETER`.
- **The body** is ordinary Zyl code, not a quoted template. It is exactly one form: a `defmacro` with several body forms is `E_MALFORMED_FORM`, so wrap them in `begin`.
- **Expansion** happens at compile time. Macro definitions are removed from the program once expanded.
- **Top level only.** A `defmacro` inside a function body or any other form is `E_MACRO_ILLEGAL_ACCESS`: its template could name the run-time variables around it, which a compile-time rewrite cannot see.

## 23.2 How a Macro Call Expands

A macro call `(name arg1 arg2 ...)` is replaced by the macro's body, with every occurrence of a parameter name replaced by the corresponding **unevaluated argument expression**, and every variable the body itself binds renamed (§23.4). Nothing in the body runs at compile time: an `if`, a `match` or a call in the body is copied into the program and runs when the program runs.

```lisp
(defmacro my-unless (c body) (if c unit body))
(defmacro my-when (c body) (my-unless (not c) body))
(defmacro pick-unless (c a b) (if c b a))

(defn main ()
  (begin
    (my-when true (print "when-true runs"))
    (my-when false (print "when-false runs"))
    (print (pick-unless false 42 0))
    0))
```

Output:

```
when-true runs
42
```

The expansion is type-checked like code written by hand, after expansion. Both branches of an `if` have one type, so `my-unless` returns `unit` for the skipped case and its body must be Unit, as `print` is; `(my-unless false 42)` is `E_TYPE_MISMATCH`. A macro that yields a value takes it for both branches, as `pick-unless` does. The condition must be a `Bool`.

Because arguments are substituted, not evaluated, an argument used twice in the body is evaluated twice:

```lisp
(defmacro square (x) (* x x))

(print (square (begin (print "arg evaluated") 3)))
; arg evaluated
; arg evaluated
; 9
```

### Arguments

- Parameters and arguments are paired by position.
- A call must pass exactly one argument per parameter. Too many or too few is `E_ARITY_MISMATCH`, reported at the call.

### Where parameters are substituted

A parameter is substituted wherever the body names it, in every form: calls, `let` and `let-mut`, `if`, `while`, `for`, `match` (scrutinee, patterns and arms), `fn`/`lambda`, `try`, `with-resource`, `begin`, the assertions, `test` bodies and the rest. It is also substituted where the body needs a **name**:

| Position | Example body | The argument must be |
|----------|--------------|----------------------|
| `let`/`let-mut` binder | `(let n v body)` | an identifier, which becomes the binder |
| `set!` target | `(set! a b)` | an identifier, the variable assigned |
| `fn`/`defn` parameter, `for`/`try`/`with-resource`/`match` binder | `(fn (p) ...)` | an identifier |
| name of a `defn`, `def`, `deftype` or `impl` | `(defn name (k) (* k k))` | an identifier |

An argument that is not an identifier in one of these positions is `E_MALFORMED_PARAMETER`.

```lisp
(defmacro bind (n v body) (let n v body))
(print (bind q 7 (+ q 1)))                  ; 8

(defmacro swap! (a b) (let tmp a (begin (set! a b) (set! b tmp))))
(let-mut x 1 (let-mut y 2 (begin (swap! x y) (print x) (print y))))   ; 2, 1

(defmacro def-square (name) (defn name (k) (* k k)))
(def-square sq)
(print (sq 5))                              ; 25
```

Macro calls are recognised in every position too: inside `match` arms, `fn` bodies, `for` loops, `try`, `impl` methods, `test` bodies, and at top level, where a call can expand to a definition, as `def-square` does.

## 23.3 No Quasiquote

Zyl has no quasiquote, unquote or unquote-splicing: the body itself is the template. The lexer does not recognise `` ` ``, `,`, `'` or `@`. Each of them outside a string or comment is `E_INVALID_CHAR`, so a backquoted Common Lisp-style macro is rejected at its first backquote.

## 23.4 Hygiene

Spec §19.2 requires gensym-based hygiene: every variable a macro introduces is renamed to a unique symbol, so that a macro's binders cannot capture the caller's variables and the caller's bindings cannot capture the macro's free names. The expander implements both halves.

**Body binders are renamed.** Every variable the body binds (`let`, `let-mut`, `fn`/`lambda` and `defn` parameters, `for`, the `catch` name of a `try`, `with-resource`, and `match` pattern variables) gets a fresh name of the form `name__hygN` in each expansion. `N` comes from a counter that advances in source order, never from an address, so the same program always expands to the same names (Chapter 26). Arguments are the caller's code and keep their names, so they still refer to the caller's variables:

```lisp
(defmacro add-tmp (x) (let tmp 100 (+ tmp x)))

(let tmp 1 (print (add-tmp tmp)))   ; 101
```

The expansion is `(let tmp__hyg0 100 (+ tmp__hyg0 tmp))`. `_` is never renamed, and a renamed name keeps its leading underscore, so the unused-variable warnings treat it the same way.

**Free names resolve where the macro is defined.** Module resolution runs before expansion and rewrites every reference to a top-level definition to its canonical key (Chapter 25), so a function the body calls is the one visible at the definition, whatever the call site binds. The only names a call site could still capture are its own local variables. A body that names a variable which is unbound at the definition but local at the call site is rejected instead of captured:

```lisp
(defmacro getv () v)

(let v 3 (print (getv)))
;; error[E_UNBOUND_VARIABLE]: macro `getv` refers to `v`, which is not bound
;; where the macro is defined; the local variable of that name at this call
;; site cannot be captured (macros are hygienic)
```

A value the macro needs from the call site must be passed as an argument. Where a parameter supplies a binder (the `bind` and `swap!` examples in §23.2), the name is the caller's, and it binds or assigns the caller's variable, as intended.

## 23.5 Expansion Algorithm

Spec §19.3 specifies post-order (innermost-first) traversal; §19.5 says macros are collected before expansion.

The implementation:

1. **Registration.** Every *top-level* `defmacro` is collected before any expansion, so a macro can be used before it is defined. Two macros with one name are `E_DUPLICATE_DEFINITION`, as are a macro and a function with one name in the same file.
2. **Arguments first.** At each call, the arguments are expanded first.
3. **Substitution and renaming.** The expanded arguments are substituted into the body, and the body's binders are renamed (§23.4).
4. **Re-expansion.** The result is walked again, so macros used inside a macro body expand too. This is how `my-when` expands through `my-unless` above.

```lisp
(defn main () (print (triple 7)) 0)     ; used before its definition: prints 21

(defmacro triple (x) (+ x (+ x x)))
```

A macro may share its name with a function it imports: module resolution gives the macro that function's key, and the macro then takes over every call to it (Chapter 10 shows a macro `unless` over `core/core`'s function).

### Termination

Spec §19.4 requires deterministic expansion, and §28 defines `E_MACRO_NON_TERMINATION` for an expansion loop. Because a macro body is not evaluated at expansion time, *any* macro whose expansion reaches a call to itself diverges, even one whose recursion is guarded by an `if`. The expander reports it as soon as a macro is called while its own expansion is still in progress, directly or through other macros:

```lisp
(defmacro countdown (n) (if (= n 0) 0 (countdown (- n 1))))
;; (countdown 3) → error[E_MACRO_NON_TERMINATION]: macro `countdown`
;;                 expands to a call of itself, so its expansion never ends

(defmacro ping (x) (pong x))
(defmacro pong (x) (ping x))
;; (ping 1) → E_MACRO_NON_TERMINATION, pointing at the call in `pong`
```

A chain of distinct macros nested more than 256 deep is also `E_MACRO_NON_TERMINATION`. Recursion belongs in functions.

## 23.6 Built-in Forms That Look Like Macros

`and`, `or`, `cond` and `not` are core forms. The parser desugars them into nested `if` before macro expansion:

| Form | Desugaring |
|------|------------|
| `(and e1 e2 ...)` | `(if e1 (and e2 ...) false)` |
| `(or e1 e2 ...)` | `(if e1 true (or e2 ...))` |
| `(cond (c1 b1) ... (else b))` | nested `if`; a clause guarded by `true` or `else` ends it |
| `(not e)` | negation |

Both `and` and `or` short-circuit:

```lisp
(and (begin (print "a") true) false (begin (print "c") true))
;; prints "a", then the result 0 (false)
```

Every operand is a `Bool`, and so is the result: `(or 5 6)` is `E_TYPE_MISMATCH`, since an `Int` is not a condition. A `cond` without a `true` or `else` clause is Unit, like an `if` without an else.

`begin` is a core form. There is no `let*`, and no `when` or `unless` form (`when` is only a keyword inside `match` guards). User macros named `when`, `unless` and so on work as shown above.

## 23.7 Macro Constraints (Spec §19.4)

| Constraint | Status |
|------------|--------|
| AST-only | holds: a macro receives and produces syntax trees |
| No runtime access | holds by construction: the body is never evaluated at compile time. A `defmacro` that is not at top level, where its body could name run-time variables, is `E_MACRO_ILLEGAL_ACCESS` |
| Deterministic | holds: expansion is a pure function of the source, and fresh names come from a source-order counter |
| Terminating | enforced: `E_MACRO_NON_TERMINATION` (§23.5) |
| Hygienic | enforced (§23.4) |

## 23.8 Macro Errors

| Error | When |
|-------|------|
| `E_MACRO_NON_TERMINATION` | a macro reached again during its own expansion, or expansion nested more than 256 deep |
| `E_MACRO_ILLEGAL_ACCESS` | a `defmacro` inside a function body or other form |
| `E_ARITY_MISMATCH` | a macro call with the wrong number of arguments |
| `E_DUPLICATE_DEFINITION` | two macros with one name, or a macro and a function with one name in one file |
| `E_MALFORMED_FORM` | a `defmacro` with no body or with more than one body form |
| `E_MALFORMED_PARAMETER` | a macro parameter that is not an identifier, or a non-identifier argument used where the body needs a name |
| `E_UNBOUND_VARIABLE` | a body names a variable that is local at the call site but unbound where the macro is defined (§23.4) |

Each one points at the offending form in the source.

## 23.9 Debugging Macros

There is no flag that prints the expanded program and no REPL command for macro expansion. The available tools:

- `zyl prog.zyl --emit-asm -o prog.s`, then read the assembly for the function using the macro.
- The REPL (`zyl repl`) accepts `defmacro` definitions, so you can try a macro interactively and look at what it computes.
- A diagnostic that names `something__hygN` refers to a variable a macro body bound, renamed by hygiene.
- `tests/regression/macros.zyl` shows the supported style.

## 23.10 Patterns That Work

### Syntax sugar over existing forms

```lisp
(defmacro my-unless (c body) (if c unit body))
(defmacro inc! (v) (+ v 1))
```

### Conditional code at a single switch point

```lisp
(defn debug-enabled () false)

(defmacro debug (body) (if (debug-enabled) body))

(debug (print "debug output"))   ; expands to (if (debug-enabled) (print ...))
```

An `if` without an else is Unit, so `debug` takes only Unit bodies. The condition is tested at run time. A macro cannot remove code at compile time, because its body is never evaluated.

### Evaluating an argument exactly once

Bind the argument with a `let` inside the macro. Hygiene (§23.4) keeps the binder from colliding with anything at the call site:

```lisp
(defmacro square (x) (let n x (* n n)))   ; x evaluated once
```

A helper function works as well:

```lisp
(defn square-fn (n) (* n n))
(defmacro square (x) (square-fn x))
```

## 23.11 Best Practices

1. **Prefer functions.** Use a macro only when you need call-by-name evaluation or new surface syntax.
2. **Pass what the body needs from the call site as an argument**: a hygienic body cannot see the caller's locals.
3. **Never write a recursive macro**: it is rejected with `E_MACRO_NON_TERMINATION`.
4. **Remember that arguments are substituted**, and may be evaluated more than once or not at all.
5. **Keep backquote, comma, quote and `@` out of source files** outside strings and comments.

## 23.12 Comparison with Other Lisps

| Feature | Common Lisp | Scheme (R7RS) | Racket | Zyl (implemented) |
|---------|-------------|---------------|--------|-------------------|
| Hygiene | manual (`gensym`) | `syntax-rules` | `syntax-parse` | automatic renaming of body binders |
| Template syntax | quasiquote | pattern templates | quasisyntax | the body itself; parameters substituted |
| Parameters | destructuring lambda list | patterns | patterns | plain identifiers |
| Expansion-time evaluation | ✅ | ❌ (`syntax-rules`) | ✅ | ❌ |
| Procedural macros | ✅ | ❌ (`syntax-rules`) | ✅ | ❌ |
| Termination check | ❌ | ❌ | ❌ | ✅ (a macro reached during its own expansion) |
