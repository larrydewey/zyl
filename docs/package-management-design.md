# Zyl Package Management — Design (spec v5.0)

Status: IMPLEMENTED on 2026-09-23 (modules
`stdlib/compiler/{package,qualify,store,workspace,lock,index,mvs,cli,
capability_check,module_resolver}.zyl`, driver in `selfhost/driver.zyl`).
The normative text is now `zyl_specification.txt` §31 (v5.0), with
`spec/16-package-system.md` as its structured copy; this document is the
design as written before implementation, kept for its rationale. Where
the implementation differs from it, §16 below says so, and `PROGRESS.md`
(the §31 implementation session) records the deliberate deviations and
the remaining gaps. Supersedes the roadmap sketch in the old §20.6.

Two things in §14's phase plan were not done as written, because the
specification says otherwise: the standard library stays implicit
(§25) rather than becoming a manifest-bearing workspace member, and
this repository was not converted into a workspace — workspace support
exists (`stdlib/compiler/workspace.zyl`) and is exercised by the lock's
placement rule, but the compiler's own tree still builds as it did.

This document was the normative design for the v5.0 package system. It
records sixteen decisions, the grammars, the algorithms, the new error
codes, and a five-phase implementation plan. Where it contradicted the
v4.2 specification text, the specification was to be amended; each such
point is marked **[amends spec]**, and all of them have been made (§15).

---

## 1. Design decisions

| # | Decision | Chosen | Rejected |
|---|----------|--------|----------|
| 1 | Manifest format | S-expression `zyl.pkg` **[amends spec §24.5]** | TOML |
| 2 | Version resolution | Minimal Version Selection **[amends spec §20.6]** | Highest-compatible with a solver; exact pins |
| 3 | Compilation model | Whole-program source splicing | Separate compilation with a frozen ABI |
| 4 | Symbol identity | Mangled, package- and module-qualified, with import tables | Flat namespace; package-only prefix |
| 5 | Fetching | Shell out to `git`/`curl` into a content-addressed store; builds are offline | Native sockets + TLS; git-only |
| 6 | Trust | Author Ed25519 keys, trust on first use, verification mandatory | Registry root key; transparency log; hashes only |
| 7 | Capabilities | Declared per package, deny by default, compiler-enforced | Audit-only; defer |
| 8 | Features | Additive-only, unified across the graph, recorded in the lock | Per-edge without unification; no features |
| 9 | Native C deps | Declarative manifest entries only, no build scripts | Sandboxed build step; system libraries only |
| 10 | Stdlib | Implicit, versioned with the compiler | Stdlib as packages; split |
| 11 | Index | Git-hosted repository of S-expression metadata, scoped `org/name` | Static HTTP; no index |
| 12 | Compiler compatibility | Minimum version plus editions | Minimum only; exact pin |
| 13 | Import syntax | `package:module` — colon separates the two | Manifest aliases; longest-prefix match |
| 14 | Visibility | Two levels: package-private by default, `pub` to export | Three levels; manifest export list |
| 15 | Workspaces | One root lock, one shared store, path deps between members | Per-package locks; no workspaces |
| 16 | Rollout | Five phases, language before distribution | Distribution first; single release |

### Non-goals for 5.0

- A stable ABI or binary-only package distribution.
- Cross-compilation and target triples beyond the current x86_64 target.
- Arbitrary code execution at build time, in any form.
- A hosted registry service. The index is a git repository; anyone can
  serve one, and there is no server component to operate.
- Yanking as a deletion mechanism. Published versions are immutable; a
  yank is an advisory flag in the index that affects new resolutions
  only, never an existing lock.

---

## 2. Package identity

A package name is a scoped path of exactly two segments for major
versions 0 and 1:

```
acme/json
```

For major version 2 and above the major is a third path segment, so that
two majors are distinct packages and can coexist in one graph:

```
acme/json/v2
acme/json/v3
```

This is deliberate: under a single name a diamond requiring both 1.x and
2.x would be unresolvable, and under an `@`-suffix syntax the lexer would
need a new identifier character. The `/vN` suffix costs nothing — `/` is
already an identifier character (`chr-ident-start-p` /
`chr-ident-cont-p` in `lexer.zyl`).

Versions are strict SemVer `MAJOR.MINOR.PATCH`, optionally followed by
`-` and a pre-release identifier. Ordering is the usual SemVer ordering.
Pre-release versions are never selected unless some manifest in the graph
names that exact pre-release as its requirement.

Major version 0 is treated as unstable: each distinct minor is its own
compatibility unit, so `0.3.x` and `0.4.x` do not satisfy one another.

### Canonical symbol key

Every top-level definition has a canonical, globally unique key:

```
<package>@<major>::<module-path>::<symbol>
```

For example:

```
acme/json@1::json/parser::parse
beta/xml@2::xml/parser::parse       ; different package
acme/json@1::json/lexer::parse      ; same package, different module
acme/json/v2@2::json/parser::parse  ; different major
```

Two packages may therefore define the same function name, and two modules
inside one package may as well. The key is also the sort key used by
monomorphization's alphabetical canonical ordering, so ordering stays a
total order regardless of which packages enter the graph.

### Mangling

Assembly labels must be injective functions of the canonical key.
`zyl_cstr_sanitize` (`runtime/actor_runtime.c`) is **not** usable for
this: it maps every byte outside `[A-Za-z0-9_]` to `_`, so `acme/json`,
`acme.json` and `acme-json` all collapse to `acme_json`. A lossy encoder
at this point would silently merge distinct functions.

The mangler is:

```
escape(b) = b                 when b in [A-Za-z0-9]
          = "_5F"             when b is '_'
          = "_x" + HEX(b)     otherwise, HEX uppercase, two digits

mangle(key) = "zy_" + escape(package) + "_" + major
                    + "__" + escape(module)
                    + "__" + escape(symbol)
```

so:

```
acme/json@1::json/parser::parse
  ->  zy_acme_x2Fjson_1__json_x2Fparser__parse
```

The escape is injective, so the mangle is. When the result exceeds 200
bytes the readable prefix is truncated to 184 bytes and 16 hex digits of
BLAKE3 over the full canonical key are appended. *Implemented as
`zyl_mangle_key` / `zyl_sym_escape` in `runtime/actor_runtime.c`, with a
C BLAKE3 (`zyl_blake3_hex`) beside it, rather than reusing
`stdlib/math/hash/blake3.zyl` as planned: the runtime copy is the one
implementation on the build path (mangling and the archive, lock and
graph hashes), and the two agree on test vectors.*

Monomorphized instances carry fully-qualified type arguments, or generics
from different packages would re-collide:

```
acme/json@1::json::encode<acme/json@1::json::Node>
acme/json@1::json::encode<beta/xml@2::xml::Node>
```

### Trait coherence

Because two packages can now each write `impl Ord for Vec`, spec §24.6's
"coherence applies at crate level" needs a concrete orphan rule:

> A package may implement a trait for a type only if it defines the trait
> or defines the type.

Violations are `E_PKG_ORPHAN_IMPL`. Coherence is otherwise checked over
the whole resolved graph, which is possible precisely because the build
is whole-program.

---

## 3. Manifest: `zyl.pkg`

Parsed by the existing `lexer.zyl` + `parser.zyl`. No new parser, no new
tokenizer rules, and comments and formatting are already handled.

```lisp
(package
  (name    "acme/json")
  (version "1.4.0")
  (zyl     "5.0")            ; minimum compiler version
  (edition "2026")           ; syntax era; see §11

  (description "A deterministic JSON reader and writer.")
  (license "Apache-2.0")
  (repository "https://github.com/acme/json")

  ;; Capabilities this package is permitted to use. Absent means none.
  (capabilities io)

  (deps
    (dep "core/bytes" "2.1.0")
    (dep "acme/utf8"  "1.0.0" (features utf16))
    (dep "acme/dev"   "0.3.0" (path "../dev"))      ; workspace member
    (dep "acme/git"   "1.0.0" (git "https://..." (rev "a1b2c3d"))))

  (dev-deps
    (dep "acme/quickcheck" "2.0.0"))

  (features
    (feature utf16 (deps (dep "acme/utf16" "1.0.0")))
    (feature simd))

  (native
    (sources "c/fastpath.c")
    (cflags "-O2" "-DJSON_STRICT")
    (link-libs "m")))
```

### Field rules

- `name`, `version`, `zyl`, `edition` are required. Everything else is
  optional and defaults to empty.
- Requirement strings are bare versions. **There are no range
  operators.** Under MVS a requirement is a *minimum*, and the major is
  implied by the version itself, so `^1.4.0` and `1.4.0` would mean the
  same thing. Admitting both would be two ways to write one fact, which
  the determinism posture does not want. A range operator in a
  requirement is `E_PKG_BAD_REQUIREMENT`, whose message explains this.
- Key order inside a form is free; the *canonical* serialisation written
  by `zyl` tooling is the order shown above, with `deps` sorted by name.
- Duplicate `dep` entries for one name are `E_PKG_DUPLICATE_DEP`.
- `dev-deps` are used when building this package's own tests and never
  enter the graph of a package that depends on it.

---

## 4. Modules, imports and visibility

### Import syntax

```lisp
(use acme/json:parser { parse parse-strict })  ; package, module in it
(use acme/json { parse })                      ; package root module
(use acme/json:parser { parse => json-parse }) ; renaming import
(use acme/json:parser *)                       ; whole public surface
(use internal/helpers)                         ; module in THIS package
(use acme/ffi:raw :unsafe { poke })            ; unsafe import
```

