# Chapter 14: Lexical Structure and Syntax

This chapter is the reference for how Zyl source text becomes tokens and
then forms. The normative rules are in `zyl_specification.txt` §1 (lexical
structure) and §2 (abstract syntax). The behavior described under
"Implementation" comes from the self-hosted lexer
(`stdlib/compiler/lexer.zyl`), reader (`stdlib/compiler/parser.zyl`) and
post-processor (`stdlib/compiler/expr_inner.zyl`). Where the two differ,
the difference is stated.

## 14.1 Source Encoding

The specification says only that source is UTF-8 (§1.1).

The lexer works byte by byte and classifies ASCII only:

- **Non-ASCII bytes** are accepted inside string literals and comments.
  Anywhere else they are an unrecognized character (see 14.3), so
  identifiers are ASCII.
- **Line endings**: LF. A carriage return is whitespace, so CRLF files
  compile.
- **Byte-order mark**: not recognized. A leading BOM is an unrecognized
  character, the token stream ends before the first form, and the program
  is empty (the link step then reports a missing `main`).

## 14.2 Tokens

§1.2 lists the token classes:

```
IDENTIFIER | INTEGER | FLOAT | STRING | BOOLEAN | SYMBOL | KEYWORD
"(" | ")" | "{" | "}" | ":" | "[" | "]"
```

Every token carries its byte offset in the file, which is how diagnostics
report `file:line:col`.

### Identifiers

```
Identifier ::= IdentStart IdentCont*
IdentStart ::= [a-zA-Z] | "_" | "-" | "?" | "!" | "+" | "/" | "=" | "<" | ">" | "*" | "%"
IdentCont  ::= IdentStart | [0-9] | "."
```

- Case-sensitive, ASCII only.
- Cannot start with a digit. A `-` immediately followed by a digit starts
  a negative number instead; `-x` is an identifier.
- `.` may appear after the first character. This is what makes
  `Trait.method` a single identifier (Chapter 20).
- Operators are ordinary identifiers: `+`, `<=`, `set!`, `str-concat`,
  `=>` all lex the same way.
- `@` is not an identifier character. The module resolver relies on this:
  a name containing `@` is always a canonical symbol key (§31.2), never
  user text.

### Integers

```
Integer ::= "-"? ( Decimal | "0x" HexDigit+ | "0o" OctDigit+ | "0b" BinDigit+ )
Decimal ::= Digit+
```

- Decimal, plus `0x`, `0o` and `0b` prefixes in either case (`0xFF`,
  `0B1010`).
- Int64 signed (§20.1).
- No suffixes.

> **Implementation gap.** A literal outside the Int64 range is not
> rejected. The conversion routine returns 0 and the lexer uses that
> value, so `99999999999999999999` compiles as `0`.

### Floats

```
Float    ::= "-"? Digit+ ( "." Digit* )? Exponent?     ; needs "." or an exponent
Exponent ::= ("e" | "E") ("+" | "-")? Digit+
```

- IEEE-754 binary64 (§20.2).
- A float must start with a digit: `1.5`, `1.`, `1e3` and `2E-2` are
  floats, but `.5` is not a token at all.
- No `inf` or `nan` literal.

A numeric token that contains a second `.`, such as `1.2.3`, is not
rejected by the lexer. It reaches the assembler as a malformed constant,
and the build fails there.

### Strings

```
String     ::= "\"" ( AnyByteExceptQuoteOrBackslash | Escape )* "\""
Escape     ::= "\\n" | "\\t" | "\\r" | "\\0" | "\\\"" | "\\\\" | "\\e" | "\\x" HexDigit HexDigit
```

- `\e` is ESC (0x1b); `\xNN` is any byte.
- A literal may span lines.
- There is no interpolation and there are no raw strings.
- Strings are NUL-terminated at runtime, so `\0` ends the string early.
- An unterminated string is reported before reading starts, as
  `E_UNTERMINATED_STRING`.

> **Implementation gap.** An unknown escape such as `\q` is not reported.
> The whole literal decodes to a null string, which prints as an empty
> line.

