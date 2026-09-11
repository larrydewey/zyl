# Appendix C: Built-in Operations

Complete reference for all built-in operators and special forms.

## C.1 Arithmetic Operators

| Operator | Signature | Description |
|----------|-----------|-------------|
| `+` | `(+ Int...)` → `Int` | Sum (unary: identity) |
|  | `(+ Float...)` → `Float` | Sum (unary: identity) |
| `-` | `(- Int Int)` → `Int` | Difference (unary: negation) |
|  | `(- Float Float)` → `Float` | Difference (unary: negation) |
| `*` | `(* Int...)` → `Int` | Product (unary: identity) |
|  | `(* Float...)` → `Float` | Product (unary: identity) |
| `/` | `(/ Int Int)` → `Int` | Quotient (truncates toward 0) |
|  | `(/ Float Float)` → `Float` | Quotient (IEEE-754) |
| `%` | `(% Int Int)` → `Int` | Remainder (sign follows dividend) |

**All arithmetic is n-ary (except unary forms) and left-associative.**

### Overflow Behavior (Int)

- **Checked** (default): Runtime error `E_OVERFLOW`
- **Wrapping**: Not yet exposed
- **Saturating**: Not yet exposed

### Division by Zero

- **Int**: Runtime error `E_DIVISION_BY_ZERO`
- **Float**: Returns `inf`, `-inf`, or `nan` per IEEE-754

## C.2 Comparison Operators

| Operator | Signature | Description |
|----------|-----------|-------------|
| `==` | `(== a b)` → `Bool` | Structural equality |
| `!=` | `(!= a b)` → `Bool` | Structural inequality |
| `<` | `(< a b)` → `Bool` | Less than (Int, Float) |
| `>` | `(> a b)` → `Bool` | Greater than |
| `<=` | `(<= a b)` → `Bool` | Less or equal |
| `>=` | `(>= a b)` → `Bool` | Greater or equal |

**Structural equality** works on primitives — `Int`, `Float`, `Bool`, `String` —
and on values compared field-by-field. For structs and ADTs, `==` compares
identity (pointer), **not** structure: two separately-constructed equal structs
are *not* equal. Compare struct fields individually instead
(e.g. `(== (struct-get p "x") (struct-get q "x"))`).

## C.3 Boolean Operators (Short-Circuiting)

| Operator | Signature | Description |
|----------|-----------|-------------|
| `and` | `(and Bool...)` → `Bool` | Short-circuit AND |
| `or` | `(or Bool...)` → `Bool` | Short-circuit OR |
| `not` | `(not Bool)` → `Bool` | Logical negation |

**Implemented as macros** expanding to `if` — not special forms.

## C.4 Type Predicates

| Operator | Signature | Description |
|----------|-----------|-------------|
| `int?` | `(int? x)` → `Bool` | Is Int? |
| `float?` | `(float? x)` → `Bool` | Is Float? |
| `bool?` | `(bool? x)` → `Bool` | Is Bool? |
| `string?` | `(string? x)` → `Bool` | Is String? |
| `struct?` | `(struct? x)` → `Bool` | Is struct? |
| `alias?` | `(alias? x)` → `Bool` | Is alias? |

## C.5 Collection Operations

| Operator | Signature | Description |
|----------|-----------|-------------|
| `len` | `(len Vec/Map/String)` → `Int` | Length |
| `vec` | `(vec Elem...)` → `Vec` | **Not a builtin** — use `vec-create` |
| `map` | `(map K V...)` → `Map` | **Not a builtin** — use `map-create` |
| `tuple` | `(tuple Elem...)` → `Tuple` | **Not implemented** — reserved name |

**Note**: `vec`, `map`, and `tuple` are reserved identifiers but the literal
forms themselves are not implemented yet — use the stdlib collection functions
and structs for grouping values.

## C.6 Mutation

| Operator | Signature | Description |
|----------|-----------|-------------|
| `set!` | `(set! var value)` → `Unit` | Rebinding (let-mut only) |

**No field mutation** — `set! (struct-get p "x") 5` is forbidden.

## C.7 I/O Operations

| Operator | Signature | Description |
|----------|-----------|-------------|
| `print` | `(print Expr...)` → `Unit` | Write to stdout |
| `read-line` | `(read-line)` → `Result<String, String>` | Read stdin line |
| `exit` | `(exit Int)` → `Never` | Terminate program |
| `close` | `(close Handle)` → `Unit` | Close resource |
| `file-open` | `(file-open Path Mode)` → `Int` | Open file (Mode: `"r"`, `"w"`, `"a"`) |
| `file-read` | `(file-read Handle Count)` → `String` | Read bytes from file |
| `file-write` | `(file-write Handle Data)` → `Int` | Write data to file |
| `file-close` | `(file-close Handle)` → `Unit` | Close file |

## C.8 Error Operations

| Operator | Signature | Description |
|----------|-----------|-------------|
| `error` | `(error String)` → `Result<T, String>` | Creates `(Err msg)` |
| `unwrap` | `(unwrap Result)` → `T` | Extracts `Ok` or panics |

## C.9 Special Forms (Core Syntax)

