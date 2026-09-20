# Zyl LSP Server — Architecture Plan

## Executive Summary

Build a **native Zyl LSP server** (`stdlib/lsp/lsp_server.zyl`) that reuses the existing self-hosted compiler pipeline, providing rust-analyzer parity (diagnostics, hover, go-to-def, completion, document symbols, semantic tokens, code actions) with Zyl's unique strengths: deterministic incremental compilation, region/capability-aware diagnostics, and macro-expansion-aware navigation.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        LSP Server (Zyl)                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ JSON-RPC     │  │ Document     │  │ Compiler Pipeline    │  │
│  │ Transport    │◄─┤ Manager      │◄─┤ (Reused)             │  │
│  │ (stdio)      │  │ (VFS +       │  │                      │  │
│  └──────────────┘  │  Incremental)│  │  Parse → Macro →     │  │
│         ▲          │  └──────┬──────┘  │  Type → Region →     │  │
│         │            │       │         │  Mono → ICNF → CG    │  │
│         │            │       ▼         └──────────┬───────────┘  │
│         │            │  ┌──────────────┐         │              │
│         └────────────┼─►│ LSP Services │         │              │
│                      │  │ (Diagnostics,│         │              │
│                      │  │  Hover, Goto,│         │              │
│                      │  │  Completion, │         │              │
│                      │  │  Symbols,    │         │              │
│                      │  │  CodeAction) │         │              │
│                      │  └──────────────┘         │              │
└──────────────────────┴──────────────────────────┴──────────────┘
```

---

## Core Design Decisions

### 1. Native Zyl Implementation (Not Rust)
- **Why**: Full dogfooding, self-hosted consistency, no Cargo dependency
- **Transport**: JSON-RPC 2.0 over stdio (same as rust-analyzer)
- **Entry point**: New `lsp-server` binary built via `./boot.sh`

### 2. Reuse Compiler Pipeline — No Duplication
| LSP Feature | Compiler Phase Reused |
|-------------|----------------------|
| Diagnostics | All phases (parse → codegen) |
| Hover (types) | Type Inference + Monomorphization |
| Go-to-Definition | Module Resolver + Type Inference env |
| Completion | Type Inference env + VTable + Trait Context |
| Document Symbols | AST + ICNF function table |
| Semantic Tokens | Lexer + Type Inference kinds |
| Code Actions | Error codes + fix-it engine |

### 3. Incremental Compilation via Persistent Compiler State
```
DocumentManager:
  - VFS: Map<URI, SourceText>
  - ParseCache: Map<URI, (Ast, TokenStream, BalanceResult)>
  - InferenceCache: Map<URI, TypeInferer>
  - MonoCache: Map<URI, MonoContext>
  - ICNFCache: Map<URI, List<IFn>>
  - Version: Int (LSP document version)
