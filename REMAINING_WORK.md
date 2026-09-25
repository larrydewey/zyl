# Remaining Work (after items 5,6,11,22,23,26,27 + type-name fix complete)

## P1: Diagnostics
- [x] Labelled secondary spans for capability errors (`E_MUT_CONFLICT`, `E_CAPABILITY_LEAK`, `E_PKG_CAPABILITY_VIOLATION`); `E_REGION_ESCAPE` is raised and located but has no secondary label yet
- [x] "Did you mean" suggestions (edit-distance over in-scope names)
- [x] Structured JSON error output (`--error-format=json`); the LSP does not consume it yet
- [x] Warning sweep: the self-build is warning-free, and parameter warnings carry spans (qualify and macro expansion now copy them)

## P2: Codegen Correctness
- [x] Field and return kinds: `compiler/type_annotate.zyl` feeds inferred String/Float kinds to codegen and the interpreter (generic Vec/Map elements included); prelude `Show` trait with container impls and `derive Show`; trait calls resolved statically with per-type specialization; structural `==` on ADT values; open: other derivable traits
- [x] ~~Whitespace collapse / per-file paren check in `assemble.py`~~ — obsolete: the compiler builds from `selfhost/driver.zyl` through module resolution; `assemble.py` and the bundle are gone
- [x] Tail-call optimization in `codegen.zyl`: direct tail calls with at most six arguments are jumps; open: indirect and stack-argument tail calls, interpreter TCO
- [x] `print` on `Result`: the prelude impl already existed; the real bug was a payload without `Show` (garbage or segfault via the runtime trait dispatch), now printed raw; open: explicit `Show.show` on a type without an impl still falls into that dispatch

## P3: Language Features
- [x] Dot syntax: `v.field` (chained) and `(v.method args)` / `((expr).method args)` resolved by receiver type; open: ambiguous method names on unknown-type receivers need the qualified name
- [x] Contract injection (spec §23): lowered in `expr_inner.zyl`; open: profiles, `checkpoint` rollback, typed `recover` arms
- [x] `try` around an even-arity call segfaulted or hung (frame pointer overwritten)
- [x] Trait method with a compound (or no) return type: `print` of the call printed an address
- [x] 16-, 32-, 64-bit byte loads/stores; distinct `ByteBuf`/`ByteSlice` handle types
- [x] `Secret`: frame zeroization on return, redaction (`<secret>`), `Secret` trait, Secret-field taint; `impl-not` with a flow rule (`E_IMPL_FORBIDDEN`); open: heap erasure explicit, `set!` into `let-mut` untracked
- [x] `receive` form, `actor-self`, and a runnable structured-message actor example (`book/examples/actor-counter/`)
- [x] Top-level `def` in compiled programs: immutable globals, initialized in source order before `main`
- [x] Hash finalization: final hash of compiler/graph/native/asm hashes embedded in the binary (`zyl_build_hash`) and recorded in `.buildinfo`

## P3.5: Open follow-ups (from P1-P3)
- [x] Lexer: an unrecognized character is `E_INVALID_CHAR` (located), an unterminated string `E_UNTERMINATED_STRING`
- [x] A trait call on a known type with no impl is `E_TRAIT_NOT_FOUND` (located)
- [x] Secret: a `let-mut` that is ever `set!` to a secret is secret for its whole scope
- [x] Dot syntax: `(expr).field` (chained, and `((expr).f.m args)` calls `m` on a field)
- [x] Secret checker / impl-not flow rule diagnostics are located (`error[CODE]` with file:line:col)
- [x] Derivable traits: Show, Debug, Eq, Ord, Hash, Clone, with the field requirement checked (`E_TRAIT_NOT_DERIVABLE`); open: Vec/Map implement only Show
- [x] Tail calls: indirect calls, stack arguments within the caller's incoming area, and interpreter TCO (except String/Float results)
- [x] Contracts: profiles (`--contracts=P`, `(contracts P)`), `checkpoint` rollback of `let-mut` state, `recover` arms by error code
- [x] Hash finalization: ICNF hash from a canonical ICNF printer (`icnf_print.zyl`), resolved graph recorded in `.buildinfo`

## P4: Tooling & Packages
- [x] Documentation: arenas and the `arena`/`cap` arguments of `vec-create`, `map-create`, `set-create` (book §4.3 "Arenas"); a negative `cap` now means 0 instead of a null write
- [x] `zyl doc` generator (`compiler/doc.zyl`): module headers, item docs from the comment block above each definition, `;|` precedence, pub-only in packages
- [x] Reject nested `feature-gate` (`E_PKG_FEATURE_NESTED`)
- [x] Package index: `ZYL_INDEX` (git URL or local path), `zyl publish --index DIR`, `file://` archives; tested end to end (open: hosting the default index repository)
- [x] Content-hash build cache (spec 31.4): `~/.zyl/cache/<key>`, `ZYL_NO_BUILD_CACHE=1` to bypass
- [x] LSP: unused-binding and shadowing warnings are published as Warning diagnostics; every diagnostic is placed at its `--> line:col`
- [x] VS Code extension 0.4.0: esbuild bundle (10-file `.vsix`) and a `$zyl` problem matcher used by the build tasks
- [x] REPL: definitions entered at the prompt can use `def` bindings

## Deferred Design Work (order agreed 2026-09-24)
- [x] Wider byte widths (16/32/64-bit)
- [x] FFI timeouts enforced: literal timeout required (`E_FFI_TIMEOUT_REQUIRED`), worker-thread bridge raises `E_FFI_TIMEOUT`
- [x] Real regions: per-call regions, escape analysis over ICNF, region annotations, `E_REGION_ESCAPE` (done 2026-09-24, `docs/regions-design.md`)
- [x] The deterministic region extension registry: `with-region` with `arena` and `fixed` kinds, `E_REGION_SPEC`, `E_REGION_EXHAUSTED` (done 2026-09-24)
- [x] Sound HM type checking: every type error reported, no cast form, byte and file operands typed; `receive` the one known hole (done 2026-09-25, `docs/sound-types-design.md`)
- [x] Ergonomic zero-copy views beyond `byteslice`: `text/view` (`StrView`, `Cursor`) and `collections/slice` (`Slice`), tied to their base by escape analysis (done 2026-09-25)
- [x] List literals: `(list ...)`, `[...]` and quoted constant data `'(...)`, Cons chains in source order (done 2026-09-25)
- [x] Quasiquote (`` `d ``, `,e`, `,@e`) and macro `&rest` parameters spliced with `,@name` (done 2026-09-25)
- [ ] Leftovers: Vec/Map derive beyond Show; explicit `Show.show` without an impl hits runtime dispatch; ambiguous dot methods on unknown receivers; Secret heap erasure explicit; interpreter TCO for String/Float results; LSP consuming `--error-format=json`; hosting the default package index
- [ ] Deterministic concurrency (Kahn): single-sender channels with linear endpoints, blocking receive, no select, bounded buffers, commutative TAtomic read after join, actor output channels drained by main, `--sched=deterministic` oracle vs seeded chaos mode
- [x] ~~Inline assembly~~: rejected (breaks determinism)
- [ ] Deterministic intrinsics instead of asm (popcnt, clz/ctz, bswap, rotl, crc32, mul-hi; later SIMD with fallback)
