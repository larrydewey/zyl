# Chapter 10: Macros and Metaprogramming

Macros let you write code that writes code. The specification (Spec §19) calls for **hygienic**, **innermost-first**, **deterministic** macros that are collected before expansion. The compiler implements them as **templates**: a macro's parameters are replaced by the unevaluated argument expressions, and the variables the template binds are renamed so they cannot collide with the caller's. This chapter teaches the implemented system and marks where it is narrower than the specification. Every runnable example was compiled with `zyl` and run.

## 10.1 What Are Macros?

A macro is a compile-time rewrite rule:

```lisp
(defmacro name (param ...) template)
```

(`macro` is accepted as a synonym for `defmacro`.) The template is exactly one form; to expand to several, wrap them in `begin`. A `defmacro` with two template forms is `E_MALFORMED_FORM`.

When the compiler sees a call `(name arg ...)`, it:

1. Expands macro calls inside the arguments first
2. Replaces each parameter name in `template` with the corresponding argument expression, **unevaluated**, and renames the variables the template binds (§10.3)
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
    (print (my-when true 2))    ; 2
    0))
```

### Arguments Are Spliced, Not Evaluated

Because an argument is copied into the template as source, a parameter that appears twice in the template evaluates its argument twice:

```lisp
(defmacro double (x) (+ x x))

(defn noisy ()
  (begin (print "evaluated") 21))

(defn main ()
  (print (double (noisy)))
  0)
```

Output:

```
evaluated
evaluated
42
```

If you need the argument evaluated once, bind it with `let` inside the template (hygiene, §10.3, keeps that binder private to the macro) or write a function instead.

### Macros vs Functions: Laziness

Splicing is what makes a macro useful: the macro decides whether an argument is evaluated at all. `core/core` defines `when` and `unless` as ordinary **functions**, so both of their arguments are always evaluated:

```lisp
(defn main ()
  (begin
    (unless true (print "core unless is a function"))
    (print "end")
    0))
```

```
core unless is a function
end
```

(The body of the `core/core` functions is a statement: they are typed `Bool Unit -> Unit`.)

A macro version skips the body when the condition says so. An `if` without an else branch is a statement, of type `Unit`, and so is the `print` it guards:

```lisp
(defmacro unless (c body)
  (if (not c) body))

(defn main ()
  (begin
    (unless true (print "should not print"))
    (print "end")
    0))
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
  (print (log-and-return (+ 1 2)))
  0)
```

```
evaluating
3
```

There is no way to print the *source* of the argument (the spec's `',expr`); a template can only place the argument where it will be evaluated.

## 10.3 Hygiene

The specification requires gensym-based hygiene: names a template introduces are renamed so they cannot collide with the caller's names. The expander renames every variable a template binds (`let`, `let-mut`, `fn` parameters, `for`, `match` pattern variables, the `catch` name of a `try`) to a fresh name in each expansion, and leaves the arguments, which are the caller's code, alone:

```lisp
(defmacro add-tmp (e)
  (let tmp 100 (+ tmp e)))

(defn main ()
  (let tmp 1
    (print (add-tmp tmp)))
  0)
```

```
101
```

The macro's `tmp` is 100 and the caller's is 1. The expansion is `(let tmp__hyg0 100 (+ tmp__hyg0 tmp))`: the fresh names are numbered by a counter that follows the source, so they are the same on every compile.

It works the other way round too: a template cannot see the caller's local variables. A name the template uses without binding it means what it means where the macro is *defined*, at top level. If the caller has a local variable of that name, the compiler refuses to let the macro capture it:

```lisp
(defmacro getv () v)

(defn main ()
  (let v 3 (print (getv))))
;; error[E_UNBOUND_VARIABLE]: macro `getv` refers to `v`, which is not bound
;; where the macro is defined; ...
```

Pass such values in as arguments. When a parameter is used where the template needs a name, such as a `let` binder or a `set!` target, the caller's identifier is used, so a macro can bind or assign a variable the caller names:

```lisp
(defmacro swap! (a b)
  (let tmp a (begin (set! a b) (set! b tmp))))

(defn main ()
  (let-mut tmp 1
    (let-mut y 2
      (begin (swap! tmp y) (print tmp) (print y))))
  0)
```

```
2
1
```

The caller's variable is called `tmp` too, and the swap still works, because the template's own `tmp` was renamed.

## 10.4 Expansion Order

Arguments are expanded before the macro that receives them, so expansion is innermost-first, as the spec requires:

```lisp
(defmacro m1 (x) (m2 x))
(defmacro m2 (x) (+ x 1))

(defn main ()
  (print (m1 (m1 5)))    ; 7
  0)
```

1. The inner `(m1 5)` expands to `(m2 5)`, then to `(+ 5 1)`
2. The outer call receives `(+ 5 1)`: `(m1 (+ 5 1))` becomes `(m2 (+ 5 1))`, then `(+ (+ 5 1) 1)`
3. At run time that evaluates to 7

## 10.5 Macro Registration

All `defmacro` forms are collected from the whole program **before** any expansion (Spec §19.5), so a macro can be used above its definition:

