# Chapter 25: Module System and Packages

Complete reference for Zyl's module system and its package system: files as modules, `use` imports, `pub` visibility, canonical symbol keys, `zyl.pkg` manifests, Minimal Version Selection, the lock, the content store, the signed index, capabilities, features, native dependencies, workspaces and the `zyl` subcommands.

The normative text is spec v5.0 §24 (modules) and §31 (packages). Both are implemented in the self-hosted compiler: module resolution lives in `stdlib/compiler/module_resolver.zyl`, and the package system in `stdlib/compiler/{package,qualify,mvs,lock,store,index,capability_check,workspace,cli}.zyl`. Where the implementation departs from the specification, this chapter says so. The departures are also recorded in `PROGRESS.md` and `docs/package-management-design.md`.

## 25.1 Modules Are Files

A module is a `.zyl` file. Its module path is the file's path relative to the root of the package that contains it, without the `.zyl` extension:

| File | Package | Module path |
|------|---------|-------------|
| `greet/greet.zyl` | `acme/greet` | `greet` (the root module) |
| `greet/text/shout.zyl` | `acme/greet` | `text/shout` |
| `stdlib/collections/vec.zyl` | the standard library | `collections/vec` |

A package's **root module**, the one that `(use acme/greet)` names, is the module spelled by the last segment of the package name. For `acme/greet` that is `greet.zyl` at the package root. The standard library already uses this layout (`core/core.zyl`, `math/math.zyl`).

Spec §24.1 defines a `(module module-name)` declaration. The resolver accepts the form and discards it: a module's identity comes from its file path, and the declaration has no effect. You can leave it out.

## 25.2 Importing: `use`

```
use ::= "(" "use" ModulePath [":unsafe"] [ImportList | "*"] ")"
ImportList ::= "{" (Identifier | Identifier "=>" Identifier)* "}"
```

A module path takes one of three forms (§24.2):

| Form | Meaning |
|------|---------|
| `package:module` | a module inside a declared dependency, e.g. `acme/greet:text/shout` |
| `package` | that dependency's root module, e.g. `acme/greet` |
| `module` | a module of the current package, or of the standard library, e.g. `util/strings` or `collections/vec` |

A package name always contains `/`, and the package/module separator is `:`, so the three forms never collide.

```lisp
;; Import specific symbols
(use acme/greet { greet greet-twice })

;; Rename on import (the local name follows =>)
(use acme/greet { greet => hi })

;; A non-root module of a dependency
(use acme/greet:text/shout { shout })

;; Import the whole visible surface; `*` and a bare path mean the same thing
(use acme/greet *)
(use acme/greet)

;; A module of the standard library
(use collections/vec)
```

Symbols in an import list are separated by whitespace, not commas.

### Rules

1. **Dependencies must be declared.** A `use` that names a package absent from `zyl.pkg` is `E_PKG_UNDECLARED_DEP`.
2. **Only `pub` symbols cross a package boundary.** Naming a private symbol in an import list is `E_PKG_PRIVATE_SYMBOL`. Naming one that does not exist is `E_PKG_UNKNOWN_SYMBOL`.
3. **Renames are local.** `=>` changes the name only in the importing module.
4. **Lookup order is fixed.** A single-segment path is looked up first as a module of the importing package, then as a module of the standard library, then as a dependency's root module. The same source always names the same file.
5. **`unsafe` is a reserved module name** (`E_PKG_RESERVED_MODULE`). The lexer discards whitespace, so `pkg :unsafe` and `pkg:unsafe` are one token stream, and the marker has to win.

### Implementation notes

- **`*` does not check names.** With an explicit list, each name is checked when the import is resolved. With `*` or a bare path, a use of a private symbol is not diagnosed by the resolver. It survives as an unresolved reference, reported by codegen as `E_UNBOUND_VARIABLE: call to undefined function`.
- **`:unsafe` is parsed and ignored.** Spec §31.9 ties `:unsafe` imports to the `unsafe` capability but does not say what such an import permits. The implementation records the marker and does nothing with it: it does not bypass visibility, and a package without the `unsafe` capability can write it without error.
- **The standard library is one surface.** The implicit standard library (§25) has no manifest and therefore no `pub` surface. A `use` of any standard-library module exposes every standard-library definition that has been loaded. For example, `testing/testing` pulls in the allocator's `str-eq`. A named list still adds its renames on top.
- **`core/core` is implicit.** A program that loads none of `core/core`, `core/option` or `core/result` gets `core/core` anyway.

