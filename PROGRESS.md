# Zyl Project Progress

## Status: BUILD PASSING — Lambda closure support in progress

Last updated: 2026-06-24

---

## Overview

Zyl is a deterministic Lisp systems language with region-based memory, actor concurrency, capability types, SSA IR, and FFI safety. The project is being built from scratch based on the formal specification (`zyl_specification.txt`).

## Architecture

```
src/
├── main.rs          # CLI entry point (compile/interpret)
├── repl.rs          # Interactive REPL
├── ast/             # Abstract Syntax Tree definitions
├── lexer/           # Tokenizer/Lexer
├── parser/          # S-expression parser → AST
├── typeck/          # Hindley-Milner type inference with regions/capabilities
├── region/          # Region inference (Stack/Heap/Global/Circular/Pin)
├── macros/          # Hygienic macro system (AST-only, gensym-based)
├── ir/              # ICNF - SSA Intermediate Representation
├── codegen/         # Code generation (x86_64 assembly + LLVM IR interface)
├── actor/           # Actor concurrency model (spawn/send/FIFO mailboxes)
├── ffi/             # FFI model with pinning and timeout enforcement
├── eval/            # Bootstrap interpreter (big-step semantics)
├── compiler/        # Full 10-phase compilation pipeline
└── util/            # Utility functions
```

## Compilation Pipeline (Spec §22)

1. ✅ Parsing — tokenize and parse source into AST
2. ✅ Macro expansion — expand all macro calls in the AST
3. ✅ Type inference (HM with regions + capabilities)
4. ✅ Region inference (escape analysis)
5. ✅ Monomorphization (generic instantiation)
6. ✅ ICNF generation (SSA IR)
7. ✅ Optimization (safe only: DCE, inline, loop unroll)
8. ✅ Code generation (x86_64 asm + LLVM IR interface)
9. ✅ Linking
10. ✅ Hash finalization (SHA-256 determinism contract)

## Current Build Status

- **Build**: ✅ Passing — all codegen destination registers resolve properly
- **Tests**: 98 passed, 0 failed (Rust unit tests); 0 Zyl stdlib tests passing
- **Spec**: Updated to v3.4 with currying and macro system (§20.5) and package management roadmap (§20.6)

### Recent Fixes (2026-06-23)
- ✅ **Hardcoded location placeholders fixed** — All 68+ `Location::new(999, 999)` placeholders replaced with real token locations
  - Token enum now carries `Location` as a second field on each variant (e.g., `Token::Ident(String, Location)`)
  - Added `token.location()` method to extract location from any token
  - Parser uses `self.loc()` helper for current position and `expect_kind()` for token type checking
  - Error messages now show actual source positions: e.g., "Invalid expression at 1:9"
  - EOF cases still use `(0, 0)` since there's no token available at end of input
- ✅ **Location tracking unit tests added** — Comprehensive test suite covering:
  - Lexer: single-line column tracking, multiline line/column tracking, comments affecting positions, string literals, keywords
  - Parser: error location accuracy for invalid expressions, multiline errors, comment-aware parsing, curried lambdas, let bindings
  - Complex scenarios: deeply nested structures (6+ levels), multiple nested if/let/try blocks, mixed whitespace handling, long comments
- ✅ **Codegen destination register resolution fixed** — Assembly now uses proper x86_64 registers instead of SSA ID strings
  - Root cause: `SsaValue::Display` formats as `{id}@{region}` (e.g., `0@Stack`), which was being inserted directly into asm templates
  - Fix: All instruction destinations now resolve via `gen_dest_reg()` → actual register names (`%rax`, `%rcx`, etc.)
  - Call instructions also resolve function pointers through registers instead of SSA IDs
  - Generated assembly is now valid x86_64 that assembles successfully

