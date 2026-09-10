# Chapter 14: Lexical Structure and Syntax

This chapter provides a complete reference for Zyl's lexical structure and syntax grammar.

## 14.1 Source Encoding

- **Encoding**: UTF-8 only
- **Line endings**: LF (Unix) or CRLF (Windows) — both accepted
- **BOM**: Not recognized (treated as content)

## 14.2 Tokens

```
Token ::= Identifier
        | Integer
        | Float
        | String
        | Boolean
        | Symbol
        | Keyword
        | Punctuator

Punctuator ::= "(" | ")" | "{" | "}" | ":" | "[" | "]"
```

### Identifiers

```
Identifier ::= Letter (Letter | Digit | "-" | "_" | "?" | "!" | "*" | "+" | "-" | "/" | "=" | "<" | ">" | "%")*
Letter ::= [a-zA-Z] | Unicode_Letter
Digit ::= [0-9]
```

**Rules:**
- Case-sensitive
- Cannot start with digit
- `-` allowed internally (kebab-case convention)
- Special chars `?!*-/=<>%` allowed for operator-like names

### Integers

```
Integer ::= DecimalInteger
DecimalInteger ::= "0" | NonZeroDigit Digit*
NonZeroDigit ::= [1-9]
```

- **Base**: Decimal only (no hex, octal, binary)
- **Range**: Int64 signed (-2^63 to 2^63-1)
- **Overflow**: Compile error if out of range
- **No suffixes**: `L`, `UL`, etc. not supported

### Floats

```
Float ::= DecimalFloat
DecimalFloat ::= Digit+ "." Digit* Exponent?
             |  "." Digit+ Exponent?
             |  Digit+ Exponent
Exponent ::= ("e" | "E") ("+" | "-")? Digit+
```

- **Format**: IEEE-754 binary64 (double precision)
- **Special values**: `inf`, `-inf`, `nan` not representable as literals (use FFI)

### Strings

```
String ::= "\"" StringChar* "\""
StringChar ::= AnyCharExceptQuoteAndBackslash
             | EscapeSequence
EscapeSequence ::= "\\" | "\"" | "\n" | "\t" | "\r" | "\0"
```

- **Encoding**: UTF-8
- **Interpolation**: Not supported (use `buf-append` or FFI)
- **Raw strings**: Not supported

### Booleans

```
Boolean ::= "true" | "false"
```

### Symbols

```
Symbol ::= "'" Identifier
```

- Quoted identifier used as data
- Not evaluated as variable

### Keywords

```
Keyword ::= ":" Identifier
```

- Self-evaluating
- Used for options, modifiers

## 14.3 Comments

```
Comment ::= ";" AnyChar* Newline
```

- Line comments only
- No block comments
- No doc comments (convention: `;;` for documentation)

## 14.4 Whitespace

- Space, tab, newline, carriage return
- Token separator only — no semantic meaning
- No significant indentation

## 14.5 Grammar (EBNF)

```
Program ::= TopLevelForm*

TopLevelForm ::= Definition
               | Expression

Definition ::= "def" Identifier Expression
             | "defn" Identifier "(" Param* ")" Expression
             | "defun" Identifier "(" Param* ")" Expression
             | "defmacro" Identifier "(" Pattern* ")" Template
             | "defstruct" Identifier "(" Field* ")" DeriveClause?
             | "defstruct+" Identifier "(" Field* ")" DeriveClause?
             | "deftype" Identifier "(" Variant* ")" BoundClause?
             | "trait" Identifier "(" TraitMethod* ")" BoundClause?
             | "impl" Identifier Identifier "(" ImplBody* ")"
             | "alias" Identifier TypeExpr
             | "derive" Identifier "[" Identifier* "]"
             | "use" Identifier ImportSpec
             | "export" Identifier
             | "module" Identifier

Param ::= Identifier
        | "(" Identifier TypeExpr ")"

Field ::= "(" Identifier ")"

Variant ::= "(" Identifier TypeExpr* ")"

TraitMethod ::= "(" Identifier "(" Param* ")" TypeExpr ")"

ImplBody ::= "defn" Identifier "(" Param* ")" Expression

BoundClause ::= ":" Identifier "[" Identifier* "]"

DeriveClause ::= ":derive" "[" Identifier* "]"

ImportSpec ::= "{" Identifier ("," Identifier)* "}"
             | "*"
             | ":unsafe" "{" Identifier ("," Identifier)* "}"

Expression ::= Atom
             | List

Atom ::= Integer
       | Float
       | Boolean
       | String
       | Symbol
       | Keyword
       | Identifier

List ::= "(" Expression* ")"

Pattern ::= Identifier
          | "_"                    ; Forbidden in user code
          | "(" Pattern* ")"

Template ::= Expression            ; With quasiquote/unquote
```

## 14.6 Reserved Keywords

Cannot be used as identifiers in definition forms:

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

**Error**: `E_RESERVED_KEYWORD`

## 14.7 Precedence and Associativity

**No operator precedence** — all grouping explicit via parentheses.

```
(+ 1 (* 2 3))    ; Explicit: 1 + (2 * 3)
(* (+ 1 2) 3)    ; Explicit: (1 + 2) * 3
```

All operators are prefix functions with n-ary semantics.

## 14.8 Evaluation Order

**Strict left-to-right** for all expressions:

```
(f a b c)
;; 1. Evaluate f
;; 2. Evaluate a
;; 3. Evaluate b
;; 4. Evaluate c
;; 5. Apply f to (a, b, c)
```

Applies to:
- Function arguments
- `let` bindings (parallel, but initializers evaluated left-to-right in outer scope)
- `if` branches (condition, then, else)
- `match` scrutinee, then patterns
- Arithmetic operands