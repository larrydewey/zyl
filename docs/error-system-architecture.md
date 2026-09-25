# Zyl Error System Architecture

## Vision

The most incredible developer experience for a systems Lisp. Every error is actionable, every location is precise, every suggestion is correct. No Python scripts, no guesswork, no "figure it out yourself."

## Current State (as of 2026-09-23)

### What Works
- **Catalog**: `stdlib/compiler/error_codes.zyl` holds 111 distinct codes
  (phase, severity, default message), covering spec §28 and the §31
  package codes; `docs/errors.md` lists every one, which module raises
  it, and which are catalog-only. The catalog is data: checkers write the
  code into their own message, and nothing looks it up at raise time.
- **Located diagnostics**: `err-at` in `stdlib/compiler/error_report.zyl`
  renders `error[CODE]: message`, a `--> path:line:col` line, the source
  line, a caret under the node's column and a `= help:` fix-it line.
  Spans come from the runtime's source/span table (`zyl_source_register`,
  `zyl_span_line`, `zyl_span_col`, `zyl_span_line_text`). A node with no
  recorded span degrades to the header plus help line. Canonical symbol
  keys are shortened to the name the user wrote (`err-name`). Used today
  by the balance check, `duplicate_check.zyl`, `arity_check.zyl`,
  `exhaustiveness_check.zyl`, `expr_inner.zyl` (`E_MALFORMED_PARAMETER`)
  and `codegen.zyl` (`E_UNBOUND_VARIABLE`).
- **Native balance validator**: `sexp_balance.zyl`, a stack-based,
  string- and comment-aware scan over bracket type, run on the source
  text before parsing (`compile-check-balance` in `pipeline.zyl`,
  `check-balanced` in `parser.zyl`), with its own fix-it text
  (`sb-hint`).
- **Warnings**: `unused_check.zyl` reports `W_UNUSED_FUNCTION`,
  `W_UNUSED_PARAMETER`, `W_UNUSED_VARIABLE` and `W_SHADOWED_BINDING` on
  stderr without failing the compile; `secret_check.zyl` reports
  `E_ZEROIZE_MISSING` at severity 2.
- **LSP diagnostics**: `stdlib/lsp/compiler_bridge.zyl` turns a balance
  result, a compiler panic message or the type checker's reports into an
  LSP `Diagnostic` with the code, a range (the message's `-->` location,
  else the first backticked name in it) and source `zyl`. The server
  runs the same checks as the compiler through type checking
  (`document_manager.zyl`), so every type error in the document is
  published at once, each where it is; `lsp_server.zyl` publishes them with
  `textDocument/publishDiagnostics`, and `services/code_action.zyl`
  offers a quick fix when a diagnostic carries `fixIt` data (today only
  balance diagnostics do, with the `sb-hint` text).
- **REPL**: diagnostics print as the compiler formats them, and an error
  leaves the session standing (`docs/repl.md`).
- Compile-fail tests (`tests/compile-fail/`, `tests/packages-fail/`)
  check that rejected programs are rejected; fixed point verified.

### What's Broken / Missing
1. ~~**Paren balance**: no location, no context, no help~~ FIXED
   (2026-09-19): native stack-based validator reports exact line/column
   and a fix-it hint (see Phase 1 below).
2. **Coverage of located diagnostics**: only the checks listed above use
   `err-at`. Every other check raises a plain `PANIC: CODE: message`
   through `zyl_panic`, with no location.
3. ~~**No source snippets**~~ PARTLY FIXED: located diagnostics show the
   offending line with a caret. There is no multi-line context and no
   underline spanning a whole expression.
4. **No "did you mean?"**: typos in variant names, field names and
   function names get no suggestion.
5. **Fix-it hints** are fixed per check (`= help:` text), not computed
   suggested edits.
6. **No color output**: compiler diagnostics are monochrome (the REPL
   colors its own prompt and results, not the diagnostics).
