# Chapter 23: Macro System and Hygiene

Complete reference for Zyl's macro system: definition, substitution, expansion order, and the hygiene and termination rules the specification requires.

The normative text is spec v5.0 §19. The implementation is `stdlib/compiler/macro_expand.zyl`, which runs after module resolution and before the static checks and type inference (see Chapter 26). The implemented system is much smaller than §19 describes, and this chapter documents the implementation and marks each place where the specification asks for more.

## 23.1 Macro Definition

```
defmacro ::= "(" "defmacro" Identifier "(" Identifier* ")" Body ")"
```

```lisp
(defmacro name (param1 param2 ...) body)
```

`(macro name ...)` is accepted as a synonym.

- **Parameters** are plain identifiers. Spec §19.1 calls them patterns; the implementation has no destructuring, literal or rest parameters.
- **The body** is ordinary Zyl code, not a quoted template. If the body has several forms, only the last is kept, silently, so wrap multiple forms in `begin`.
- **Expansion** happens at compile time. Macro definitions are removed from the program once expanded.

## 23.2 How a Macro Call Expands

A macro call `(name arg1 arg2 ...)` is replaced by the macro's body, with every occurrence of a parameter name replaced by the corresponding **unevaluated argument expression**. That is all an expansion does. Nothing in the body runs at compile time: an `if`, a `match` or a call in the body is copied into the program and runs when the program runs.

```lisp
(defmacro my-unless (c body) (if c 0 body))
(defmacro my-when (c body) (my-unless (not c) body))

(defn main ()
  (begin
    (my-when true (print "when-true runs"))
    (my-when false (print "when-false runs"))
    (print (my-unless false 42))
    0))
```

Output:

```
when-true runs
42
```

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
- **Extra arguments are dropped silently.**
- **A missing argument** leaves the parameter's name in the expansion, where it usually surfaces as `E_UNBOUND_VARIABLE` pointing at the macro body.

### Where parameters are substituted

Substitution walks function calls, `let` and `let-mut` values and bodies, `if`, `while`, the value of `set!`, `begin`, `print`, the assertions, `struct-get`, `defn` and `test`. It does **not** walk into `match`, `fn`/`lambda`, `try` or `for`, and it does not replace a parameter used as a `let` binder or a `set!` target:

```lisp
(defmacro pick (x) (match x (Some v v) (None 0)))
;; (pick (Some 5)) → E_UNBOUND_VARIABLE: unbound identifier `x`

(defmacro bind (n v body) (let n v body))
;; (bind q 7 (+ q 1)) → binds a variable literally named `n`; `q` is unbound
```

The same limit applies to recognising macro calls. A macro call inside a `match` arm or a `try` is not expanded, and fails at link time as an undefined reference. A macro call inside a `fn` body is not expanded either, and currently compiles to a program that crashes. Call macros only from positions the expander walks.

## 23.3 No Quasiquote

Zyl has no quasiquote, unquote or unquote-splicing: the body itself is the template. The lexer does not recognise `` ` ``, `,`, `'` or `@`. An unrecognised character currently ends the token stream **without an error**, so everything after it in the file is silently dropped. A backquoted Common Lisp-style macro therefore makes the rest of the file vanish, typically surfacing as an `undefined reference to _ZYL_main` link error. Do not use these characters outside strings and comments.

## 23.4 Hygiene

Spec §19.2 requires gensym-based hygiene: every variable a macro introduces is renamed to a unique symbol, so that a macro's binders cannot capture the caller's variables and the caller's bindings cannot capture the macro's free names.

**The implementation performs no renaming.** Expansion is textual substitution, so capture happens in both directions.

A macro's binder captures the caller's variable:

```lisp
(defmacro add-tmp (x) (let tmp 100 (+ tmp x)))

(let tmp 1 (print (add-tmp tmp)))
;; compile time: W_SHADOWED_BINDING: `tmp` shadows an outer binding of the same name
;; prints 200   (a hygienic expansion would print 101)
```

A macro's free name picks up whatever the call site has in scope:

```lisp
(defmacro getv () v)

(let v 3 (print (getv)))   ; prints 3
```

Function names in call position are not captured this way, because call heads are resolved to canonical keys (Chapter 25) before expansion.

Until hygiene is implemented:

- Give macro-introduced binders distinctive names that a caller is unlikely to use.
- Treat `W_SHADOWED_BINDING` in code that uses macros as a likely capture.
- Prefer functions: they are hygienic by construction.

A `swap!` macro cannot be written: `set!` targets are not substituted (§23.2), so `(set! a b)` in a macro body always names a variable literally called `a`.

## 23.5 Expansion Algorithm

Spec §19.3 specifies post-order (innermost-first) traversal; §19.5 says macros are collected before expansion.

The implementation:

1. **Registration.** Every *top-level* `defmacro` is collected before any expansion, so a macro can be used before it is defined. Macros defined inside other forms are not collected. If two macros share a name, the last definition wins, without a diagnostic.
2. **Arguments first.** At each call, the arguments are expanded first.
3. **Substitution.** The expanded arguments are substituted into the body.
4. **Re-expansion.** The result is walked again, so macros used inside a macro body expand too. This is how `my-when` → `my-unless` works above.

```lisp
(defn main () (print (triple 7)))       ; used before its definition: prints 21

(defmacro triple (x) (+ x (+ x x)))
```

### Termination