## 25.3 Visibility: `pub`

There are two levels (§24.4):

| Level | Declaration | Visible to |
|-------|-------------|------------|
| **Package-private** | (default) | every module of the defining package |
| **Public** | `(pub defn ...)` | any package that declares this one as a dependency |

`pub` prefixes a definition inline. It is not a wrapper list:

```lisp
; greet/greet.zyl — root module of acme/greet
(pub defn greet (n) (+ n 100))

; package-private: visible anywhere in acme/greet, invisible outside
(defn helper (n) (* n 2))

(pub defn greet-twice (n) (helper (greet n)))
```

`pub` applies to `defn`, `def`, `deftype` (with all of its constructors), `defstruct`, `defstruct+`, `trait` and `defmacro`.

Visibility governs reachability only. Every definition, public or private, gets its own canonical key (§25.5), so renaming a private definition cannot break a consumer.

`(export symbol)` is deprecated (§24.3), and the keyword stays reserved. The resolver drops `export` forms without effect, so exporting a non-`pub` definition does **not** make it importable. It still fails with `E_PKG_PRIVATE_SYMBOL`.

## 25.4 Module Resolution

`module_resolver.zyl` turns the `use` graph into one compilation unit. Zyl compiles whole programs (§31.4): packages ship source, and the resolver splices the whole resolved graph into one expression list that is monomorphized globally. There is no ABI and no separate compilation.

The resolver makes two passes:

1. **Discovery.** It walks the `use` graph depth-first from the root module, parses each file once, and records each module's definitions and imports. A cycle inside one package is `E_MODULE_CYCLE`; a cycle that leaves one package and re-enters it is `E_PKG_CYCLE` (§24.5).
2. **Qualification.** It rewrites every identifier to its canonical key, using a table built from the whole discovered graph. A module's table is built weakest-first: the rest of its package, then the modules it explicitly `use`s, then its own definitions. Later entries win.

Qualification happens only after discovery has finished, so the meaning of a name never depends on the order in which the graph was walked. Determinism (§27) requires this.

### Where files are found

- **The root package** is the directory of the source file being compiled. If that directory holds a `zyl.pkg`, the root is that package. Otherwise the root is the implicit package `local/main` at major 0.
- **Modules of a package** are found at `<package root>/<module path>.zyl`.
- **Path dependencies** are found relative to the directory of the manifest that declares them.
- **Registry and git dependencies** are found in the content store, under the hash recorded in `zyl.lock` (§25.9).
- **The standard library** is found in the compiler's bundle directory: `$ZYL_HOME` when it holds a `stdlib/`, otherwise `~/.zyl` when that holds one, otherwise the directory next to the compiler binary (for example `build/boot/`). An installed `~/.zyl` therefore takes precedence over a checkout's `build/boot/stdlib`.

There is no `ZYL_PATH` search path and no `zyl.toml`.

### Cycles

```lisp
;; acme/cyc — cyc.zyl
(use a)
(defn main () 0)

;; a.zyl
(use b)
(defn fa () 1)

;; b.zyl
(use a)
(defn fb () 2)
```

```
PANIC: E_MODULE_CYCLE: module: module graph is not a DAG at acme/cyc|a
```

A missing module in a manifest-bearing dependency is `E_PKG_UNKNOWN_MODULE`. In a lone file it is `E_MODULE_NOT_FOUND`. A missing module of the *current* package is currently reported as `E_PKG_UNDECLARED_DEP`, because a single-segment path that matches no file falls through to the dependency lookup.

## 25.5 Canonical Symbol Keys and Mangling

Every top-level definition has a canonical key (§31.2):

```
<package>@<major>::<module-path>::<symbol>

acme/greet@0::greet::greet
acme/greet@0::text/shout::shout
zyl/std@5::collections/vec::vec-push
local/main@0::hello::main-helper
```

Two packages may define the same name, and so may two modules in one package. The tests in `tests/packages/two-parses/` import a `parse` from both `acme/json` and `beta/xml` into one program. The canonical key is also the sort key for monomorphization's alphabetical naming (§17).