The rule is: **if the form contains a colon, the text before it is a
package name and the text after it is a module path within that package.
With no colon, the whole path is a module within the current package.**
A package's own root module is reached by naming the package with no
colon part, which is unambiguous because a package name always contains
a `/` and is always a declared dependency.

The lexer already produces exactly the tokens needed — `:` is not an
identifier-continue character, so `acme/json:parser` is `TkIdent
"acme/json"` followed by `TkKeyword "parser"`. *As implemented, `use`
forms are read by `module_resolver.zyl` from the raw parse tree
(`mr-use-*`: the colon part, `*`, `:unsafe`, and `{ a b => c }` brace
lists), before conversion to ExprInner; the `EUseModule` arm in
`expr_inner.zyl` still passes `None` and `false`, and nothing downstream
needs it to do otherwise.*

One wrinkle: the lexer discards whitespace, so `(use acme/json :unsafe)`
and `(use acme/json:unsafe)` produce identical token streams. `unsafe` is
therefore a **reserved module name** — no package may contain a module
called `unsafe`. Violations are `E_PKG_RESERVED_MODULE`.

Existing stdlib imports such as `(use core/list)` are unaffected: they
contain no colon, and stdlib is resolved implicitly (§9).

### Visibility

Two levels. A definition is visible throughout its own package by
default, and crosses the package boundary only when marked `pub`:

```lisp
(pub defn parse (s) ...)     ; exported from the package
(defn scan-ws (s) ...)       ; visible package-wide, invisible outside
(pub deftype Node (...))     ; types and traits export the same way
```

Importing a non-`pub` symbol from another package is
`E_PKG_PRIVATE_SYMBOL`. Importing a name the package does not define at
all is `E_PKG_UNKNOWN_SYMBOL`.

Visibility is about reachability only. A private symbol still receives a
unique mangled name — privacy never depends on name uniqueness, so
renaming a private function can never break a consumer.

`export` (spec §24.3) becomes redundant and is deprecated: `pub` at the
definition site is the single mechanism. The keyword stays reserved.

### Resolution

Module resolution stays DAG-based (spec §24.5) and now applies at two
levels: modules within a package must form a DAG, and packages must
form a DAG. Cycles are `E_PKG_CYCLE` and `E_MODULE_CYCLE` respectively.

The pre-5.0 resolver (`module_resolver.zyl`) spliced every dependency's
whole body and did no symbol filtering. Under this design it gains a
real import table per compilation unit: a map from the local name a file
uses to a canonical key. Name lookup consults that table, not a global
namespace. *As implemented (`qualify.zyl` with `module_resolver.zyl`),
a module's table is built weakest-first: the rest of its package, then
the modules it explicitly `use`s, then its own definitions, so only a
name nobody disambiguated falls back to last-one-wins.*

---

## 5. Version resolution: Minimal Version Selection

Given the root manifest, build the dependency graph by loading each
reachable manifest, then:

```
for each package name P reachable from the root:
    selected(P) = max over all requirements R on P of version(R)
```

That is: each requirement is a minimum; the selected version is the
greatest of the minimums, within a major (majors are distinct packages,
§2). No search, no backtracking, no solver.

```
A requires C 1.2.0
B requires C 1.5.0
-------------------
selected: C 1.5.0
```

Properties this buys, all of which matter here:

- Resolution is a pure function of the manifests in the graph. It does
  not depend on what the index happens to contain today, so it does not
  drift over time and does not need a lockfile to be reproducible.
- Adding a dependency can never silently upgrade an unrelated one.
- Removing a dependency can never silently downgrade another, because
  the selected version is a maximum over a set that only shrinks.
- The result is stable under index mirroring and index outages.

Upgrades are explicit acts: `zyl update acme/json` rewrites the
requirement in `zyl.pkg`. The version you get is the version your
manifest — or a dependency's manifest — asks for.

The root manifest may override a selection for the whole graph:

```lisp
(overrides
  (override "acme/json" "1.9.2")          ; force at least this
  (override "acme/bad"  (path "../fork")))
```

Overrides apply only in a root package or workspace, never transitively
from a dependency, and are recorded in the lock.

**[amends spec §20.6]**, which said "highest compatible version".

---

## 6. Lockfile: `zyl.lock`

The lock is an integrity and provenance record, not a resolution input.
Because MVS is already deterministic, deleting the lock changes nothing
about *which* versions are selected; it only discards the recorded
hashes, keys and capability set, which is exactly the security-relevant
part.

