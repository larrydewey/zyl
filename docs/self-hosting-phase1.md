# Self-Hosting Phase 1: Compiler IR in Zyl

**Status:** Design RFC
**Date:** 2026-08-04
**Author:** Zyl compiler bootstrap effort

## 1. Goal

Define the compiler's intermediate representations — the **AST** and **ICNF**
(SSA IR) — as flat, ID-based data structures written in Zyl, with no recursive
`deftype` types. This is the substrate every later self-hosting phase (lexer,
parser, type inference, monomorphization, ICNF, codegen) is built on.

The Rust compiler's types live in `src/ast.rs` (`Expr`/`ExprInner`, ~50
variants) and `src/icnf.rs` (`ICNFNode`/`ICNFInner`, ~30 variants). The Zyl IR
must represent the same information. **Approach A (flat)** from `PROGRESS.md`
is the design; Approach B (Rust bridge) is rejected for Phase 1.

## 2. Constraints (why the encoding looks this way)

1. **No recursive types.** Zyl `deftype` cannot express `(deftype Expr (Call ... (List Expr)))`. All tree structure must be flattened into a node pool with child references by ID.
2. **`Vec<T>`/`Map<K,V>` store `Int` payloads only.** A pool cannot be a `Vec<Node>`. Nodes must be stored as fixed-layout records in a raw arena block, addressed by `alloc-read-int`/`alloc-write-int`.
3. **64-bit pointers must never be truncated.** Arena addresses are full 64-bit values. All pointer loads must use 64-bit (`rax`), never 32-bit (`eax`). (Two codegen bugs in this class were fixed in this session: struct-param prologue stores and `buf-append` operand loads.)
4. **Determinism.** Same source → same pool contents. No hashing order dependence; string interning order must be source order.
5. **Strings.** Zyl `String` is a pointer to a NUL-terminated buffer. Literal strings are easy; dynamically *built* strings live in a zeroed arena buffer and are referenced by their `Int` pointer (see `stdlib/io/io.zyl` StringBuffer pattern).

## 3. Core encoding

### 3.1 Node record

Every AST or ICNF node is one fixed-size record in a contiguous arena block.
Record stride: **8 words = 64 bytes**. Node id = record index (0-based), so the
record address is `pool_base + id * 64`.

| word | field   | meaning |
|------|---------|---------|
| +0   | `kind`  | opcode (Int constant, §4) |
| +8   | `a`     | first child node id, or value (-1 = none) |
| +16  | `b`     | second child node id, or value |
| +24  | `c`     | third child node id, or value |
| +32  | `kids`  | pointer to child-list block (variadic operands), 0 = none |
| +40  | `str`   | pointer to interned NUL-terminated string, 0 = none |
| +48  | `val`   | numeric payload (Int literal, timeout, discriminant) |
| +56  | `aux`   | second numeric payload (line number / column, region tag) |

All fields are `Int`. `a`/`b`/`c` are for fixed-arity operands; `kids` is a
variadic child list (see §3.2). Only the fields a given opcode uses carry
meaning; the rest are `0`/`-1`.

### 3.2 Child lists

A variadic operand sequence (call args, `begin` bodies, match arms, struct
fields) is a separate arena block:

| word | meaning |
|------|---------|
| +0   | count (number of child ids) |
| +8   | child node id 0 |
| +16  | child node id 1 |
| ...  | ... |

The block's address is stored in the node's `kids` word. This keeps recursion
out of the type system while allowing arbitrary nesting: a child list can
contain node ids whose own records reference further child lists.

### 3.3 String interning

Identifiers, function names, field names, string literals, and error messages
are stored as NUL-terminated bytes in the arena's **string area**. A string is
identified by its `Int` pointer; the pointer is stored in the node's `str` word.

- Build: `arena-alloc-zeroed` a fresh buffer, then `buf-append` the content
  (`buf-append` copies bytes including the terminator).
- Length: `alloc-strlen` (FFI `zyl_cstr_len`).
- Compare: byte-wise scan; a deterministic `str-eq` helper is provided.
- Print: `(file-write 1 ptr)` writes the bytes to stdout (verified working;
  `print-string` on `Int`-typed pointers does *not* work — codegen's string
  detection requires the operand to be `String`-typed, see §6 limitation).

String literals in Zyl source are passed to interning directly; identifiers
read from source are interned the same way. Interning is **not** deduplicated
in this first increment (deterministic, source-ordered; dedup is a later
optimization). Every node that needs a string gets a fresh copy.

## 4. Opcode constants

One `Int` per AST/ICNF variant, defined as named constants in
`stdlib/compiler/ir.zyl`. The numeric values are arbitrary but fixed.

### 4.1 AST opcodes (subset for Phase 1 increment 1)

| opcode   | a | b | c | kids | str | val |
|----------|---|---|---|------|-----|-----|
| `AST_ATOM_IDENT` | – | – | – | – | name | – |
| `AST_ATOM_INT`   | – | – | – | – | – | literal |
| `AST_ATOM_FLOAT` | – | – | – | – | text | – |
| `AST_ATOM_BOOL`  | – | – | – | – | – | 0/1 |
| `AST_ATOM_STR`   | – | – | – | – | text | – |
| `AST_ATOM_KEYWORD`| – | – | – | – | text | – |
| `AST_ATOM_SYMBOL` | – | – | – | – | text | – |
| `AST_CALL`       | fn | – | – | args | – | – |
| `AST_DEF`        | val | – | – | – | name | – |
| `AST_DEFN`       | body | – | – | params | name | – |
| `AST_LET`        | value | body | – | – | name | – |
| `AST_LET_MUT`    | value | body | – | – | name | – |
| `AST_IF`         | cond | then | else | – | – | – |
| `AST_BEGIN`      | – | – | – | stmts | – | – |
| `AST_STRUCT_GET` | target | – | – | – | field | – |
| `AST_MAKE_STRUCT`| – | – | – | field-vals | type | – |
| `AST_LAMBDA`     | body | – | – | params | – | – |
| `AST_PRINT`      | – | – | – | args | – | – |
| `AST_MATCH`      | scrutinee | – | – | arms | – | – |
| `AST_SPAWN`      | thunk | – | – | – | – | – |
| `AST_SEND`       | actor | msg | – | – | – | – |
| `AST_FFI_CALL`   | – | – | – | args | ffi-name | timeout |