Mangling is injective. Letters and digits are kept, `_` becomes `_5F`, and every other byte becomes `_x` followed by two uppercase hex digits:

```
acme/greet@0::greet::greet-twice
  ->  zy_acme_x2Fgreet_0__greet__greet_x2Dtwice
```

Keys over 200 bytes are truncated to a 184-byte prefix followed by 16 hex digits of the key's BLAKE3 hash. The mangler is `zyl_mangle_key` in the runtime.

`main` and the four inlined string builtins (`str-concat`, `str-length`, `str-substring`, `str-equal`) are never qualified: the runtime and the lowering recognise them by spelling.

## 25.6 Packages and `zyl.pkg`

A package is a directory with a `zyl.pkg` manifest. The manifest is an S-expression, read by the language's own parser (§31.3):

```lisp
(package
  (name "acme/json") (version "1.4.0")
  (zyl "5.0") (edition "2026")
  (description "...") (license "MIT") (repository "...")
  (capabilities io)
  (deps
    (dep "core/bytes" "2.1.0")
    (dep "acme/utf8"  "1.0.0" (features utf16))
    (dep "acme/dev"   "0.3.0" (path "../dev"))
    (dep "acme/git"   "1.0.0" (git "https://..." (rev "a1b2c3d"))))
  (dev-deps (dep "acme/quickcheck" "2.0.0"))
  (features (feature utf16 (deps (dep "acme/utf16" "1.0.0")))
            (feature simd))
  (native (sources "c/fastpath.c") (cflags "-O2") (link-libs "m")))
```

- `name`, `version`, `zyl` and `edition` are required. Every other field defaults to empty. A missing required field is `E_MANIFEST_INVALID`.
- **Names** are scoped paths of two segments (`acme/json`). For major 2 and above, the major is a third segment (`acme/json/v2`), so two majors are distinct packages and can coexist in one graph (§31.1). A bad name is `E_PKG_BAD_NAME`.
- **Versions** are strict SemVer `MAJOR.MINOR.PATCH` with an optional `-pre` suffix (`E_PKG_BAD_VERSION`).
- **Requirements are bare minimum versions.** A range operator is `E_PKG_BAD_REQUIREMENT`:

  ```
  PANIC: E_PKG_BAD_REQUIREMENT: package: requirement ^0.1.0 on acme/greet uses a range operator - MVS takes bare minimum versions
  ```

- `dev-deps` are resolved by `zyl test` and never enter a dependent's graph.
- A root manifest may also carry `(overrides ...)` (§25.7) and `(deny-capabilities ...)` (§25.11).

### A two-package example

```bash
zyl new acme/greet      # creates greet/zyl.pkg and greet/greet.zyl
zyl new acme/hello      # creates hello/zyl.pkg and hello/hello.zyl
```

`zyl new` names the directory after the last segment of the package name, writes a minimal manifest, and writes a root module with a placeholder `pub defn` and a `main`.

```lisp
; hello/zyl.pkg
(package
  (name "acme/hello") (version "0.1.0")
  (zyl "5.0") (edition "2026")
  (deps (dep "acme/greet" "0.1.0" (path "../greet"))))
```

```lisp
; hello/hello.zyl
(use acme/greet { greet => hi greet-twice })
(use acme/greet:text/shout { shout })

(defn main ()
  (begin
    (print (hi 1))
    (print (greet-twice 1))
    (print (shout 4))
    0))
```

With `greet/greet.zyl` as in §25.3 and `greet/text/shout.zyl` containing `(pub defn shout (n) (* n 10))`:

```bash
$ cd hello && zyl build && ./hello
101
202
40
```

`zyl build` compiles the root module (`hello.zyl`) to `./hello`, keeps the assembly beside it as `hello.s`, and writes `hello.buildinfo` (§25.15). Running `zyl hello.zyl` directly inside the package directory also works: the compiler finds `zyl.pkg` next to the source file and resolves the same graph.

## 25.7 Version Resolution: Minimal Version Selection

For each package reachable from the root, the selected version is the **greatest of the minimum versions** required of it, within one compatibility unit (§31.5). A major is a compatibility unit, and each minor of major 0 is its own unit. The algorithm does no search and no backtracking, and it never consults the index to choose a version:

```
selected(P) = max over all requirements R on P of version(R)
```