7. **Single error**: the first error stops compilation, exit status 1.
8. **No error recovery**: the compiler cannot continue past an error.
9. **Many catalog codes are never raised**: type inference rejects only
   an argument that clashes with a parameter annotation or field type
   (`E_TYPE_MISMATCH`; `E_RETURN_TYPE_MISMATCH` is catalog-only), and
   several runtime codes
   (`E_ASSERT_FAIL`, `E_USER_ERROR`, `E_DIVISION_BY_ZERO` in compiled
   code) are not what a failing program prints. `docs/errors.md` has the
   list.
10. **Name drift**: `exhaustiveness_check.zyl` raises
    `E_NON_EXHAUSTIVE_MATCH` for a missing variant, while spec §28 and
    the catalog name that `E_MATCH_NONEXHAUSTIVE`. The catalog also has
    duplicate entries (`E_CANNOT_INFER` twice, `E_OUT_OF_MEMORY` twice
    with different messages, `E_ALIGNMENT_FAILED` and
    `E_ALIGN_CHECK_FAILED` with the same message).
11. ~~**No native balance validator**: Currently requires Python script~~
    FIXED (2026-09-19): `sexp_balance.zyl`, wired into the real compile
    path.

The rest of this document is the design target. Sections 2 to 6 below
describe output and data structures that are **not** implemented unless
the phase plan marks them done; the actual types are listed under
"Data Structures".

## Target State: Incredible Error Experience

### 1. Native S-Expression Balance Validator (`stdlib/compiler/sexp_balance.zyl`)

**Purpose**: Replace Python paren counting with Zyl-native structural validation.

**Features**:
- Walk AST/S-expressions structurally (not string counting)
- Report exact location of first unbalanced delimiter
- Show context: 3 lines before/after with `>>` pointer
- Suggest likely fix: "missing `)` at line X, column Y" or "extra `(` at line X"
- Handle all delimiter types: `()`, `[]`, `{}`, `""`
- String-aware (ignore parens inside strings)
- Comment-aware (ignore parens after `;`)
- Fast: single pass, O(n) time, O(d) space (d = max depth)

**Integration Points**:
- Parser: called during tokenization phase
- REPL: live balance checking as user types
- CLI: `--check-balance` flag for CI/pre-commit
- LSP: real-time balance diagnostics

### 2. Rich Error Reporting

#### 2.1 Colorized Output
```
error[E0308]: type mismatch at tests/example.zyl:12:15
  |
12 |     (let x (cons 1 "hello"))
  |               ^^^^^^^^^^^^ expected Int, found String
  = note: expected type `Int`, found type `String`
  = help: did you mean `(cons 1 2)`?
```

#### 2.2 Source Snippets with Pointers
```
  --> tests/match.zyl:9:3
   |
 7 |   (match shape
 8 |     (Circle r ...)
 9 |     (Square s ...)   ^^^^^ missing arm: Triangle
   |
```

#### 2.3 "Did You Mean?" Suggestions
| Error Type | Suggestion Example |
|------------|-------------------|
| Unknown variant | `Triangle` → did you mean `Tri`? |
| Unknown field | `.x` → did you mean `.y`? |
| Unknown function | `pritn` → did you mean `print`? |
| Arity mismatch | `foo 1` → did you mean `foo 1 2`? |
| Type mismatch | `String` → did you mean `Int`? |

#### 2.4 Fix-It Hints
```zyl
; E_TYPE_MISMATCH
  = help: try `(cast x Int)` or change `x` to type Int

; E_MATCH_NONEXHAUSTIVE
  = fix: add `(Triangle t ...)` arm or add `(_ ...)` catch-all

; E_ARITY_MISMATCH
  = fix: add missing argument: `(foo 1 2)`
```

### 3. Error Code Catalog (Complete)

**Current**: 111 codes in `stdlib/compiler/error_codes.zyl`, listed with
their raising module in `docs/errors.md`, plus the warnings and
REPL-interpreter codes the catalog does not contain  
**Target**: All codes with:
- Full description
- Common causes
- Example code that triggers it
- Step-by-step fix
- Related errors
- Link to spec section