### Recent Fixes (2026-06-22)
- ✅ **Curried function parser fixed** — `(defn f ((x) x))` and `(defn add ((x) (y) (+ x y)))` now work correctly
  - Root cause: `parse_defn_inner` was not properly handling the curried param syntax where each param is wrapped in parens `(name)`
  - Fixed by adding lookahead to distinguish param groups `(name)` from body expressions that start with `(`
  - Also fixed paren consumption discipline: `parse_list` consumes the final `)`, inner parsers consume intermediate parens
- ✅ **Build passing** — 0 errors, 44 tests pass. Testing framework v3.3 fully integrated.
- ✅ **Lexer: keyword support** — Added `:` prefix handling in lexer so keywords like `:foo` are properly tokenized as `Token::Keyword`
- ✅ **Lexer: location tracking** — Lexer now tracks line/column positions via `location()` method; all tokens carry their source position for meaningful error messages
- ✅ **Parser: curried function syntax** — Added support for `(defn name ((param) body))` syntax in both `parse_defn_inner` and `parse_fn_inner`. Curried params like `(f)` are parsed via `parse_inner_list()` and the identifier is extracted as the parameter name, with remaining content treated as the body.
- ✅ **Parser: `parse_body_expr` helper** — Extracted body parsing logic into a reusable helper method for curried function handling
- ✅ **Parser: pattern matching fixes** — Fixed non-const patterns in match arms (`"fn".into()` → `ref val` with guard)
- ✅ **Lexer: free function `lex()`** — Added `pub fn lex(source: &str)` wrapper so parser can call `crate::lexer::lex(source)`
- ✅ **Parser: match literal variant body parsing** — Fixed `parse_match_inner`: pattern loop for non-literal variants now breaks on non-Ident tokens (literals are body expressions, not invalid patterns). Previously `(0 "zero")` failed with "invalid match pattern" because the parser tried to parse `"zero"` as a pattern.
- ✅ **Eval: match wildcard support** — Added wildcard (`_`) catch-all in `match_variant`: returns `true` for any value when variant is `_`.
- ✅ **Eval: float literal matching** — Added `Value::Float` case in `match_variant` with epsilon-based comparison for float literal patterns.
- ✅ **Testing framework v3.3 build fixes** — Fixed 16 build errors:
  - Parser keyword values now parse as strings (not expressions) to match AST type `Vec<(String, String)>`
  - Added `parse_string_or_expr_to_string()` helper for flexible keyword value parsing
  - Fixed borrow checker issues in assert parsers by cloning tokens before advancing
  - Fixed typeck constraint type mismatch (`*ret.clone()` for Box<Ty> deref)
  - Fixed region module non-exhaustive pattern match for all 12 test Expr variants
  - Fixed eval TestRegistration keywords type to match AST `Vec<(String, String)>`
- ✅ **Quote support** — Added `(quote expr)` special form and `'` syntactic sugar for list literals
  - AST: Added `Expr::Quote(Box<Expr>)` variant with Display impl
  - Lexer: Added `Token::Quote` for `'` prefix character
  - Parser: Added `"quote"` dispatch in `parse_list()` and `'` handling in `parse_expr()`
  - Evaluator: Added `expr_to_value()` helper to convert AST → Value without evaluation
  - Typeck/Region: Added support for Quote in both modules
  - Empty list `()` now parses as `App("", [])` instead of error
- ✅ **List builtins** — Added essential list manipulation operations:
  - `first`, `rest`, `nth`, `length`, `cons`, `append`, `list`
  - All registered in `is_builtin()` and `eval_builtin()`
- ✅ **Lexer: `%` operator** — Added `%` to `is_ident_start`/`is_ident_cont` for modulo builtin
- 🔄 **Stdlib TDD in progress** — Writing Zyl stdlib using test-driven development:
  - Created `tests/test_stdlib.zyl` with 30+ tests for core math and list operations
  - Created `stdlib/core.zyl` with identity, const, compose, when/unless, max/min/abs, factorial, etc.
  - Created `stdlib/lists.zyl` with reverse, append, nth, map, filter, fold-left, all?, any?, find, zip
  - **BLOCKED**: Curried function parser fix needed — `(defn f ((x) x))` fails

