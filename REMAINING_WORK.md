# Remaining Work (after items 5,6,11,22,23,26,27 + type-name fix complete)

## P1: Diagnostics
- [x] Labelled secondary spans for capability errors (`E_MUT_CONFLICT`, `E_CAPABILITY_LEAK`, `E_PKG_CAPABILITY_VIOLATION`); no region diagnostic is raised yet
- [x] "Did you mean" suggestions (edit-distance over in-scope names)
- [x] Structured JSON error output (`--error-format=json`); the LSP does not consume it yet
- [x] Warning sweep: the self-build is warning-free, and parameter warnings carry spans (qualify and macro expansion now copy them)

## P2: Codegen Correctness
- [x] Field and return kinds: `compiler/type_annotate.zyl` feeds inferred String/Float kinds to codegen and the interpreter (generic Vec/Map elements included); prelude `Show` trait with container impls and `derive Show`; trait calls resolved statically with per-type specialization; open: structural `==` on inferred ADT values, other derivable traits
- [x] ~~Whitespace collapse / per-file paren check in `assemble.py`~~ — obsolete: the compiler builds from `selfhost/driver.zyl` through module resolution; `assemble.py` and the bundle are gone
- [ ] Tail-call optimization in `codegen.zyl` (the lexer's mutually recursive whitespace skip still leaks a frame per character on very large single files)

## P3: Language Features
- [ ] Contract injection (spec §23) against real `expr_inner.zyl` shapes, wired into pipeline
- [ ] 16-, 32-, 64-bit byte loads/stores; distinct byte-buffer handle type
- [ ] `Secret`: zeroization on scope exit, `print` redaction, `Secret` trait
- [ ] `receive` form and runnable structured-message actor example
- [ ] Top-level `def` in compiled programs
- [ ] Hash finalization mixing graph hash into binary

## P4: Tooling & Packages
- [ ] `zyl doc` generator over `;|`/`;;` doc-comment convention
- [ ] Real package index; content-hash build cache; reject nested `feature-gate`
- [ ] LSP: return unused-binding warnings instead of printing them
- [ ] Bundle VS Code extension with problem matcher
- [ ] REPL: let definitions at prompt capture `def` bindings

## Deferred Design Work
- [ ] Wider byte widths (16/32/64-bit) beyond `byteslice`
- [ ] Deterministic region extension registry (fixed growth, alignment, policy)
- [ ] Capability-mediated sharing (TCap/atomic shared region, typed bounded channels)
- [ ] Inline assembly with region/capability-aware register rules
- [ ] Ergonomic zero-copy views beyond `byteslice` (parsing, substrings, array slices)

---
*Items 22 (assert), 23 (unwrap), 5/6/11/26/27 (runtime), and type-name-matching fix complete as of commit f6ea129*
