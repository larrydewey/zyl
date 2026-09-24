# Zyl Specification — Package System

**Canonical authority:** `zyl_specification.txt` §31 (also §20.6, §24, §25, §27, §28, §29 G12–G13)
**Related:** `docs/package-management-design.md` (rationale, alternatives, plan)
**Implementation:** implemented. See `PROGRESS.md` for what landed, the deliberate deviations and the remaining gaps.

---

## Status

v5.0 specifies this system normatively, and the compiler implements it:
`stdlib/compiler/{package,qualify,store,workspace,lock,index,mvs,cli,
capability_check,module_resolver}.zyl`, plus `zyl_mangle_key` and BLAKE3 in
the runtime. Every definition carries a canonical key, visibility and
capabilities are enforced, and `zyl` has the subcommands of §31.11.

Deliberate deviations (recorded in `PROGRESS.md`):

- **The standard library stays implicit** per §25: package `zyl/std` at the
  compiler's major (the compiler reports version `5.0.0`), no manifest,
  fully visible, never capability-enforced, and not a workspace member.
  Importing any stdlib module exposes the whole loaded stdlib surface.
- **A lone file is package `local/main` at major 0.** It has declared no
  capabilities, so no capability ceiling is enforced against it;
  `deny-capabilities` and the capability pass apply only to packages with
  a `zyl.pkg`.
- **Module layout:** module path `M` of package `P` is the file
  `<root of P>/M.zyl`; a package's root module, which `(use acme/json)`
  names, is the module spelled by the name's last segment.
- **`zyl.buildinfo`'s fourth input is the assembly hash**, not the ICNF
  hash, because the ICNF has no serialised form.

Known gaps:

- `zyl fetch` downloads registry archives over HTTPS, but does not yet
  clone, archive and install a `git` dependency.
- No index repository exists; the index URL in the examples is a
  placeholder, so the fetch path is tested through its pure parts only.
- Hash finalization records its inputs in `zyl.buildinfo` but does not mix
  the graph hash into the binary. The `native-objects` field is always
  empty, and the native object hash is not recorded in the lock as
  §31.10 requires. The resolved graph is not written into
  `zyl.buildinfo`.
- There is no build cache (§31.4); every build recompiles the whole graph.
- Paths and URLs handed to `tar`, `zstd`, `git`, `curl` or `cc` must match a
  strict character set; a package root containing a space or quote is
  refused rather than escaped.
- A nested `feature-gate` is not rejected; it is simply not seen by the
  resolver's top-level scan.

---

## Package Identity

| Concept | Form | Notes |
|---------|------|-------|
| Name, major 0–1 | `acme/json` | Two scoped segments |
| Name, major ≥ 2 | `acme/json/v2` | Major is a third segment |
| Version | `1.4.0`, `1.4.0-rc1` | Strict SemVer, SemVer ordering |

Two majors are distinct packages and may coexist in one graph. Major 0 is
unstable: each minor is its own compatibility unit. A pre-release is selected
only when some manifest names that exact pre-release.

---

## Symbol Identity

Canonical key:

```
<package>@<major>::<module-path>::<symbol>
```

```
acme/json@1::json/parser::parse
beta/xml@2::xml/parser::parse        ; different package
acme/json@1::json/lexer::parse       ; same package, different module
acme/json/v2@2::json/parser::parse   ; different major
```

Two packages may define the same name; so may two modules within a package.
The key doubles as monomorphization's sort key, keeping the canonical
alphabetical ordering (§17) total over any graph.

### Mangling (must be injective)

```
escape(b) = b               for [A-Za-z0-9]
          = "_5F"           for '_'
          = "_x" + HEX(b)   otherwise (two uppercase hex digits)

mangle = "zy_" + escape(pkg) + "_" + major
               + "__" + escape(module) + "__" + escape(symbol)
```

```
acme/json@1::json/parser::parse  ->  zy_acme_x2Fjson_1__json_x2Fparser__parse
```

Over 200 bytes, truncate the prefix to 184 and append 16 hex digits of
BLAKE3 over the full key.

