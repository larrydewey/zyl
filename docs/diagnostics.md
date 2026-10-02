# Diagnostics: the compiler speaks like a mentor

Every message the compiler, the REPL or a compiled program's runtime
prints is written to these rules. They apply to a compile error, a
warning, a runtime panic (`E_OVERFLOW`, `E_DIVISION_BY_ZERO`,
`E_CONTRACT_VIOLATION`, ...) and to the help text of a tool. A message
that breaks one is a bug.

## The shape

1. **Head line, under 80 characters: what is wrong, in plain words,
   naming the user's identifier.** Not what the compiler was doing, not
   what it expected in its own terms. "`+` on Int needs a numeric
   policy, and this package declares none", not "unify failed".

2. **One sentence of why, only when the reason is security or is not
   obvious.** A missing paren needs no why. A refused `/` does: Zyl
   stops only where the source says it may.

3. **The fix, as the exact line to write, in a code span, imperative.**
   "write `(numeric checked)` at the top of the file", not "consider
   declaring a policy". When there are several fixes, name each with
   what it does: "`(div! a b)` to stop the program on a zero divisor,
   `(div? a b)` to get None, or divide by a nonzero literal".

The renderer (`error_report.zyl`) prints these as

```
error[E_PARTIAL_OPERATION]: `/` has a divisor that may be zero
  --> src/stats.zyl:14:22
   |
14 |   (let mean (/ total count)
   |                      ^
   = help: write `(div! a b)` to stop the program on a zero divisor, `(div? a b)` to get None, or divide by a nonzero literal
```

A runtime panic has no source span (the program has already been
built), so it carries the same head and help on one message:

```
error[E_OVERFLOW]: integer overflow in `+`
  = help: write `(numeric wrapping)` at the top of the file if wrap-around is intended, or `(numeric saturating)` to clamp
```

## Where it points

**At the offending expression, never at the enclosing `defn` head.** A
diagnostic about a divisor points at the divisor; one about an operator
points at the operator's form. A secondary label may name the
definition ("in this definition") when the error is about a boundary
between two things, as a capability violation is; it is never the
primary span.

## Words that may not appear

No internal vocabulary. Never: "unify", "ICNF", "operator code",
"lower", "annotate", a pass name, a node kind, a register, "the
backend". The user wrote Zyl, and the message is about their Zyl. The
error code is the pointer to everything else: `zyl explain CODE` prints
the catalog entry, the phase, and every place in the tree that raises it.

## One message per root cause

A single mistake produces a single diagnostic. A missing policy is
reported at the first operation that needs one, not at all forty; a
malformed form is reported once, where it is. The type checker is the
exception that proves the rule: it reports every type error, then fails
once, because each type error is its own root cause.

## Checklist for a new diagnostic

- Head line under 80 characters, names the identifier, plain words.
- Why: present only if security or non-obvious; one sentence.
- Fix: exact text in a code span, imperative.
- Span: the offending expression.
- No internal vocabulary.
- The code is in `error_codes.zyl` (so `zyl explain` knows it) and in
  `spec/15-error-model.md` and `docs/errors.md`.
- A compile-fail test under `tests/compile-fail/` pins the code and,
  where it matters, the location (`; expect-at: FILE:LINE:COL`).
