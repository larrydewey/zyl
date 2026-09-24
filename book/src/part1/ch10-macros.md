# Chapter 10: Macros and Metaprogramming

Macros let you write code that writes code. The specification (Spec §19) calls for **hygienic**, **innermost-first**, **deterministic** macros that are collected before expansion. The current compiler implements a smaller, simpler system: a macro is a **template** whose parameters are replaced by the unevaluated argument expressions. This chapter teaches the implemented system and marks where it still falls short of the specification. Every runnable example was compiled with `zyl` and run.

## 10.1 What Are Macros?

A macro is a compile-time rewrite rule:

```lisp
(defmacro name (param ...) template)
```

(`macro` is accepted as a synonym for `defmacro`.)

When the compiler sees a call `(name arg ...)`, it:

1. Expands macro calls inside the arguments first
2. Replaces each parameter name in `template` with the corresponding argument expression, **unevaluated**
3. Expands the result again, so a template may call other macros

Macro definitions exist only at compile time; they are removed from the program after expansion and produce no code of their own.

## 10.2 Defining Macros

### Basic Syntax

The template is ordinary Zyl code, written exactly as the expansion should read. There is no quasiquote: backquote, `,` and `,@` are not supported, and a template that uses them does not compile.

```lisp
(defmacro my-unless (c body)
  (if (not c) body 0))

(defmacro my-when (c body)
  (my-unless (not c) body))       ; a macro may expand into another macro

(defn main ()
  (begin
    (print (my-unless false 1))   ; 1
    (print (my-when true 2))))    ; 2
```

### Arguments Are Spliced, Not Evaluated

Because an argument is copied into the template as source, a parameter that appears twice in the template evaluates its argument twice:

```lisp
(defmacro double (x) (+ x x))

(defn noisy ()
  (begin (print "evaluated") 21))

(defn main ()
  (print (double (noisy))))
```

Output:

```
evaluated
evaluated
42
```

If you need the argument evaluated once, bind it with `let` inside the template, keeping the hygiene caveat in §10.3 in mind, or write a function instead.

### Macros vs Functions: Laziness

Splicing is what makes a macro useful: the macro decides whether an argument is evaluated at all. `core/core` defines `when` and `unless` as ordinary **functions**, so both of their arguments are always evaluated:

```lisp
(defn main ()
  (begin
    (unless true (print "core unless is a function"))
    (print "end")))
```

```
core unless is a function
end
```

A macro version skips the body when the condition says so:

```lisp
(defmacro unless (c body)
  (if (not c) body 0))

(defn main ()
  (begin
    (unless true (print "should not print"))
    (print "end")))
```

```
end
```

A macro takes precedence over a function of the same name: once `unless` is defined as a macro, every call to `unless` in the program is expanded, including calls that would otherwise reach the `core/core` function.

### Wrapping an Expression

```lisp
(defmacro log-and-return (e)
  (begin
    (print "evaluating")
    e))

(defn main ()
  (print (log-and-return (+ 1 2))))
```

```
evaluating
3
```