```lisp
(defn main ()
  (print (triple 2))        ; 6
  0)

(defmacro triple (x) (* 3 x))
```

## 10.6 Where Macros Expand

A macro call expands wherever it is written: function and test bodies, `let`, `if`, `while`, `for`, `match` arms, `fn` bodies, `try`, `impl` methods, and at top level, where a macro can expand to a definition. Parameters are substituted everywhere in the template in the same way.

```lisp
(defmacro square-it (x) (* x x))
(defmacro def-square (name) (defn name (k) (square-it k)))

(def-square sq)

(defn main ()
  (begin
    (print (match (Some 3) (Some v (square-it v)) (None 0)))
    (let f (fn (z) (square-it z)) (print (f 4)))
    (print (sq 10))
    0))
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
| No runtime access | Holds: nothing in a template runs at compile time. A `defmacro` inside a function body, where the template could name the function's run-time variables, is rejected with `E_MACRO_ILLEGAL_ACCESS` |
| Deterministic | Holds: expansion is a pure rewrite of the source |
| Terminating | Checked: a macro that expands, directly or through other macros, into another call to itself is rejected with `E_MACRO_NON_TERMINATION` |

Because a template is never evaluated, a recursive macro can never stop, even when the recursion sits behind an `if`, so the compiler reports it rather than looping:

```lisp
(defmacro forever (x) (forever x))

(defn main () (print (forever 1)))
;; error[E_MACRO_NON_TERMINATION]: macro `forever` expands to a call of
;; itself, so its expansion never ends
```

A macro call must pass exactly one argument per parameter (`E_ARITY_MISMATCH`), and a macro name may be defined only once (`E_DUPLICATE_DEFINITION`, also raised for a function with the same name as a macro in the same file).

## 10.8 Built-in Forms That Look Like Macros

Several forms that other Lisps define as macros are built into Zyl's parser instead:

| Form | Behavior |
|------|----------|
| `and` | Short-circuit: stops at the first false operand |
| `or` | Short-circuit: stops at the first true operand |
| `cond` | `(cond (test value) ... (else value))`, a chain of `if`s; a clause may hold several forms, run in order |
| `begin` | Sequencing; the value is the last expression |

`let*` is not available; nest `let` forms instead.

```lisp
(defn say ((s String) r) (begin (print s) r))

(defn main ()
  (begin
    (print (and (say "a" true) (say "b" false) (say "c" true)))
    (print (cond ((> 1 2) 10) ((> 2 1) 20) (else 30)))
    0))
```

```
a
b
0
20
```

The `and` evaluates the first two operands and stops at `false` (printed as `0`), so `(say "c" true)` never runs. The operands of `and` and `or`, like every condition, must be `Bool`. The `String` annotation on `s` pins `say` to strings; without it `say` is generic and `print` still shows the argument's inferred type.

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

3. A diagnostic naming a variable like `tmp__hyg0` refers to a variable a macro template bound, renamed by hygiene (§10.3).

## 10.10 Macro Best Practices

1. **Prefer functions.** Use a macro only when you need control over evaluation (skipping or repeating an argument).
2. **Use each parameter once** in the template, unless repeated evaluation is the point.
3. **Pass what the template needs as arguments**: it cannot see the caller's local variables (§10.3).
4. **Never write self-expanding macros**: they are rejected (§10.7).

---

## For Experts: Under the Hood

### Expansion Algorithm

The expander is `stdlib/compiler/macro_expand.zyl`. It runs on the parsed program, after module resolution and before type inference:

1. **Collect** (`me-collect`): walk the top-level forms and record every macro definition as a name, its parameter names, and its body template, rejecting a duplicate name.
2. **Strip** (`me-strip`): remove the macro definitions from the program.
3. **Rewrite** (`me-rewrite`): walk every remaining form, every node shape, with a context holding a substitution environment, the macros whose expansion is in progress, and the call site's local variables. At a call `(f arg ...)`:
   - rewrite the arguments under the current context, which expands the macros inside them first;
   - if `f` names a macro, check that it is not already being expanded and that the argument count matches, then rewrite its template under a new environment that binds each parameter to the corresponding rewritten argument, and return the result.

In a template, a binder is renamed by pushing a `name -> name__hygN` entry onto the environment for the binder's scope; an identifier is looked up in the environment and replaced by the argument or the fresh name it maps to. An argument is inserted as it is and not walked again, so the caller's names inside it are never renamed. Each rewritten node keeps its original source position, so diagnostics inside expanded code point at the user's source.

### Hygiene and Canonical Keys

Module resolution runs before expansion and rewrites every reference to a top-level definition to its canonical key (Chapter 25). A template's references to functions and globals are therefore already fixed to the definitions visible where the macro is written. What remains for the expander is the call site's local variables: renaming the template's binders keeps them from capturing the caller's, and the check against the call site's locals keeps a free template name from being captured by one.

### Determinism

Expansion is a pure function of the source: the macro table is built in source order, the rewrite is a fixed traversal, and the fresh-name counter is threaded through that traversal rather than taken from any global or address. The same source always produces the same expanded program.

---

**Next:** [Chapter 11: Testing](ch11-testing.md) covers the built-in test framework and assertions.
