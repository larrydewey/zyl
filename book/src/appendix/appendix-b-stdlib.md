# Appendix B: Standard Library Overview

Reference for Zyl's standard library modules and their exports.

## B.1 Core Modules

### `core` — Fundamental Operations

```lisp
(use core {
  ; Arithmetic
  + - * / %
  
  ; Comparison
  == != < > <= >=
  
  ; Boolean
  and or not
  
  ; Type predicates
  int? float? bool? string? struct? alias?
  
  ; I/O
  print read-line
  
  ; Struct
  struct-get make-
  
  ; Conversion
  int float string
  
  ; Control
  begin if cond while for try catch error unwrap assert
  
  ; Collections
  len vec map tuple
  
  ; Math
  abs min max
})
```

### `option` — Optional Values

```lisp
(use option {
  Option Some None
  is-some is-none
  unwrap map bind
  or-else unwrap-or
})

;; Type
(deftype Option (Some T) None)
```

### `result` — Error Handling

```lisp
(use result {
  Result Ok Err
  is-ok is-err
  unwrap map bind
  map-err bind-err
})

;; Type
(deftype Result (Ok T) (Err E))
```

### `testing` — Built-in Testing Framework

```lisp
(use testing {
  test-suite test
  assert-equal assert-fail assert-true assert-false
  test-property gen-int gen-bool gen-string gen-float
  setup teardown run-tests test-compile
})
```

## B.2 Collections

### `collections/vec` — Vectors

```lisp
(use collections/vec {
  vec-create vec-push vec-pop
  vec-get vec-set vec-len vec-cap
  vec-slice vec-append vec-clear
})
```

### `collections/map` — Hash Maps

```lisp
(use collections/map {
  map-create map-put map-get
  map-len map-has map-remove
  map-keys map-values map-entries
})
```

### `collections/set` — Hash Sets

```lisp
(use collections/set {
  set-create set-add set-remove
  set-len set-contains
  set-union set-intersect set-diff
})
```

## B.3 Concurrency

### `actor` — Actor System

```lisp
(use actor {
  spawn send wait_all
  ActorRef
})
```

## B.4 FFI

### `ffi` — Foreign Function Interface

```lisp
(use ffi {
  ffi-call ffi-pin ffi-unpin
})
```

## B.5 Low-Level

### `allocator` — Memory Allocator

```lisp
(use allocator {
  alloc-malloc alloc-free alloc-realloc
  alloc-write-int alloc-read-int
  alloc-strlen buf-append
  cstr-to-string string-to-cstr
})
```

### `atomic` — Atomic Operations

```lisp
(use atomic {
  atomic-new atomic-load atomic-store
  atomic-add atomic-sub atomic-cas
})
```

## B.6 I/O

### `io` — File I/O

```lisp
(use io {
  file-open file-read file-write file-close
  file-seek file-tell file-size
  FileHandle
  ; Modes: "r" "w" "a" "r+"
})
```

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
│   └── result.zyl
├── collections/
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