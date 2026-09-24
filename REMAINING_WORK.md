# Remaining Work (after items 5,6,11,22,23,26,27 complete)

## P1: Diagnostics
- [ ] Locate remaining diagnostics: thread offending node to failure, call `err-at`
- [ ] Fix `=`-on-strings comparisons in `type_inference.zyl` (root of "cannot determine type of match scrutinee" and REPL `:type` unresolved)
- [ ] Labelled secondary spans for capability/region errors
- [ ] "Did you mean" suggestions (edit-distance over in-scope names)
- [ ] Structured JSON error output for tools/LSP
- [ ] Warning sweep (`W_UNUSED_PARAMETER`, `W_SHADOWED_BINDING` from `boot.sh`)

## P2: Codegen Correctness
- [ ] Field and return kinds so compiled `print`/`==` agree with interpreter
- [ ] Tail-call optimization in `codegen.zyl` (or self-tail-recursive whitespace skip in `lexer.zyl`) so `assemble.py` no longer collapses whitespace
- [ ] Per-file paren-depth check in `assemble.py`

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
*Items 22 (assert), 23 (unwrap), 5/6/11/26/27 (runtime) complete as of commit be7405f*