### Booleans

```
Boolean ::= "true" | "false"
```

At runtime a boolean is the word 0 or 1; `(print true)` prints `1`.

### Keywords

```
Keyword ::= ":" Whitespace* Identifier
```

`:le` is a keyword token. The reader turns it into an identifier that
keeps its colon (`:le`), and whichever form contains it decides what it
means:

- the endian selector of the byte forms, `(load-u8 :le buf 0)`
  (Chapter 32);
- the `:unsafe` import marker and `package:module` paths in `use` (§24.2);
- `:derive` in `defstruct+` (Chapter 20).

A keyword is **not** self-evaluating. In expression position, `:kw` is
an unbound identifier (`E_UNBOUND_VARIABLE`).

The lexer skips whitespace between the colon and the name, so `: Ord` and
`:Ord` produce the same token. A `:` followed by anything that cannot
start an identifier is a bare colon token, and the reader turns a bare
colon into an empty list.

### Symbols

§1.2 lists a SYMBOL token but does not give its syntax. The lexer produces
one for `~name`, and the reader turns it into the plain identifier `name`.
A `~` followed by a non-identifier character is the one-character
identifier `~`.

There is no quote syntax. `'foo` and `(quote foo)` do not produce data:
the first ends the token stream (see 14.3) and the second is an ordinary
call to an undefined function.

### Delimiters

`( )`, `[ ]` and `{ }` are separate tokens, but the reader turns all three
into the same list node. The containing form decides what the group
means. For example, `{ a b }` is the symbol list of an import (§24.2), and
`[Eq Ord]` is a list of trait names. There are no vector or map literals.

Before the reader runs, `stdlib/compiler/sexp_balance.zyl` checks that
every opener has a closer of the same kind. It reports
`E_UNBALANCED_UNCLOSED`, `E_UNBALANCED_UNEXPECTED_CLOSE` or
`E_UNBALANCED_MISMATCHED_BRACKET` with the offending position and a hint.

## 14.3 Comments and Unrecognized Characters

```
Comment ::= ";" AnyByte* ( Newline | EndOfFile )
```

- `;` line comments only (§1.4). There are no block comments.
- `;;` and `;;;` are conventions for heavier comments, not separate
  syntax.

Any byte that is not whitespace, a delimiter, `"`, `:`, `~`, `;`, a digit
or an identifier character ends the token stream. The lexer treats it as
end of input. That includes `'`, `` ` ``, `,`, `@`, `#`, `$`, `&`, `|`,
`^`, `\` and non-ASCII bytes outside strings and comments.

> **Compiler defect.** Nothing reports this. The rest of the file is
> silently dropped, and if the parentheses before the stray character
> still balance, the program compiles and runs without the dropped code:
>
> ```lisp
> (defn main ()
>   (begin
>     (print 1)
>     @
>     (print 2)
>     0))
> ```
>
> This compiles without a diagnostic and prints only `1`. Because commas
> are unrecognized, never write `{ a, b }` in an import list: use
> `{ a b }`.

## 14.4 Whitespace

Space, tab, carriage return and line feed separate tokens and have no
other meaning (§1.5). Indentation is not significant. Other control
characters, such as form feed, are unrecognized characters (14.3).

## 14.5 Grammar

Zyl uses no-dispatch parsing (§2 and `docs/architecture-decisions.md`).
The reader produces only atoms and lists. A separate post-processor
decides which lists are special forms.

### Reader grammar

```
Program ::= Datum*
Datum   ::= Atom | "(" Datum* ")" | "[" Datum* "]" | "{" Datum* "}"
Atom    ::= Integer | Float | String | Boolean | Identifier | Keyword | Symbol
```

### Forms the post-processor recognizes

§2 gives the abstract syntax. The table shows what the self-hosted
post-processor actually does with each definition form.

| Form | Status |
|------|--------|
| `(defn name (Param*) body...)` | Recognized. |
| `(defun ...)` | Not recognized (§2 lists it as a synonym). It is an ordinary call, so the function is never defined and calls to it fail at link time. |
| `(def name expr)` | An immutable global, evaluated once, in source order, before `main` or the tests run. |
| `(deftype Name Variant+)` | Recognized (Chapter 18). |
| `(defstruct Name Field*)`, `(defstruct+ ...)` | Recognized. |
| `(trait Name ...)` | Accepted with no effect (Chapter 20). |
| `(impl Trait Type (defn ...)*)` | Recognized (Chapter 20). |
| `(derive Type Trait*)` | Generates `Show`; other traits accepted, nothing generated (Chapter 20). |
| `(alias Name Type)` | Accepted with no effect. |
| `(defmacro name (pattern*) template)` | Recognized; `macro` is a synonym (Chapter 23). |
| `(use path ...)`, `(module name)`, `(pub <definition>)` | Recognized (Chapter 25). `export` is accepted but deprecated (§24.3). |

```
Param    ::= Identifier | "(" Identifier TypeExpr ")"
Field    ::= Identifier | "(" Identifier ")" | "(" Identifier TypeExpr ")"
Variant  ::= Identifier | "(" Identifier TypeExpr* ")"
ImportSpec ::= "{" ( Identifier | Identifier "=>" Identifier )* "}"
             | "*"
             | ":unsafe" "{" Identifier* "}"
