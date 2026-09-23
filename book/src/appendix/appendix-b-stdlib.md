# Appendix B: Standard Library Overview

Reference for Zyl's standard library modules and their exports.

## B.1 Core Modules

Every `use` takes a full path: the module is a file under `stdlib/`, so
`(use core/core)`, not `(use core)`.

### `core/core` — Fundamental Operations

Operators and special forms (`+ - * / %`, `== != < > <= >=`, `and or not`,
`if cond begin while for`, `try catch error unwrap assert`, `print`, `len`,
`tuple`, `struct-get`) are resolved by the compiler itself. `core` additionally
provides small helper functions:

```lisp
(use core/core)
;identity const flip compose apply
;abs min max clamp signum square cube
;xor nand nor implies
;is-bool is-zero is-even is-odd
;print-int print-float print-string print-bool
;option-to-result option-from-result result-to-option result-from-option
```

### `core/option` — Optional Values

```lisp
(use core/option)
;Option Some None
;option-some option-none
;option-is-some option-is-none
;option-unwrap option-unwrap-or
;option-map option-flatmap
;option-and option-or option-expect option-inspect

;; Type
(deftype Option (Some T) None)
```

Note: `option-unwrap` requires a default — `(option-unwrap opt default)`. There
is no unchecked `unwrap` in the stdlib; the compiler's `unwrap` special form is
for `Result` values.

### `core/result` — Error Handling

```lisp
(use core/result)
;Result Ok Err
;result-ok result-err
;result-is-ok result-is-err
;result-unwrap result-unwrap-or
;result-map result-flatmap result-and-then result-inspect
;result-and result-or result-expect

;; Type
(deftype Result (Ok T) (Err E))
```

`result-unwrap` also takes a default: `(result-unwrap res default)`.

### `core/list` — Singly-Linked Lists

```lisp
(use core/list)
;List Cons Nil
;is-nil list-car list-cdr list-rest
;car cdr cadr caddr cddr
;list-length list-append list-reverse list-sum
```

`car`/`cdr`/`cadr`/`caddr`/`cddr` are plain functions, not macros: each
takes one argument and evaluates it once, so a macro would buy nothing
and a function can be passed to a higher-order function.

### `core/map` — Ordered Maps

```lisp
(use core/map)
;Map map-new map-insert map-get map-has map-remove
;map-entries ME.key ME.value
```

Iteration order is deterministic, which is what lets the compiler use
this map internally without breaking reproducible builds.

### `testing/testing` — Built-in Testing Framework

The core testing forms (`test-suite`, `test`, `assert-equal`, `assert-true`,
`assert-false`, `assert-fail`, `test-property`, `setup`, `teardown`,
`run-tests`, `test-compile`) are compiler special forms. `testing` adds helpers:

```lisp
(use testing/testing)
;test-run test-suite-run
;assert-equal-values assert-true-value assert-false-value assert-fail-expr
;property-int property-bool property-string property-float
```

> `test-count`, `run-tests-filtered`, `run-tests-parallel`, and
> `run-tests-with-timeout` exist as **placeholders** that raise an error until
> runtime support lands.

## B.2 Collections

All standard collections are **arena-backed** and **persistent**: operations
like `vec-push` and `map-put` return a new container rather than mutating in
place. Keys and elements are `Int` values. Coordinate with an arena via
`(arena-create block-size)`; passing `0` as the arena uses a private default.

### `collections/vec` — Vectors

```lisp
(use collections/vec)
;vec-create vec-create-default
;vec-len vec-cap
;vec-get vec-set vec-push vec-pop vec-last
;vec-free
```

- `vec-create arena cap` — empty vector with capacity `cap` (arena `0` = private arena)
- `vec-get v i` — element, or `-1` when out of bounds
- `vec-set v i value` — returns an updated vector (writes past `len` extend it, up to `cap`)
- `vec-push v value` — returns a new vector, reallocating when full
- `vec-pop v`, `vec-last v`, `vec-free v`

There is no `vec-slice`, `vec-append`, or `vec-clear` in the current stdlib.

### `collections/map` — Association Maps

```lisp
(use collections/map)
;map-create map-create-default
;map-len map-cap
;map-put map-get map-remove map-has map-find
;map-free
```

Note that `map-get` takes a **default value**: `(map-get m key default)`.

There are no `map-keys`, `map-values`, or `map-entries` functions; the
persistent assoc-list module provides `assoc-keys`/`assoc-values` instead.