```lisp
(lock
  (version 1)
  (compiler "5.0.0" (hash "blake3:9f2c..."))

  (pkg "acme/json" "1.4.0"
    (source (registry "https://github.com/zyl-lang/index"))
    (hash   "blake3:4d7e...")
    (key    "ed25519:1a2b...")
    (sig    "ed25519:88cd...")
    (features utf16)
    (capabilities io)
    (deps "core/bytes" "acme/utf8"))

  (pkg "core/bytes" "2.1.0" ...)

  (capability-closure io ffi)
  (graph-hash "blake3:cc10..."))
```

- `hash` is BLAKE3 over the canonical package archive (§7).
- `key` is the publisher key pinned on first use. A later publication
  under a different key is `E_PKG_KEY_CHANGED` and requires explicit
  acceptance (`zyl update --accept-key acme/json`).
- `capability-closure` is the union of every capability granted anywhere
  in the graph. Growth in this set between resolutions is surfaced as a
  diff by `zyl update` and is a hard error under `--locked`.
- `graph-hash` is BLAKE3 over the canonical serialisation of everything
  above, and is an input to binary hash finalization (§12).

The lock is committed for applications **and** for libraries. For a
library it does not constrain consumers — a consumer runs its own MVS
over manifests — but it pins what the library's own CI builds and tests.

---

## 7. Fetching and the content store

The runtime has no sockets. It has `zyl_exec_cmd` and `zyl_system_cmd`
(`runtime/actor_runtime.c`), which is enough, and keeps every network
operation outside the deterministic path.

```
zyl fetch    git/curl  ->  ~/.zyl/store/blake3/<hash>/   ($ZYL_HOME/store when set)
zyl build    reads the store only; never touches the network
```

`zyl build` with a store entry missing fails with `E_PKG_NOT_IN_STORE`
rather than fetching implicitly. CI is therefore `zyl fetch --locked &&
zyl build`, and a build that succeeds once succeeds forever offline.

### Canonical archive

A published package is a `.tar.zst` whose content hash must be stable
across producers, so the archive format is pinned:

- Paths are relative to the package root, sorted bytewise.
- Only regular files and directories; no symlinks, no devices.
- Mode is normalised to `0644` for files, `0755` for directories.
- All timestamps are zero, all uid/gid are zero, all user/group names
  are empty.
- Excluded: `build/`, `.git/`, `zyl.lock`, and anything matched by
  `(exclude ...)` in the manifest.
- zstd level 19, long-distance matching off.

`hash` in the lock is BLAKE3 over the *uncompressed* canonical tar, so
it is independent of the compressor's version.

---

## 8. Index and trust

### Index

A git repository of S-expression metadata, sharded by name:

```
ac/me/acme/json.zyl
```

```lisp
(index-entry
  (name "acme/json")
  (versions
    (v "1.4.0"
       (url  "https://packages.zyl-lang.org/acme/json/1.4.0.tar.zst")
       (hash "blake3:4d7e...")
       (key  "ed25519:1a2b...")
       (sig  "ed25519:88cd...")
       (zyl  "5.0")
       (yanked false))
    (v "1.3.0" ...)))
```

`zyl fetch` clones or pulls the index and reads it locally. There is no
server to run: a git remote and any static file host suffice, and the
whole index is trivially mirrorable. Index history is an audit log for
free.

### Trust

The publisher signs the BLAKE3 hash of the canonical archive with an
Ed25519 key. `stdlib/math/crypto/asymmetric/ed25519.zyl` already
implements this, so verification is self-hosted with no new C.

Verification is **mandatory** and cannot be disabled by a flag. The trust
model is trust on first use, per package:

1. On first resolution of a package, its publisher key is pinned into
   `zyl.lock`. *As implemented, the pin also lives beside the store, one
   file per package under `~/.zyl/keys/`, and `idx-check-key` compares
   against that file.*
2. On every later fetch, the signature must verify against the pinned
   key and the content hash must match the lock.
3. A key change is `E_PKG_KEY_CHANGED`, a hash change is
   `E_PKG_HASH_MISMATCH`. Both stop the build until a human accepts the
   change explicitly, which produces a visible lockfile diff.

No central authority holds a signing key, and key rotation is a
reviewable event in version control rather than an invisible one.

---

## 9. Capabilities

This is the feature that justifies doing package management in Zyl
specifically rather than copying Cargo. Zyl's type system can *enforce*
what other package managers can only document.

A package declares the capabilities it may use. Absent means none:

```lisp
(capabilities io)          ; may do IO, may not use FFI or spawn actors
(capabilities)             ; pure computation only
```

The capability set is:

| Capability | Grants |
|------------|--------|
| `io` | `core/io` and everything under `stdlib/io` |
| `ffi` | `ffi-call`, `ffi-pin`, Pin-region allocation |
| `actor` | `spawn`, `send`, `receive` |
| `secret` | the `Secret` capability type and `stdlib/math/secret` |
| `native` | shipping and compiling C sources (§10) |
| `unsafe` | `:unsafe` imports |