> **Lossy sanitizing is forbidden here.** `zyl_cstr_sanitize`
> (`runtime/actor_runtime.c`) maps every byte outside `[A-Za-z0-9_]` to
> `_`, so `acme/json`, `acme.json` and `acme-json` all collapse to
> `acme_json`. Using it on the label path would silently merge distinct
> functions. The code generator applies `zyl_mangle_key` to every
> canonical key and keeps `zyl_cstr_sanitize` only for the fixed set of
> names that carry no key (and for `ffi-call` target names).

Monomorphized instances carry fully-qualified type arguments:

```
acme/json@1::json::encode<acme/json@1::json::Node>
acme/json@1::json::encode<beta/xml@2::xml::Node>
```

---

## Manifest — `zyl.pkg`

S-expression, read by the language's own lexer and parser. No TOML.

```lisp
(package
  (name "acme/json") (version "1.4.0")
  (zyl "5.0") (edition "2026")
  (description "...") (license "...") (repository "...")
  (capabilities io)
  (deps
    (dep "core/bytes" "2.1.0")
    (dep "acme/utf8"  "1.0.0" (features utf16))
    (dep "acme/dev"   "0.3.0" (path "../dev"))
    (dep "acme/git"   "1.0.0" (git "https://..." (rev "a1b2c3d"))))
  (dev-deps (dep "acme/quickcheck" "2.0.0"))
  (features (feature utf16 (deps (dep "acme/utf16" "1.0.0"))) (feature simd))
  (native (sources "c/fastpath.c") (cflags "-O2") (link-libs "m")))
```

| Rule | Detail |
|------|--------|
| Required fields | `name`, `version`, `zyl`, `edition` |
| Requirements | Bare versions only; a range operator is `E_PKG_BAD_REQUIREMENT` |
| Canonical order | As shown, with `deps` sorted by name |
| `dev-deps` | Never enter a dependent's graph |

Range operators are rejected because under MVS a requirement *is* a minimum
and the major is implied by the version, so `^1.4.0` and `1.4.0` would denote
the same thing — two spellings of one fact.

---

## Imports and Visibility

```lisp
(use acme/json:parser { parse parse-strict })  ; package : module
(use acme/json { parse })                      ; package root module
(use acme/json:parser { parse => json-parse }) ; rename
(use acme/json:parser *)                       ; whole public surface
(use internal/helpers)                         ; module in THIS package
(use acme/ffi:raw :unsafe { poke })            ; unsafe import
```

A module declares itself with `(module module-name)` (§24.1).

Colon present → package on the left, module path on the right. Colon absent →
a module in the current package, or a dependency's root module when the
path is a package name. A package name always contains `/`, so the forms
never collide. Naming a package absent from the manifest is
`E_PKG_UNDECLARED_DEP`.

The implementation resolves a colon-less path in a fixed order: a module of
the importing package, then a module of the implicit standard library
(which is how `(use core/list)` finds `stdlib/core/list.zyl`), then a
declared dependency's root module.

Modules within a package must form a DAG (`E_MODULE_CYCLE`), and packages
must form a DAG (`E_PKG_CYCLE`) (§24.5). Coherence is checked over the whole
resolved graph; a package may implement a trait for a type only if it
defines the trait or the type (`E_PKG_ORPHAN_IMPL`, §24.6).

`unsafe` is a reserved module name (`E_PKG_RESERVED_MODULE`): the lexer drops
whitespace, so `pkg :unsafe` and `pkg:unsafe` are one token stream.

Visibility has two levels:

| Form | Visible |
|------|---------|
| `(defn f ...)` | Throughout the defining package |
| `(pub defn f ...)` | To any package depending on it |

Importing a non-`pub` name is `E_PKG_PRIVATE_SYMBOL`. Visibility governs
reachability only — every definition gets a unique mangled symbol, so
renaming a private one cannot break a consumer. `export` (§24.3) is
deprecated in favour of `pub`.

---

## Resolution — Minimal Version Selection

```
for each package P reachable from the root:
    selected(P) = max over all requirements R on P of version(R)
```

Each requirement is a minimum; the selection is the greatest minimum within a
major. No solver, no backtracking.