### `collections/set` — Hash Sets

```lisp
(use collections/set)
;set-create set-len set-cap
;set-contains set-add set-remove set-find
```

There is no `set-union`, `set-intersect`, or `set-diff` in the current stdlib.

### `collections` — Assoc Lists and List Helpers

```lisp
(use collections/collections)
;assoc-empty assoc-put assoc-get assoc-has assoc-remove
;assoc-size assoc-keys assoc-values assoc-map assoc-fold
;list-map list-filter list-fold
;list-take list-drop list-nth
;list-contains list-range list-count
```

## B.3 Concurrency

### `actor/actor` — Actor System

`spawn` and `send` are compiler special forms. `actor` wraps them with
lifecycle operations:

```lisp
(use actor/actor)
;actor-spawn actor-send actor-send-with-timeout
;actor-is-alive actor-wait actor-terminate
```

`spawn` returns an `ActorRef` (an `Int` handle). There is no callable
`wait_all`; when `main` returns, the runtime automatically waits for all
spawned actors to process their mailboxes.

## B.4 FFI

### `ffi/ffi` — Foreign Function Interface

`ffi-call`, `ffi-pin`, and `ffi-unpin` are compiler special forms. `ffi` adds
convenience wrappers:

```lisp
(use ffi/ffi)
;ffi-pin-value ffi-unpin-value
;ffi-safe-call ffi-pin-call-unpin
```

## B.5 Low-Level

### `allocator/allocator` — Memory Allocator and Arenas

```lisp
(use allocator/allocator)
;alloc-malloc alloc-free alloc-read-int alloc-write-int
;alloc-int alloc-incr alloc-decr alloc-strlen
;arena-create arena-alloc arena-alloc-zeroed
;arena-reset arena-destroy arena-used arena-capacity
;str-len str-eq str-length str-concat str-substring str-intern
;buf-append
```

### `atomic/atomic` — Atomic Operations

```lisp
(use atomic/atomic)
;atomic-load atomic-store
;atomic-add atomic-sub atomic-max atomic-min
;atomic-cas atomic-fetch-add atomic-incr atomic-decr
```

## B.6 I/O

### `io/io` — File and Buffer I/O

`file-open`, `file-read`, `file-write`, `file-close`, and `read-line` are
compiler special forms (file handles are `Int` fds). `io` adds named helpers
and buffered output:

```lisp
(use io/io)
;io-file-open-read io-file-open-write io-file-open-append
;io-file-read io-file-write io-file-close
;io-read-line io-print io-print-int io-print-string io-print-float io-newline
;io-safe-read io-safe-write io-safe-close
;make-stdout Stdout
;make-string-buffer StringBuffer string-buffer-str
;string-buffer-len string-buffer-destroy
```

There is no `file-seek`, `file-tell`, or `file-size` in the current stdlib.

## B.7 Mathematics and Cryptography (stdlib/math/)

About 7,500 lines of pure Zyl — hashes, AEADs, elliptic curves, RSA,
key derivation, big-number arithmetic and random number generation.
Only AES (hardware AES-NI) and system entropy (`getrandom(2)`) call
into C. `(use math/math)` imports the whole tree.

| Module | Provides |
|---|---|
| `math/bits` | 32/64-bit word operations, rotations, unsigned compare, byte packing |
| `math/words` | fixed-size arena-backed `Int` arrays, hex and string conversion |
| `math/secret/secret` | `ct-eq`, `ct-ne`, `ct-select`, `ct-mask`, `declassify`, `zeroize` |
| `math/bignum/bignum` | fixed-width naturals |
| `math/bignum/montgomery` | Montgomery multiplication, constant-time `mont-exp` |
| `math/bignum/barrett` | reduction by a fixed modulus |
| `math/bignum/modular` | modular add/sub, Fermat inverse, Miller–Rabin |
| `math/rand/crypto` | `getrandom(2)` entropy |
| `math/rand/deterministic` | seeded ChaCha20 generator |
| `math/hash/sha2`, `sha512`, `sha3` | SHA-256, SHA-512, SHA3-256/512, SHAKE128/256 |
| `math/hash/blake2b`, `blake3` | BLAKE2b, BLAKE3 |
| `math/hash/hmac` | HMAC-SHA256 |
| `math/crypto/symmetric/*` | ChaCha20, Poly1305, ChaCha20-Poly1305, AES-GCM |
| `math/crypto/asymmetric/*` | X25519, Ed25519, ECDSA, RSA-PSS/OAEP |
| `math/crypto/kdf/*` | HKDF, PBKDF2, Argon2id |