Enforcement runs as a dedicated pass after module resolution and before
type inference (`capability_check.zyl`). Every top-level form is tagged
with its owning package by the resolver — as implemented, the tag is the
package half of the form's canonical key — and the pass rejects:

- use of a capability-bearing construct (`ffi-call`, `spawn`, a `:unsafe`
  import) from a package lacking the grant;
- a `use` of a capability-bearing stdlib module from a package lacking
  the grant — each stdlib module declares which capability it provides,
  so this is a table lookup rather than a dataflow analysis.

All violations are `E_PKG_CAPABILITY_VIOLATION`. *As implemented, see
§16 for which constructs each capability actually guards.*

A declared set is a ceiling on the package itself. It is not a grant a
consumer must repeat — per-edge re-granting is noise that people learn to
paste without reading. Instead the *effective transitive closure* is
computed and written to `zyl.lock` as `capability-closure`, and:

- `zyl update` prints a diff when the closure grows, naming the package
  that introduced each new capability;
- under `--locked`, growth is a hard error;
- a root package may hard-forbid capabilities graph-wide:

```lisp
(deny-capabilities ffi native unsafe)
```

The practical result: a dependency that declares `(capabilities)` is
*provably* unable to open a file, call C, or reach the network,
regardless of what its source does — and a supply-chain attack that adds
such a call changes the closure, which changes the lock, which shows up
in review.

---

## 10. Features and native dependencies

### Features

Features are additive-only. A feature may add new top-level definitions
and new trait impls; it may never remove or alter an existing one.

```lisp
(feature-gate utf16
  (pub defn parse-utf16 (b) ...))
```

`feature-gate` is valid only at top level. Because gated forms are
*separate definitions*, the additive property holds by construction —
there is no way to express "when feature X, this function has a different
signature". A gated definition colliding with a base definition is
`E_PKG_FEATURE_COLLISION`.

Features are unified: the union of every request across the graph is
computed, the package is compiled once with that union, and the union is
written to the lock. Since features cannot change existing signatures,
unification can never break a consumer that did not ask for the feature —
which is the failure mode that makes Cargo's unification painful.

A feature may pull in optional dependencies, which enter the MVS graph
only when the feature is in the union.

### Native dependencies

Declarative only. No build scripts, in any form — arbitrary code at build
time would forfeit the determinism contract (spec §27) outright.

```lisp
(native
  (sources "c/fastpath.c" "c/util.c")
  (cflags "-O2" "-DJSON_STRICT")
  (link-libs "m" "pthread")
  (include-dirs "c/include"))
```

- `native` requires the `native` capability, and using the resulting
  symbols requires `ffi`.
- Paths are package-relative; escaping the package root is
  `E_PKG_NATIVE_PATH_ESCAPE`.
- `cflags` are drawn from an allowlist (`-O*`, `-D*`, `-I` via
  `include-dirs`, `-std=*`, `-f` for a fixed safe subset). Anything else
  is `E_PKG_NATIVE_FLAG_DENIED`. Notably `-I/abs/path`, `-L`, `-l` as raw
  flags, and any `-Wl,` are rejected; linking is expressed through
  `link-libs`.
- `zyl` invokes `cc` itself with a canonical, sorted argument vector, and
  the object hash is recorded in the lock. *Not implemented: the lock has
  no object-hash field, and `zyl.buildinfo`'s `native-objects` list is
  always empty (§16).*

Packages that need autoconf-style probing are out of scope for 5.0. The
supported answer is to vendor a pre-configured C source set.

---

## 11. Workspaces, editions, tooling

### Workspaces

```lisp
;; zyl-workspace.zyl at the repository root
(workspace
  (members "stdlib" "selfhost" "tools/lsp")
  (overrides ...))
```

- One `zyl.lock` at the workspace root, covering every member.
- One shared `build/` cache and one shared store.
- Members depend on one another by path:
  `(dep "zyl/compiler" "5.0.0" (path "../compiler"))`.
- A path dep must still carry a version, which must match the target's
  manifest; this keeps a member publishable without edits.

Under MVS a single root lock cannot skew between members, because the
selected version is a function of the union of the members' manifests.

### Editions

`(zyl "5.0")` is a minimum compiler version; a compiler older than it
refuses with `E_PKG_COMPILER_TOO_OLD`.

`(edition "2026")` names the syntax and defaults era. Packages of
different editions coexist in one graph: each package is parsed and
lowered under its own edition's rules, which is possible because editions
are a front-end concern and everything converges on one ICNF. An unknown
edition is `E_PKG_UNKNOWN_EDITION`.

Editions exist so a future release can change syntax or defaults without
a flag day. 5.0 defines exactly one edition, `2026`.

### CLI