There is no way to print the *source* of the argument (the spec's `',expr`); a template can only place the argument where it will be evaluated.

## 10.3 Hygiene

The specification requires gensym-based hygiene: names a template introduces are renamed so they cannot collide with the caller's names. **The current expander performs no renaming.** A name bound inside a template is an ordinary name in the expanded code, so it can capture a variable from the call site:

```lisp
(defmacro add-tmp (e)
  (let tmp 100 (+ tmp e)))

(defn main ()
  (let tmp 1
    (print (add-tmp tmp))))
```

A hygienic expander would print 101 (the macro's `tmp` is 100, the caller's is 1). The current one prints:

```
200
```

The expansion is `(let tmp 100 (+ tmp tmp))`, and both `tmp`s refer to the macro's binding. Until hygiene lands, give names bound inside templates a prefix no caller will use (for example `add-tmp-v` instead of `tmp`).

## 10.4 Expansion Order

Arguments are expanded before the macro that receives them, so expansion is innermost-first, as the spec requires:

```lisp
(defmacro m1 (x) (m2 x))
(defmacro m2 (x) (+ x 1))

(defn main ()
  (print (m1 (m1 5))))    ; 7
```

1. The inner `(m1 5)` expands to `(m2 5)`, then to `(+ 5 1)`
2. The outer call receives `(+ 5 1)`: `(m1 (+ 5 1))` becomes `(m2 (+ 5 1))`, then `(+ (+ 5 1) 1)`
3. At run time that evaluates to 7

## 10.5 Macro Registration

All `defmacro` forms are collected from the whole program **before** any expansion (Spec §19.5), so a macro can be used above its definition:

```lisp
(defn main ()
  (print (triple 2)))        ; 6

(defmacro triple (x) (* 3 x))
```

## 10.6 Where Macros Expand

The expander walks function bodies, test bodies, and nested `let`, `let-mut`, `if`, `cond`, `while`, `begin`, `print`, `set!` values, `struct-get`, the `assert-*` forms, and ordinary call arguments. It does **not** yet look inside:

- `match` arms
- `fn`/`lambda` bodies
- `for` loops

A macro call in one of those positions is left as a call to a function that does not exist, and linking fails with an `undefined reference` naming the macro. The same limit applies inside templates: a parameter used inside a `match` or `fn` in the template body is not substituted. Keep macro calls, and the parameters inside templates, in the positions listed above.

```lisp
(defmacro square-it (x) (* x x))

(defn main ()
  (let-mut n 3
    (begin
      (while (< n 5)
        (begin
          (print (square-it n))
          (set! n (+ n 1))))
      (if (> n 0) (print (square-it 10)) (print 0)))))
```

```
9
16
100
```

## 10.7 Macro Constraints (Spec §19.4)

| Constraint | Status in the current compiler |
|------------|--------------------------------|
| AST-only | Holds: a template is syntax and can only produce syntax |
| No runtime access | Holds: nothing in a template runs at compile time |
| Deterministic | Holds: expansion is a pure rewrite of the source |
| Terminating | **Not checked**: a macro that expands to itself makes the compiler loop forever |

The error codes `E_MACRO_ILLEGAL_ACCESS` and `E_MACRO_NON_TERMINATION` are defined in the error catalog (`stdlib/compiler/error_codes.zyl`), but the expander does not report either yet. Avoid macros that expand, directly or through other macros, into another call to themselves.

## 10.8 Built-in Forms That Look Like Macros

Several forms that other Lisps define as macros are built into Zyl's parser instead:

| Form | Behavior |
|------|----------|
| `and` | Short-circuit: stops at the first false operand |
| `or` | Short-circuit: stops at the first true operand |
| `cond` | `(cond (test value) ... (else value))`, a chain of `if`s |
| `begin` | Sequencing; the value is the last expression |

`let*` is not available; nest `let` forms instead.

```lisp
(defn say ((s String) r) (begin (print s) r))

(defn main ()
  (begin
    (print (and (say "a" true) (say "b" false) (say "c" true)))
    (print (cond ((> 1 2) 10) ((> 2 1) 20) (else 30)))))
```

```
a
b
0
20
```

The `and` evaluates the first two operands and stops at `false` (printed as `0`), so `(say "c" true)` never runs. The `String` annotation on `s` makes `print` treat the parameter as a string; an unannotated parameter prints as a machine word.

## 10.9 Debugging Macros

The compiler has no option that prints the expanded program (the only output option is `--emit-asm`), and the REPL has no `:macroexpand` command. To check an expansion:

1. Write the expansion you expect by hand, as ordinary code, and confirm it behaves the same as the macro call.
2. Test the macro directly with the test harness (Chapter 11). Macros expand inside `test` bodies:

```lisp
(defmacro square-it (x) (* x x))

(test "square-it-expands"
  (assert-equal (square-it 4) 16))

(run-tests)
```

3. If linking fails with an `undefined reference` that names your macro, the call sits in a position the expander does not visit (§10.6).

## 10.10 Macro Best Practices

1. **Prefer functions.** Use a macro only when you need control over evaluation (skipping or repeating an argument).
2. **Use each parameter once** in the template, unless repeated evaluation is the point.
3. **Prefix names bound in templates** so they cannot capture the caller's variables (§10.3).
4. **Keep calls in expandable positions**: not inside `match` arms, `fn` bodies, or `for` loops.
5. **Never write self-expanding macros**: there is no termination check.

---

## For Experts: Under the Hood

### Expansion Algorithm

The expander is `stdlib/compiler/macro_expand.zyl`. It runs on the parsed program, after module resolution and before type inference:

1. **Collect** (`me-collect`): walk the top-level forms and record every macro definition as a name, its parameter names, and its body template.
2. **Strip** (`me-strip`): remove the macro definitions from the program.
3. **Rewrite** (`me-rewrite`): walk every remaining form with a substitution environment that starts empty. At a call `(f arg ...)`:
   - rewrite the arguments under the current environment, which expands the macros inside them first;
   - if `f` names a macro, rewrite its template under a new environment that binds each parameter to the corresponding rewritten argument, and return the result.

Identifiers found in the environment are replaced by the bound expression; nothing else is renamed. Each rewritten node keeps its original source position, so diagnostics inside expanded code point at the user's source.

### Why Hygiene Is Missing

Hygiene requires renaming every binder a template introduces (a fresh, deterministic gensym per expansion) and leaving call-site identifiers alone. The current substitution environment only maps parameter names to arguments; there is no renaming step for `let` names inside the template, so a template binder and a caller variable with the same spelling become the same variable.

### Determinism

Expansion is a pure function of the source: the macro table is built in source order, the rewrite is a fixed traversal, and no counter or external input is involved. The same source always produces the same expanded program.

---

**Next:** [Chapter 11: Testing](ch11-testing.md) covers the built-in test framework and assertions.
