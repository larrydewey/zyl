# Appendix B: Standard Library Overview

Reference for Zyl's standard library modules and their exports.

## B.1 Core Modules

### `core` — Fundamental Operations

Operators and special forms (`+ - * / %`, `== != < > <= >=`, `and or not`,
`if cond begin while for`, `try catch error unwrap assert`, `print`, `len`,
`tuple`, `struct-get`) are resolved by the compiler itself. `core` additionally
provides small helper functions:

```lisp
(use core)
;identity const flip compose apply
;abs min max clamp signum square cube
;xor nand nor implies
;is-bool is-zero is-even is-odd
;print-int print-float print-string print-bool
;option-to-result option-from-result result-to-option result-from-option
```

### `option` — Optional Values

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

### `result` — Error Handling

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

### `list` — Singly-Linked Lists

```lisp
(use core/list)
;List Cons Nil
;is-nil list-car list-cdr
;list-length list-append list-reverse list-sum
```

### `testing` — Built-in Testing Framework

The core testing forms (`test-suite`, `test`, `assert-equal`, `assert-true`,
`assert-false`, `assert-fail`, `test-property`, `setup`, `teardown`,
`run-tests`, `test-compile`) are compiler special forms. `testing` adds helpers:

```lisp
(use testing)
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

### `actor` — Actor System

`spawn` and `send` are compiler special forms. `actor` wraps them with
lifecycle operations:

```lisp
(use actor)
;actor-spawn actor-send actor-send-with-timeout
;actor-is-alive actor-wait actor-terminate
```

`spawn` returns an `ActorRef` (an `Int` handle). There is no callable
`wait_all`; when `main` returns, the runtime automatically waits for all
spawned actors to process their mailboxes.

## B.4 FFI

### `ffi` — Foreign Function Interface

`ffi-call`, `ffi-pin`, and `ffi-unpin` are compiler special forms. `ffi` adds
convenience wrappers:

```lisp
(use ffi)
;ffi-pin-value ffi-unpin-value
;ffi-safe-call ffi-pin-call-unpin
```

## B.5 Low-Level

### `allocator` — Memory Allocator and Arenas

```lisp
(use allocator/allocator)
;alloc-malloc alloc-free alloc-read-int alloc-write-int
;alloc-int alloc-incr alloc-decr alloc-strlen
;arena-create arena-alloc arena-alloc-zeroed
;arena-reset arena-destroy arena-used arena-capacity
;str-len str-eq str-length str-concat str-substring str-intern
;buf-append
```

### `atomic` — Atomic Operations

```lisp
(use atomic)
;atomic-load atomic-store
;atomic-add atomic-sub atomic-max atomic-min
;atomic-cas atomic-fetch-add atomic-incr atomic-decr
```

## B.6 I/O

### `io` — File and Buffer I/O

`file-open`, `file-read`, `file-write`, `file-close`, and `read-line` are
compiler special forms (file handles are `Int` fds). `io` adds named helpers
and buffered output:

```lisp
(use io)
;io-file-open-read io-file-open-write io-file-open-append
;io-file-read io-file-write io-file-close
;io-read-line io-print io-print-int io-print-string io-print-float io-newline
;io-safe-read io-safe-write io-safe-close
;make-stdout Stdout
;make-string-buffer StringBuffer string-buffer-str
;string-buffer-len string-buffer-destroy
```

There is no `file-seek`, `file-tell`, or `file-size` in the current stdlib.

## B.7 Compiler (stdlib/compiler/)

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

## B.8 Finding Stdlib Source

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
└── compiler/
    └── *.zyl (20+ files)
```

Note: modules are resolved **relative to the compiler's working directory** at
build time. If a program says `(use allocator/allocator)` and the run gives
``module 'allocator/allocator' not found``, the compiler was started from the
wrong directory — run it from the Zyl project root (where `stdlib/` lives).