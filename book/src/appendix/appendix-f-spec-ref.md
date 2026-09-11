# Appendix F: Language Specification Quick Reference

Condensed reference mapping Zyl Specification (v4.2) sections to language features.

## F.1 Specification Structure

| Section | Topic | Key Points |
|---------|-------|------------|
| 0 | Core Design Principles | P1-P9 (Determinism, Safety, Explicit Effects, Regions, Strict Eval, Phase Isolation, Inference, Optional Layers, Testability) |
| 1 | Lexical Structure | UTF-8, tokens, keywords, comments, whitespace |
| 2 | Abstract Syntax | Complete AST grammar |
| 3 | Value Model | Primitives, tuples, closures, actors, addresses, structs, Result, Unit |
| 4 | Type System | Primitives, composites, capabilities, functions, traits, inference |
| 5 | Trait System | Declaration, implementation, coherence, resolution, derive |
| 6 | Generics | Function/type params, bounds, monomorphization, ADTs, errors |
| 7 | Closures | Explicit syntax, capture inference, concurrency, effects |
| 8 | ADTs | Declaration, construction, pattern matching, exhaustiveness |
| 9 | Region System | Stack/Heap/Global/Circular/Pin, 8 region rules |
| 10 | Mutability & Aliasing | TCap/TMut invariant, struct immutability, alias transparency |
| 11 | Evaluation Semantics | Big-step, strict left-to-right, function/closure application |
| 12 | Control Flow | If, try/catch, match, assert, while, for, cond, begin, with-resource, error |
| 13 | Memory Operations | Stack, Heap, Circular, Pin, Global |
| 14 | Stack Safety | TCO guarantee |
| 15 | Concurrency | Actors: spawn, send, isolation, determinism |
| 16 | FFI | ffi-call, ffi-pin, ffi-unpin, FFI_Pinnable types |
| 17 | Monomorphization | Canonical naming, deterministic |
| 18 | ICNF | SSA IR with region annotations |
| 19 | Macros | Defmacro, hygiene, innermost-first, constraints |
| 20 | Numeric Model | Int64, Float64, division by zero, determinism |
| 20.5 | Testing | test-suite, test, assertions, fixtures, property-based, compile-time |
| 20.6 | Package Mgmt | v5.0 roadmap |
| 21 | Built-in Operations | Arithmetic, comparison, boolean, predicates, collections, mutation, I/O, errors |
| 22 | Compilation Pipeline | 11 phases, strict order |
| 23 | Contracts | Profiles, requires/ensures/invariant/recover/checkpoint |
| 24 | Modules | Declaration, import/export, visibility, resolution |
| 25 | Stdlib | Core modules |
| 26 | Implementation Contract | Must/May/Must Not |
| 27 | Determinism Contract | Observable vs non-observable |
| 28 | Error Model | 49 error codes, compile vs runtime |
| 29 | Formal Guarantees | G1-G11 |
| 30 | Version Roadmap | v4.0, v4.1, v4.2, v5.0 |

## F.2 Quick Syntax Reference

```
Program         ::= TopLevelForm*
TopLevelForm    ::= Definition | Expression

Definition      ::= (def Name Expr)
                | (defn Name (Params...) Body)
                | (defmacro Name (Patterns...) Template)
                | (defstruct Name (Fields...) Derive?)
                | (deftype Name (Variants...) Bound?)
                | (trait Name (Methods...) Bound?)
                | (impl Trait Type (ImplBody...))
                | (alias Name Type)
                | (derive Type [Traits...])
                | (use Module ImportSpec)
                | (export Name)
                | (module Name)

Expression      ::= Atom | List
Atom            ::= Int | Float | Bool | String | Symbol | Keyword | Identifier
List            ::= (Expression*)

Special Forms   ::= (let (Name Expr) Body)
                | (let-mut (Name Expr) Body)
                | (if Expr Expr Expr)
                | (try Expr (catch Name Expr))
                | (match Expr (Variant Pattern Expr)*)
                | (spawn Expr)
                | (send Expr Expr)
                | (ffi-call String Expr* Int)
                | (ffi-pin Expr)
                | (ffi-unpin Expr)
                | (assert Expr String)
                | (while Expr Expr)
                | (for (Bindings) Expr Expr)
                | (cond (Expr Expr)* (else Expr)?)
                | (begin Expr+)
                | (error String)
                | (unwrap Expr)
                | (fn (Params...) Body)
                | (lambda (Params...) Body)
```

## F.3 Key Invariants (Normative)

