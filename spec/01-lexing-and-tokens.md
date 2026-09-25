# Zyl Specification — Lexing and Tokens

**Canonical authority:** `zyl_specification.txt` §1
**Related:** `spec/02-syntax-and-forms.md`
**Implementation:** `stdlib/compiler/lexer.zyl`, `stdlib/compiler/parser.zyl`

---

## 1.1 Source Encoding

UTF-8.

## 1.2 Tokens

```
IDENTIFIER | INTEGER | FLOAT | STRING | BOOLEAN | SYMBOL | KEYWORD
"(" | ")" | "{" | "}" | ":" | "[" | "]" | "'"
```

### 1.2.1 Reader sugar

| Written | Reads as | Meaning |
|---------|----------|---------|
| `[e1 ... en]` | `(list e1 ... en)` | a list literal (§4.9) |
| `'d` | `(quote d)` | quoted constant data (§4.9) |

In a derive, `(derive T [Eq Show])` and `(:derive [Eq Show])`, the
bracket still names traits. Any other character outside a string or
comment, such as a backtick, is `E_INVALID_CHAR`.

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
defun, let, let-mut, fn, lambda, trait, impl, deftype, alias, derive,
defstruct, defstruct+, module, use, export). Attempting to do so is a compile-time
error: `E_RESERVED_KEYWORD`. This prevents users from accidentally shadowing core
language constructs and breaking the compiler's dispatch mechanism.

## 1.4 Comments

```
; line comment
```

## 1.5 Whitespace

Whitespace is a token separator only.

---

## Implementation Notes

These notes describe the self-hosted lexer (`stdlib/compiler/lexer.zyl`)
and reader (`stdlib/compiler/parser.zyl`). They are not normative; where
they differ from the text above, the difference is recorded as a known
divergence.

### Token kinds

`TkIdent`, `TkInt`, `TkFloat`, `TkString`, `TkBool`, `TkSymbol`,
`TkKeyword`, `TkLParen`, `TkRParen`, `TkLBrace`, `TkRBrace`, `TkLBracket`,
`TkRBracket`, `TkColon`, `TkQuote` and `TkEof`. Every token carries its byte offset
in the source, which is how diagnostics report `file:line:col`.

### Literals

- **Integers:** decimal, plus `0x`, `0o` and `0b` radix prefixes (either
  case). A `-` immediately followed by a digit begins a negative literal.
- **Floats:** a digit run containing `.` or an `e`/`E` exponent (radix
  literals excepted).
- **Strings:** `"..."` with the escapes `\n \t \r \0 \" \\ \e` and `\xNN`.
- **Booleans:** exactly `true` and `false`.
- **Bytes:** there is no byte literal syntax. A byte is written with the
  special form `(byte N)`, where `N` is an integer literal in 0–255;
  anything else is `E_BYTE_VALUE_OOB`.
- There are no character literals.

### Identifiers, keywords and symbols

- An identifier starts with a letter or one of `_ - ? ! + / = < > * %`,
  and may continue with those characters, digits and `.`.
- `:name` is a keyword token. The reader keeps the colon (`AstIdent ":name"`),
  which is what lets the module resolver tell `(use pkg:mod)` from
  `(use pkg mod)` (§24.2). A bare `:` is `TkColon`.
- `~name` is a symbol token and reads as the identifier `name`.
- `@` is not an identifier character. The resolver relies on this: a name
  containing `@` is always a canonical symbol key (§31.2), never user text.

### Delimiters

`( )`, `[ ]` and `{ }` are all tokens. The reader turns a `( )` or `{ }`
group into a list node; the meaning of `{...}` is decided by the form
that contains it (for example the `{ symbol }` import list of §24.2). A
`[ ]` group reads as a list node headed by the identifier `list`, so
`[1 2 3]` is `(list 1 2 3)` (`bracket-forms`, `parser.zyl`); a derive's
trait list drops that head (`derive-drop-list`, `expr_inner.zyl`). There
are no vector or map literals.

`'` is `TkQuote`: the reader reads the next form `d` and returns
`(quote d)` (`read-quote`).

Before reading, `stdlib/compiler/sexp_balance.zyl` checks that every
opener has a matching closer of the same kind and reports
`E_UNBALANCED_UNCLOSED`, `E_UNBALANCED_UNEXPECTED_CLOSE` or
`E_UNBALANCED_MISMATCHED_BRACKET` with the offending position.

### Comments

Only `;` line comments exist. A character the lexer does not recognise
(a backtick, say) is `E_INVALID_CHAR`.

### Reserved keywords (§1.3.1)

Not enforced. `E_RESERVED_KEYWORD` is catalogued and not raised. Binding a §1.3 keyword as a
name, for example `(let match 3 ...)`, compiles. The canonical §30 lists
this enforcement under FUTURE.