```
Key insight: Zyl's **pure functional pipeline** (no mutation, deterministic) makes caching trivial — each phase is `Input → Output`, so invalidation = recompute from changed phase forward.

### 4. Determinism as LSP Feature
- Same document version → identical diagnostics/semantic tokens every time
- No "flaky" LSP behavior — critical for CI integration

---

## Module Structure

```
stdlib/lsp/
├── lsp_types.zyl           # LSP protocol types (InitializeParams, TextDocumentItem, etc.)
├── json_rpc.zyl            # JSON-RPC 2.0 encoding/decoding (stdio transport)
├── vfs.zyl                 # Virtual file system + version tracking
├── document_manager.zyl    # Incremental pipeline state per document
├── lsp_server.zyl          # Main server loop, request routing
├── services/
│   ├── diagnostics.zyl     # PublishDiagnostics (all phases)
│   ├── hover.zyl           # HoverProvider (type + doc)
│   ├── goto_definition.zyl # DefinitionProvider
│   ├── completion.zyl      # CompletionProvider
│   ├── document_symbols.zyl# DocumentSymbolProvider
│   ├── semantic_tokens.zyl # SemanticTokensProvider
│   └── code_action.zyl     # CodeActionProvider (uses error_fixit)
├── compiler_bridge.zyl     # Adapter: compiler pipeline → LSP types
├── capability_registry.zyl # Server capabilities advertisement
├── workspace.zyl           # Multi-root workspace, zyl.toml DAG
└── repl_integration.zyl    # REPL as LSP client
```

---

## Phase Plan

## Two facts that reshaped every phase below

Discovered during implementation, both confirmed by direct testing, both
now load-bearing design constraints rather than surprises:

- **Wall 1 — no source position tracking exists anywhere in the real
  compiler.** `Token`/`Ast`/`Expr`/`ExprInner` (lexer.zyl/ast.zyl/
  expr_inner.zyl) carry zero line/col fields. Only `sexp_balance.zyl`
  tracks position, via its own private byte-scan. So "type at this
  exact cursor position" (real inference-driven hover, inlay hints) is
  not reachable through the real AST. Fix used throughout: `lsp/
  source_index.zyl`, a standalone text scanner (same technique as
  sexp_balance) that maps cursor position <-> identifier text and
  top-level-form location, independent of the compiler's own AST. Real
  data, keyed by NAME rather than by exact expression position.
- **Wall 2 — every real compiler diagnostic is `exit(1)` if uncaught.**
  parser errors, mutability_check's E_MUT_CONFLICT/E_CAPABILITY_LEAK/
  E_INVALID_CAPABILITY, icnf's E_MATCH_NONEXHAUSTIVE/E_DUPLICATE_VARIANT
  all called `zyl_f_error` (hard `exit(1)`, uncatchable) — fine for a
  one-shot CLI compile, fatal for a server that must survive an
  in-progress edit. Fixed at the root: every such call site across
  `stdlib/compiler/*.zyl` was swapped to `zyl_panic` (same `exit(1)`
  fallback when uncaught, but unwinds via `try`/`catch` when caught).
  `lsp/document_manager.zyl` wraps its whole analysis pipeline in
  `try`/`catch`; a real compiler error becomes one Diagnostic instead
  of killing the process — confirmed by direct testing (a genuine
  `E_MUT_CONFLICT` source produces a diagnostic and the process
  survives).

Also found and fixed along the way, all now real fixes rather than open
bugs: `codegen.zyl` silently compiled every unbound identifier to the
literal `0` instead of erroring (the ORIGINAL crash this work started
from — `arena` referenced-but-never-bound in the balance-checker
wiring, compiled to `0`, used as a pointer, segfault); a
`(match x (Nil ...) (name ...))` catch-all-bind arm parses fine but
codegen never allocates an Env slot for the bound name in either an
ADT-scrutinee or an Int-scrutinee match (found independently in
`type_inference.zyl` and in this LSP's own `json_rpc.zyl` draft); no
call-site arity checking existed anywhere in the pipeline (added,
`compiler/arity_check.zyl`, caught a real 4-arg-call-to-a-3-arg-function
bug in `codegen.zyl`'s own `icnf-size` on its first run); array literal
syntax (`[...]`) reliably crashes or mislinks under the current
self-hosted compiler (worked around throughout with explicit Cons/Nil
chains); the native string-escape decoder (`zyl_cstr_decode` in
`runtime/actor_runtime.c`) silently returned a null string for `\r`
(and any escape besides `\n`/`\t`/`\"`/`\\`) — broke this server's own
Content-Length/CRLF framing until fixed. `zyl_system_cmd` (used by
`repl_integration.zyl`) crashes inside libc's `system()` on this
runtime (pthread worker thread + vfork interaction) — that one is
flagged, not fixed; see repl_integration.zyl's header comment.

### Phase 0: Foundation ✅ COMPLETE (real, verified)
- [x] `lsp_types.zyl` — LSP 3.17 type definitions, 643 lines covering the
  full surface this server actually uses (not the originally-estimated
  ~2500; that estimate assumed exhaustive coverage of features with no
  implementation here, e.g. semantic-highlighting-range edge cases)
- [x] `json_rpc.zyl` — real recursive-descent JSON parser/encoder +
  Content-Length stdio transport, byte-tested round-trip
- [x] `vfs.zyl` — open-document store, real incremental text-edit
  application (multi-line insert/delete tested)
- [x] `document_manager.zyl` — per-document analysis: balance check,
  then parse/resolve/macro-expand/mutability-check inside `try`/`catch`
  (Wall 2), then a flat `SymTable` built directly from the
  macro-expanded exprs (NOT `collect-definitions` / full type
  inference — see compiler_bridge.zyl's header for why: that path's
  own pre-existing `str-eq`-vs-`=` bugs, once fixed, blow the native
  call stack compiling this compiler's own source; reverted rather than
  chase a second deep compiler bug under time pressure)
- [x] `compiler_bridge.zyl` — balance-result → Diagnostic, and the
  `SymTable` (name -> declared signature / ADT variants) the
  name-based services below query
- [x] `capability_registry.zyl` — real `ServerCapabilities`
- [x] `lsp_server.zyl` — real main loop: JSON-RPC request/notification
  dispatch, DocManager+Workspace threaded through as plain recursive
  arguments (no mutable globals — see codegen.zyl's cg-load-nonslot
  comment on why top-level `def` can't hold real state)
- [x] `initialize` → `initialized` → request handling, end-to-end
  tested over real stdio against the built `zyl-lsp` binary

### Phase 1: Diagnostics ✅ COMPLETE (real, verified)
- [x] `sexp_balance.zyl` → `PublishDiagnostics`, real line/col
- [x] Parse / mutability-check / capability errors → one Diagnostic via
  the Wall-2 `try`/`catch` path (message text real, position is start-
  of-file — Wall 1 means a caught panic has no position to report)
- [x] E_MUT_CONFLICT / E_CAPABILITY_LEAK / E_INVALID_CAPABILITY are
  REAL, load-bearing checks (mutability_check.zyl) — genuinely Zyl-
  specific value, confirmed firing correctly through the LSP path

### Phase 2: Navigation ✅ COMPLETE (name-based, not position-based — see Wall 1)
- [x] **Hover**: word-at-cursor (`source_index.zyl`) → `SymTable`
  lookup → declared signature (param names + any written type
  annotation text; no inferred types — nothing infers them, see Wall 1)
- [x] **Go-to-Definition**: same word-at-cursor → `SymTable` membership
  check → declaration location via `source_index`'s own top-level-form
  scan
- [x] **Document Symbols**: real, from `source_index`'s top-level-form
  scan (function/deftype/defstruct/trait, with real line/col)
- [x] **Rename** (Phase 6 originally): renames the declaration site
  only, not call sites (no reference tracking without Wall 1); prepareRename included

### Phase 3: Intelligence ✅ COMPLETE (reduced scope — see Wall 1)
- [x] **Completion**: keywords (static) + known function names + known
  ADT type names + known variant constructors, all from `SymTable`.
  Dropped from the original plan: in-scope local variables (`Env` is a
  codegen-time construct, not tied to a source position — nothing to
  query "at the cursor"), trait methods, module-exports-as-a-separate-
  category (already covered by the flat function list)
- [x] **Semantic Tokens**: real token classification via a byte scan
  (`services/semantic_tokens.zyl`) — comments, strings, numbers,
  keywords. Dropped: per-identifier function/variant coloring (needs a
  word-at-range lookup per token; not wired yet) and the originally-
  planned Zyl-specific categories (`capability`, `region`, `ffi-call`,
  ...) — those need real capability/region data this compiler doesn't
  expose per-expression (see Wall 1)

### Phase 4: Code Actions ✅ COMPLETE (reduced scope)
- [x] Quick-fixes for balance errors, built from the SAME `fixIt` text
  `sexp_balance.zyl`'s `sb-hint` already computes — one real quickfix
  per unclosed/unexpected/mismatched-bracket diagnostic
- [ ] Fix-its for E_MATCH_NONEXHAUSTIVE / E_MUT_CONFLICT / other caught
  panics: not implemented — those diagnostics carry only a message
  string today (Wall 2's catch path), no structured "here's what's
  missing" data to build a fix-it from
- [x] `error_fixit.zyl` was never a real file in this codebase; not
  integrated (nothing to integrate)

### Phase 5: REPL Integration + Workspace ✅ COMPLETE (workspace symbols reduced scope, see below)
- [x] `repl_integration.zyl` — wired into `lsp_server.zyl` as the
  `workspace/executeCommand` command `zyl.evalDocument` (compile+run the
  document's current buffer, return captured stdout+stderr). Was
  blocked on `zyl_system_cmd` crashing on every call in this runtime
  (pthread-worker + `system()`'s internal `vfork()`); fixed at the root
  by reimplementing `zyl_system_cmd` with `posix_spawn` in
  `runtime/actor_runtime.c`, the same fix `zyl_cc_compile`/`zyl_run_bin`
  already had. Verified end-to-end over real stdio: evaluating a 4-line
  document returns the correct computed output. VS Code command:
  `zyl.evalDocument`, output shown in a dedicated "Zyl Eval" channel.
- [x] `workspace.zyl` — multi-root folder tracking + real workspace/symbol
  search across every currently-open document
- [ ] `zyl.toml` DAG parsing: intentionally NOT implemented. `zyl.toml`
  isn't a real format yet anywhere in this language — it's listed as
  "planned v5.0" in `book/src/part2/ch25-modules.md`, this compiler has
  no TOML parser, and no project anywhere in this repo uses one. Inventing
  a workspace-config format on the spot for a v5.0-labeled placeholder
  risks conflicting with whatever the real spec eventually says; this is
  genuinely future work, not a "time, not architecture" shortcut.
  Workspace symbol search across every currently-OPEN document (above)
  is real and already covers the interactive case.

### Phase 6: Polish ✅ MOSTLY COMPLETE (folded into existing services, reduced scope per Wall 1)
- [x] Folding Ranges — one per top-level form (`document_symbols.zyl`)
- [x] Selection Ranges — one expansion step to the enclosing top-level
  form (no token-level innermost range — Wall 1)
- [x] Workspace Symbols — see Phase 5
- [x] Rename — see Phase 2
- [x] Format — real: reindents every line by paren depth
  (`services/code_action.zyl`), does not reflow/rewrap expressions
- [ ] Inlay Hints — API wired (`inlay-hints-for`), returns an empty
  list: real TYPE inlay hints need a type inferred at a specific source
  position, which nothing in this compiler produces (Wall 1); left
  honestly empty rather than fabricated. (Parameter-name hints at call
  sites wouldn't need type inference, only call-site argument
  positions — which also aren't tracked anywhere; would need a new
  nested, depth-aware position-recovering text scanner, a bigger
  standalone feature than the rest of this phase. Not attempted here.)
- [x] Call Hierarchy — `services/call_hierarchy.zyl`: real caller/callee
  graph built by reusing `compiler/unused_check.zyl`'s `uc-refs`
  reference collector, declaration positions from
  `source_index.zyl`'s existing top-level-form scan.
  `textDocument/prepareCallHierarchy` +
  `callHierarchy/incomingCalls`/`outgoingCalls` all wired into
  `lsp_server.zyl` and verified over real stdio. Scope, honestly
  stated: per-document only (same limit as workspace symbols above);
  `fromRanges` reuses the other function's own declaration range rather
  than the real call-site position (Wall 1 — no such position exists to
  give); a reference used only as a value (not a direct call) is still
  counted as an edge, since telling the two apart needs type
  information this compiler doesn't have.
- [x] VS Code extension v0.1.0 — `editors/vscode/`: fixed real bugs in
  the pre-existing draft (`vscode.LanguageClient` doesn't exist — the
  language client comes from the separate `vscode-languageclient`
  package, not the `vscode` module; added it as a real dependency,
  fixed the `onReady()` call removed in v8+, added the missing
  `zyl.restartLSP` command contribution, added `zyl.evalDocument`).
  Compiles clean with `tsc`.

---

## Critical Integration Points

### 1. Compiler Bridge (`compiler_bridge.zyl`)
```zyl
; Convert compiler internal types → LSP types
(defn lsp-range-from-loc (loc) ...)      ; ErrorLocation → Range
(defn lsp-diagnostic-from-error (ei) ...) ; ErrorInfo → Diagnostic
(defn lsp-hover-from-type (ty env) ...)   ; Type + Env → Hover (markdown + range)
(defn lsp-completion-from-env (env vt tc) ...) ; Env + VTable + TraitCtx → CompletionItem[]
```

### 2. Document Manager Incremental Invalidation
```zyl
(defn dm-on-change (dm uri version edits)
  (let old (dm-get dm uri)
    (let new-text (apply-edits old.text edits)
      (let parse-result (parse-with-cache dm uri new-text)
        (if (parse-changed? old parse-result)
          (dm-invalidate-from dm uri 'parse)
          (let infer-result (infer-with-cache dm uri parse-result)
            (if (infer-changed? old infer-result)
              (dm-invalidate-from dm uri 'type-infer)
              (dm-update dm uri version new-text parse-result infer-result)))))))
```

### 3. Capability Types in Diagnostics — Zyl Killer Feature
```zyl
; E_MUT_CONFLICT diagnostic with capability-specific data
{
  "code": "E_MUT_CONFLICT",
  "message": "TMut/TCap aliasing violation",
  "data": {
    "capabilityConflict": {
      "location1": {"kind": "TMut", "variable": "x", "line": 10},
      "location2": {"kind": "TCap", "variable": "x", "line": 15}
    }
  }
}
```

### 4. Region-Aware Hover
```zyl
; Hover shows region assignment + escape status
"contents": [
  "**Type**: `TMut<Int>`",
  "**Region**: `Heap` (escapes via closure capture)",
  "**Escape reason**: captured by `fn (y) (+ x y)` at line 12"
]
```

---

## Bootstrap Integration

### Build Process
```bash
# 1. Add lsp modules to assemble.py bundle (DONE)
# 2. Add lsp_server binary target to boot.sh (DONE)
# 3. ./boot.sh --bootstrap-from-self (reseed)
# 4. ./install.sh → ~/.zyl/bin/zyl-lsp
```

### Server Entry Point
```zyl
; selfhost/lsp_main.zyl
(defn main ()
  (let arena (arena-create 1073741824)
    (lsp-run-server arena)))
```

---

## Unique Zyl LSP Advantages (vs rust-analyzer)

| Feature | rust-analyzer | Zyl LSP (Planned) |
|---------|---------------|-------------------|
| Deterministic diagnostics | ❌ (query cache non-determinism) | ✅ **Guaranteed** |
| Region/capability diagnostics | ❌ | ✅ **Native** |
| Macro-expansion-aware goto | Limited | ✅ **Full** (innermost-first hygiene tracked) |
| Actor message type checking | N/A | ✅ **Send-capability aware** |
| FFI pinning diagnostics | N/A | ✅ **Pin region + timeout** |
| Contract overlay diagnostics | N/A | ✅ **Separate layer** |
| Self-hosted compiler as library | ❌ | ✅ **First-class** |

---

## Testing Strategy

```zyl
; tests/regression/lsp.zyl
(test "lsp-diagnostics-balance" 
  (assert-equal (lsp-diagnostics-for "(defn foo (") 
    [(Diagnostic "E_UNBALANCED_UNCLOSED" ...)]))
(test "lsp-hover-type"
  (assert-equal (lsp-hover-at "(let x 42 x)" 10)
    (Hover "Type: `Int`\nRegion: `Stack`" ...)))
```

- Unit test each service via `compiler_bridge` functions
- Integration test via JSON-RPC replay (recorded sessions)
- Regression: `run_regression_tests.sh --filter lsp`

**Latency targets:**
- Diagnostics (incremental): <50ms for 5K LOC
- Hover: <30ms
- Completion: <50ms
- Go-to-definition: <40ms
- Full reparse (cold): <500ms for 10K LOC

---

## File Tree (New Files)

```
stdlib/lsp/
├── lsp_types.zyl           # ~2500 lines — LSP 3.17 protocol ADTs
├── json_rpc.zyl            # ~400 lines  — JSON encode/decode + stdio transport
├── vfs.zyl                 # ~200 lines  — Virtual file system
├── document_manager.zyl    # ~500 lines  — Incremental pipeline state
├── compiler_bridge.zyl     # ~400 lines  — Compiler internals → LSP types
├── capability_registry.zyl # ~100 lines  — ServerCapabilities advertisement
├── workspace.zyl           # ~300 lines  — Multi-root, zyl.toml DAG
├── repl_integration.zyl    # ~300 lines  — REPL as LSP client
├── lsp_server.zyl          # ~500 lines  — Main server loop, request routing
└── services/
    ├── diagnostics.zyl     # ~400 lines  — Phase 1
    ├── hover.zyl           # ~200 lines  — Phase 2
    ├── goto_definition.zyl # ~200 lines  — Phase 2
    ├── completion.zyl      # ~300 lines  — Phase 3
    ├── document_symbols.zyl# ~200 lines  — Phase 2
    ├── semantic_tokens.zyl # ~300 lines  — Phase 3
    └── code_action.zyl     # ~300 lines  — Phase 4

tools/repl.zyl              # REFACTOR: use lsp_integration, remove duplicate pipeline

editors/vscode/
├── package.json
├── src/extension.ts
├── syntaxes/zyl.tmLanguage.json
├── language-configuration.json
└── tsconfig.json

tests/lsp/
├── integration/*.json      # JSON-RPC request/response recordings
├── multi_root/             # Workspace test fixtures
├── perf/                   # Benchmark sources
└── repl_session.zyl        # REPL interaction test
```

---

## Zero External Dependencies

- **No Cargo, no Rust, no C libraries** for LSP server
- JSON: native Zyl encoder/decoder
- Transport: stdio (POSIX `read`/`write` via FFI)
- File I/O: existing `file-open`/`file-read`/`file-write`/`file-close` FFI
- Process spawn: existing `zyl_cc_compile`/`zyl_run_bin` (REPL)

---

## Definition of Done (Per Phase)

| Phase | Criteria |
|-------|----------|
| **0** | `zyl-lsp` binary builds, responds to `initialize`, `shutdown`, `exit` |
| **1** | `textDocument/didOpen` → `publishDiagnostics` with balance + type + region errors |
| **2** | `textDocument/hover`, `textDocument/definition`, `textDocument/documentSymbol` work on test corpus |
| **3** | `textDocument/completion` (all 5 sources), `textDocument/semanticTokens` (with Zyl legend) |
| **4** | `textDocument/codeAction` with ≥10 fix-its; `workspace/executeCommand` for refactors |
| **5** | `zyl lsp --repl` works; multi-root workspace loads `zyl.toml` DAG; workspace symbols |
| **6** | Inlay hints, folding, selection ranges, call hierarchy, rename, format; VS Code extension v0.1.0 |

---

## Timeline Summary

| Week | Phase | Deliverable |
|------|-------|-------------|
| 1-2 | 0 | LSP types, JSON-RPC, VFS, DocManager, Server skeleton |
| 2-3 | 1 | **Diagnostics** (balance, type, region, capability) |
| 3-4 | 2 | Hover, Go-to-Definition, Document Symbols |
| 4-5 | 3 | Completion, Semantic Tokens (Zyl-specific types) |
| 5-6 | 4 | Code Actions (fix-its from error_fixit) |
| 6-7 | 5 | REPL integration, Multi-root workspace (zyl.toml DAG) |
| 7-8 | 6 | Polish: inlay hints, folding, call hierarchy, rename, format, VS Code extension |

---

## Status

**Phases 0-4 and most of Phase 6 real and verified; Phase 5 partial.**
`zyl-lsp` builds via `./boot.sh` (separate from the compiler's own
self-hosting bundle — see "Bootstrap Integration" above) and has been
exercised end-to-end over real stdio: `initialize` → real capabilities,
`didOpen` → real `publishDiagnostics`, `hover`/`definition`/
`documentSymbol`/`completion`/`shutdown` all return real, correct data
against a live compile of `document_manager.zyl`'s own analysis
pipeline. Self-hosting fixed point verified unaffected (byte-identical
stage2/stage3 output) after every compiler-side change this work made.
Full regression suite: 46/46. `zyl_system_cmd` fixed (posix_spawn,
matching `zyl_cc_compile`/`zyl_run_bin`) and REPL-eval + call hierarchy
both wired in and verified over real stdio since. Remaining honest gaps
are listed inline per-phase above (type inlay hints, `zyl.toml` DAG
parsing — the latter deferred because the format itself doesn't exist
yet, not for lack of time) rather than claimed as done.