Params (`Param`) and match arms (`MatchArm`) are also nodes:
- `AST_PARAM`: `str` = name, `val` = 1 if typed, `kids` = 0. (Type as string in
  a second word is deferred; Phase 1 models untyped params.)
- `AST_MATCH_ARM`: `str` = variant name, `a` = body, `kids` = pattern nodes.

The remaining AST variants (modules, traits, tests, ADTs, struct defs, for /
while, closures, files, with-resource, macros) get opcodes in later increments;
the table above covers everything the compiler core touches first.

### 4.2 ICNF opcodes (subset for Phase 1 increment 1)

| opcode   | a | b | c | kids | str | val/aux |
|----------|---|---|---|------|-----|---------|
| `ICNF_CONST`   | – | – | – | – | atom-enc | – |
| `ICNF_LOAD`    | – | – | – | – | name | – |
| `ICNF_ASSIGN`  | value-id | – | – | – | name | – |
| `ICNF_BINOP`   | left | right | – | – | – | opkind |
| `ICNF_UNOP`    | operand | – | – | – | – | opkind |
| `ICNF_CALL`    | – | – | – | args | fname | – |
| `ICNF_IF`      | cond | – | – | – | result-var | – |
| `ICNF_BEGIN`   | – | – | – | stmts | – | – |
| `ICNF_MAKE_STRUCT` | – | – | – | field-vals | type | – |
| `ICNF_STRUCT_GET`  | target | – | – | – | – | byte-offset |
| `ICNF_FFI_CALL` | – | – | – | args | fname | timeout |
| `ICNF_PRINT`   | – | – | – | args | – | – |
| `ICNF_UNIT`    | – | – | – | – | – | – |

ICNF `If`/`While`/`Match` embedded bodies (`Vec<ICNFNode>`) become child lists
on the corresponding record (`a`/`b`/`c` point to list blocks).

## 5. Node pool API (`stdlib/compiler/ir.zyl`)

```
pool-create (arena) (cap) -> pool   ; allocate cap*64 zeroed block + state
pool-append (pool) -> id            ; bump count, return next id (extends block on overflow)
pool-kind   (pool) (id) -> Int
pool-a/b/c  (pool) (id) -> Int
pool-kids   (pool) (id) -> Int      ; child-list block pointer
pool-str    (pool) (id) -> Int      ; string pointer
pool-val    (pool) (id) -> Int
pool-aux    (pool) (id) -> Int
pool-set-*  (pool) (id) (field) (value)   ; write a field
kids-new    (arena) -> list
kids-push   (arena) (list) (child-id) -> new-list   ; grow-on-append
kids-len    (list) -> Int
kids-get    (list) (i) -> Int
str-intern  (arena) (s String) -> Int   ; copy s into arena, return pointer
str-len     (ptr) -> Int                ; alloc-strlen
str-eq      (p1) (p2) -> Bool
str-print   (ptr) -> Unit               ; file-write(1, ptr) + "\n"
```

The pool header (count, arena handle, capacity) is itself a small arena
record, e.g. `pool` = pointer to `[count, cap, base, arena]`. Growth
re-allocates a larger block and copies records (bump allocator; old block
reclaimed on arena reset — deterministic).

## 6. Known limitations / deferred

1. **`Int`→`String` coercion absent.** `print-string` requires a `String`-typed
   operand; codegen will not treat an `Int`-typed variable holding a pointer as
   a string. Workaround used throughout: print via `(file-write 1 ptr)`. A
   future codegen feature (`String` param that accepts a pointer) would remove
   this wart. Also means string *contents* are only ever built via interning +
   `buf-append`, never reassembled as `String` values.
2. **Typed params** modeled only as a flag; the type-string word is deferred.
3. **Float storage** uses the literal text (like the Rust lexer) until a
   float-word encoding is needed.
4. **No interning dedup.** Same identifier appears once per reference node.
   Safe; slightly larger pools. Dedup is a later optimization.
5. **No spans beyond line/aux.** Phase 1 records `aux` = line; full
   start/end span tracking comes with the lexer phase.

## 7. Verification strategy

Phase 1 increment 1 ships a test program (`test_ir.zyl`) that:
1. Creates a pool on a fresh arena.
2. Builds a small AST by id — e.g. `(defn add (a b) (+ a b))` lowered into
   `AST_DEFN` → params list, body `AST_CALL("+")` → arg idents — using the
   constructors.
3. Walks the pool by id and re-emits the S-expression to stdout via
   `str-print`, asserting the round-trip matches the original source text.
4. Exercises `kids` growth (append beyond the initial list capacity) and a
   nested `AST_LET`/`AST_IF` to prove arbitrary nesting through child lists.

Determinism: the same test run twice must produce identical stdout. This is
guarded by the existing regression harness.

## 8. Files

| file | purpose |
|------|---------|
| `stdlib/compiler/ir.zyl` | opcode constants, pool API, constructors, accessors, walker |
| `test_ir.zyl` | end-to-end verification (§7) |
| `docs/self-hosting-phase1.md` | this document |
