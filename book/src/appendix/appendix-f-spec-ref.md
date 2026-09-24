# Appendix F: Language Specification Quick Reference

A condensed map of `zyl_specification.txt` — the Zyl Formal
Specification, **v5.0** — from section numbers to language features,
with pointers to where this book covers each one. The specification is
normative for the language; where the implementation differs, the
source code is the authority for what a program does today, and
Appendices A–C record the differences.

## F.1 Specification Structure

| § | Title | Key points | Book |
|---|---|---|---|
| 0 | Core Design Principles | P1–P9: Determinism, Safety, Explicit Effects, Region-Based Memory, Strict Evaluation, Phase Isolation, Inference Over Annotation, Optional Layers Do Not Interfere, Testability | Ch. 1, 26 |
| 1 | Lexical Structure | UTF-8; tokens; keywords (§1.3); reserved keywords as identifiers (§1.3.1); `;` comments | Ch. 14 |
| 2 | Abstract Syntax (AST) | The expression grammar, from `def` to `test-compile` | Ch. 14, F.2 |
| 3 | Value Model | Int64, UInt64, Float64, Bool, String, Tuple, Closure, ActorRef, Address, StructValue, ResultValue, Unit | Ch. 2 |
| 4 | Type System | Primitives, composites (Vec, Map, Result, Struct, Alias), capability types (§4.3), function types, bounds, HM inference, type equality | Ch. 15, 17 |
| 5 | Trait System | Declaration, implementation, coherence C1–C3, resolution, bounds, derive, standalone derive | Ch. 20 |
| 6 | Generics | Declaration, type-parameter semantics, collections, monomorphization and canonical naming (§6.4), generic ADTs, derivation, error cases | Ch. 7, 19 |
| 7 | Closures (Explicit Syntax Only) | `fn`/`lambda`, capture inference, concurrency, effects | Ch. 8 |
| 8 | Algebraic Data Types (ADTs) | Declaration, construction, pattern matching and exhaustiveness (§8.3) | Ch. 18 |
| 9 | Region System (Core Memory Model) | Stack, Heap, Global, Circular, Pin; rules R1–R8 (§9.1) | Ch. 16 |
| 10 | Mutability and Aliasing | The TMut/TCap invariant, struct immutability, alias transparency | Ch. 5, 17 |
| 11 | Evaluation Semantics (Big-Step) | Strict left-to-right; function and closure application; test execution | Ch. 26 |
| 12 | Control Flow | if, try/catch, match, assert, while, for, cond, begin, with-resource, error (§12.1–§12.10) | Ch. 3, 6 |
| 13 | Memory Operations | Stack, Heap, Circular, Pin, Global | Ch. 16 |
| 14 | Stack Safety Guarantee | Deep recursion never overflows | Ch. 29 |
| 15 | Concurrency Model (Actors) | Private state, FIFO mailbox, spawn/send, isolation | Ch. 9, 21 |
| 16 | FFI Model | `ffi-call`, `ffi-pin`, `ffi-unpin`; FFI_Pinnable types; pin semantics | Ch. 12, 22 |
| 17 | Monomorphization | Alphabetical canonical specialization names | Ch. 19 |
| 18 | ICNF (Intermediate Canonical Normal Form) | SSA IR with region annotations | Ch. 28 |
| 19 | Macro System (Full Formalization) | `defmacro`, gensym hygiene, innermost-first expansion, constraints, registration | Ch. 10, 23 |
| 20 | Numeric Model | Int64 (checked, wrapping, saturating), IEEE-754 Float64, division by zero, bit-level determinism | Ch. 2, 32 |
| 20.5 | Testing Framework (Core Language Built-in) | Registration, assertions, fixtures, property-based tests, runner, compile-time tests | Ch. 11 |
| 20.6 | Package Management | Summary; normative text in §31 | Ch. 25 |
| 21 | Built-in Operations (Semantics) | Arithmetic, comparison, boolean, type predicates, collections, mutation, I/O, error signaling, sequencing, Iterator trait, struct and alias accessors (§21.1–§21.12) | App. C |
| 22 | Compilation Pipeline | 11 phases, strict order | Ch. 26, F.4 |
| 23 | Contract and Recovery System (Optional Overlay) | Profiles; requires, ensures, invariant, recover, checkpoint, local overrides | Ch. 24 |
| 24 | Module System | Declaration, importing (`use` with `{ symbol }`, `=>`, `:unsafe`, `*`), `pub` exports, two-level visibility, DAG resolution, the package-boundary orphan rule (§24.1–§24.6) | Ch. 25 |
| 25 | Standard Library (Abstract) | Core modules; the stdlib is implicit, versioned with the compiler | App. B |
| 26 | Implementation Contract | What the compiler MUST, MAY and MUST NOT do | Ch. 26 |
| 27 | Determinism Contract | Observable versus non-observable behavior; package builds | Ch. 26 |
| 28 | Error Model | 20 core codes plus 36 package codes, all compile errors except the runtime ones | App. A |
| 29 | Formal Guarantees | G1–G13 | F.3 |
| 30 | Version Roadmap | v4.0, v4.1, v4.2, v5.0 (current), FUTURE | — |
| 31 | Package System | Identity, symbol keys and mangling, manifest, compilation model, MVS, lock, content store, index and trust, capabilities, features and native dependencies, workspaces and editions, determinism (§31.1–§31.12) | Ch. 25 |

