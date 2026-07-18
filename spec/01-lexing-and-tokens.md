# Zyl Specification — Lexing and Tokens

**Canonical authority:** `zyl_specification.txt` §1
**Related:** `spec/02-syntax-and-forms.md`
**Implementation:** `src/lexer.rs`, `src/parser.rs`

---

## 1.1 Source Encoding

UTF-8.

## 1.2 Tokens

```
IDENTIFIER | INTEGER | FLOAT | STRING | BOOLEAN | SYMBOL | KEYWORD
"(" | ")" | "{" | "}" | ":" | "[" | "]"
```

## 1.3 Keywords

The following identifiers are reserved keywords and cannot be used as user identifiers:

```
def, defn, defun, let, let-mut, if, try, catch, spawn, send,
ffi-call, ffi-pin, ffi-unpin, assert, trait, impl, fn, lambda,
while, for, cond, begin, pub, use, export, requires, ensures, invariant,
recover, checkpoint, contracts, defmacro, alias, defstruct, defstruct+,
with-resource, derive, unwrap, error, Ok, Err, match, struct-get,
make-, test-suite, test, assert-equal, assert-fail, assert-true,
assert-false, test-property, setup, teardown, run-tests, test-compile
```

## 1.3.1 Reserved Keywords as Identifiers

The keywords listed in §1.3 are reserved and MUST NOT be used as identifiers
(variable names, function names, type names) in any definition form (def, defn,
deffun, let, let-mut, fn, lambda, trait, impl, deftype, alias, derive,
defstruct, defstruct+, module, use, export). Attempting to do so is a compile-time
error: `E_RESERVED_KEYWORD`. This prevents users from accidentally shadowing core
language constructs and breaking the compiler's dispatch mechanism.

## 1.4 Comments

```
; line comment
```

## 1.5 Whitespace

Whitespace is a token separator only.