Consequences (normative):

- Resolution is a pure function of the manifests in the graph.
- Adding a dependency never silently upgrades an unrelated one.
- Removing a dependency never silently downgrades another.
- An upgrade is an explicit edit to a requirement in a manifest.

A requirement that cannot be satisfied within a major is `E_PKG_VERSION_CONFLICT`. A pre-release is selected only when some manifest in the graph names that exact pre-release.

A root package or workspace may override a selection graph-wide. Overrides never propagate from a dependency, and they are recorded in the lock:

```lisp
(overrides (override "acme/json" "1.9.2")
           (override "acme/bad" (path "../fork")))
```

The implementation is `stdlib/compiler/mvs.zyl`. It does not check a path dependency's requirement against the version in that path's own manifest outside a workspace: requiring `"0.3.0"` of a path whose manifest says `0.1.0` builds without complaint.

## 25.8 The Lock File: `zyl.lock`

The lock is an integrity and provenance record, not a resolution input (§31.6). Deleting it does not change which versions are selected. `zyl fetch` and `zyl update` write it. `zyl build` only reads it.

```lisp
(lock
  (version 1)
  (compiler "5.0.0" (hash "blake3:2ebe9bf1...d512fd"))
  (pkg "acme/greet" "0.1.0"
    (source (path "../greet"))
    (capabilities ffi))
  (capability-closure ffi)
  (graph-hash "blake3:8b09f859...691f75"))
```

A registry package's entry also records `(hash ...)`, the BLAKE3 hash of its canonical archive, plus the pinned publisher `(key ...)`, the `(sig ...)`, its unified `(features ...)`, its `(capabilities ...)` and its `(deps ...)`. A path dependency records no hash, key or signature: the working tree changes under the developer's hands, so a pinned hash would be wrong by the next keystroke.

`capability-closure` is the union of every capability declared in the graph. `graph-hash` is BLAKE3 over the canonical serialisation of everything above it.

`zyl build --locked` requires the lock to describe exactly the graph the manifests imply:

| Condition | Error |
|-----------|-------|
| No `zyl.lock` | `E_PKG_LOCK_STALE: package: --locked was given but there is no zyl.lock` |
| A required package is absent, or at another version | `E_PKG_LOCK_STALE` |
| The capability closure has grown | `E_PKG_CAPABILITY_GROWTH` |
| The lock is malformed or of an unknown version | `E_PKG_LOCK_INVALID` |

Commit the lock for applications and libraries alike. A library's lock constrains its own CI, never its consumers.

## 25.9 Content Store and Canonical Archive

```
zyl fetch   populates ~/.zyl/store/blake3/<hash>/   (the only command that networks)
zyl build   reads the store only; a missing package is E_PKG_NOT_IN_STORE
```

`ZYL_HOME` replaces `~/.zyl` for the store, the index clone and the key directory, as it does for the standard-library lookup.

```
PANIC: E_PKG_NOT_IN_STORE: package: acme/json is not in the lock or the store - run zyl fetch
```

Archives are canonical, so content hashes agree across producers (§31.7). Paths are relative to the package root and sorted bytewise. The archive holds regular files and directories only. Modes are normalised to 0644 for files and 0755 for directories. Timestamps, uid and gid are zero, and user and group names are empty. `build/`, `.git/`, `zyl.lock` and any `(exclude ...)` patterns are left out. The archive is compressed with zstd at level 19. The recorded hash is over the **uncompressed** tar, so it does not depend on the compressor.

Every path or URL that reaches `tar`, `zstd`, `git`, `curl` or `cc` is checked against a strict character set first. A package root containing a space or a quote is refused rather than escaped.

## 25.10 Index and Trust

The index is a git repository of S-expression metadata, sharded by name (`ac/me/acme/json.zyl`), with no server component (§31.8):

```lisp
(index-entry (name "acme/json")
  (versions (v "1.4.0" (url "https://...tar.zst") (hash "blake3:...")
               (key "ed25519:...") (sig "ed25519:...")
               (zyl "5.0") (yanked false))))
```