In the text of the specification, §20.5 and §20.6 are headed "TESTING
FRAMEWORK" and "PACKAGE MANAGEMENT" without the numbers; they sit
between §20 and §21.

### §31 at a glance

| § | Title | Key points |
|---|---|---|
| 31.1 | Package Identity | Scoped name (`acme/json`, `acme/json/v2` for major ≥ 2); strict SemVer |
| 31.2 | Symbol Identity and Mangling | Canonical key `<package>@<major>::<module>::<symbol>`; injective mangling |
| 31.3 | Manifest — `zyl.pkg` | Required `name`, `version`, `zyl`, `edition`; bare-version requirements |
| 31.4 | Compilation Model | Whole-program; packages ship source |
| 31.5 | Version Resolution — Minimal Version Selection | Greatest minimum within a major; overrides at the root |
| 31.6 | Lock File — `zyl.lock` | Hashes, pinned keys, signatures, capability closure, graph hash |
| 31.7 | Content Store and Canonical Archive | `~/.zyl/store/blake3/<hash>/`; only `zyl fetch` uses the network |
| 31.8 | Index and Trust | Git-hosted index; mandatory Ed25519; trust on first use; yanks |
| 31.9 | Capabilities | `io`, `ffi`, `actor`, `secret`, `native`, `unsafe`; deny by default |
| 31.10 | Features and Native Dependencies | Additive, unified features; declarative C sources; no build scripts |
| 31.11 | Workspaces, Editions, Tooling | `zyl-workspace.zyl`; edition `2026`; the `zyl` subcommands |
| 31.12 | Determinism | Hash finalization inputs; `zyl.buildinfo` |

## F.2 Quick Syntax Reference

Condensed from §2, §24 and §31.10, in the spellings the compiler
accepts.

```
Program         ::= TopLevelForm*
TopLevelForm    ::= Definition | Expression

Definition      ::= (def Name Expr)
                  | (defn Name (Param*) Body)
                  | (defmacro Name (Name*) Template)
                  | (defstruct Name (Field*))
                  | (deftype Name (Variant*))
                  | (trait Name (TraitMethod*))
                  | (impl Trait Type (ImplBody*))
                  | (alias Name Type)
                  | (derive Type Trait*)
                  | (pub defn Name (Param*) Body)      ; also pub deftype, defstruct, ...
                  | (feature-gate Feature Definition)
                  | (use ModulePath ImportSpec?)
                  | (module Name)

ImportSpec      ::= { Symbol* } | { Symbol => Alias } | :unsafe { Symbol* } | *
Param           ::= Name | (Name Type)
Field           ::= (Name Type)

Expression      ::= Atom | List
Atom            ::= Int | Float | Bool | String | Keyword | Symbol | Identifier
List            ::= (Expression*)

Special Forms   ::= (let Name Expr Body)
                  | (let-mut Name Expr Body)
                  | (set! Name Expr)
                  | (if Expr Expr Expr)
                  | (cond (Expr Expr)* (else Expr)?)
                  | (while Expr Expr)
                  | (for (Name Expr) Expr Expr)
                  | (begin Expr+)
                  | (match Expr Arm*)
                  | (try Expr (catch Name Expr))
                  | (with-resource (Name Expr) Body)
                  | (fn (Param*) Body)
                  | (lambda (Param*) Body)
                  | (spawn Expr)
                  | (send Expr Expr)
                  | (ffi-call String Expr* Int)
                  | (ffi-pin Expr)
                  | (ffi-unpin Expr)
                  | (struct-get Expr String)
                  | (make-Name Expr*)
```