```

- A parameter is a bare name or `(name Type)`. Anything else is
  `E_MALFORMED_PARAMETER`, which catches a dropped `)` that would
  otherwise put the body into the parameter list.
- `_` is the discard name. `_` and any name that starts with `_` are
  exempt from the unused-binding and shadowing warnings and from
  `E_DUPLICATE_PARAMETER`, so `(defn f (_ _) 1)` is legal.
- A `defn` has no return-type slot. In `(defn f ((a Int)) Int body)`, the
  `Int` is read as the first body expression and is reported as an
  unbound identifier.
- Match arms and patterns are covered in Chapter 18.

## 14.6 Reserved Keywords

§1.3 reserves these names, and §1.3.1 makes it a compile-time error,
`E_RESERVED_KEYWORD`, to bind one of them in a definition form:

```
def, defn, defun, let, let-mut, if, try, catch, spawn, send,
ffi-call, ffi-pin, ffi-unpin, assert, trait, impl, fn, lambda,
while, for, cond, begin, pub, use, export, requires, ensures,
invariant, recover, checkpoint, contracts, defmacro, alias,
defstruct, defstruct+, with-resource, derive, unwrap, error,
Ok, Err, match, struct-get, make-, test-suite, test,
assert-equal, assert-fail, assert-true, assert-false,
test-property, setup, teardown, run-tests, test-compile
```

§30 lists this enforcement under FUTURE, and the compiler does not
enforce it. This program compiles and prints `3`:

```lisp
(defn main ()
  (let match 3
    (begin
      (print match)
      0)))
```

The only place `E_RESERVED_KEYWORD` is raised today is for the byte-access
widths that are reserved but not implemented (`load-u16`, `store-i64` and
the like; see Chapter 32).

## 14.7 Precedence and Associativity

There is no operator precedence. Every form is prefix, and grouping is
always explicit:

```lisp
(+ 1 (* 2 3))    ; 1 + (2 * 3)
(* (+ 1 2) 3)    ; (1 + 2) * 3
```

`+` and `*` accept any number of operands and fold them left to right
(§21.1).

## 14.8 Evaluation Order

Evaluation is strictly left to right (§0 P5, §11), and the compiler never
reorders side effects (§26):

```
(f a b c)
;; 1. Evaluate f
;; 2. Evaluate a
;; 3. Evaluate b
;; 4. Evaluate c
;; 5. Apply f to (a, b, c)
```

This applies to:

- function and constructor arguments;
- the operands of arithmetic and comparison;
- `let`: the initializer is evaluated before the body (`let` binds one
  name, so there is no parallel binding);
- `if`: the condition first, then exactly one branch;
- `begin`: each expression in order, and the value is the last one
  (§12.8);
- `match`: the scrutinee once, then arms tried in source order (§12.3).