### 4. Error Recovery

- Continue parsing after first error
- Collect all errors in module
- Group by file, then by line
- Show error count: `error: 3 errors, 2 warnings`
- Exit with non-zero if any errors

### 5. Multiple Error Display
```
error[E0308]: type mismatch at foo.zyl:5:10
  = note: expected Int, found String

error[E0425]: unbound variable at foo.zyl:12:5
  = note: variable `x` not found in scope
  = help: did you mean `y`?

error[E0382]: use of moved value at foo.zyl:20:8
  = note: `x` moved here at line 15
  = help: use `x` before moving, or `clone` if Copy
```

### 6. LSP Structured Errors
```json
{
  "code": "E0308",
  "message": "type mismatch",
  "severity": "error",
  "range": { "start": { "line": 11, "character": 9 }, "end": { "line": 11, "character": 25 } },
  "source": "type_check",
  "relatedInformation": [
    { "location": { "uri": "foo.zyl", "range": ... }, "message": "expected Int" }
  ],
  "data": {
    "suggestions": ["(cast x Int)", "change x to Int"],
    "fixIt": { "replace": { "start": ..., "end": ... }, "text": "(cast x Int)" }
  }
}
```

## Implementation Architecture

### Core Modules (All Native Zyl)

```
stdlib/compiler/
├── sexp_balance.zyl        # Native balance validator            (exists)
├── error_codes.zyl         # Error code catalog + metadata       (exists)
├── error_report.zyl        # Located formatting: err-at, snippet (exists)
├── error_suggest.zyl       # "Did you mean?" engine              (planned)
├── error_fixit.zyl         # Fix-it hint generator               (planned)
├── error_recovery.zyl      # Error recovery & continuation       (planned)
└── error_lsp.zyl           # LSP structured error format         (planned; today
                            #   stdlib/lsp/compiler_bridge.zyl does this job)
selfhost/driver.zyl         # CLI entry point; the pipeline itself is
                            #   stdlib/compiler/pipeline.zyl
```

### Data Structures

What `error_report.zyl` actually defines today (Int fields first, a
layout rule inherited from the Rust bootstrap):

```zyl
(deftype ErrorLocation
  (EL line Int col Int file-path String))

(deftype ErrorSnippet
  (ES pointer-col Int error-line String))
```

`err-at` itself takes `(code msg fid off help)` and returns the rendered
String; there is no `ErrorInfo` record. The design target was:

```zyl
(deftype ErrorLocation
  (EL file-path line column))

(deftype ErrorSnippet
  (ES lines-before error-line lines-after pointer-column))

(deftype ErrorSuggestion
  (ESug text confidence replacement?))

(deftype ErrorFixIt
  (EFix description replacement?))

(deftype ErrorInfo
  (EI code                ; Symbol (E0308, E0382, etc.)
   EI message             ; String
   EI severity            ; Error|Warning|Note
   EI location            ; ErrorLocation
   EI snippet             ; ErrorSnippet (Option)
   EI suggestions         ; List ErrorSuggestion
   EI fix-its             ; List ErrorFixIt
   EI related             ; List ErrorInfo (cause chains)
   EI help-id             ; String (doc link)
  ))

(deftype Diagnostic
  (Diag file-path
        errors     ; List ErrorInfo
        warnings   ; List ErrorInfo
        notes      ; List ErrorInfo
  ))
```

### Pipeline Integration

Target (only step 1 exists; it scans the raw source text, before the
lexer, rather than the token stream):

1. **Lexer**: `sexp_balance.zyl` validates token stream balance
2. **Parser**: Collects structural errors, continues on error
3. **Type Inference**: Emits `ErrorInfo` with suggestions
4. **Monomorphization**: Emits `ErrorInfo` with fix-its
5. **ICNF/Codegen**: Emits `ErrorInfo` with location
6. **Driver**: Aggregates, sorts, formats, outputs