`Keyword` is `:name` and `Symbol` is `~name`. The specification also
lists `defun`, `(let (Name Expr) Body)`, `(assert Expr String)`,
`(unwrap Expr)`, `(error String)` and `(export Name)`. Of those, the
compiler accepts the parenthesised `let`; parses `assert`, `unwrap`,
`export` without lowering them; treats `error` as a library function
that panics; and does not recognise `defun` (Appendix C).

## F.3 Key Invariants and Guarantees (Normative)

| # | Invariant | Section |
|---|-----------|---------|
| 1 | Same source + inputs → identical outputs and binaries | P1, §27, G4 |
| 2 | No undefined behavior | P2, G1 |
| 3 | No use-after-free, double free, invalid aliasing, data races | G2, G3 |
| 4 | All effects statically trackable | P3 |
| 5 | Region inference assigns Stack/Heap/Global/Circular/Pin | P4, §9 |
| 6 | Strict left-to-right evaluation | P5, §11 |
| 7 | Phases strictly ordered (1 → 11) | P6, §22 |
| 8 | Inference over annotation | P7, §4.6 |
| 9 | Contracts never alter core semantics | P8, §23, G8 |
| 10 | Testing is built in | P9, §20.5 |
| 11 | TCap/TMut aliasing invariant | §10 |
| 12 | Struct fields immutable (rebind only) | §10, G9 |
| 13 | Match exhaustiveness mandatory | §8.3 |
| 14 | FFI requires Pin + timeout; external code cannot corrupt Zyl memory | §16, G5 |
| 15 | Deterministic iteration (Map) | §4.2 |
| 16 | Canonical monomorphization naming | §6.4, §17 |
| 17 | Trait coherence: no conflicting impls | §5.3, G6 |
| 18 | Closure captures correctly region-assigned | §7.2, G7 |
| 19 | Aliases are zero-cost | §10, G10 |
| 20 | `with-resource` cleans up before an error propagates | §12.9, G11 |
| 21 | A package cannot exercise a capability it does not declare | §31.9, G12 |
| 22 | A locked build is reproducible from pinned hashes and keys | §31.8, §31.12, G13 |

## F.4 Phase Dependencies (Must Not Violate)

From §22: no phase may depend on a later one.

```
1. Parsing
   ↓
2. Macro Expansion
   ↓
3. Type Inference + Trait Resolution   (includes derive validation)
   ↓
4. Region Inference + Capture Analysis
   ↓
5. Monomorphization
   ↓
6. ICNF Generation
   ↓
7. Optimization                        (safe only)
   ↓
8. Code Generation
   ↓
9. Linking
   ↓
10. Contract Injection                 (optional)
   ↓
11. Hash Finalization
```

§31.9 places package capability enforcement after module resolution and
before type inference.

## F.5 Error Codes in §28

The core codes. All are compile errors unless the description names a
runtime event.

| Code | Meaning |
|-------|---------|
| `E_USER_ERROR` | `(error msg)` |
| `E_MUT_CONFLICT` | Aliasing violation |
| `E_ASSERT_FAIL` | Assertion failure |
| `E_FFI_TIMEOUT` | FFI call exceeded its timeout |
| `E_REGION_ESCAPE` | Region rule violation |
| `E_MACRO_NON_TERMINATION` | Macro expansion loop |
| `E_MATCH_NONEXHAUSTIVE` | Missing match case |
| `E_UNINITIALIZED_USE` | Variable used before initialisation |
| `E_CAPABILITY_LEAK` | TMut leaked |
| `E_TRAIT_NOT_FOUND` | Missing impl |
| `E_DUPLICATE_IMPL` | Conflicting impls |
| `E_MACRO_ILLEGAL_ACCESS` | Macro accessed a runtime value |
| `E_CONTRACT_VIOLATION` | Contract failed |
| `E_OVERFLOW` | Integer overflow |
| `E_DIVISION_BY_ZERO` | Division by zero |
| `E_TEST_FAILURE` | Test assertion failed |
| `E_TEST_RUNNER_ERROR` | Test harness error |
| `E_TRAIT_NOT_DERIVABLE` | Cannot derive trait |
| `E_RESERVED_KEYWORD` | Reserved keyword used as an identifier |
| `E_CANNOT_INFER` | Generic parameter with no call-site evidence |