| Form | Syntax | Description |
|------|--------|-------------|
| `def` | `(def Name Expr)` | Top-level constant |
| `defn` | `(defn Name (Params...) Body)` | Function definition |
| `defun` | Same as `defn` | Synonym |
| `let` | `(let (Name Expr) Body)` | Immutable binding |
| `let-mut` | `(let-mut (Name Expr) Body)` | Mutable binding |
| `if` | `(if Cond Then Else)` | Conditional (3-armed) |
| `try` | `(try Expr (catch Name Expr))` | Error handling |
| `match` | `(match Expr (Variant Pat Body)...)` | Pattern match |
| `spawn` | `(spawn Expr)` → `ActorRef` | Spawn actor |
| `send` | `(send ActorRef Expr)` → `Unit` | Send message |
| `ffi-call` | `(ffi-call String Expr* Int)` → `Result` | FFI call |
| `ffi-pin` | `(ffi-pin Expr)` → `TPin` | Pin for FFI |
| `ffi-unpin` | `(ffi-unpin Expr)` → `Unit` | Unpin memory |
| `assert` | `(assert Expr String)` → `Unit` | Runtime check |
| `while` | `(while Cond Body)` → `Unit` | Loop |
| `for` | `(for (Bindings) Cond Body)` → `Unit` | Loop with init |
| `cond` | `(cond (Cond Body)... (else Body))` | Multi-way branch |
| `begin` | `(begin Expr+)` → `Last Expr` | Sequence |
| `error` | See C.8 | Create error |
| `unwrap` | See C.8 | Extract or panic |

## C.10 Definition Forms (Extended)

| Form | Syntax | Description |
|------|--------|-------------|
| `trait` | `(trait Name (Methods...) Bound?)` | Trait declaration |
| `impl` | `(impl Trait Type (ImplBody...))` | Trait implementation |
| `deftype` | `(deftype Name (Variants...) Bound?)` | ADT declaration |
| `defstruct` | `(defstruct Name (Fields...) Derive?)` | Struct declaration |
| `defstruct+` | `(defstruct+ Name (Fields...) Derive?)` | Struct with derive |
| `alias` | `(alias Name Type)` | Type alias |
| `derive` | `(derive Type [Traits...])` | Standalone derive |
| `defmacro` | `(defmacro Name (Patterns...) Template)` | Macro definition |
| `with-resource` | `(with-resource (Name Expr) Body)` | RAII |
| `module` | `(module Name)` | Module declaration |
| `use` | `(use Module ImportSpec)` | Import |
| `export` | `(export Name)` | Export symbol |
| `requires` | `(requires Expr)` | Precondition |
| `ensures` | `(ensures Expr)` | Postcondition |
| `invariant` | `(invariant Expr)` | Loop invariant |
| `recover` | `(recover ((ErrorType Expr)...))` | Recovery |
| `checkpoint` | `(checkpoint Expr)` | Checkpoint scope |
| `contracts` | `(contracts Profile)` | Contract profile |

## C.11 Testing Forms

| Form | Syntax | Description |
|------|--------|-------------|
| `test-suite` | `(test-suite String (Tests...) Keywords?)` | Test group |
| `test` | `(test String Body Keywords?)` | Test case |
| `assert-equal` | `(assert-equal Expr Expr)` | Equality check |
| `assert-fail` | `(assert-fail Expr String?)` | Expect error |
| `assert-true` | `(assert-true Expr String?)` | Expect true |
| `assert-false` | `(assert-false Expr String?)` | Expect false |
| `test-property` | `(test-property String Gen Property)` | Property test |
| `setup` | `(setup Body+)` | Per-test setup |
| `teardown` | `(teardown Body+)` | Per-test teardown |
| `run-tests` | `(run-tests Keywords?)` | Execute tests |
| `test-compile` | `(test-compile Expr ExpectError?)` | Compile test |

## C.12 REPL Commands

| Command | Description |
|---------|-------------|
| `:help` | Show commands |
| `:quit` | Exit REPL |
| `:type <expr>` | Show inferred type |
| `:ast <expr>` | Show parsed AST |
| `:icnf <expr>` | Show ICNF |
| `:macroexpand <expr>` | Show macro expansion |
| `:macroexpand-all <expr>` | Full macro expansion |

## C.13 Compiler Flags

> **Status**: `-o` is implemented; the `--emit-*` family, `--test`,
> `--filter`, and `--boot`/`--no-boot` flags are on the compiler roadmap. For
> phase dumps today, the Rust bootstrap accepts `--dump-icnf <path>` (ICNF
> JSON) and `--emit-zyl <path>`.

| Flag | Description |
|------|-------------|
| `--emit-ast` | Output Phase 1 AST |
| `--emit-expanded` | Output Phase 2 expanded AST |
| `--emit-typed` | Output Phase 3 typed AST |
| `--emit-regions` | Output Phase 4 region AST |
| `--emit-mono` | Output Phase 5 monomorphized AST |
| `--emit-icnf` | Output Phase 6 ICNF |
| `--emit-opt` | Output Phase 7 optimized ICNF |
| `--emit-asm` | Output Phase 8 assembly |
| `-o <file>` | Output executable name |
| `--test` | Run tests in file |
| `--filter <pattern>` | Filter tests |
| `--no-boot` | Skip boot fixed point in tests |
| `--boot` | Force boot fixed point in tests |