| # | Invariant | Section |
|---|-----------|---------|
| 1 | Same source + inputs → identical outputs/bins | P1, §27 |
| 2 | No undefined behavior | P2, G1 |
| 3 | No use-after-free, data races, nulls | P2, G2, G3 |
| 4 | All effects statically trackable | P3 |
| 5 | Region inference assigns Stack/Heap/Global/Circular/Pin | P4, §9 |
| 6 | Strict left-to-right evaluation | P5, §11 |
| 7 | Phases strictly ordered (1→11) | P6, §22 |
| 8 | Inference over annotation | P7, §4.6 |
| 9 | Contracts never alter core semantics | P8, §23 |
| 10 | Testing is built-in | P9, §20.5 |
| 11 | TCap/TMut aliasing invariant | §10 |
| 12 | Struct fields immutable (rebind only) | §10 |
| 13 | Match exhaustiveness mandatory | §8.3 |
| 14 | FFI requires Pin + timeout | §16 |
| 15 | Deterministic iteration (Map) | §4.2, §15 |
| 16 | Canonical monomorphization naming | §6.4, §17 |

## F.4 Phase Dependencies (Must Not Violate)

```
1. Parsing
   ↓ (no later phase deps)
2. Macro Expansion
   ↓
3. Type Inference + Trait Resolution
   ↓
4. Region Inference + Capture Analysis
   ↓
5. Monomorphization
   ↓
6. ICNF Generation
   ↓
7. Optimization
   ↓
8. Code Generation
   ↓
9. Linking
   ↓
10. Contract Injection
   ↓
11. Hash Finalization
```

## F.5 Error Code Categories

| Range | Category | Examples |
|-------|----------|----------|
| E_USER_ERROR | User `error` | — |
| E_MUT_CONFLICT | Capability | TMut/TCap alias |
| E_ASSERT_FAIL | Runtime | `assert`, `unwrap` |
| E_FFI_TIMEOUT | FFI | C function hang |
| E_REGION_ESCAPE | Region | Value escapes |
| E_MACRO_NON_TERMINATION | Macro | Expansion loop |
| E_MATCH_NONEXHAUSTIVE | Match | Missing variant |
| E_UNINITIALIZED_USE | Type | Use before init |
| E_CAPABILITY_LEAK | Capability | TMut to actor |
| E_TRAIT_NOT_FOUND | Trait | Missing impl |
| E_DUPLICATE_IMPL | Trait | Conflicting impls |
| E_MACRO_ILLEGAL_ACCESS | Macro | Runtime access |
| E_CONTRACT_VIOLATION | Contract | Pre/post fail |
| E_OVERFLOW | Numeric | Int overflow |
| E_DIVISION_BY_ZERO | Numeric | Int div by 0 |
| E_TEST_FAILURE | Test | Assertion failed |
| E_TEST_RUNNER_ERROR | Test | Harness bug |
| E_TRAIT_NOT_DERIVABLE | Derive | Field lacks trait |
| E_RESERVED_KEYWORD | Lexical | Keyword as ident |
| E_CANNOT_INFER | Generic | Param unconstrained |

## F.6 Standard Library Quick Index

| Module | Key Exports |
|--------|-------------|
| `core` | + - * / %, == != < >, and or not, print, read-line, int? float? bool? string?, struct-get, len, begin, if, let, let-mut, try, match, error, unwrap, assert |
| `option` | Option, Some, None, option-is-some, option-unwrap, option-map, option-flatmap |
| `result` | Result, Ok, Err, result-is-ok, result-unwrap, result-map, result-ok, result-err |
| `collections/vec` | vec-create, vec-push, vec-pop, vec-get, vec-set, vec-len, vec-cap, vec-last |
| `collections/map` | map-create, map-put, map-get, map-len, map-has, map-remove |
| `collections/set` | set-create, set-add, set-remove, set-len, set-contains |
| `actor` | spawn, send (special forms); actor-spawn, actor-send, actor-wait, actor-is-alive |
| `ffi` | ffi-call, ffi-pin, ffi-unpin (special forms); ffi-safe-call |
| `io` | file-open, file-read, file-write, file-close, read-line (special forms) |
| `allocator` | alloc-malloc, alloc-free, arena-create, arena-alloc, str-concat, buf-append |
| `testing` | test-suite, test, assert-equal, run-tests (special forms) |

## F.7 Compiler Flags Summary

> **Status**: `-o` is implemented today; the `--emit-*`, `--test`, and
> `--filter` flags are roadmap items (see Appendix C.13).

| Flag | Phase Output |
|------|-------------|
| `--emit-ast` | 1 |
| `--emit-expanded` | 2 |
| `--emit-typed` | 3 |
| `--emit-regions` | 4 |
| `--emit-mono` | 5 |
| `--emit-icnf` | 6 |
| `--emit-opt` | 7 |
| `--emit-asm` | 8 |
| `-o <file>` | 9 (executable) |

## F.8 REPL Commands

| Command | Action |
|---------|--------|
| `:help` | Show help |
| `:quit` | Exit |
| `:type <expr>` | Show type |
| `:ast <expr>` | Show AST |
| `:icnf <expr>` | Show ICNF |
| `:macroexpand <expr>` | Show expansion |
| `:macroexpand-all <expr>` | Full expansion |