Chapter 34 covers the representation conventions, the deliberate
omissions and how the library was verified.

## B.8 Language Server (stdlib/lsp/)

The language server is a Zyl program like any other, built from these
modules and entered through `selfhost/lsp_main.zyl`:

| Module | Purpose |
|---|---|
| `lsp_types.zyl` | LSP protocol types |
| `json_rpc.zyl` | JSON-RPC 2.0 framing over stdio |
| `vfs.zyl` | Document text and edit application |
| `document_manager.zyl` | Per-document analysis cache and diagnostics |
| `compiler_bridge.zyl` | Compiler data to LSP types; the symbol table |
| `source_index.zyl` | Position tracking by text scan |
| `builtins.zyl` | The built-in and special-form table behind hover and completion |
| `capability_registry.zyl` | `ServerCapabilities` |
| `workspace.zyl` | Multi-root folders, workspace symbol search |
| `lsp_server.zyl` | The request loop |
| `services/*.zyl` | hover, goto, completion, symbols, semantic tokens, code actions, call hierarchy, inlay hints, signature help |

Chapter 35 covers what the server provides and what it cannot.

## B.9 Compiler (stdlib/compiler/)

Internal modules for the self-hosted compiler:

| Module | Purpose |
|--------|---------|
| `lexer.zyl` | Tokenizer |
| `parser.zyl` | Parser |
| `ast.zyl` | AST definitions |
| `expr_inner.zyl` | ExprInner ADT |
| `macro_expand.zyl` | Macro expansion |
| `type_system.zyl` | Type ADT, Subst, TypeEnv |
| `type_inference.zyl` | HM inference engine |
| `region_inference.zyl` | Region inference |
| `monomorphization.zyl` | Monomorphization |
| `icnf.zyl` | ICNF lowering |
| `codegen.zyl` | x86_64 codegen |
| `contract_injection.zyl` | Contract overlay |
| `trait_dispatch.zyl` | Trait method dispatch |
| `closure_inline.zyl` | Closure inlining |
| `assert_lowering.zyl` | Assert lowering |
| `module_resolver.zyl` | Module resolution |
| `resolver.zyl` | Name resolution |
| `optimization.zyl` | Safe-only optimizations (constant folding, dead code) |
| `sexp_balance.zyl` | S-expression balance check, with line/column tracking |
| `error_codes.zyl` | The error-code catalog |
| `error_report.zyl` | Error formatting and source snippets |
| `duplicate_check.zyl` | Duplicate definitions |
| `arity_check.zyl` | Call arity |
| `mutability_check.zyl` | Mutability and capability rules |
| `exhaustiveness_check.zyl` | Match exhaustiveness |
| `secret_check.zyl` | The `Secret` capability's constant-time obligations |
| `unused_check.zyl` | Unused and shadowed bindings (warnings) |

## B.10 Finding Stdlib Source

All stdlib source in `stdlib/`:
```
stdlib/
├── core/
│   ├── core.zyl
│   ├── option.zyl
│   ├── result.zyl
│   └── list.zyl
├── collections/
│   ├── collections.zyl
│   ├── vec.zyl
│   ├── map.zyl
│   └── set.zyl
├── actor/
│   └── actor.zyl
├── ffi/
│   └── ffi.zyl
├── io/
│   └── io.zyl
├── atomic/
│   └── atomic.zyl
├── allocator/
│   └── allocator.zyl
├── testing/
│   ├── testing.zyl
│   └── test_test_harness.zyl
├── math/
│   ├── bits.zyl, words.zyl, math.zyl
│   ├── secret/, bignum/, rand/
│   ├── hash/
│   └── crypto/{symmetric,asymmetric,kdf}/
├── lsp/
│   ├── *.zyl
│   └── services/*.zyl
├── mlib/
│   └── deep.zyl
└── compiler/
    └── *.zyl (27 files)
```

Note: modules are resolved **relative to the compiler's working directory** at
build time. If a program says `(use allocator/allocator)` and the run gives
``module 'allocator/allocator' not found``, the compiler was started from the
wrong directory — run it from the Zyl project root (where `stdlib/` lives).