| Property | Consequence |
|----------|-------------|
| Pure function of the manifests | Does not depend on index contents; does not drift |
| Monotone in requirements | Adding a dep never silently upgrades an unrelated one |
| Monotone in removal | Removing a dep never silently downgrades another |

Upgrades are explicit acts that rewrite a requirement. A root package or
workspace may override graph-wide:

```lisp
(overrides (override "acme/json" "1.9.2")
           (override "acme/bad" (path "../fork")))
```

Overrides never propagate from a dependency, and are recorded in the lock.

---

## Lock, Store, Index, Trust

| Artifact | Role |
|----------|------|
| `zyl.lock` | Integrity and provenance record; **not** a resolution input |
| `~/.zyl/store/blake3/<hash>/` | Content-addressed package store |
| Index (git repo) | Name+version → URL, hash, publisher key, signature |

Deleting the lock does not change which versions are selected — only which
hashes, keys and capabilities are pinned. The lock is committed for
applications and libraries alike; a library's lock constrains its own CI,
never its consumers.

```lisp
(lock
  (version 1)
  (compiler "5.0.0" (hash "blake3:..."))
  (pkg "acme/json" "1.4.0"
    (source (registry "https://github.com/zyl-lang/index"))
    (hash "blake3:...") (key "ed25519:...") (sig "ed25519:...")
    (features utf16) (capabilities io)
    (deps "core/bytes" "acme/utf8"))
  (capability-closure io ffi)
  (graph-hash "blake3:..."))
```

| Field | Meaning |
|-------|---------|
| `hash` | BLAKE3 over the canonical uncompressed archive |
| `key` | Publisher key, pinned on first use |
| `capability-closure` | Union of every capability granted in the graph |
| `graph-hash` | BLAKE3 over the canonical serialisation of the above |

`zyl fetch` is the sole command permitted to access the network; `zyl build`
reads the store and fails with `E_PKG_NOT_IN_STORE` rather than fetching.

The canonical archive (`.tar.zst`) makes content hashes agree across
producers:

- paths relative to the package root, sorted bytewise
- regular files and directories only; no symlinks, no devices
- mode normalised to 0644 (files) and 0755 (directories)
- all timestamps, uid and gid zero; user and group names empty
- excluded: `build/`, `.git/`, `zyl.lock`, and any `(exclude ...)` patterns
- zstd level 19, long-distance matching off

The recorded hash is over the *uncompressed* tar, so it does not depend on
the compressor.

The index is a git repository of S-expression metadata, sharded by name
(`ac/me/acme/json.zyl`), with no server component:

```lisp
(index-entry (name "acme/json")
  (versions (v "1.4.0" (url "https://...tar.zst") (hash "blake3:...")
               (key "ed25519:...") (sig "ed25519:...")
               (zyl "5.0") (yanked false))))
```

The publisher signs the BLAKE3 hash of the canonical archive with an
Ed25519 key.

Signing is mandatory with no opt-out. Trust on first use, per package: the
publisher key is pinned into the lock on first resolution, and every later
fetch must verify the signature against the pinned key and match the
content hash. A key change is `E_PKG_KEY_CHANGED` and a content change is
`E_PKG_HASH_MISMATCH`; both halt the build until accepted explicitly,
producing a lock diff. Published versions are immutable; a yank is
advisory and affects new resolutions only (`E_PKG_YANKED`), never an
existing lock.

---

## Capabilities

| Capability | Grants |
|------------|--------|
| `io` | `core/io`, `stdlib/io` |
| `ffi` | `ffi-call`, `ffi-pin`, Pin-region allocation |
| `actor` | `spawn`, `send`, `receive` |
| `secret` | `Secret` capability type, `stdlib/math/secret` |
| `native` | Shipping and compiling C sources |
| `unsafe` | `:unsafe` imports |

Deny by default: `(capabilities)` means pure computation. Enforcement runs
after module resolution and before type inference, over top-level forms
tagged with their owning package. Violations are
`E_PKG_CAPABILITY_VIOLATION`.

A declared set bounds the declaring package and is not re-granted per edge.
The transitive closure is written to the lock; growth is reported by
`zyl update` and is `E_PKG_CAPABILITY_GROWTH` under `--locked`. A root may
add `(deny-capabilities ffi native unsafe)`.