Subcommands of the existing self-hosted `zyl` binary, written in Zyl —
not a separate tool, and not Python:

```
zyl new <name>              scaffold a package
zyl add <pkg> <version>     add a dependency, update the lock
zyl fetch [--locked]        populate the store; the only networked command
zyl build [--locked]        offline build
zyl test
zyl update [pkg]            raise requirements; show capability diff
zyl vendor                  copy the store into ./vendor for air-gapped CI
zyl audit                   print the capability closure and key pins
zyl publish                 build the canonical archive, sign, emit index entry
zyl key new|show            manage publisher keys
```

*As implemented (`zyl` with no arguments prints the list): `zyl add
<name> [version]` takes the index's latest version when none is given
and rewrites `zyl.pkg`; `zyl fetch` takes no flag and writes `zyl.lock`;
`zyl update` takes no package argument, re-resolves the whole graph,
rewrites `zyl.lock` and prints either `capability closure unchanged` or
`capability closure grew to: ...`; `zyl audit` prints each package's
capabilities and the closure, not key pins; `zyl publish` prints the
index entry with a `(url "https://REPLACE-ME")` placeholder, or with
`--index DIR [--url-base URL]` adds it to a local index and commits; `zyl key`
has no subcommands and shows the publisher key, creating
`~/.zyl/keys/publisher.seed` on first use.*

`zyl fetch` is the sole command permitted to touch the network. Every
other command fails closed if something is missing from the store.

---

## 12. Determinism and hashing

The determinism contract (spec §27) extends to the package graph. Hash
finalization (pipeline step 11) takes as input, in this canonical order:

1. the compiler's own hash;
2. `graph-hash` from the lock — itself covering every package name,
   version, content hash, publisher key, resolved feature set, edition
   and declared capability set;
3. the canonical native-object hashes;
4. the existing ICNF hash.

`zyl build` writes `zyl.buildinfo` next to the binary, recording all four
plus the resolved graph in canonical form, so a third party can verify a
binary was produced from a claimed set of inputs. *As implemented it is
written as `<binary>.buildinfo` with `compiler-hash`, `graph-hash`
(empty when there is no lock), an always-empty `native-objects` and
`asm-hash` in place of an ICNF hash; the resolved graph is not written,
and none of it is mixed into the binary's own hash yet (§16).*

Consequences worth stating explicitly:

- Two machines with the same `zyl.pkg`, the same `zyl.lock` and the same
  compiler produce byte-identical binaries.
- An index compromise cannot change a build that has a lock, because
  content hashes and publisher keys are pinned.
- Build caching is sound: cache entries are keyed by content hash, and
  the determinism contract guarantees a cache hit and a rebuild agree.

---

## 13. New error codes

Per spec §28, every code must be defined and used consistently. These are
added to `stdlib/compiler/error_codes.zyl`. Phase 9 is the existing
`module` phase; a new phase **19 = package** covers manifest, lock,
index, fetch and signature errors. *Done: all 36 are in the catalog and
in spec §28, the phase legend has the entry, and every one has at least
one raising site (`docs/errors.md` lists them).*

