# Zyl LSP Server — Architecture Plan

## Current Status (verified against the code, 2026-09-23)

**The server is implemented and ships.** Source is `stdlib/lsp/` (plus
`stdlib/lsp/services/`), the entry point is `selfhost/lsp_main.zyl`, and
`./boot.sh` builds it directly to `build/boot/zyl-lsp` (it is not part of
the `assemble.py` compiler bundle; only `stdlib/lsp/builtins.zyl` is, for
the REPL). `./install.sh` installs it as `~/.zyl/bin/zyl-lsp`. The VS Code
extension is `editors/vscode/` at version 0.3.0. End-to-end coverage is
`tests/lsp/lsp_protocol_test.py` (96/96 checks), run by
`./run_regression_tests.sh --filter lsp`. The Status section at the end of
this document lists every request the server answers.

**Deviations from the plan below:** analysis is name-based over the raw
text (`stdlib/lsp/source_index.zyl`) rather than driven by type inference;
there is no incremental per-phase cache (each change re-runs the front end
and checks on the whole document); diagnostics are produced in
`compiler_bridge.zyl`/`document_manager.zyl`, not a `services/diagnostics.zyl`;
the built-in table `stdlib/lsp/builtins.zyl` and `services/signature_help.zyl`,
`services/inlay_hints.zyl`, `services/call_hierarchy.zyl` are additions.

**Not done:** inference-driven hover and type inlay hints; local-variable
completion; region-aware hover and region diagnostics; structured
capability-conflict data on diagnostics; cross-file navigation for files
that are not open; a workspace-wide package graph (`zyl.pkg` workspaces
exist in the compiler since spec v5.0 §31, but the LSP does not load
them); fix-its beyond bracket balance; `zyl lsp --repl`; latency
measurement against the targets listed below.

**Position data.** "Wall 1" below (no source positions in the compiler) was
true when the LSP was built. Since then tokens carry a byte offset and the
reader records each node's offset in a span table in
`runtime/actor_runtime.c`, which the command-line compiler uses for
`file:line:col` diagnostics. The LSP does not use that table yet: it still
locates a checker diagnostic by searching the document for the first
backticked name in the message, and falls back to (0,0) when there is none.

The sections below are the plan as written, annotated where the built
server differs.

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
- **Entry point**: New `lsp-server` binary built via `./boot.sh` (built as `zyl-lsp`, from `selfhost/lsp_main.zyl`)

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

Planned layout. As built there is no `services/diagnostics.zyl`,
`services/hover.zyl` is a 33-line wrapper over the symbol table and
`builtins.zyl`, `repl_integration.zyl` implements the `zyl.evalDocument`
command (compile and run via the `zyl` CLI), and the extra files
`builtins.zyl`, `source_index.zyl`, `services/signature_help.zyl`,
`services/inlay_hints.zyl` and `services/call_hierarchy.zyl` exist.

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

(`zyl.toml` was never adopted. The package manifest is `zyl.pkg`, spec
v5.0 §31.)

---

## Phase Plan

## Two facts that reshaped every phase below

Discovered during implementation, both confirmed by direct testing. Wall 2
is resolved; Wall 1 has since been partly lifted in the compiler (see the
Current Status section) but the LSP has not been changed to use it:

