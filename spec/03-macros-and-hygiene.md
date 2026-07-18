# Zyl Specification — Macros and Hygiene

**Canonical authority:** `zyl_specification.txt` §19
**Related:** `spec/02-syntax-and-forms.md`
**Implementation:** `src/macro_expander.rs`

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

## Pattern Matching

- Variables: match any expression, bind to name
- Literals: match exactly
- `&` prefix: variadic (matches zero or more)
- Built-in operators are excluded from macro expansion (+, -, *, /, <, >, ==, !=, etc.)

## Gensym Hygiene

All macro-introduced variables are renamed to unique symbols using a
monotonically increasing counter. This prevents variable capture:

```lisp
(let x 1 (my-macro (let x 2 body)))
```

The internal `x` in `my-macro` expands to a gensym (e.g., `_gensym_1`) that
does not capture the outer `x`.

## ___skip_ Placeholder

Omitted `if` branches produce `Atom::Keyword("___skip_")`, which is treated
as Unit type during type inference.
