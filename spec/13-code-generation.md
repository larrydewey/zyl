# Zyl Specification — Code Generation

**Canonical authority:** `zyl_specification.txt` §21 (Built-In Operations semantics)
**Related:** `docs/architecture-decisions.md` §D8
**Implementation:** `src/codegen.rs`

---

## Output Format

Intel syntax: `.intel_syntax noprefix`

### Sections

| Section | Contents |
|---------|----------|
| `.text` | Function code |
| `.rodata` | String literals |
| `.bss` | hexbuf (for integer-to-string conversion) |

---

## Calling Convention

System V AMD64 ABI.

### Argument Passing

| Position | Register |
|----------|----------|
| 1 | edi |
| 2 | esi |
| 3 | edx |
| 4 | ecx |
| 5 | r8d |
| 6 | r9d |

### Return Values

| Type | Register |
|------|----------|
| Integer/Bool | eax |
| Pointer | rax |

---

## Stack Frame

Local variables at `[rbp - offset]`.
Offset calculation: `(slot_idx + 1) * 8` (8 bytes per slot, aligned).

**Note:** Function parameters stored at `(i+1)*8` (matching load pattern).

---

## Built-In Operations (Semantics)

### 21.1 Arithmetic

```
(+ a b ...)       — sum (unary + returns 0)
(- a b)           — difference (unary - returns negation)
(* a b ...)       — product (unary * returns 1)
(/ a b)           — quotient; b!=0 (Int: error, Float: Inf/NaN)
(% a b)           — remainder; sign follows dividend
```

### 21.2 Comparison

```
(== a b)          — structural equality
(!= a b)          — structural inequality
(< a b)           — less than (Int, Float)
(> a b)           — greater than
(<= a b)          — less or equal
(>= a b)          — greater or equal
```

### 21.3 Boolean

```
(not x)           — logical negation
(and a b ...)     — short-circuit AND
(or a b ...)      — short-circuit OR
```

### 21.4 Type Predicates

```
(int? x), (float? x), (bool? x), (string? x)
(struct? x), (alias? x)
```

### 21.5 Collection

```
(len x)           — length of Vec, Map, String
(vec elem...)     — constructs Vec
(map key val...)  — constructs Map (deterministic iteration)
(tuple elems...)  — constructs Tuple
```

### 21.6 Mutation

```
(set! var value)  — rebinding only. Cannot mutate struct fields directly.
```

### 21.7 I/O & Resources

```
(print x ...)     — stdout
(read-line)       — stdin
(exit code)       — terminate
(close handle)    — free resource
```

### 21.8 Error Signaling

```
(error msg)       — returns (Err msg). Does not throw.
```

### 21.9 Sequencing

```
(begin e1 ... en) — returns value of en
```

### 21.10 Iterator Trait

```lisp
(trait Iterator (next () (Option T)))
```

Collections implement this for `for` loops.

### 21.11 Struct Accessors

```lisp
(struct-get struct field-name)
```

Compiler generates field accessors for every defstruct.

### 21.12 Alias Accessors

```lisp
(unwrap alias-val)
```

Explicit extraction (usually implicit).

---

## Code Generation Instructions

### Constants
- Int: immediate load
- Float: load from .rodata
- Bool: load 1 or 0
- String: pointer to .rodata

### Variable Access
- Load: `[rbp - offset]`
- Store: `[rbp - offset]`

### Control Flow
- Branches: `cmp` + `setcc` pattern
- Labels: unique `.L{N}` format
- Jumps: `jmp`, `jl`, `jg`, `je`, `jne`, etc.

### Struct Operations
- Construction: `malloc` + field store with offset mapping
- Access: load from struct pointer + offset

---

## Integer-to-String Conversion

Division-by-10 loop writing to `hexbuf` (in .bss).
Handles negative numbers via sign flag and negation.
