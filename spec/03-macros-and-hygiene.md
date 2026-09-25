# Zyl Specification — Macros and Hygiene

**Canonical authority:** `zyl_specification.txt` §19
**Related:** `spec/02-syntax-and-forms.md`
**Implementation:** `stdlib/compiler/macro_expand.zyl` (expansion), `stdlib/compiler/expr_inner.zyl` (`parse-macro`)

---

## 19.1 Macro Definition

```
(defmacro name (pattern*) template)
```

A pattern is a parameter name. The list may end in `&rest name`: a call
then passes at least one argument per parameter before `&rest` (fewer is
`E_ARITY_MISMATCH`), and `name` is bound to the remaining arguments,
possibly none. `&rest` anywhere else, or not followed by exactly one
name, is `E_MALFORMED_PARAMETER`. Without `&rest` a call passes exactly
one argument per parameter (`E_ARITY_MISMATCH`).

In the template:

- a parameter stands for its argument, unevaluated;
- `,x` is `x` (parameters are substituted anyway);
- `,@name`, for the `&rest` parameter `name`, splices its arguments in
  place, in order, where any number of expressions may appear: the
  arguments of a call (a constructor and `ffi-call` included), `begin`,
  `print`, `setup` and `teardown`. Elsewhere, such as in an `if`, it is
  `E_MALFORMED_FORM`, as is a `,@` outside a quasiquote whose operand is
  not the `&rest` parameter (inside a quasiquote, `,@` is §4.9's);
- the `&rest` parameter as a value is the list literal of its
  arguments, `(list a1 .. an)`, so its arguments share one type, and a
  quasiquote in a template can splice it: `` `(,a ,@rest 0) ``.

A `,` or `,@` still present after expansion is `E_MALFORMED_FORM`.

```lisp
(defmacro my-when (c &rest body) (if c (begin ,@body) unit))
(defmacro sum (&rest xs) (+ 0 ,@xs))       ; (sum 1 2 3) is (+ 0 1 2 3)
(defmacro framed (a &rest xs) `(,a ,@xs 0)) ; (framed 9 8 7) is [9 8 7 0]
```

## 19.2 Hygiene

Gensym-based hygiene. All macro-introduced variables are renamed to unique symbols.
Spliced arguments are the caller's code and keep their names.

## 19.3 Expansion Algorithm

Post-order traversal (innermost first).

**Rationale:** Innermost-first ensures that nested macro calls expand correctly:
the innermost macro produces output that outer macros can then match against.

**Rejected alternative:** Pre-order expansion — would cause outer macros to see
unexpanded inner macro calls, producing incorrect results.

## 19.4 Macro Constraints

- AST-only: macros cannot access runtime values
- No runtime access: violation produces `E_MACRO_ILLEGAL_ACCESS`
- Deterministic: same input always produces same expansion

## 19.5 Macro Registration

Macros are collected before expansion begins. All defmacro definitions in
scope are registered and available for expansion.

---

## Implementation Notes

Not normative. The self-hosted expander implements a subset of §19; the
gaps are recorded here, not papered over.

### What is implemented

- **Definition:** `(defmacro name (p1 p2 ...) body)`; `macro` is accepted as
  a synonym. The body is the last form after the parameter list. A
  parameter that is not an identifier is `E_MALFORMED_PARAMETER`, and so
  is a `&rest` that is not followed by exactly one name at the end of the
  list (`me-check-rest`).
- **Registration (§19.5):** top-level macro definitions are collected
  before expansion (`me-collect`) and then removed from the program
  (`me-strip`). Two macros with one name are `E_DUPLICATE_DEFINITION`, as
  are a macro and a `defn` with one name in the same source file. (Across
  files a macro may share an imported function's name: module resolution
  gives it that function's canonical key, and the macro takes over the
  function's calls.)
- **Expansion order (§19.3):** innermost first. For a call to a registered
  macro, the arguments are expanded first; the body is then instantiated
  with its parameters bound to the expanded arguments, and the result is
  walked again, so a macro call produced by an expansion is itself
  expanded. The walk covers every ExprInner shape, so a macro call expands
  in any position (`match` arms, `fn` bodies, `for`, `try`,
  `with-resource`, `impl` methods, tests, top level).
- **Substitution:** a parameter is replaced by its argument wherever the
  body names it. Where the body needs a name (a `let`/`let-mut`/`fn`/
  `for`/`try`/`with-resource`/`match` binder, a `set!` target, the name
  of a `defn`/`def`/`deftype`/`impl`), the argument must be an identifier
  and becomes that name; anything else is `E_MALFORMED_PARAMETER`.
  Parameters and arguments are paired positionally, and a count mismatch
  is `E_ARITY_MISMATCH` at the call; with `&rest`, too few arguments for
  the parameters before it is (`me-check-arity-rest`).
- **Rest parameters:** the substitution environment binds a `&rest`
  parameter to the list of remaining arguments (`SRest`). In a list of
  expressions the expander rewrites (`me-rewrite-list-acc`), `,@name`
  is replaced by those arguments (`me-splice-of`); `me-kids` then
  rejects a changed count unless the node takes any number of children
  (`me-variadic`: calls, `begin`, `print`, constructors, `ffi-call`,
  `setup`, `teardown`). The parameter as a value becomes the `Cons`
  chain of its arguments (`me-list-expr`), built from `core/list`'s own
  `Cons` and `Nil`, which `me-find-prelude-list` reads from the
  program's resolved `deftype`. In a template, `(unquote x)` is replaced
  by `x` (`me-apply`). A quasiquote in a template was already desugared
  by `qualify.zyl`, so its `,@` is a `zyl-qq-append` call by the time the
  expander sees it.
- **Hygiene (§19.2):** every variable the body binds is renamed to a fresh
  `name__hygN` per expansion; `N` is a counter threaded through the walk
  in source order, so expansion stays deterministic. `_` and
  compiler-internal `__` names are not renamed. Arguments, spliced ones
  included, are not renamed.
  Free names resolve at the definition site: module resolution has already
  qualified every reference to a top-level definition, and a free body
  name that is a local variable at the call site is `E_UNBOUND_VARIABLE`
  instead of being captured.
- **Termination (§19.4, §28):** a macro called while its own expansion is
  in progress (directly or through other macros) is
  `E_MACRO_NON_TERMINATION`; since bodies are not evaluated, such an
  expansion can never finish. Expansion nested more than 256 deep is
  reported the same way.
- **Runtime access (§19.4):** a `defmacro` anywhere but top level, where
  its body could name run-time variables of the enclosing form, is
  `E_MACRO_ILLEGAL_ACCESS`.
- **Pipeline position:** expansion runs after module resolution and
  before the static checks and type inference (see the pipeline in
  `spec/00-language-overview.md`).

### What is not implemented

- **Patterns.** Parameters are plain names, optionally ending in
  `&rest name`; there is no destructuring and no literal pattern.
- **List literals in templates.** `[0 ,@xs]` in a template splices into
  the arguments of the `Cons` the list literal became, which yields an
  ill-formed `Cons` and an `E_TYPE_MISMATCH`, not a longer list. Write
  `` `(0 ,@xs) ``.