- **Signing.** The publisher signs the BLAKE3 hash of the canonical archive with an Ed25519 key. Verification is mandatory and has no opt-out flag. The Ed25519 implementation ships inside the compiler (`stdlib/math/crypto/asymmetric/ed25519.zyl`).
- **Trust on first use.** The first resolution pins the publisher key, both in `zyl.lock` and in `~/.zyl/keys/`. Every later fetch must verify against the pinned key and match the content hash. A key change is `E_PKG_KEY_CHANGED` and a hash change is `E_PKG_HASH_MISMATCH`. An unsigned entry is `E_PKG_UNSIGNED`, and a bad signature is `E_PKG_SIGNATURE_INVALID`.
- **Yanks** are advisory. They affect new resolutions only (`E_PKG_YANKED`), never an existing lock. Published versions are immutable.

**Status.** The default index URL, `https://github.com/zyl-lang/index`, is a placeholder: no index repository exists yet. `zyl fetch` and `zyl update` clone or pull `~/.zyl/index` before resolving, so today they need a local clone of some git repository there, even for a graph made only of path dependencies. Without one, they fail with `E_PKG_FETCH_FAILED`. The fetch path is covered by unit tests over its pure parts (entry parsing, sharding, signing, verification) rather than end to end. A `git` dependency is recognised, pinned by revision and resolvable from the store, but `zyl fetch` does not yet clone and install one.

## 25.11 Capabilities

A package declares the capabilities it may use. An absent `(capabilities ...)` field means none (§31.9):

```lisp
(capabilities io ffi)   ; may do file IO and call C; may not spawn actors
(capabilities)          ; pure computation only
```

| Capability | Grants |
|------------|--------|
| `io` | `file-open`, `file-read`, `file-write`, `file-close`, `read-line`; `core/io` and everything under `stdlib/io` |
| `ffi` | `ffi-call`, `ffi-pin`, `ffi-unpin`; everything under `stdlib/ffi` |
| `actor` | `spawn`, `send`, `receive`; everything under `stdlib/actor` |
| `secret` | the `Secret` capability type and `stdlib/math/secret` |
| `native` | shipping and compiling C sources (§25.13) |
| `unsafe` | `:unsafe` imports |

`print` is not capability-gated.

Enforcement (`capability_check.zyl`) runs after module resolution and before type inference, over the qualified program. The package half of each definition's canonical key says who owns it, so no side table of ownership is needed. A violation names both sides of the boundary:

```
PANIC: E_PKG_CAPABILITY_VIOLATION: capability: package acme/hello uses ffi in acme/hello@0::hello::reach without declaring it in zyl.pkg
```

A declared set is a **ceiling on the declaring package**, not a grant along an edge. If `acme/greet` declares `ffi` and exports a function that calls C, a caller without `ffi` may still call that function. `zyl audit` lists what every package in the graph may do, together with the closure recorded in the lock:

```
$ zyl audit
acme/hello (root):
acme/greet: ffi
closure: ffi
```

A root package may forbid capabilities graph-wide:

```lisp
(deny-capabilities ffi native unsafe)
```

```
PANIC: E_PKG_CAPABILITY_VIOLATION: capability: acme/greet@0::greet::c-len uses ffi , which the root package forbids with deny-capabilities
```

`zyl update` reports growth in the capability closure ("capability closure grew to: ffi"). Under `zyl build --locked`, growth is `E_PKG_CAPABILITY_GROWTH`.

### Limits of the current implementation

- **Manifest-bearing packages only.** The standard library holds every capability and is never checked. A lone file compiled without a `zyl.pkg` has declared nothing, so nothing is enforced against it. `deny-capabilities` likewise applies only to manifest-bearing packages.
- **Only `defn` and `def` bodies are walked.** A capability-bearing construct in `main`, or in a top-level `(test ...)` form, is not checked. `main` is never qualified, so it has no owning package. A `test` form is not a definition when the pass runs. A package declaring `(capabilities)` can therefore call `ffi-call` or `spawn` directly from `main` and still build.
- **`unsafe` is not enforced**, because `:unsafe` imports are not acted on (§25.2).

## 25.12 Features

Features are additive only (§31.10). A feature may add top-level definitions and trait impls. It may not remove or alter an existing one:

```lisp
; acme/feat — feat.zyl
(pub defn base (n) (+ n 1))

(feature-gate simd (pub defn fast (n) (* n 8)))

; declared, never requested below: not part of the build at all
(feature-gate utf16 (pub defn wide (n) (* n 16)))
```