| Code | Phase | Meaning |
|------|-------|---------|
| `E_MANIFEST_INVALID` | 19 | `zyl.pkg` is malformed or missing a required field |
| `E_MANIFEST_NOT_FOUND` | 19 | no `zyl.pkg` in the package root |
| `E_PKG_BAD_NAME` | 19 | name is not a valid scoped path |
| `E_PKG_BAD_VERSION` | 19 | version is not strict SemVer |
| `E_PKG_BAD_REQUIREMENT` | 19 | range operator in a requirement; MVS takes minimums |
| `E_PKG_DUPLICATE_DEP` | 19 | two `dep` entries for one name |
| `E_PKG_NOT_FOUND` | 19 | name not present in the index |
| `E_PKG_VERSION_NOT_FOUND` | 19 | version not present in the index |
| `E_PKG_NOT_IN_STORE` | 19 | build needs a package the store lacks; run `zyl fetch` |
| `E_PKG_HASH_MISMATCH` | 19 | archive hash differs from the lock |
| `E_PKG_SIGNATURE_INVALID` | 19 | Ed25519 signature does not verify |
| `E_PKG_KEY_CHANGED` | 19 | publisher key differs from the pinned key |
| `E_PKG_UNSIGNED` | 19 | index entry carries no signature |
| `E_PKG_YANKED` | 19 | new resolution selected a yanked version |
| `E_PKG_LOCK_STALE` | 19 | `--locked` but the manifests imply a different graph |
| `E_PKG_LOCK_INVALID` | 19 | lock is malformed or of an unknown version |
| `E_PKG_COMPILER_TOO_OLD` | 19 | package requires a newer compiler |
| `E_PKG_UNKNOWN_EDITION` | 19 | edition not known to this compiler |
| `E_PKG_FETCH_FAILED` | 19 | git/curl exited non-zero |
| `E_PKG_ARCHIVE_INVALID` | 19 | archive violates the canonical format |
| `E_PKG_NATIVE_PATH_ESCAPE` | 19 | native source path escapes the package root |
| `E_PKG_NATIVE_FLAG_DENIED` | 19 | cflag outside the allowlist |
| `E_PKG_NATIVE_BUILD_FAILED` | 19 | `cc` failed on a native source |
| `E_PKG_CYCLE` | 9 | dependency graph is not a DAG |
| `E_MODULE_CYCLE` | 9 | module graph within a package is not a DAG |
| `E_PKG_VERSION_CONFLICT` | 9 | requirement cannot be satisfied within a major |
| `E_PKG_PRIVATE_SYMBOL` | 9 | imported symbol is not `pub` |
| `E_PKG_UNKNOWN_SYMBOL` | 9 | imported symbol does not exist |
| `E_PKG_UNKNOWN_MODULE` | 9 | module path does not exist in that package |
| `E_PKG_UNDECLARED_DEP` | 9 | `use` names a package absent from the manifest |
| `E_PKG_RESERVED_MODULE` | 9 | module named `unsafe` |
| `E_PKG_ORPHAN_IMPL` | 12 | impl where neither trait nor type is local |
| `E_PKG_CAPABILITY_VIOLATION` | 13 | construct used without the declared capability |
| `E_PKG_CAPABILITY_GROWTH` | 13 | capability closure grew under `--locked` |
| `E_PKG_FEATURE_UNKNOWN` | 19 | requested feature not declared |
| `E_PKG_FEATURE_COLLISION` | 19 | gated definition collides with a base definition |

---

## 14. Implementation plan

Every phase changes the compiler's own source, so every phase ends with
`python3 selfhost/assemble.py`, `./boot.sh --bootstrap-from-self`,
`./boot.sh`, and a committed seed, per `AGENTS.md`. Each phase is
independently useful and independently fixed-point-verified.

*Status (2026-09-23): all five phases landed in one implementation
session, not five. Phase 2's conversion of this repository into a
workspace was deliberately not done (see the top of this document); the
other deviations are in §16. File names below are the plan's; the
manifest reader is `package.zyl`, name lookup is `qualify.zyl` and
`module_resolver.zyl`, and the orphan rule is checked in
`module_resolver.zyl` rather than `trait_dispatch.zyl`.*

### Phase 1 — Namespacing and visibility

The language changes, with no distribution machinery at all.

- `zyl.pkg` reader: a new `stdlib/compiler/manifest.zyl` on top of the
  existing parser.
- Parser: populate the symbol list and unsafe flag in `EUseModule`
  (`expr_inner.zyl`); parse the colon form.
- Injective mangler, replacing `zyl_cstr_sanitize` on the label path.
  This is the one change that must land before anything else can be
  trusted, since the current sanitiser silently merges distinct names.
- `module_resolver.zyl`: per-unit import tables, package tagging of every
  top-level form, cycle detection at both levels.
- `resolver.zyl`: name lookup through the import table.
- `pub` parsing and boundary enforcement.
- Monomorphization: canonical keys in instance names, qualified type
  arguments.
- Orphan rule in `trait_dispatch.zyl`.
- New error codes for phases 9 and 12.

Exit test: the repo's own `stdlib/` compiles with every module carrying a
package tag, two test packages define a same-named function and link, and
the struct and balanced-parens regression filters pass.

### Phase 2 — Workspace and self-application

- `zyl-workspace.zyl`, path deps, root lock skeleton with no hashes.
- Convert this repository into a workspace: `stdlib`, `selfhost`,
  `tools`, with real `zyl.pkg` files and explicit `pub` surfaces.
- Implicit stdlib resolution wired to the compiler version.

Exit test: `./boot.sh` reaches a clean fixed point with the compiler
built as a workspace of packages, and the full regression suite passes.

### Phase 3 — Resolution, lock, store

- MVS over the graph; overrides.
- Content-addressed store, canonical archive format, BLAKE3 hashing.
- `zyl.lock` writer and reader; `--locked`.
- `zyl new`, `zyl add`, `zyl build`, `zyl test`, `zyl vendor`.

Exit test: a multi-package fixture resolves identically from a cold and a
warm store, and produces byte-identical binaries on repeated builds.

### Phase 4 — Index, fetch, signing, capabilities

- Index format and a `zyl fetch` that shells to git and curl.
- Ed25519 signing and verification over the archive hash; TOFU key
  pinning; `zyl publish`, `zyl key`.
- Capability declaration, the enforcement pass, closure computation,
  `zyl audit`, `deny-capabilities`.