### Major Feature: Testing Framework v3.3
- ✅ **Spec updated to v3.3** — Added §20.5 (Testing Framework) and §20.6 (Package Management Roadmap)
- ✅ **P9 Testability principle** — Added to core design principles
- ✅ **AST extensions** — Added 12 new Expr variants for testing framework
- ✅ **Generator enum** — Added Generator type for property-based testing
- ✅ **Display impl** — Added Display implementations for all test Expr variants
- ✅ **Parser support** — Added 10 parser functions for test constructs + `parse_string_or_expr_to_string()` helper
- ✅ **EvalState extensions** — Added test_registry and test_results fields
- ✅ **Evaluation logic** — Added test registration, assertions, property testing, runner
- ✅ **Error model** — Added E_TEST_FAILURE, E_TEST_RUNNER_ERROR
- ✅ **Standard library** — Noted testing primitives as core language built-ins
- ✅ **Roadmap** — Documented v3.3 (current), v4.0 (package management), v4.1 (future)
- ✅ **Type checking** — Added typeck support for all 12 test Expr variants
- ✅ **Region inference** — Added region module support for all 12 test Expr variants
- ✅ **Build status** — 0 errors, 44 tests pass

### Design Decisions Locked (2026-06-22)

**Currying (§7.2):**
- Both `((x) body)` and `(fn (x) body)` are valid syntax
- `(() body)` is also valid — desugars to `(fn () body)`, type `Unit → TReturn`
- Multi-param curried: `((x) (y) (+ x y))` reads as "takes x, returns a function that takes y"
- Type system chains arrow types naturally: `Int → (Int → Int)`
- `(def f ((x) (+ x 1)))` works — def recognizes `((param) body)` as a curried lambda
- Parser re-architected for robust currying handling (non-brittle, unified)