```lisp
; acme/feat's manifest
(features (feature simd) (feature utf16))

; a dependent asks for one
(deps (dep "acme/feat" "1.0.0" (features simd) (path "../lib")))
```

- Features are **unified**: the union of all requests across the graph is computed, and the package is compiled once with that union. The union is recorded in the lock.
- An **optional dependency** named in a `(feature ...)` enters the graph only when its feature is in the union.
- Requesting an undeclared feature is `E_PKG_FEATURE_UNKNOWN`.
- A gated definition that collides with a base definition is `E_PKG_FEATURE_COLLISION`.
- `feature-gate` is valid at top level only. The implementation honours it at top level but does not reject a nested one: a nested gate never reaches the resolver's top-level scan and is compiled as an ordinary form.

## 25.13 Native Dependencies

Native C sources are declarative. Build scripts are forbidden in any form, because arbitrary build-time code would forfeit §27:

```lisp
(package
  (name "acme/fast") (version "0.1.0")
  (zyl "5.0") (edition "2026")
  (capabilities ffi native)
  (native (sources "c/fast.c") (cflags "-O2" "-DTRIPLE=3")))
```

```c
/* c/fast.c */
long long fast_triple(long long n) { return n * TRIPLE; }
```

```lisp
; fast.zyl
(defn triple (n) (ffi-call "fast_triple" n 1000))

(defn main ()
  (begin
    (print (triple 14))
    0))
```

```bash
$ zyl build && ./fast
42
```

- Shipping sources requires `native`. Calling them requires `ffi`.
- Source paths and include directories are package-relative. An escape is `E_PKG_NATIVE_PATH_ESCAPE`.
- `cflags` come from an allowlist: `-O*`, `-D*`, `-std=*`, `-fPIC`, `-fno-strict-aliasing`, `-fwrapv`, `-fstack-protector-strong` and `-fno-omit-frame-pointer`. Anything else, including raw `-I`, `-L`, `-l` and `-Wl,`, is `E_PKG_NATIVE_FLAG_DENIED`. Includes go through `include-dirs` and libraries through `link-libs`.
- `cc` is invoked with a canonical, sorted argument vector, and objects land in `build/native/`. A `cc` failure is `E_PKG_NATIVE_BUILD_FAILED`.

**Status.** Only the root package's `native` block is compiled and linked. A dependency's native sources are not built. The spec also says the object hashes are recorded in the lock and in `zyl.buildinfo`: today the lock records none, and `zyl.buildinfo` carries an empty `(native-objects)` field.

## 25.14 Workspaces and Editions

A workspace root carries `zyl-workspace.zyl` (§31.11):

```lisp
(workspace (members "greet" "hello") (overrides ...))
```

- One `zyl.lock`, at the workspace root, covers every member. Under MVS a single root lock cannot skew between members.
- Members depend on one another by path and must still name the version that the target's manifest declares, so each member stays publishable (`E_PKG_VERSION_CONFLICT` otherwise).

**Status.** The member-version check joins the dependency's path to the *workspace root*, while the resolver joins it to the *member's* directory. With the usual member-relative spelling (`(path "../greet")`), the check finds no manifest and silently passes. A mismatched version is therefore not caught.

**Editions.** `(zyl "5.0")` is a minimum compiler version (`E_PKG_COMPILER_TOO_OLD`). `(edition "2026")` names the syntax era. v5.0 defines exactly one edition, `2026`, and any other is `E_PKG_UNKNOWN_EDITION`.

## 25.15 The `zyl` Subcommands

| Command | Does |
|---------|------|
| `zyl <file.zyl> [-o out] [--emit-asm]` | compile one file (a lone file is package `local/main`) |
| `zyl new <org/name>` | create `<name>/zyl.pkg` and the root module `<name>/<name>.zyl` |
| `zyl add <name> [version]` | add a dependency and re-serialise the manifest canonically; without a version, it takes the latest non-yanked release from the index |
| `zyl fetch` | sync the index, resolve (dev-deps included), download and verify, and write `zyl.lock` |
| `zyl build [--locked]` | resolve offline, compile the root module, link native objects, and write `<name>.buildinfo` |
| `zyl test` | build as above, then run the binary; dev-deps are resolved |
| `zyl update` | re-resolve with a refreshed index, rewrite the lock, and report capability-closure growth |
| `zyl vendor` | copy every resolved package into `./vendor` |
| `zyl audit` | list the capabilities of each package, and the locked closure |
| `zyl publish` | build the canonical archive, hash and sign it, and print the index entry |
| `zyl key` | show the publisher key, creating `~/.zyl/keys/publisher.seed` if needed |
| `zyl repl` / `zyl eval <file>` | interactive session / run without producing a binary |

