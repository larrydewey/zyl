# Zyl Progress Tracker

## Phase 1: Parsing (Lexer + Parser → AST) ✅ COMPLETE

### Completed
- [x] **Project structure**: `src/` with modules (`main.rs`, `error.rs`, `lexer.rs`, `ast.rs`, `parser.rs`)
- [x] **Full error model** (spec §28): All E_* variants defined in `error.rs` with Location/Span tracking
- [x] **AST nodes** (spec §2): Complete Expr enum covering all language constructs from spec v4.1
  - Definitions, bindings, control flow, closures, FFI, concurrency
  - Type system (traits, impls, deftype), structs/aliases/derive
  - Testing framework, module system, I/O operations
- [x] **Lexer** (spec §1): Tokenizer producing all token types from spec
  - Identifiers including operators (+, -, *, /, ==, !=, <, >, <=, >=)
  - Literals (int, float, bool, string), keywords (`:` prefix), symbols (`~` prefix)  
  - Delimiters: `()`, `{}`, `[]`, `:`
  - Line comments (`;`) stripped during lexing
- [x] **Parser** (spec §2): Recursive descent S-expression parser with ~40 special form handlers
  - Modular design — REPL can reuse the same parsing code
  - All dispatch via sequential if-else to avoid type mismatch issues

### Phase 1.5: Reserved Keyword Enforcement (NEW)
- [x] **E_RESERVED_KEYWORD error code** added to `error.rs` (§28 spec update)
- [x] **RESERVED_KEYWORDS constant** in `parser.rs` — covers all special forms from §1.3
- [x] **Parser checks** added to: def, defn/defun, let/let-mut, fn/lambda (via dispatch), 
  defmacro, trait, impl, deftype, alias, derive, defstruct/defstruct+, with-resource binding,
  for loop variable, try/catch name, set! target, export symbol
- [x] **Spec updates**: §1.3.1 added to both `zyl_specification.txt` and 
  `specifications/ZylFormalSpecificationv4.1.txt`; E_RESERVED_KEYWORD added to §28

### Files Created/Modified (Phase 1.5)
| File | Lines Changed | Description |
|------|---------------|-------------|
| `src/error.rs` | +3 | Added E_RESERVED_KEYWORD variant |
| `src/parser.rs` | ~60 | RESERVED_KEYWORDS constant, check_reserved_keyword() helper, checks in all special form parsers |
| `zyl_specification.txt` | +12 | §1.3.1 reserved keyword rule, §28 error code update |
| `specifications/ZylFormalSpecificationv4.1.txt` | +12 | Same spec updates as root file |

### Test Results (Phase 1.5)
```bash
# Reserved keyword 'test' in defn → clear error
$ echo '(defn test (a b) (+ a b))' > t.zyl && ./target/debug/zyl t.zyl
Error: parser: reserved keyword 'test' cannot be used as identifier at 1:7-1:8 ✓

# Reserved keyword 'if' in let → clear error  
$ echo '(let if 5 if)' | ./target/debug/zyl /dev/stdin
Error: parser: reserved keyword 'if' cannot be used as identifier at 1:6-1:7 ✓

# Valid function definition still works
$ echo '(defn my_test (a b) (+ a b))' > t.zyl && ./target/debug/zyl t.zyl
Phase 1 complete: Parsing succeeded. ✓
```

### Known Limitations / TODOs for Phase 1
- [x] Double-paren let bindings `((x val))` not supported (single-paren `(x val)` works) → **Deferred** — keep simple, revisit later with ergonomics iteration
- [ ] Test suite/test decl keyword arguments limited by pre-parsed arg model  
- [ ] run-tests similarly limited — keywords need raw token access → **Deferred** until proper parsing infrastructure in Phase 3+

### Files Created/Modified
| File | Lines | Description |
|------|-------|-------------|
| `src/main.rs` | ~70 | Entry point, CLI wiring, Phase 1 pipeline |
| `src/error.rs` | ~136 | Full error model with all E_* codes from spec §28 |
| `src/ast.rs` | ~439 | Complete AST definitions + S-expression pretty printing |
| `src/lexer.rs` | ~353 | Tokenizer with comment stripping, location tracking |
| `src/parser.rs` | ~601 | Recursive descent parser with special form handlers |
| `src/repl.rs` | ~3 | Stub (deferred per user decision) |

### Test Results
```bash
# Simple function definition + arithmetic
$ echo '(defn add (x y) (+ x y))' > test.zyl && ./target/debug/zyl test.zyl
Tokens: 14 produced. Expressions parsed: 1 ✓

# Let binding with expression value  
$ echo '(let result (+ 3 4) result)' | ./target/debug/zyl /dev/stdin
AST output shows correct Let node with name="result", val=Apply("+",[3,4]), body=Ident("result") ✓

# Full program: factorial + let + if + begin + deftype
$ timeout 5 ./target/debug/zyl test_final.zyl
Tokens: 62 produced. Expressions parsed: 5 ✓
AST output includes Defn(factorial), Let(result, ...), If(...), Begin([...]), Deftype(Option)

# Match arm parsing (via deftype variants)
$ echo '(deftype Option (Some Int) None)' | ./target/debug/zyl /dev/stdin
Parsed correctly with Some(Int) variant and unit None variant ✓
```