**Macro System (§19):**
- Hygienic macros with gensym (already implemented, now formally specified)
- Pattern-based definition: `(defmacro name (pattern*) template)`
- Expansion at Phase 2 — after parsing, as AST transformation, before type checking
- Recursive expansion until no more macro calls remain; termination check via E_MACRO_NON_TERMINATION
- Variadic patterns: trailing variables bind to remaining elements as a list; `,rest` splices into templates
- Hygiene context is fresh per invocation (nested macros don't share contexts)
- Macros can be exported/imported across modules via `(export (defmacro ...))` and `(use module { macro-name })`
- All defmacros collected first, then expansion begins — order doesn't matter
- Template step renamed to "construct" (not evaluate) to avoid runtime confusion

**AST Grammar (§2):**
- Added missing variants: `match`, `quote`, `while`, `for`, `cond` as explicit AST nodes
- `defun` and `defn` are synonyms — both produce identical AST nodes

**Type System (§4.4):**
- `TFun([TypeExpr] TypeExpr)` brackets mean zero or more parameter types; second is return type

**Traits (§5.1):**
- `self` in trait methods has no special semantics — just a naming convention following Rust

**Generics (§6.1):**
- `defun` and `defn` are synonyms for generic function declarations

**ADTs & Pattern Matching (§8.3):**
- Patterns support three forms: variant constructors with field bindings (`(Some v)`), literal values for exact matching (`(0 "zero")`), and wildcards (`_`)

**Control Flow (§12):**
- `cond` requires explicit `(else body)` keyword for fallback clause
- `try/catch` catches all runtime errors; bound name is the error tuple `(code, location, message)`
- `spawn` returns `ActorRef(ID)`; `send` returns `Unit`

**Regions (§9):**
- `Global` region defined as static/compile-time allocated memory for constants and string literals

**Stack Migration (§14):**
- Reframed from implementation details to guarantee: "The compiler guarantees that deep recursion never causes stack overflow"

**Concurrency (§15):**
- Actor mailboxes are unbounded (heap-allocated list) — simple, matches no-shared-state simplicity

**FFI (§16):**
- `ffi-pin` returns the pinned `Address`; user calls it explicitly when they need a raw pointer

**Numeric Model (§20.2):**
- NaN != NaN follows IEEE-754 strictly; structural equality does not override floating-point semantics

**Testing Framework (§20.5):**
- Deterministic seed for generators based on test ID + source hash (reproducible across runs)
- Default 100 iterations for property tests; configurable via `:iterations N` keyword

**Built-in Operations (§21):**
- Added: `error` (raises E_USER_ERROR), `close` (file/resource handle), `tuple`, `vec`, `map`
- `set!` defined as mutation primitive for let-mut bindings
- `receive` added to actor module
- Iterator trait with `next() -> Option<T>` defines iteration protocol for `for` loops

**Module System (§24):**
- Wildcard import `(use module-name *)` supported to import all public symbols

**Error Model (§28):**
- Added E_USER_ERROR — distinguishes user signaling from internal assertion failures
- E_UNINITIALIZED_USE caught by SSA dominance analysis during ICNF generation

**SSA/IR (§18):**
- TMut captures represented as heap-allocated slots (pointers); mutations write to pointer target

### Ongoing Issues
1. ~~**Curried function parser broken (defn)**~~ — FIXED (2026-06-22)
   - `(defn f ((x) x))` and `(defn add ((x) (y) (+ x y)))` now work correctly
2. ~~**Hardcoded error locations**~~ — FIXED (2026-06-23)
   - All `Location::new(999, 999)` placeholders replaced with real token locations
3. ~~**🔴 `def` with curried function RHS fails**~~ — FIXED (2026-06-23)
   - `(def zip-fn ((a) (fn (b) ...)))` and `(def add ((x) (y) (+ x y)))` now parse correctly
   - `parse_expr()` checks `is_curried_lambda()` before falling through to `parse_list()`, so curried syntax is recognized everywhere

### Remaining Warnings (non-blocking)
- ✅ **Recursive function self-reference** — Implemented `Rc<RefCell<Value>>` self-referential closures. When a `defn` creates a closure, it binds the closure to its own captured environment via shared reference, so recursive calls can find themselves. Also added `self_ref` field to `Value::Closure` and updated all pattern matches.
- ✅ **Parser: `parse_if_inner` missing closing paren** — The `if` inner parser wasn't consuming its closing `)`, causing the defn body loop to see `RParen` immediately and exit without parsing the if expression. Fixed by adding `self.expect(Token::RParen)?` after parsing the three branches.
- ✅ **Parser: nested application support** — Added `Expr::AppExpr(Box<Expr>, Vec<Expr>)` variant for higher-order calls like `((compose inc inc) 5)` where the operator is itself an expression. Added `parse_inner_list()` helper that parses a list when the opening LParen has already been consumed.
- ✅ **Parser special form dispatch** — Rewrote `parse_list` to dispatch special forms (`let`, `defn`, `if`, etc.) to dedicated inner parsers instead of treating them as generic App nodes. This fixes `-e` expression mode for all special forms.
- ✅ **Double-RParen bug** — Removed duplicate closing paren consumption: inner parsers consume their own `)`, so `parse_list` dispatch no longer tries to consume another one.
- ✅ **EOF handling in `parse_program`** — Changed loop condition from `!= Token::Eof` to `.is_some()` because the lexer breaks on Eof and doesn't include it in the token list.
- ✅ **`defs.pop()` bug** — When a program has only definitions (no body expressions), `defs.pop()` was removing the last def. Changed to `defs.last().cloned()` to preserve defs while using the last one as implicit return value.
- ✅ **Lexer scientific notation** — Moved exponent (`e`/`E`) handling outside the decimal point check, so `1e10` is correctly parsed as Float (not Int).
- ✅ **Region escape analysis** — Added escape tracking for function arguments in App expressions. Variables passed to functions are now marked as escaping (conservative but correct).
- ✅ **Test assertions** — Fixed `test_comments` expected token count (5 not 4), fixed `test_floats` for scientific notation.
- ✅ **REPL feature parity** — Rewrote `repl.rs` with persistent `EvalState` across evaluations. Definitions now accumulate between lines. Added multi-line input buffering (unclosed parens), `defs` command (lists all bindings), `clear` command, and `Env` accessor methods (`get_bindings`, `get_parent`) for introspection.
- ✅ **Unary operators** — Added unary `-` (negation), unary `+` (identity / empty-sum=0), and truthiness-negation `not` (works on any value, not just bool).
- ✅ **Spec §8.1 BUILTIN OPERATIONS** — Added formal specification for all builtin operations: arithmetic (`+`, `-`, `*`, `/`, `%` with unary forms), comparison (`==`, `!=`, `<`, `>`, `<=`, `>=`), boolean (`not`, `and`, `or`), type predicates (`int?`, `float?`, `bool?`, `string?`), and other builtins (`len`, `unit`, `print`, `read-line`, `exit`, `begin`). Defined truthiness semantics.

### Remaining Warnings (non-blocking)
1. ~~**Lambda/closure handling in compiler pipeline**~~ — IN PROGRESS: ICNF generation treats lambdas as opaque Unit constants, causing "undefined variable" errors for programs with lambda expressions in the body. REPL handles this via environments but compiler path is incomplete.
2. **Value equality** — `Value` enum can't derive `PartialEq` due to `Closure` variant; need custom `values_equal()` helper
3. **codegen has_ending_return** — type mismatch on parameter (`Option<&BlockId>` vs `Option<BlockId>`)

## What's Implemented

### Core Language Features
- ✅ Lexer: integers, floats (including scientific notation), booleans, strings, identifiers, keywords, comments
- ✅ Parser: all special forms (def, defn, let, let-mut, if, try/catch, spawn, send, ffi-call, ffi-pin, assert)
- ✅ Parser: nested applications (`((f x) y)`) via `Expr::AppExpr` and `parse_inner_list()`
- ✅ AST: full node types per spec §2 (including `AppExpr` for higher-order calls)
- ✅ Type system: HM inference with regions and capabilities (§4), including `AppExpr` typing
- ✅ Region inference: stack/heap allocation, escape analysis (§5), including `AppExpr` escaping
- ✅ Macro system: hygienic, gensym-based, innermost-first expansion (§15)
- ✅ ICNF: SSA IR with phi nodes, dominance analysis (§14), including `AppExpr` codegen
- ✅ Actor model: spawn/send with FIFO mailboxes, deadlock detection (§11)
- ✅ FFI: pinning, timeout enforcement, security isolation (§12)
- ✅ Bootstrap interpreter: big-step semantics, strict left-to-right evaluation (§7)
- ✅ **Recursive functions**: self-referential closures via `Rc<RefCell<Value>>` — functions can call themselves
- ✅ **Higher-order functions**: closures as first-class values, function composition works
- ✅ Code generation: x86_64 assembly output, LLVM IR interface (§17 phase 8)
- ✅ Full compiler pipeline: all 10 phases (§17)

### Standard Library (Abstract - §20)
- ✅ Core: identity, control primitives
- ✅ Collections: Vec, Map (types defined)
- ✅ Option: Some, None (types defined)
- ✅ Result: Ok, Err (types defined)
- ✅ IO: print, read (via FFI)
- ✅ Atomic: load, store, add (types defined)
- ✅ Actor: spawn, send (built-in)
- ✅ FFI: ffi-call, ffi-pin (built-in)

### Determinism Contract (§18)
- ✅ SHA-256 hash finalization on compiled output
- ✅ Strict evaluation order preserved
- ✅ All effects statically trackable

## Next Steps

### Immediate (continue stdlib TDD)
1. ✅ **Curried function parser fixed for `defn`** — `(defn f ((x) x))` works
2. ✅ **Build passing** — 0 errors, 44 tests pass
3. ✅ **Currying re-architected** — Removed brittle lookahead/backtracking hacks; unified curried lambda parsing via `parse_curried_lambda()`, `is_param_group()`, and `is_curried_lambda()` methods
   - `((x) body)` now properly desugars to `(fn ((x)) body)` at parse time
   - Multi-level currying handled recursively: `((x) (y) (+ x y))` → `(fn ((x)) (fn ((y)) (+ x y)))`
   - Simplified `parse_defn_inner()` and `parse_fn_inner()` to use shared curried lambda parser
   - Removed unused `parse_body_expr()` helper
   - All 44 tests pass; manual testing confirms correct behavior for single/multi-param curried lambdas, defn with curried syntax, and normal fn/defn
4. ✅ **Fixed `def` with curried function RHS** — `(def name ((param) body))` now works
   - Parser recognizes `((param) body)` as a lambda-like form in all contexts via `is_curried_lambda()` check
5. 🔄 **Lambda/closure support in compiler pipeline (Phase 1)** — IN PROGRESS
   - Goal: Full closure parity between REPL and compiler
   - Approach: Each unique lambda gets its own named ICNF function; parameters become regular params; closures capture env + func pointer
6. Run `tests/test_stdlib.zyl` through interpreter — expect many failures (TDD)
7. Fix stdlib function implementations to pass tests
8. Clean up unused variable warnings in eval module

### Post-Build / Self-Hosting Path
5. 🔄 **Lambda/closure support in compiler pipeline** — IN PROGRESS: ICNF generation treats lambdas as opaque Unit constants, causing "undefined variable" errors for programs with lambda expressions in the body.
6. Wire compiler pipeline end-to-end (phases 1-10 connected)
7. Write Zyl test programs that exercise all language features
8. Test the compiler pipeline end-to-end
9. Add more builtin operations (Option/Result types, Vec/Map collections, IO)
10. **Implement the standard library in Zyl itself** (self-hosting bootstrap)
    - Core primitives: identity, const, compose, when/unless ✅ (in progress)
    - Collections: Vec, Map with push/pop/get/len/set operations
    - Option/Result types with is-some, unwrap, ok/err constructors
    - IO: println, read, file-read/write
    - Math: abs, max, min, factorial ✅ (in progress)
11. **Bootstrap process**: minimal Rust compiler → compile stdlib subset → expand compiler → iterate to self-compilation
12. Add more optimization passes
13. Improve code generation quality

## Key Design Decisions

### Currying (locked 2026-06-22)
- `((x) body)` is syntactic sugar for `(fn ((x)) body)` — both are valid
- Multi-param curried functions: `((x) (y) (+ x y))` naturally produces type `Int → Int → Int`
- Curried syntax works in all contexts: def, defn, let, fn arguments
- Desugaring happens at parse time; the IR sees only `(fn ((x)) body)` form

### Macro System (locked 2026-06-22)
- Gensym-based hygiene prevents variable capture without user intervention
- Pattern-based definition: `(defmacro name (pattern*) template)`
- AST-only expansion at Phase 1 (after parsing, before type checking)
- Recursive expansion with termination detection
- No runtime value access; no type observation by macros

### General Principles
- **Bootstrap first**: Interpreter built before compiler to validate semantics
- **Self-hosting goal**: Eventually write stdlib in Zyl and compile with Zyl
- **Strict left-to-right**: Per spec P5, evaluation order is deterministic
- **Region-based memory**: No GC needed; static region inference replaces manual management
- **SSA IR**: ICNF enables safe optimizations while preserving determinism