Package subcommands find the package root by searching upward from the working directory for a `zyl.pkg`, and fail with `E_MANIFEST_NOT_FOUND` if they find none.

`zyl.buildinfo` records the inputs of §31.12 in canonical order:

```lisp
(buildinfo
  (compiler-hash "blake3:2ebe9bf1...d512fd")
  (graph-hash "blake3:8b09f859...691f75")
  (native-objects)
  (asm-hash "blake3:c762dfc9...84a87e"))
```

Notes on the current state:

- `graph-hash` is empty until `zyl fetch` has written a lock.
- The fourth field hashes the emitted assembly, not the ICNF, because the ICNF has no serialised form. Assembly is a deterministic function of the ICNF.
- The graph hash is recorded but not yet mixed into the binary itself.
- `zyl publish` leaves the archive in `~/.zyl/tmp/`, and its printed entry carries `(url "https://REPLACE-ME")` for you to fill in.
- Nothing reads `./vendor` yet: `zyl vendor` copies the graph, but builds still resolve from paths and the store.
- There is no build cache: every build recompiles the whole graph.

## 25.16 Trait Coherence Across Packages

Coherence is checked over the whole resolved graph. The **orphan rule** (§24.6): a package may implement a trait for a type only if it defines the trait or the type.

```lisp
; app depends on acme/shapes, which defines both Describable and Circle
(use acme/shapes { Describable Circle })

(impl Describable Circle        ; E_PKG_ORPHAN_IMPL
  (defn describe (self) 1))
```

Qualification has already happened when the check runs, so a name's package half says who defines it.

## 25.17 Standard Library Modules

The standard library is package `zyl/std` at the compiler's major. It is implicit (§25): it needs no manifest entry, it is fully visible, and its capabilities are never enforced against it. A selection:

| Module | Representative definitions |
|--------|----------------------------|
| `core/core` (implicit) | `identity`, `compose`, `abs`, `max`, `min`, `clamp`, option/result conversions |
| `core/list` | `List`, `car`, `cdr`, `list-length`, `list-append`, `list-reverse` |
| `core/option` | `Option`, `option-unwrap`, `option-is-some`, `option-map`, `option-unwrap-or` |
| `core/result` | `Result`, `result-unwrap`, `result-is-ok`, `result-map`, `result-and-then` |
| `core/map` | `Map`, `map-new`, `map-insert`, `map-get`, `map-has`, `map-remove` |
| `collections/vec` | `vec-create`, `vec-push`, `vec-get`, `vec-set`, `vec-len`, `vec-pop` |
| `collections/map` | `map-create`, `map-put`, `map-get`, `map-has`, `map-remove`, `map-len` |
| `collections/set` | `set-create`, `set-add`, `set-contains`, `set-remove`, `set-len` |
| `collections/collections` | `Assoc`, `assoc-put`, `assoc-get`, `list-map`, `list-filter`, `list-fold` |
| `allocator/allocator` | `alloc-malloc`, `alloc-free`, `arena-create`, `arena-alloc`, `buf-append`, `alloc-strlen` |
| `atomic/atomic` | `atomic-load`, `atomic-store`, `atomic-add`, `atomic-cas` |
| `actor/actor` | `actor-spawn`, `actor-send`, `actor-wait`, `actor-terminate` |
| `ffi/ffi` | `ffi-pin-value`, `ffi-unpin-value`, `ffi-safe-call` |
| `io/io` | `io-file-open-read`, `io-file-read`, `io-file-write`, `io-read-line`, `io-print` |
| `testing/testing` | the `test`/`run-tests` harness, `assert-equal-values`, `property-int` |
| `math/...` | `bits`, `words`, `bignum/`, `hash/` (SHA-2, SHA-3, BLAKE2b, BLAKE3), `crypto/`, `rand/`, `secret/` |

## 25.18 Errors