## Phase 2: Macro Expansion ✅ COMPLETE

### Design Decision: No-Dispatch Parsing + Uniform Handling
Phase 1 parsing uses `no_dispatch = true` — all S-expressions become raw Call/Apply nodes. This avoids the fundamental problem where special form names used as pattern variables (e.g., `(defmacro unless (cond body) ...)` with nested `cond`) get dispatched during recursive descent before defmacro can see them.

Phase 2 handles both raw Call/Apply AND specialized ExprInner variants uniformly via:
- **`normalize_for_match()`** — converts raw `"if"`/`"let"` etc. to their specialized ExprInner forms for pattern matching and substitution
- **Post-order expansion** in `expand_expr()` — children expanded before macro call check, with recursive re-expansion after substitution (handles nested macros)

### Completed
- [x] **Two-pass parsing**: no-dispatch → raw Call/Apply AST → PostProcessor converts back to specialized ExprInner variants for clean output
- [x] **`src/macro_expander.rs`** (498 lines): Complete macro system
  - `MacroDef` struct with name, patterns, template
  - GensymRegistry — counter-based unique symbol generation (`{prefix}#{counter}`)
  - Pattern matching engine: structural match on Call/Apply/Begin/If/etc. via normalize_for_match
  - Template substitution with hygiene for Let/Lambda/Fn bindings (gensyms prevent capture)
  - Innermost-first post-order expansion traversal
  - Recursive re-expansion after substitution (nested macros work correctly)
  - Variadic patterns (`&` prefix support)
  - Built-in operator exclusion list for macro candidate detection
- [x] **Parser**: `parse_exprs_no_dispatch()` + `parse_list_no_dispatch()` methods, no-dispatch flag on Parser struct
- [x] **AST PostProcessor** in `ast.rs`: Converts raw special forms (if/let/while/for/cond/try/match) to specialized ExprInner variants after Phase 2 for clean downstream AST output
- [x] **Pipeline integration**: register() extracts defmacros from both raw Call and MacroDef nodes; expand() runs innermost-first

### Files Created/Modified
| File | Lines Changed | Description |
|------|---------------|-------------|
| `src/macro_expander.rs` | +498 (new) | Complete macro expansion engine with gensym hygiene, pattern matching, substitution |
| `src/parser.rs` | ~60 added | no_dispatch flag, parse_exprs_no_dispatch(), parse_list_no_dispatch() methods |
| `src/ast.rs` | ~130 added | PostProcessor struct for converting raw Call/Apply special forms to specialized ExprInner variants |
| `src/main.rs` | +5 modified | Parser uses no_dispatch=true; PostProcessor runs after parsing, before macro expansion |

### Test Results
```bash
# Basic unless macro with 'cond' as pattern variable name (special form names work!)
$ echo '(defmacro unless (cond body) (if (not cond) body))(unless false "hello")' > t.zyl && ./target/debug/zyl t.zyl
Macro expansion complete: 1 expressions.
AST output: If(Call(not, [false]), Str("hello"), Ident("___")) ✓

# Nested macro expansion (when → unless → if-if double nesting)  
$ echo '(defmacro when (cond body) (unless (not cond) body))(when true "nested works")' > t.zyl && ./target/debug/zyl t.zyl
AST output: If(Call(not, [Call(not, [true])]), Str("nested works"), ...) ✓

# Hygiene: pattern variable used as name position in let template
$ echo '(defmacro let-bind (var val expr) (let var val expr))(let-bind x 42 x)' > t.zyl && ./target/debug/zyl t.zyl  
AST output: Let("x", Int(42), Ident(x)) ✓

# Pattern variable named 'cond' inside defmacro args — no dispatch error
$ echo '(defmacro unless (cond body) (if cond body))(unless false "hello")' > t.zyl && ./target/debug/zyl t.zyl
Macro expansion complete: 1 expressions. ✓
```

### Known Limitations / TODOs for Phase 2
- [ ] Gensym format `{prefix}#{counter}` is simple counter-based; could use context hashes for better uniqueness across nested expansions
- [ ] No macro expansion loop detection (max depth guard) — E_MACRO_NON_TERMINATION error code defined but not enforced yet
- [ ] Built-in macros (`unless`, `when`, `cond`) not pre-registered — all must be user-defined via defmacro
- [ ] Pattern matching only supports structural equality + identifier capture; no destructuring patterns (e.g., `(Some x)` to extract from variant)

## Phase 3: Type Inference + Trait Resolution (Pending)
- Hindley-Milner with capability types
- Derive validation for Eq, Ord, Debug, Clone, Hash
