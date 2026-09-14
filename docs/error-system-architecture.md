# Zyl Error System Architecture

## Vision

The most incredible developer experience for a systems Lisp. Every error is actionable, every location is precise, every suggestion is correct. No Python scripts, no guesswork, no "figure it out yourself."

## Current State (as of 2026-09-13)

### What Works
- 60+ error codes defined in `docs/errors.md` (from `ZylError` enum in Rust bootstrap)
- Location format: `Error: match: non-exhaustive pattern match at 9:3-9:4`
- Compile-fail tests validate error emission
- Fixed point verified (stage2 == stage3)

### What's Broken / Missing
1. **Paren balance**: `E_UNBALANCED_PARENS: '(' and ')' counts differ` - no location, no context, no help
2. **Location precision**: "at 9:3-9:4" is technically precise but clunky to reason about
3. **No source snippets**: User sees column numbers but not the actual code
4. **No "did you mean?"**: Typos in variant names, field names, function names go undetected
5. **No fix-it hints**: No suggested code changes
6. **No color output**: All stderr is monochrome
7. **Single error**: First error stops compilation
8. **No error recovery**: Can't continue past errors
9. **No LSP structured errors**: IDE integration missing
10. **No native balance validator**: Currently requires Python script

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

**Current**: 60 codes in `docs/errors.md`  
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
├── sexp_balance.zyl        # Native balance validator (NEW)
├── error_codes.zyl         # Error code enum + metadata
├── error_report.zyl        # Rich error formatting
├── error_suggest.zyl       # "Did you mean?" engine
├── error_fixit.zyl         # Fix-it hint generator
├── error_recovery.zyl      # Error recovery & continuation
├── error_lsp.zyl           # LSP structured error format
└── driver.zyl              # Orchestrate error pipeline
```

### Data Structures

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
- [ ] `sexp_balance.zyl` - native structural balance validator
- [ ] `error_codes.zyl` - complete error code enum + metadata
- [ ] `error_report.zyl` - colorized output + source snippets
- [ ] Integrate into driver pipeline

### Phase 2: Intelligence
- [ ] `error_suggest.zyl` - "did you mean?" engine
- [ ] `error_fixit.zyl` - fix-it hints for top 20 errors
- [ ] Error recovery (continue past errors)
- [ ] Multiple error aggregation

### Phase 3: Polish
- [ ] LSP structured error format
- [ ] Complete error catalog (all 60+ codes documented)
- [ ] Color-blind safe mode
- [ ] CLI flags: `--color`, `--error-format`, `--max-errors`

## Integration with Rust Eviction

**BLOCKS**: Phase C (REPL) - REPL requires rich error feedback for interactive use

**Rust Eviction Plan Update** (docs/rust-eviction-plan.md):
- Add Phase A.8: Implement native error system
- REPL (Phase C) depends on Phase A.8 completion
- `sexp_balance.zyl` replaces Python balance scripts

## Testing Requirements

- Compile-fail tests for each error code
- Balance validator tests: balanced, unbalanced-open, unbalanced-close, nested, strings, comments
- Suggestion accuracy > 80% on typo corpus
- Fix-it hints resolve > 60% of common errors
- LSP output matches VS Code diagnostic spec

## Success Criteria

- [ ] Zero Python scripts in build/test path
- [ ] Every error has location + snippet + suggestion + fix-it
- [ ] First-time user can fix any error without docs
- [ ] Color output works in all terminals
- [ ] REPL shows live balance + errors
- [ ] LSP integration works in VS Code/Cursor
- [ ] Fixed point preserved through all changes

---

**Status**: Phase 1 (sexp_balance + error_codes + error_report) blocks REPL development.  
**Owner**: Native Zyl implementation only - no Rust code.  
**Fixed Point**: Every change must pass `./boot.sh --skip-rust` before commit.