Resolver and package errors abort compilation with `PANIC: CODE: area: message` and exit status 1. All of these are spec §28 codes except `E_MODULE_NOT_FOUND`, which the resolver uses for a missing file outside a package.

| Error | Cause |
|-------|-------|
| `E_MODULE_CYCLE` | module graph within a package is not a DAG |
| `E_PKG_CYCLE` | package dependency graph is not a DAG |
| `E_MODULE_NOT_FOUND` | module file missing (lone file, not a package) |
| `E_PKG_UNKNOWN_MODULE` | module path does not exist in that package |
| `E_PKG_UNDECLARED_DEP` | `use` names a package absent from the manifest |
| `E_PKG_PRIVATE_SYMBOL` | imported symbol is not `pub` |
| `E_PKG_UNKNOWN_SYMBOL` | imported symbol does not exist |
| `E_PKG_RESERVED_MODULE` | a module named `unsafe` |
| `E_PKG_ORPHAN_IMPL` | impl where neither trait nor type is local |
| `E_MANIFEST_INVALID` / `E_MANIFEST_NOT_FOUND` | bad or missing `zyl.pkg` |
| `E_PKG_BAD_NAME` / `E_PKG_BAD_VERSION` / `E_PKG_BAD_REQUIREMENT` | malformed name, version, or a range requirement |
| `E_PKG_DUPLICATE_DEP` | two dep entries for one name |
| `E_PKG_VERSION_CONFLICT` | unsatisfiable within a major, or a workspace member version mismatch |
| `E_PKG_NOT_FOUND` / `E_PKG_VERSION_NOT_FOUND` | not in the index |
| `E_PKG_NOT_IN_STORE` | a build needs a package the store lacks |
| `E_PKG_HASH_MISMATCH` / `E_PKG_SIGNATURE_INVALID` / `E_PKG_KEY_CHANGED` / `E_PKG_UNSIGNED` | integrity and trust failures |
| `E_PKG_YANKED` | a new resolution selected a yanked version |
| `E_PKG_LOCK_STALE` / `E_PKG_LOCK_INVALID` | `--locked` mismatch, or a bad lock |
| `E_PKG_COMPILER_TOO_OLD` / `E_PKG_UNKNOWN_EDITION` | `zyl` or `edition` field unsatisfied |
| `E_PKG_FETCH_FAILED` / `E_PKG_ARCHIVE_INVALID` | `git`/`curl` failure, non-canonical archive |
| `E_PKG_NATIVE_PATH_ESCAPE` / `E_PKG_NATIVE_FLAG_DENIED` / `E_PKG_NATIVE_BUILD_FAILED` | native dependency rules |
| `E_PKG_FEATURE_UNKNOWN` / `E_PKG_FEATURE_COLLISION` | feature rules |
| `E_PKG_CAPABILITY_VIOLATION` / `E_PKG_CAPABILITY_GROWTH` | capability rules |

## 25.19 Best Practices

1. **Write a `zyl.pkg` for anything you share.** Without one, nothing is enforced and every definition is keyed under `local/main`.
2. **Mark the public surface with `pub`.** Everything else stays package-private and free to change.
3. **Prefer explicit import lists.** They are checked at resolution time, while `*` and bare imports defer mistakes to the linker.
4. **Declare the narrowest capability set** and read `zyl audit` after adding a dependency.
5. **Commit `zyl.lock`**, and build CI with `zyl build --locked`.
6. **Do not define `main` in a module meant to be `use`d.** Spliced forms are not renamed away from `main`, so a library's `main` collides with the importer's.

## 25.20 Comparison with Other Languages

| Feature | Rust | Go | Zyl |
|---------|------|-----|-----|
| Module unit | file or `mod` block | directory | file |
| Import | `use foo::bar;` | `import "foo"` | `(use pkg:module { bar })` |
| Visibility | `pub` (several levels) | capitalisation | `pub` / package-private |
| Version selection | SAT-style, highest compatible | Minimal Version Selection | Minimal Version Selection |
| Lock | `Cargo.lock` | `go.sum` | `zyl.lock` (BLAKE3, pinned Ed25519 keys) |
| Build scripts | `build.rs` | none (cgo directives) | forbidden; declarative `native` |
| Per-package capabilities | none | none | declared, deny by default |
| Separate compilation | per crate | per package | none: whole-program |