This underwrites guarantee **G12**: a package cannot exercise a capability it
does not declare.

In the implementation, `capability_check.zyl` recognises the constructs
directly (`ffi-call`, `ffi-pin`, `ffi-unpin`, `spawn`, `send`, `receive`,
`file-open`, `file-read`, `file-write`, `file-close`, `read-line`) and
classifies a call into the standard library by its module path: `io/…`
and `core/io` need `io`, `actor/…` needs `actor`, `ffi/…` needs `ffi`, and
`math/secret/…` needs `secret`. §25 says each stdlib module declares the
capability it provides; the implementation keeps that mapping in the
checker instead. A `Secret` annotation by itself needs no grant.

---

## Features and Native Dependencies

Features are additive-only and unified across the graph.

```lisp
(feature-gate utf16 (pub defn parse-utf16 (b) ...))
```

Top level only. Gated forms are separate definitions, so no feature can alter
an existing signature — which is what makes unification safe here.
Base/gated collision is `E_PKG_FEATURE_COLLISION`.

Features are unified: the union of all requests across the graph is
computed, the package is compiled once with that union, and the union is
recorded in the lock. Optional dependencies enter the graph only when their
feature is in the union.

Native dependencies are declarative; **build scripts are forbidden in any
form**, since build-time code would forfeit §27.

```lisp
(native (sources "c/fastpath.c") (cflags "-O2") (link-libs "m")
        (include-dirs "c/include"))
```

- Requires the `native` capability; using the symbols requires `ffi`.
- Paths are package-relative (`E_PKG_NATIVE_PATH_ESCAPE`).
- `cflags` are allowlisted (`-O*`, `-D*`, `-std=*`, a fixed `-f` subset).
  Raw `-I`, `-L`, `-l` and any `-Wl,` are rejected
  (`E_PKG_NATIVE_FLAG_DENIED`); includes go through `include-dirs`,
  linking through `link-libs`. The implemented `-f` subset is `-fPIC`,
  `-fno-strict-aliasing`, `-fwrapv`, `-fstack-protector-strong` and
  `-fno-omit-frame-pointer`.
- The toolchain invokes `cc` with a canonical sorted argument vector and
  records the object hash in the lock. The sorted invocation is
  implemented; recording the object hash is not (see Status).

---

## Workspaces, Editions, Tooling

```lisp
(workspace (members "stdlib" "selfhost" "tools/lsp") (overrides ...))
```

The workspace file is `zyl-workspace.zyl` at the workspace root. The member
list above is the canonical example; this repository is not itself
converted into a workspace, and the standard library is not a member.

One root `zyl.lock`, one shared cache and store, path deps between members
that still carry a version so each stays publishable. Under MVS a single root
lock cannot skew between members.

`(zyl "5.0")` is a minimum compiler version (`E_PKG_COMPILER_TOO_OLD`);
`(edition "2026")` names the syntax era. Editions coexist in one graph —
each package is parsed under its own edition's rules and all converge on one
ICNF. An unknown edition is `E_PKG_UNKNOWN_EDITION`. v5.0 defines exactly
one edition, `2026`.

```
zyl new | add | fetch | build | test | update | vendor | audit | publish | key
```

The binary also accepts `zyl <file.zyl> [-o out] [--emit-asm]` for a single
file, `zyl repl` and `zyl eval <file.zyl>`; these are not part of §31.

---

## Determinism

Hash finalization (pipeline step 11) takes, in order: the compiler hash,
`graph-hash` from the lock, the canonical native-object hashes, and the ICNF
hash. `zyl build` writes `zyl.buildinfo` beside the binary recording all four
plus the resolved graph in canonical form, so a third party can verify that
a binary was produced from a claimed set of inputs. The implemented
`zyl.buildinfo` is described in `spec/14-determinism-and-hashing.md`.

- Same `zyl.pkg` + same `zyl.lock` + same compiler → identical binaries.
- An index compromise cannot alter a locked build (**G13**).
- Content-hash-keyed build caching is sound by §27.
