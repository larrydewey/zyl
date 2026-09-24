# Zyl Specification — Macros and Hygiene

**Canonical authority:** `zyl_specification.txt` §19
**Related:** `spec/02-syntax-and-forms.md`
**Implementation:** `stdlib/compiler/macro_expand.zyl` (expansion), `stdlib/compiler/expr_inner.zyl` (`parse-macro`)

---

## 19.1 Macro Definition

```
(defmacro name (pattern*) template)
```

## 19.2 Hygiene

Gensym-based hygiene. All macro-introduced variables are renamed to unique symbols.

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
  a synonym. The body is the last form after the parameter list.
- **Registration (§19.5):** top-level macro definitions are collected
  before expansion (`me-collect`) and then removed from the program
  (`me-strip`). A macro defined anywhere other than top level is not
  registered.
- **Expansion order (§19.3):** innermost first. For a call to a registered
  macro, the arguments are expanded first; the body is then instantiated
  with its parameters bound to the expanded arguments, and the result is
  walked again, so a macro call produced by an expansion is itself
  expanded.
- **Substitution:** a parameter name occurring as a bare identifier in the
  body is replaced by the corresponding argument. Parameters are paired
  with arguments positionally; extra arguments or parameters are ignored.
- **Pipeline position:** expansion runs after module resolution and
  before the static checks and type inference (see the pipeline in
  `spec/00-language-overview.md`).

### What is not implemented

- **Hygiene (§19.2).** There is no gensym renaming. A name introduced by a
  macro body can capture, or be captured by, a name at the call site.
- **Patterns.** Parameters are plain names; there is no `&` rest parameter
  and no destructuring.
- **Termination check.** There is no expansion depth limit, so a
  self-recursive macro does not terminate. `E_MACRO_NON_TERMINATION` is
  catalogued in `error_codes.zyl` but never raised.
- **Runtime-access check (§19.4).** `E_MACRO_ILLEGAL_ACCESS` is catalogued
  but never raised.
- **Coverage.** The expander descends into applications, calls, `let`,
  `let-mut`, `if`, `while`, `set!`, `begin`, `print`, the `assert-*`
  forms, `struct-get`, `defn` and `test`. A macro call inside `match`,
  `fn`/`lambda`, `for`, `try`, `with-resource`, `deftype` or `impl` is
  left unexpanded.