Spec §19.4 requires deterministic expansion, and §28 defines `E_MACRO_NON_TERMINATION` for an expansion loop. **The implementation has no depth limit and never emits this code.** Because a macro body is not evaluated at expansion time, *any* recursive macro diverges, even one whose recursion is guarded by an `if`:

```lisp
(defmacro countdown (n) (if (= n 0) 0 (countdown (- n 1))))
;; (countdown 3) → the compiler never finishes

(defmacro forever (x) (forever x))
;; (forever 1) → PANIC: error[E_OUT_OF_MEMORY]: memory budget exhausted ...
```

Do not write recursive macros. Recursion belongs in functions.

## 23.6 Built-in Forms That Look Like Macros

`and`, `or`, `cond` and `not` are core forms. The parser desugars them into nested `if` before macro expansion:

| Form | Desugaring |
|------|------------|
| `(and e1 e2 ...)` | `(if e1 (and e2 ...) false)`; the last operand is returned as is |
| `(or e1 e2 ...)` | `(if e1 true (or e2 ...))`; the last operand is returned as is |
| `(cond (c1 b1) ... (else b))` | nested `if` |
| `(not e)` | negation |

Both `and` and `or` short-circuit:

```lisp
(and (begin (print "a") true) false (begin (print "c") true))
;; prints "a", then the result 0 (false)
```

`(or 5 6)` yields `true` (printed as `1`), not 5, because a non-final operand that succeeds yields `true`. `(or false 7)` yields 7.

`begin` is a core form. There is no `let*`, and no `when` or `unless` form (`when` is only a keyword inside `match` guards). User macros named `when`, `unless` and so on work as shown above.

## 23.7 Macro Constraints (Spec §19.4)

| Constraint | Status |
|------------|--------|
| AST-only | holds: a macro receives and produces syntax trees |
| No runtime access | holds by construction: the body is never evaluated at compile time, so it cannot touch runtime values (`E_MACRO_ILLEGAL_ACCESS` is never needed and never emitted) |
| Deterministic | holds for terminating macros: expansion is a pure function of the source, though duplicate names resolve to the last definition |
| Terminating | **not enforced** (§23.5) |
| Hygienic | **not implemented** (§23.4) |

## 23.8 Macro Errors

| Error | Status |
|-------|--------|
| `E_MACRO_NON_TERMINATION` | specified (§28), never emitted: a looping macro hangs the compiler or exhausts memory (`E_OUT_OF_MEMORY`) |
| `E_MACRO_ILLEGAL_ACCESS` | specified (§28), never emitted |
| `E_UNBOUND_VARIABLE` | what a missing argument or an unsubstituted parameter usually produces |
| link-time `undefined reference` | a macro call in a position the expander does not walk (§23.2) |

There is no arity check for macro calls.

## 23.9 Debugging Macros

There is no flag that prints the expanded program and no REPL command for macro expansion. The available tools:

- `zyl prog.zyl --emit-asm -o prog.s`, then read the assembly for the function using the macro.
- The REPL (`zyl repl`) accepts `defmacro` definitions, so you can try a macro interactively and look at what it computes.
- `W_SHADOWED_BINDING` and `E_UNBOUND_VARIABLE` diagnostics that point into a macro body usually mean capture or an unsubstituted parameter.
- `tests/regression/macros.zyl` shows the supported style.

## 23.10 Patterns That Work

### Syntax sugar over existing forms

```lisp
(defmacro my-unless (c body) (if c 0 body))
(defmacro inc! (v) (+ v 1))
```

### Conditional code at a single switch point

```lisp
(defn debug-enabled () false)

(defmacro debug (body) (if (debug-enabled) body 0))

(debug (print "debug output"))   ; expands to (if (debug-enabled) (print ...) 0)
```

The condition is tested at run time. A macro cannot remove code at compile time, because its body is never evaluated.

### Evaluating an argument exactly once

Bind the argument in a helper **function**, not in a `let` inside the macro:

```lisp
(defn square-fn (n) (* n n))
(defmacro square (x) (square-fn x))   ; x evaluated once
```

## 23.11 Best Practices

1. **Prefer functions.** Use a macro only when you need call-by-name evaluation or new surface syntax.
2. **Keep macro bodies to calls, `if`, `let` values and `begin`**, the forms the expander walks.
3. **Do not introduce binders in a macro body**: there is no hygiene.
4. **Never write a recursive macro**: there is no termination check.
5. **Remember that arguments are substituted**, and may be evaluated more than once or not at all.
6. **Keep backquote, comma, quote and `@` out of source files** outside strings and comments.

## 23.12 Comparison with Other Lisps

| Feature | Common Lisp | Scheme (R7RS) | Racket | Zyl (implemented) |
|---------|-------------|---------------|--------|-------------------|
| Hygiene | manual (`gensym`) | `syntax-rules` | `syntax-parse` | none (spec requires gensym hygiene) |
| Template syntax | quasiquote | pattern templates | quasisyntax | the body itself; parameters substituted |
| Parameters | destructuring lambda list | patterns | patterns | plain identifiers |
| Expansion-time evaluation | ✅ | ❌ (`syntax-rules`) | ✅ | ❌ |
| Procedural macros | ✅ | ❌ (`syntax-rules`) | ✅ | ❌ |
| Termination check | ❌ | ❌ | ❌ | ❌ (spec requires one) |