Exit test: a tampered archive, a resigned package and an
over-reaching dependency each fail with the right code; a package
declaring `(capabilities)` cannot compile an `ffi-call`.

### Phase 5 — Native deps, features, editions

- `native` blocks, the cflag allowlist, canonical `cc` invocation.
- `feature-gate`, unification, optional deps, lock recording.
- Edition plumbing with `2026` as the sole edition.
- `graph-hash` into hash finalization; `zyl.buildinfo`.

Exit test: a package with a C source and a feature builds
reproducibly on two machines, and `zyl.buildinfo` matches.

---

## 15. Specification amendments

*Status: made. `zyl_specification.txt` is v5.0 and carries §31.*

- §20.6 — replace the roadmap with a pointer to this design; correct
  "highest compatible version" to MVS.
- §24.2 — add the colon form and the renaming import.
- §24.3 — deprecate `export` in favour of `pub`.
- §24.4 — restate visibility as two levels.
- §24.5 — `zyl.pkg`, not `zyl.toml`.
- §24.6 — state the orphan rule.
- §25 — note that stdlib is implicit and versioned with the compiler.
- §27 — extend the determinism contract to the resolved graph.
- §28 — add the codes in §13 above.
- §30 — restate the v5.0 entry.

A new spec section, §31 Package System, carries the normative form of
§§2–12 of this document, with `spec/16-package-system.md` as its
structured copy.

---

## 16. Implementation notes (2026-09-23)

Where the implementation differs from the design above. The first five
are the deliberate deviations `PROGRESS.md` records; the rest are gaps
found by reading the modules.

- **The standard library stays implicit.** It is package `zyl/std` at the
  compiler's major, with no manifest: fully visible, never
  capability-enforced, not a workspace member (§25 wins over the Phase 2
  sketch).
- **A lone file is `local/main`@0.** Compiling a file directly needs a
  package name for its keys, but no capability ceiling is enforced
  against a file that declared nothing.
- **Module layout.** A module path `M` in package `P` is
  `<root of P>/M.zyl`; a package's root module, what `(use acme/json)`
  names, is the module spelled by the name's last segment
  (`json.zyl`).
- **`zyl.buildinfo` hashes the assembly, not the ICNF**, which has no
  serialised form.
- **Qualified names are copied per occurrence**, because
  `type_inference.zyl` compares names with `=` (a pointer comparison) and
  a shared key pointer woke a dormant, broken code path.
- **Capabilities, as enforced.** `ffi` guards `ffi-call`, `ffi-pin`,
  `ffi-unpin` and `use` of `ffi/*`; `actor` guards `spawn`, `send`,
  `receive` and `actor/*`; `io` guards `file-open`, `file-read`,
  `file-write`, `file-close`, `read-line`, `core/io` and `io/*`;
  `secret` guards `use` of `math/secret/*` (not the `Secret` annotation
  itself); `native` is checked by `zyl build` when a manifest has a
  `native` block. The `unsafe` capability is accepted in manifests and
  `:unsafe` is parsed in `use`, but nothing checks one against the other.
  Pin-region allocation outside `ffi-pin` is not guarded. Only packages
  with a manifest are checked, and `deny-capabilities` applies only
  there.
- **Native objects are not hashed.** The lock has no object-hash field
  and `buildinfo`'s `native-objects` is always `()`.
- **Hash finalization** records its inputs in `buildinfo` but does not
  mix the graph hash into the binary's hash; `buildinfo` does not carry
  the resolved graph.
- **Tooling surface** differs from §11's list as described there: no
  `zyl update <pkg>` and no `--accept-key` (a key change is a hard stop
  with no accept path in the tool), no `zyl fetch --locked`, no
  `zyl key new|show`, and `zyl audit` does not print key pins.
- **cflag allowlist** is exactly: `-O*`, `-D*`, `-std=*`, `-fPIC`,
  `-fno-strict-aliasing`, `-fwrapv`, `-fstack-protector-strong`,
  `-fno-omit-frame-pointer`; include directories come from
  `include-dirs`.
- **No build cache**; every build recompiles the whole graph.
- **The default index URL** (`https://github.com/zyl-lang/index`) is not
  hosted yet; `ZYL_INDEX` selects another, and the registry path is tested
  end to end against a local git index (`tests/scripts/package-index.sh`). A `git` dependency is cloned, archived,
  locked and built (`mvs-git-fetch`), verified with a local `file://`
  repository.
- **Paths and URLs** handed to `tar`, `zstd`, `git`, `curl` or `cc` must
  pass `store-safe`'s character set; a space or quote is refused rather
  than quoted.
- **A nested `feature-gate`** is not rejected; it is treated as an
  ordinary form.
- **Ed25519 ships inside the compiler bundle** (in Zyl), because
  verification is mandatory; moving it into the runtime was considered
  and not done.
