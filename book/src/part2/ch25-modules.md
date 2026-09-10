# Chapter 25: Module System and Packages

Complete reference for Zyl's module system: declaration, imports, exports, visibility, and package management (v5.0 roadmap).

## 25.1 Module Declaration

```
module ::= "module" Identifier
```

```lisp
(module my-package/core)
```

- Must be **first form** in file (or after `def` constants)
- Defines module name for imports
- File path should match: `my/package/core.zyl`

## 25.2 Importing

```
use ::= "use" Identifier ImportSpec
```

```lisp
;; Import specific symbols
(use core { print len struct-get })

;; Import with aliases
(use collections/map { map-create => mc map-get => mg })

;; Import all public symbols
(use core *)

;; Unsafe import (bypass visibility)
(use core :unsafe { internal-fn })
```

### Import Spec

```
ImportSpec ::= "{" Identifier ("," Identifier)* "}"
             | "*"
             | ":unsafe" "{" Identifier ("," Identifier)* "}"
```

### Rules

1. **Module must be declared** in target file
2. **Visibility respected** — only `pub`/`export` symbols by default
3. **Aliases local** — don't affect original module
4. **Order matters** — later imports can shadow earlier

## 25.3 Exporting

```
export ::= "export" Identifier
```

```lisp
(module mylib)

(export public-fn)
(export PublicType)
(export PublicTrait)

;; Private by default
(defn private-helper () ...)  ; Not exported
(defn public-fn () ...)       ; Exported
```

### Visibility Levels

| Level | Declaration | Accessible From |
|-------|-------------|-----------------|
| **Private** | (default) | Same module only |
| **Public** | `pub` / `export` | Any importing module |
| **Unsafe** | `:unsafe` import | Only with `:unsafe` import |

## 25.4 Module Resolution

### Resolution Algorithm

1. **Find module file**: `<module-name>.zyl` in import paths
2. **Parse and type-check** independently
3. **Collect exports** (public symbols)
4. **Make available** to importer
5. **DAG-based** — no cycles allowed

### Import Paths

- Current directory
- `ZYL_PATH` environment variable
- Standard library paths
- Project root (with `zyl.toml` in v5.0)

### Cycle Detection

```lisp
;; a.zyl
(module a)
(use b *)

;; b.zyl
(module b)
(use a *)  ; ERROR: cyclic dependency
```

## 25.5 Crate Boundaries

### Crate = Compilation Unit

- Each `zyl` invocation compiles one crate
- Crates can depend on other crates
- Coherence rules apply at crate level

### Crate Metadata (v5.0)

```toml
# zyl.toml (planned v5.0)
[package]
name = "my-crate"
version = "1.0.0"

[dependencies]
other-crate = "1.0"
```

## 25.6 Standard Library Modules

| Module | Exports |
|--------|---------|
| `core` | `print`, `len`, `struct-get`, arithmetic, comparison, bool ops |
| `collections/vec` | `vec-create`, `vec-push`, `vec-get`, `vec-len`, `vec-cap`, `vec-pop` |
| `collections/map` | `map-create`, `map-put`, `map-get`, `map-len`, `map-has`, `map-remove` |
| `collections/set` | `set-create`, `set-add`, `set-len`, `set-contains`, `set-remove` |
| `option` | `Option`, `Some`, `None`, `is-some`, `unwrap`, `map` |
| `result` | `Result`, `Ok`, `Err`, `is-ok`, `unwrap`, `map`, `bind` |
| `actor` | `spawn`, `send`, `wait_all` |
| `ffi` | `ffi-call`, `ffi-pin`, `ffi-unpin` |
| `testing` | `test-suite`, `test`, `assert-equal`, `run-tests` |
| `allocator` | `alloc-malloc`, `alloc-free`, `buf-append`, `alloc-strlen` |

## 25.7 Package Management (v5.0 Roadmap)

Planned for v5.0 (Spec §20.6):

- **Package declaration**: `(package name version)`
- **Dependency resolution**: Highest compatible version
- **Registry**: Official + Git + Self-hosted
- **Security**: Ed25519 package signing
- **Lock files**: SHA-256 hashes
- **Workspace**: Multi-package projects
- **Feature flags**: Conditional compilation

```lisp
;; Future syntax (v5.0)
(package my-app "1.0.0")

(use other-crate { some-fn })
```

## 25.8 Current Workaround (Pre-v5.0)

- **Single crate**: All code in one compilation unit
- **File includes**: Not supported — use single crate
- **Path imports**: Not supported — use standard library paths
- **Git deps**: Not supported — vendor manually

## 25.9 Module Errors

| Error | Cause |
|-------|-------|
| `E_MODULE_NOT_FOUND` | Module file not found |
| `E_CYCLIC_DEPENDENCY` | Import cycle detected |
| `E_SYMBOL_NOT_EXPORTED` | Symbol not public in module |
| `E_DUPLICATE_IMPORT` | Same symbol imported twice |
| `E_MODULE_NAME_MISMATCH` | File name doesn't match module declaration |

## 25.10 Best Practices

1. **One module per file** — matches file system
2. **Explicit exports** — default private, opt-in public
3. **Avoid `*` imports** — prefer explicit for clarity
4. **Use aliases** — resolve naming conflicts
5. **Group related functionality** — cohesive modules

## 25.11 Comparison with Other Languages

| Feature | Rust | Go | Python | Zyl |
|---------|------|-----|--------|-----|
| Declaration | `mod foo;` | `package foo` | `__init__.py` | `(module foo)` |
| Import | `use foo::bar;` | `import "foo"` | `from foo import bar` | `(use foo { bar })` |
| Visibility | `pub` | Capitalized | `_` prefix | `export` |
| Re-export | `pub use` | N/A | `__all__` | Not yet |
| Submodules | `mod foo { mod bar }` | Nested dirs | Nested packages | Flat (one per file) |
| Crate/Package | Cargo | Go modules | pip/setuptools | v5.0 (planned) |