# Remaining Work (after items 5,6,11,22,23,26,27 + type-name fix complete)

## P1: Diagnostics
- [x] Labelled secondary spans for capability errors (`E_MUT_CONFLICT`, `E_CAPABILITY_LEAK`, `E_PKG_CAPABILITY_VIOLATION`); no region diagnostic is raised yet
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
- [ ] Tail calls: indirect calls and calls with more than six arguments; interpreter TCO
- [ ] Contracts: profiles, `checkpoint` rollback, typed `recover` arms
- [ ] Hash finalization: a real ICNF hash (needs an ICNF printer) and the resolved graph recorded in `.buildinfo`

## P4: Tooling & Packages
- [ ] Documentation: what arenas are, and which values the arena/capacity arguments of `vec-create` and similar constructors accept (0 = private default arena, handles from `arena-create`, ...)
- [ ] `zyl doc` generator over `;|`/`;;` doc-comment convention
- [ ] Real package index; content-hash build cache; reject nested `feature-gate`
- [ ] LSP: return unused-binding warnings instead of printing them
- [ ] Bundle VS Code extension with problem matcher
- [ ] REPL: let definitions at prompt capture `def` bindings

## Deferred Design Work
- [x] Wider byte widths (16/32/64-bit)
- [ ] Deterministic region extension registry (fixed growth, alignment, policy)
- [ ] Capability-mediated sharing (TCap/atomic shared region, typed bounded channels)
- [ ] Inline assembly with region/capability-aware register rules
- [ ] Ergonomic zero-copy views beyond `byteslice` (parsing, substrings, array slices)

---
*Items 22 (assert), 23 (unwrap), 5/6/11/26/27 (runtime), and type-name-matching fix complete as of commit f6ea129*