- **Wall 1 — no source position tracking existed anywhere in the real
  compiler (at the time).** `Token`/`Ast`/`Expr`/`ExprInner` (lexer.zyl/ast.zyl/
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
runtime (pthread worker thread + vfork interaction) — flagged at the
time, and later fixed by reimplementing it with `posix_spawn` (see
Phase 5); `repl_integration.zyl`'s header now says so.

### Phase 0: Foundation ✅ COMPLETE (real, verified)
- [x] `lsp_types.zyl` — LSP 3.17 type definitions, 643 lines at the time
  (681 now) covering the
  full surface this server actually uses (not the originally-estimated
  ~2500; that estimate assumed exhaustive coverage of features with no
  implementation here, e.g. semantic-highlighting-range edge cases)
- [x] `json_rpc.zyl` — real recursive-descent JSON parser/encoder +
  Content-Length stdio transport, byte-tested round-trip
- [x] `vfs.zyl` — open-document store, real incremental text-edit
  application (multi-line insert/delete tested)
- [x] `document_manager.zyl` — per-document analysis: balance check,
  then parse/resolve/macro-expand/mutability-check (now also duplicate,
  arity, exhaustiveness and secret checks; see Status) inside `try`/`catch`
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

### Phase 1: Diagnostics — DONE for balance and checker errors; no type-inference or region errors
- [x] `sexp_balance.zyl` → `PublishDiagnostics`, real line/col
- [x] Parse / mutability-check / capability errors → one Diagnostic via
  the Wall-2 `try`/`catch` path (message text real; originally reported
  at start-of-file, now placed at the first occurrence of the message's
  backticked name, with (0,0) as the fallback)
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
- [x] **Rename** (Phase 6 originally): originally the declaration site
  only; now the declaration plus every whole-word reference in the file.
  prepareRename included

### Phase 3: Intelligence ✅ COMPLETE (reduced scope — see Wall 1)
- [x] **Completion**: keywords (static) + known function names + known
  ADT type names + known variant constructors, all from `SymTable`.
  (Later extended: module paths inside `(use ...)`, and every built-in
  from `builtins.zyl` with signature and documentation, plus struct
  names and fields.) Dropped from the original plan: in-scope local variables (`Env` is a
  codegen-time construct, not tied to a source position — nothing to
  query "at the cursor"), trait methods, module-exports-as-a-separate-
  category (already covered by the flat function list)
- [x] **Semantic Tokens**: real token classification via a byte scan
  (`services/semantic_tokens.zyl`) — comments, strings, numbers,
  keywords. Per-identifier function/type/variant/field colouring has
  since been added (classified against `builtins.zyl` and the document's
  SymTable). Still dropped: the originally-
  planned Zyl-specific categories (`capability`, `region`, `ffi-call`,
  ...) — those need real capability/region data this compiler doesn't
  expose per-expression (see Wall 1)

### Phase 4: Code Actions — PARTIAL (bracket-balance quick-fixes only)
- [x] Quick-fixes for balance errors, built from the SAME `fixIt` text
  `sexp_balance.zyl`'s `sb-hint` already computes — one real quickfix
  per unclosed/unexpected/mismatched-bracket diagnostic
- [ ] Fix-its for E_MATCH_NONEXHAUSTIVE / E_MUT_CONFLICT / other caught
  panics: not implemented. Re-examined when inlay hints (below) added
  the ability to recover call-site positions by text-scanning — but a
  fix-it needs the position of the SPECIFIC construct the panic is
  about (which `match`, which `set!`), and a caught panic carries only
  a message string with no position at all, not even an approximate
  one (`diagnostic-from-panic` reports every caught panic at a fixed
  (0,0)). Unlike inlay hints' call-site positions (independently
  re-discoverable by scanning for known function names), there's
  nothing in a bare message string to correlate back to a specific
  source location when a file has more than one candidate match/set!
  matching that message — genuinely blocked on the same missing
  position data as type inlay hints, not a time shortcut.
- [x] `error_fixit.zyl` was never a real file in this codebase; not
  integrated (nothing to integrate)