### Color Scheme (ANSI)
- Error: `\x1b[31m` (red)
- Warning: `\x1b[33m` (yellow)  
- Note/Help: `\x1b[36m` (cyan)
- Source line: `\x1b[37m` (white)
- Pointer `^`: `\x1b[32m` (green)
- Reset: `\x1b[0m`
- **Color-blind safe**: Configurable via `ZYL_COLOR=never|auto|always`

## Phase Plan

### Phase 1: Foundation (Blocks REPL)
- [x] `sexp_balance.zyl` - native structural balance validator, stack-based
      over bracket TYPE (not just a net count), string/comment-aware
      *(2026-09-19)*
- [x] `error_codes.zyl` - error code catalog + metadata (fixed a
      pre-existing 14-paren-deficit in the catalog itself that had been
      silently swallowing every defn after it into the wrong nesting
      level — never caught because nothing called into this module yet)
      *(2026-09-19)*
- [ ] `error_report.zyl` - colorized output + source snippets. Partly
      done: `err-at` renders the header, `path:line:col`, the source line,
      a caret and a help line for the checks listed under "What Works";
      no colorization, no multi-line context.
- [x] Integrate into the pipeline - `compile-check-balance`
      (`stdlib/compiler/pipeline.zyl`, called from `compile-to-exprs`)
      and `zyl-parse-file` (`stdlib/compiler/parser.zyl`) both call
      `sb-check-string` and report through `report-unbalanced`, which
      reads its fix-it hint from `sb-hint` (sexp_balance.zyl); the LSP's
      `diagnostic-from-balance` reads the same hint *(2026-09-19;
      pipeline split out of the driver since)*

### Phase 2: Intelligence
- [ ] `error_suggest.zyl` - "did you mean?" engine
- [ ] `error_fixit.zyl` - fix-it hints for top 20 errors
- [ ] Error recovery (continue past errors)
- [ ] Multiple error aggregation

### Phase 3: Polish
- [ ] LSP structured error format (partly: the LSP publishes code, range
      and message per diagnostic, see "What Works"; no related
      information or computed suggestions)
- [ ] Complete error catalog (every code has an entry and a raising
      module in `docs/errors.md`; per-code causes, examples and fixes are
      not written)
- [ ] Color-blind safe mode
- [ ] CLI flags: `--color`, `--error-format`, `--max-errors`

## Integration with Rust Eviction

Historical: this plan was written as Phase A.8 of
`docs/rust-eviction-plan.md`, as a prerequisite for the REPL (Phase C).
The Rust bootstrap has since been evicted (`archive/rust-bootstrap-2026/`
is frozen), `sexp_balance.zyl` replaced the Python balance scripts, and
the REPL shipped (`docs/repl.md`) with the located diagnostics above
rather than waiting for the rest of this plan.

## Testing Requirements

- Compile-fail tests for each error code
- Balance validator tests: balanced, unbalanced-open, unbalanced-close, nested, strings, comments
- Suggestion accuracy > 80% on typo corpus
- Fix-it hints resolve > 60% of common errors
- LSP output matches VS Code diagnostic spec

## Success Criteria

- [ ] Zero Python scripts in build/test path (the build still uses
      `selfhost/assemble.py` for reseeding; the LSP and timing tests are
      Python)
- [ ] Every error has location + snippet + suggestion + fix-it
- [ ] First-time user can fix any error without docs
- [ ] Color output works in all terminals
- [ ] REPL shows live balance + errors (the REPL continues an unbalanced
      entry on a new line and reports errors after submission; no live
      diagnostics while typing)
- [ ] LSP integration works in VS Code/Cursor (diagnostics are published
      to the VS Code extension today; the structured format above is not)
- [ ] Fixed point preserved through all changes

---

**Status**: Phase 1 done except colorization; Phases 2 and 3 not started.  
**Owner**: Native Zyl implementation only - no Rust code.  
**Fixed Point**: Every change must pass `./boot.sh` (which uses no Rust) before commit.