The 36 package codes are grouped by phase: manifest, lock and registry
(25 codes, `E_MANIFEST_*` and most `E_PKG_*`); module and package
resolution (`E_PKG_CYCLE`, `E_MODULE_CYCLE`, `E_PKG_VERSION_CONFLICT`,
`E_PKG_PRIVATE_SYMBOL`, `E_PKG_UNKNOWN_SYMBOL`, `E_PKG_UNKNOWN_MODULE`,
`E_PKG_UNDECLARED_DEP`, `E_PKG_RESERVED_MODULE`); traits
(`E_PKG_ORPHAN_IMPL`); and capabilities (`E_PKG_CAPABILITY_VIOLATION`,
`E_PKG_CAPABILITY_GROWTH`). Appendix A lists every one, together with
the codes the compiler adds beyond §28 and the §28 codes it does not yet
raise.

## F.6 Standard Library Quick Index

| Module | Key exports |
|--------|-------------|
| `core/core` | `identity`, `compose`, `abs`, `min`, `max`, `clamp`, `when`, `unless`, `is-even`, `print-int`, `print-string` |
| `core/option` | `Option`, `Some`, `None`, `option-is-some`, `option-unwrap`, `option-map`, `option-flatmap` |
| `core/result` | `Result`, `Ok`, `Err`, `result-is-ok`, `result-unwrap`, `result-map`, `result-and-then` |
| `core/list` | `List`, `Cons`, `Nil`, `car`, `cdr`, `list-length`, `list-append`, `list-reverse` |
| `core/map` | `map-new`, `map-insert`, `map-get`, `map-has`, `map-remove`, `map-entries` |
| `collections/vec` | `vec-create`, `vec-push`, `vec-pop`, `vec-get`, `vec-set`, `vec-len`, `vec-cap`, `vec-last` |
| `collections/map` | `map-create`, `map-put`, `map-get`, `map-len`, `map-has`, `map-remove` |
| `collections/set` | `set-create`, `set-add`, `set-remove`, `set-len`, `set-contains` |
| `collections/collections` | `assoc-*`, `list-map`, `list-filter`, `list-fold`, `list-nth`, `list-range` |
| `actor/actor` | `actor-spawn`, `actor-send`, `actor-wait`, `actor-is-alive`, `actor-terminate` |
| `atomic/atomic` | `atomic-load`, `atomic-store`, `atomic-add`, `atomic-cas`, `atomic-fetch-add` |
| `ffi/ffi` | `ffi-pin-value`, `ffi-unpin-value`, `ffi-safe-call`, `ffi-pin-call-unpin` |
| `io/io` | `io-file-open-read`, `io-file-write`, `io-read-line`, `make-string-buffer`, `OutputStream` |
| `allocator/allocator` | `arena-create`, `arena-alloc`, `alloc-malloc`, `str-eq`, `str-intern`, `buf-append`, `error` |
| `testing/testing` | `test-run`, `assert-equal-values`, `property-int` |
| `math/...` | hashes, AEADs, curves, RSA, KDFs, bignums, RNGs, `math/secret/secret` |

Special forms such as `spawn`, `send`, `ffi-call`, `file-open`,
`test` and `run-tests` belong to the compiler, not to a module.
Appendix B has the full listing.

## F.7 Command-Line Summary

| Command | Purpose |
|------|-------------|
| `zyl <file.zyl> -o <out>` | Compile and link one file |
| `zyl <file.zyl> --emit-asm -o <out.s>` | Stop after code generation (phase 8) |
| `zyl new`, `add`, `fetch`, `build [--locked]`, `test`, `update`, `vendor`, `audit`, `publish`, `key` | The package subcommands of §31.11 |
| `zyl repl` | Interactive session |
| `zyl eval <file.zyl>` | Run a program without building a binary |

No other phase dumps (`--emit-ast`, `--emit-icnf` and the like) are
implemented. Appendix C.16 has the details.

## F.8 REPL Commands

| Command | Action |
|---------|--------|
| `:help` | List commands and editing keys |
| `:quit` | Leave the session |
| `:history` | Entries from this and earlier sessions |
| `:defs` | Definitions in scope |
| `:doc NAME` | Documentation for a built-in or special form |
| `:type EXPR` | The type of an expression, without running it |
| `:time EXPR` | Evaluate it and report how long it took |
| `:load PATH` | Read a file's definitions into the session |
| `:save PATH` | Write the session's definitions to a file |
| `:reset` | Forget every definition |
| `:clear` | Clear the screen |

The specification does not define the REPL; these are the commands
`stdlib/repl/repl.zyl` implements.
