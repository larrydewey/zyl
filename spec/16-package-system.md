# Zyl Specification — Package System

**Canonical authority:** `zyl_specification.txt` §31 (also §20.6, §24, §27, §28)
**Related:** `docs/package-management-design.md` (rationale, alternatives, plan)
**Implementation:** implemented. See `PROGRESS.md` for what landed, the deliberate deviations and the remaining gaps.

---

## Status

v5.0 specifies this system normatively, and the compiler implements it:
`stdlib/compiler/{package,qualify,store,workspace,lock,index,mvs,cli,
capability_check,module_resolver}.zyl`, plus `zyl_mangle_key` and BLAKE3 in
the runtime. Every definition carries a canonical key, visibility and
capabilities are enforced, and `zyl` has the subcommands of §31.11.

Three things here still describe intent rather than behaviour: `zyl fetch`
does not yet clone-and-install a `git` dependency, no index repository
exists to fetch from, and hash finalization records §31.12's four inputs
in `zyl.buildinfo` without mixing the graph hash into the binary's own
hash. The standard library stays implicit per §25 — package `zyl/std`,
no manifest, fully visible, never capability-enforced.

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
> (`runtime/actor_runtime.c:984`) maps every byte outside `[A-Za-z0-9_]` to
> `_`, so `acme/json`, `acme.json` and `acme-json` all collapse to
> `acme_json`. Using it on the label path would silently merge distinct
> functions.

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

Colon present → package on the left, module path on the right. Colon absent →
a module in the current package. A package name always contains `/`, so the
forms never collide.

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
workspace may override graph-wide; overrides never propagate from a
dependency.

---

## Lock, Store, Index, Trust

| Artifact | Role |
|----------|------|
| `zyl.lock` | Integrity and provenance record; **not** a resolution input |
| `~/.zyl/store/blake3/<hash>/` | Content-addressed package store |
| Index (git repo) | Name+version → URL, hash, publisher key, signature |

Deleting the lock does not change which versions are selected — only which
hashes, keys and capabilities are pinned.

`zyl fetch` is the sole command permitted to access the network; `zyl build`
reads the store and fails with `E_PKG_NOT_IN_STORE` rather than fetching.

The canonical archive fixes tar ordering, modes, timestamps and ownership so
content hashes agree across producers; the recorded hash is over the
*uncompressed* tar.

Signing is mandatory with no opt-out. Trust on first use, per package: the
publisher key is pinned into the lock on first resolution, and thereafter a
key change is `E_PKG_KEY_CHANGED` and a content change is
`E_PKG_HASH_MISMATCH`. Published versions are immutable; a yank is advisory
and affects new resolutions only.

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

---

## Features and Native Dependencies

Features are additive-only and unified across the graph.

```lisp
(feature-gate utf16 (pub defn parse-utf16 (b) ...))
```

Top level only. Gated forms are separate definitions, so no feature can alter
an existing signature — which is what makes unification safe here.
Base/gated collision is `E_PKG_FEATURE_COLLISION`.

Native dependencies are declarative; **build scripts are forbidden in any
form**, since build-time code would forfeit §27.

```lisp
(native (sources "c/fastpath.c") (cflags "-O2") (link-libs "m")
        (include-dirs "c/include"))
```

`cflags` are allowlisted (`-O*`, `-D*`, `-std=*`, a fixed `-f` subset). Raw
`-I`, `-L`, `-l` and any `-Wl,` are rejected; includes go through
`include-dirs`, linking through `link-libs`.

---

## Workspaces, Editions, Tooling

```lisp
(workspace (members "stdlib" "selfhost" "tools/lsp"))
```

One root `zyl.lock`, one shared cache and store, path deps between members
that still carry a version so each stays publishable. Under MVS a single root
lock cannot skew between members.

`(zyl "5.0")` is a minimum compiler version; `(edition "2026")` names the
syntax era. Editions coexist in one graph — each package is parsed under its
own edition's rules and all converge on one ICNF. v5.0 defines one edition.

```
zyl new | add | fetch | build | test | update | vendor | audit | publish | key
```

---

## Determinism

Hash finalization takes, in order: the compiler hash, `graph-hash` from the
lock, the canonical native-object hashes, and the ICNF hash. `zyl build`
writes `zyl.buildinfo` recording all four plus the resolved graph.

- Same `zyl.pkg` + same `zyl.lock` + same compiler → identical binaries.
- An index compromise cannot alter a locked build (**G13**).
- Content-hash-keyed build caching is sound by §27.