### Phase 5: REPL Integration + Workspace — PARTIAL (eval command and open-document workspace symbols done; no package graph)
- [x] `repl_integration.zyl` — wired into `lsp_server.zyl` as the
  `workspace/executeCommand` command `zyl.evalDocument` (compile+run the
  document's current buffer, return captured stdout+stderr). Was
  blocked on `zyl_system_cmd` crashing on every call in this runtime
  (pthread-worker + `system()`'s internal `vfork()`); fixed at the root
  by reimplementing `zyl_system_cmd` with `posix_spawn` in
  `runtime/actor_runtime.c`, the same fix `zyl_cc_compile`/`zyl_run_bin`
  already had. Verified end-to-end over real stdio: evaluating a 4-line
  document returns the correct computed output. VS Code command:
  originally `zyl.evalDocument`; since extension 0.3.0 it is
  `zyl.runCurrentFile` (Run Current File), which sends `zyl.evalDocument`
  to the server.
- [x] `workspace.zyl` — multi-root folder tracking + real workspace/symbol
  search across every currently-open document
- [ ] Workspace package graph: not implemented. The paragraph below was
  written before the package system existed. Since then spec v5.0 §31
  defined the manifest as `zyl.pkg` (not `zyl.toml`), and the compiler
  implements manifests and workspaces (`stdlib/compiler/package.zyl`,
  `stdlib/compiler/workspace.zyl`). The LSP resolves each open document's
  own package through `mr-resolve-program`, so qualified names are right,
  but it does not load a workspace's package graph or index unopened
  files. Original reasoning: `zyl.toml`
  isn't a real format yet anywhere in this language — it's listed as
  "planned v5.0" in `book/src/part2/ch25-modules.md`, this compiler has
  no TOML parser, and no project anywhere in this repo uses one. Inventing
  a workspace-config format on the spot for a v5.0-labeled placeholder
  risks conflicting with whatever the real spec eventually says; this is
  genuinely future work, not a "time, not architecture" shortcut.
  Workspace symbol search across every currently-OPEN document (above)
  is real and already covers the interactive case.

### Phase 6: Polish — DONE with reduced scope (parameter-name inlay hints only; per-document call hierarchy)
- [x] Folding Ranges — one per top-level form (`document_symbols.zyl`)
- [x] Selection Ranges — one expansion step to the enclosing top-level
  form (no token-level innermost range — Wall 1)
- [x] Workspace Symbols — see Phase 5
- [x] Rename — see Phase 2
- [x] Format — real: reindents every line by paren depth
  (`services/code_action.zyl`), does not reflow/rewrap expressions
- [x] Inlay Hints — `services/inlay_hints.zyl`: real PARAMETER NAME
  hints (`(add {a:} 1 {b:} 2)`) via a dedicated recursive-descent text
  scanner (offset/line/col threaded through, same character
  classifiers as `sexp_balance`/`source_index`) that recognizes
  `(head arg...)` where `head` names a known function in the
  document's SymTable, and hints each argument's start position with
  the callee's declared parameter name — recursing into each argument
  so a nested call gets its OWN hints too. Verified over real stdio
  against a 2-level-nested call: all 4 hints at the exact right byte
  columns. TYPE inlay hints (the original plan's `let x = ...: T`)
  remain out of reach: need a type inferred at a specific source
  position, which nothing in this compiler produces (Wall 1) — left
  honestly absent rather than fabricated.
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
- [x] VS Code extension v0.1.0 (now 0.3.0, see Status) — `editors/vscode/`: fixed real bugs in
  the pre-existing draft (`vscode.LanguageClient` doesn't exist — the
  language client comes from the separate `vscode-languageclient`
  package, not the `vscode` module; added it as a real dependency,
  fixed the `onReady()` call removed in v8+, added the missing
  `zyl.restartLSP` command contribution, added `zyl.evalDocument`).
  Compiles clean with `tsc`. In 0.3.0 the user-facing command was renamed
  `zyl.runCurrentFile` (it still sends `zyl.evalDocument` to the server),
  because the client library already registers the server's command name.

---

## Critical Integration Points

Design sketches from the plan. None of the four was built in this form:
`compiler_bridge.zyl` converts balance results and caught panics to
Diagnostics and builds the SymTable; there are no type- or env-based hover
or completion functions, no per-phase invalidation (`dm-on-change` applies
the edits and re-analyses the whole document), no `capabilityConflict`
data on diagnostics, and no region information in hover.

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
As built, the LSP modules are not in the `assemble.py` bundle (only
`stdlib/lsp/builtins.zyl` is, because the REPL uses it). `boot.sh` compiles
`selfhost/lsp_main.zyl` with the freshly built `stage2.bin` into
`build/boot/zyl-lsp`, so a change under `stdlib/lsp/` does not alter the
compiler's own output or require reseeding. `./install.sh` builds
`~/.zyl/bin/zyl-lsp-bin` and a `zyl-lsp` wrapper script that execs it.

### Server Entry Point
```zyl
; selfhost/lsp_main.zyl
(defn main ()
  (let arena (arena-create 1073741824)
    (lsp-run-server arena)))
```

---

## Unique Zyl LSP Advantages (vs rust-analyzer)

| Feature | rust-analyzer | Zyl LSP (Planned) | Status |
|---------|---------------|-------------------|--------|
| Deterministic diagnostics | ❌ (query cache non-determinism) | ✅ **Guaranteed** | Done (no caches, same input gives same output) |
| Region/capability diagnostics | ❌ | ✅ **Native** | Capability/mutability errors yes (via `mutability_check`); region diagnostics no |
| Macro-expansion-aware goto | Limited | ✅ **Full** (innermost-first hygiene tracked) | Not done: go-to-definition is a text scan of top-level forms |
| Actor message type checking | N/A | ✅ **Send-capability aware** | Not done |
| FFI pinning diagnostics | N/A | ✅ **Pin region + timeout** | Only `E_FFI_PIN_REQUIRED` for Secret arguments, via `secret_check` |
| Contract overlay diagnostics | N/A | ✅ **Separate layer** | Not done |
| Self-hosted compiler as library | ❌ | ✅ **First-class** | Done: the server links the compiler's own front end and checks |

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

As built: there is no `tests/regression/lsp.zyl` and no recorded-session
replay. `tests/lsp/lsp_protocol_test.py` starts `build/boot/zyl-lsp`,
drives it over JSON-RPC on stdio and asserts on the responses (96 checks);
`run_regression_tests.sh` runs it when the filter matches `lsp` or is
empty. The latency targets below have never been measured.

**Latency targets:**
- Diagnostics (incremental): <50ms for 5K LOC
- Hover: <30ms
- Completion: <50ms
- Go-to-definition: <40ms
- Full reparse (cold): <500ms for 10K LOC

---

## File Tree (New Files)

Planned tree with line estimates. Actual line counts (2026-09-23):
`lsp_types` 681, `json_rpc` 509, `vfs` 155, `document_manager` 172,
`compiler_bridge` 463, `capability_registry` 69, `workspace` 49,
`repl_integration` 69, `lsp_server` 1029, `builtins` 408, `source_index`
402; services: `hover` 33, `goto_definition` 198, `completion` 168,
`document_symbols` 120, `semantic_tokens` 244, `code_action` 142,
`signature_help` 67, `inlay_hints` 222, `call_hierarchy` 207. No
`services/diagnostics.zyl`. `tools/repl.zyl` was not refactored onto the
LSP; the REPL is now `stdlib/repl/` with its own ICNF interpreter, and
shares only `lsp/builtins.zyl`. `tests/lsp/` holds only
`lsp_protocol_test.py`. The VS Code extension also has `snippets/`,
`syntaxes/zyl-pkg.tmLanguage.json`, `eslint.config.mjs` and a `LICENSE`.

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

| Phase | Criteria | Met? |
|-------|----------|------|
| **0** | `zyl-lsp` binary builds, responds to `initialize`, `shutdown`, `exit` | Yes |
| **1** | `textDocument/didOpen` → `publishDiagnostics` with balance + type + region errors | Partly: balance and checker errors; no type-inference or region errors |
| **2** | `textDocument/hover`, `textDocument/definition`, `textDocument/documentSymbol` work on test corpus | Yes (name-based) |
| **3** | `textDocument/completion` (all 5 sources), `textDocument/semanticTokens` (with Zyl legend) | Partly: no local variables or trait methods; standard legend, no Zyl-specific token types |
| **4** | `textDocument/codeAction` with ≥10 fix-its; `workspace/executeCommand` for refactors | No: balance quick-fixes only; the one command is `zyl.evalDocument` |
| **5** | `zyl lsp --repl` works; multi-root workspace loads `zyl.toml` DAG; workspace symbols | Partly: workspace symbols across open documents; no `zyl lsp` subcommand, no package graph |
| **6** | Inlay hints, folding, selection ranges, call hierarchy, rename, format; VS Code extension v0.1.0 | Yes (parameter-name hints only; extension now 0.3.0) |

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

**Complete for the language as it stands today, within the limits listed
below.** `zyl-lsp` builds via `./boot.sh` and is exercised end-to-end by
`tests/lsp/lsp_protocol_test.py`, which drives the real binary over real
JSON-RPC on stdio and asserts on the responses (96/96 checks;
`./run_regression_tests.sh --filter lsp`, in both quick and full mode). The
full suite is 121/121.

### What the server answers today

`initialize` (with every provider below advertised), `initialized`,
`shutdown`, `exit`; `didOpen`, `didChange`, `didSave` (with text),
`didClose`; `publishDiagnostics`; and the requests:

| Request | Notes |
|---|---|
| `hover` | MarkupContent, with a range; resolves the document's own definitions first, then the built-in table |
| `definition` | Functions, types, structs, traits, macros, constants; a variant resolves to its `deftype`, a field to its `defstruct`. Sees through `pub` and `feature-gate` wrappers |
| `typeDefinition` | Variant to ADT, field to struct |
| `implementation` | Every `impl` naming the trait under the cursor |
| `references` | Whole-word occurrences, honouring `context.includeDeclaration` |
| `documentHighlight` | The same occurrence set, as ranges |
| `rename` / `prepareRename` | Declaration plus every reference in the file |
| `completion` | Context-aware: module paths inside `(use ...)`, otherwise built-ins (with signature and documentation) plus the document's functions, ADTs, variants, structs and fields |
| `signatureHelp` | Real parameter names from `defn`; built-in signatures from the table; correct `activeParameter` |
| `documentSymbol` | Full-form `range`, name-only `selectionRange` |
| `workspace/symbol` | Across every open document |
| `semanticTokens/full` and `/range` | Ten standard token types, three modifiers |
| `foldingRange` | Per multi-line top-level form |
| `selectionRange` | Identifier, then enclosing form |
| `codeAction` | Quick-fixes from balance diagnostics' fix-it hints |
| `formatting` / `rangeFormatting` | Re-indent by paren depth |
| `prepareCallHierarchy`, `incomingCalls`, `outgoingCalls` | Per-document |
| `inlayHint` | Parameter names at call sites |
| `workspace/executeCommand` | `zyl.evalDocument`: writes the buffer to `/tmp/zyl_lsp_eval.zyl`, compiles it with the `zyl` on `PATH`, runs it, returns captured output |

### Diagnostics

`document_manager.zyl` parses the document, resolves modules with the
document's path (so it finds the package the file belongs to, spec v5.0
§31.3), expands macros, then runs `dc-check-program`, `ac-check-program`,
`mc-check-program`, `ec-check-program` and `sc-check-program` — the order
`compile-run-checks` in `stdlib/compiler/pipeline.zyl` uses — inside
`try`/`catch`, so a checker's `zyl_panic` becomes a Diagnostic instead of
killing the server. Each diagnostic carries its `E_*` code in the LSP
`code` field and a range located by finding the message's backticked name
in the document text.

Two of the pipeline's checks are not run: `cc-check-program` (package
capability enforcement, §31.9, which needs the resolver's grant/deny sets)
and `uc-check-program` (see below). Type inference does not run at all.

The symbol table is built BEFORE the checks run and kept whatever they
say, so a document that fails exhaustiveness still offers hover,
completion and go-to-definition for the names it declares.

### Coverage of the language

`stdlib/lsp/builtins.zyl` is the single table behind hover, completion,
signature help and token colouring, and the REPL's Tab completion
uses it too. It holds every head symbol `dispatch-special`
recognises (including `pub` and `feature-gate`), every operator `icnf.zyl`
lowers to an instruction — including the bitwise family and the
byte/atomic primitives — and every type, region and capability name, each
with a signature and a one-line description. Keep it in step when
`expr_inner.zyl` gains a form; a form missing from it appears in the
editor as an ordinary unresolved identifier.

### Known gaps

- **Type inlay hints** and **inference-driven hover**. Hover shows the
  declared annotation, not an inferred type. The compiler now records
  node positions (see Current Status), but type inference's name lookups
  are unreliable (several compare strings with `=`; see
  `compiler_bridge.zyl`'s header), so position data alone would not
  produce trustworthy types.
- **Local-variable completion**. There is no scope to read at a cursor.
- **Diagnostic positions** come from a name search in the text, not from
  the compiler's span table.
- **One diagnostic at a time**, because each checker stops at its first
  problem — the same behaviour as a command-line build.
- **`unused_check` is not run**, because it reports by printing to
  stdout, which is the server's JSON-RPC channel. Surfacing those
  warnings needs the check to return them rather than print them.
- **Navigation is per-document.** Workspace symbol search covers open
  documents only; the server does not load a `zyl.pkg` workspace's
  package graph.

### Editor integration

`editors/vscode/` v0.3.0 (vscode-languageclient 10.1, VS Code engine
^1.91.0): two languages, `zyl` and `zyl-pkg` (manifests get their own
grammar so the server never compiles one as a program); a TextMate
grammar covering every special form, bitwise and byte operation, atomic,
region and capability name, plus `pub` and `feature-gate`; 17 snippets;
a `zyl` task type for single-file builds and for `build`/`test`/`fetch`
in every `zyl.pkg` directory; commands `zyl.restartLSP`, `zyl.stopLSP`,
`zyl.showServerLog` and **Run Current File** (`zyl.runCurrentFile`,
`Ctrl+Shift+Enter`, which sends `zyl.evalDocument`); settings
`zyl.lsp.enable`, `zyl.lsp.path`, `zyl.lsp.arguments`,
`zyl.lsp.trace.server`, `zyl.inlayHints.parameterNames` (applied in
client middleware) and `zyl.compiler.path` (falls back to
`build/boot/zyl-self`). `./install.sh --with-vscode` builds and installs
it. Chapter 35 of the book (`book/src/part5/ch35-tooling.md`) documents
per-editor setup for Neovim, Emacs and Helix as well.
