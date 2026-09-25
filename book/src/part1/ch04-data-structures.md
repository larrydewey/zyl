# Chapter 4: Data Structures — Structs, ADTs, and Collections

Zyl provides three primary ways to structure data: **structs** (named product types), **algebraic data types** (sum types), and **collections** (Vec, Map, Set). This chapter covers all three with working examples.

## 4.1 Structs — Named Product Types

Structs are immutable aggregates with named fields. Think of them like `struct` in C/Rust, but **immutable by default**.

### Declaration

```lisp
(defstruct Point
  (x)
  (y))

(defstruct Person
  (name String)
  (age Int))

(defstruct Vec3 x y z)
```

Each field is written `(name)`, `(name Type)`, or just `name`. A field
with a type holds only values of that type: `(make-Person 30 "Alice")`
is `E_TYPE_MISMATCH`. A field without one is an implicit **type
parameter** of the struct, as if `Point` were `(Point X Y)`: each
`make-Point` call picks the field types from its arguments, and the
checker follows them from there. `(make-Point 1 2)` is a Point of two
Ints and `(make-Point "a" 2)` one whose `x` is a String, so
`(+ (struct-get p "x") 1)` on the second one does not compile.

### Creating Instances

The compiler generates a constructor named `make-<StructName>`:

```lisp
(make-Point 3 4)
(make-Person "Alice" 30)
(make-Vec3 1 2 3)
```

Arguments are evaluated left-to-right, matched to fields in declaration order.

### Accessing Fields

```lisp
(defstruct Point (x) (y))
(defstruct Person (name String) (age Int))

(defn main ()
  (let p (make-Point 3 4)
    (let alice (make-Person "Alice" 30)
      (begin
        (print (struct-get p "x"))              ; 3
        (print (struct-get alice "age"))        ; 30
        (print (struct-get alice "name")))))   ; Alice
  0)
```

**Field names are strings** in `struct-get`. A field's declared type
follows it out: `(struct-get alice "name")` is a String and prints as
text.

**Dot syntax** is the short form: `alice.name` means
`(struct-get alice "name")`, and it chains: `seg.start.x`. It applies
when the part before the first dot is a lowercase name (a local, a
parameter or a `def`). After any expression, `.field` reads a field of
its value: `(make-Point 3 4).x`, `(segment-of line).end.y`. Reading a field a known struct does not have is
an error, `E_TYPE_MISMATCH: no field `z` on struct `Point``.

### Immutability by Default (Critical!)

```lisp
;; THIS IS A COMPILE ERROR:
(set! (struct-get p "x") 10)
;; PANIC: E_MUT_CONFLICT: set! target must be a plain variable name bound
;; via let-mut -- direct field/expression mutation is forbidden, rebind
;; the whole variable instead
```

Struct fields **cannot be mutated in place**. This is a core design decision — it simplifies reasoning about aliasing and enables the capability type system.

### "Mutating" a Struct: Rebind the Whole Value

To "mutate" a struct, use `let-mut` and `set!` to rebind the **entire struct**:

```lisp
(defstruct Point (x) (y))

(defn main ()
  (let-mut p (make-Point 0 0)
    (begin
      (set! p (make-Point 10 20))   ; Replace with new struct
      (print (struct-get p "x"))))   ; 10
  0)
```

This creates a new `Point` and rebinds `p` to it. The old `Point` becomes unreachable.

### `defstruct+`

```lisp
(defstruct+ Color (r) (g) (b))
```

`defstruct+` is accepted and defines the struct exactly as `defstruct`
does. To derive traits, use a standalone `derive` (§4.9).

### Nested Structs

```lisp
(defstruct Level3 (content))
(defstruct Level2 (data))
(defstruct Level1 (val))

(defn main ()
  (let deep (make-Level1 (make-Level2 (make-Level3 99)))
    (print (struct-get (struct-get (struct-get deep "val") "data") "content")))
  0)
;; 99
```

Each `struct-get` returns the field value, which can be another struct.

## 4.2 Algebraic Data Types (ADTs) — Sum Types

ADTs represent **"one of several variants"** — like `enum` in Rust, `data` in Haskell, or tagged unions in C.

### Declaration

```lisp
;; Variants with no fields
(deftype Light (Red) (Yellow) (Green))

;; Variants carrying data: each field is a type name
(deftype Shape
  (Circle Int)                 ; radius
  (Rectangle Int Int)          ; width height
  (Triangle Int Int Int))      ; three sides

;; A generic, recursive ADT
(deftype Tree
  (Node T (Tree T) (Tree T))   ; value, left, right
  (Leaf))
```

Each variant is `(Name FieldType...)`; a variant with no fields can be
written `(Name)` or just `Name`. A field type that is not a known type
name — conventionally a single capital letter such as `T` — is a
**type parameter**, which makes the ADT generic. A field whose type is
the ADT itself makes it recursive.

`Option`, `Result` and `List` are already defined by the core library
(§4.4); don't redeclare them.

### Constructing Variants

```lisp
Red                     ; nullary variant: just the name (or (Red))
(Circle 5)              ; Shape
(Rectangle 3 4)         ; Shape
(Node 1 (Leaf) (Leaf))  ; Tree of Int
(Some 42)               ; Option
(Cons 1 (Cons 2 Nil))   ; List
```

Give every variant a distinct name across all the types in your
program. The compiler does not reject two types that share a variant
name: a construction then builds the variant of the later declaration,
and the exhaustiveness check skips any `match` that uses the shared
name.

### Pattern Matching — The Power of ADTs

```lisp
(match expr
  (Variant1 binders... body1)
  (Variant2 binders... body2)
  ...)
```

An arm names a variant, then one binder per field, then the body.
**Exhaustiveness is mandatory** — missing a variant is a compile error
(`E_NON_EXHAUSTIVE_MATCH`).

```lisp
(deftype Shape
  (Circle Int)
  (Rectangle Int Int)
  (Triangle Int Int Int))

(defn area (s)
  (match s
    (Circle r (* 3 r r))           ; a rough pi, to keep to Ints
    (Rectangle w h (* w h))
    (Triangle _ _ _ 0)))           ; not computed here

(defn perimeter (s)
  (match s
    (Circle r (* 6 r))
    (Rectangle w h (* 2 (+ w h)))
    (Triangle a b c (+ a b c))))

(defn main ()
  (print (area (Circle 2)))            ; 12
  (print (area (Rectangle 3 4)))       ; 12
  (print (perimeter (Triangle 3 4 5)))  ; 12
  0)
```

A pattern-bound name has its field's type: with `(Rectangle Float
Float)`, `(* w h)` multiplies Floats.

### Patterns

| Pattern | Matches | Binds |
|---------|---------|-------|
| `(Some x body)` | `Some` variant | `x` = inner value |
| `(None body)` | `None` variant | (nothing) |
| `(Cons x xs body)` | `Cons` variant | `x` = head, `xs` = tail |
| `(Cons x _ body)` | `Cons` variant | `x`; the tail is discarded |
| `(_ body)` | Anything (catch-all, last arm) | (nothing) |

`_` discards a value and may appear any number of times in one arm, as
in `(Triangle _ _ _ 0)` above. A name starting with `_` (such as
`_rest`) also counts as deliberately unused. Chapter 6 covers literal,
range and OR-patterns and guards.

### One Level at a Time

A field position holds a name or `_`, never another pattern. A nested
constructor pattern is a compile error:

```lisp
(defn first-of-some (o)
  (match o
    (Some (Cons x _) x)     ; error[E_NESTED_PATTERN]
    (Some _ -1)
    (None 0)))
```

A *nullary* constructor in a field position, as in `(Some Nil -1)`, is
`E_NESTED_PATTERN` too. Match one level at a time instead, with an
inner `match` on the field:

```lisp
(defn sum-first-two (lst)
  (match lst
    (Cons x rest
      (match rest
        (Cons y _ (+ x y))     ; at least 2 elements
        (Nil x)))              ; exactly 1 element
    (Nil 0)))                  ; empty

(defn main ()
  (print (sum-first-two (Cons 1 (Cons 2 (Cons 3 Nil)))))   ; 3
  (print (sum-first-two (Cons 5 Nil)))                     ; 5
  (print (sum-first-two Nil))                              ; 0
  0)
```

### Match as Expression (Returns a Value)

```lisp
(defn option-to-result-of (opt)
  (match opt
    (Some x (Ok x))
    (None (Err "empty"))))
```

Every arm must return the **same type**. (The core library already has
this function, as `option-to-result opt err`.)

## 4.3 Collections (from `stdlib/collections/`)

Zyl's collections are library code, not built-in syntax. Import them:

```lisp
(use collections/vec)
(use collections/map)
(use collections/set)
```

`Vec` holds elements of any one type, `(Vec T)`; `collections/map` is
a table from Int keys to Int values and `collections/set` a set of
Ints, both kept in insertion order and searched linearly. For a map with
String keys and values of any type, use `core/map` (below). All of them
are *persistent in style*: an operation returns the updated collection,
and you keep using the value it returns.

### Vectors (`Vec`) — `collections/vec.zyl`

Growable arrays with O(1) indexing, generic in their element type:
`(vec-get v i)` on a `(Vec String)` is a String.

| Function | Result |
|----------|--------|
| `(vec-create arena cap)` | Empty Vec with room for `cap` elements, in `arena` (see *Arenas* below) |
| `(vec-create-default cap)` | The same, in a new private arena |
| `(vec-push v x)` | The Vec with `x` appended (grows as needed) |
| `(vec-pop v)` | The Vec without its last element (an empty Vec is returned unchanged) |
| `(vec-get v i)` | Element `i`; an `i` outside the Vec panics with `E_INDEX_OUT_OF_BOUNDS` |
| `(vec-get-or v i default)` | Element `i`, or `default` (of the element type) if `i` is outside the Vec |
| `(vec-set v i x)` | The Vec with element `i` replaced (`i` equal to the length, within capacity, appends; any other `i` outside the Vec leaves it unchanged) |
| `(vec-last v)` | The last element; an empty Vec panics with `E_INDEX_OUT_OF_BOUNDS` |
| `(vec-len v)` / `(vec-cap v)` | Length / capacity |

Use `let-mut` to track the current version:

```lisp
(use collections/vec)

(defn main ()
  (let-mut v (vec-create-default 10)
    (begin
      (set! v (vec-push v 42))
      (set! v (vec-push v 99))
      (print (vec-len v))           ; 2
      (print (vec-get v 0))         ; 42
      (print (vec-get-or v 5 -1))   ; -1 (out of bounds)
      (set! v (vec-pop v))
      (print (vec-len v))))         ; 1
  0)
```

A Vec's buffer is shared by the versions derived from it, so treat the
old value as used up once you have pushed onto it. `(print v)` prints
the elements, `[42, 99]`, through the `Show` trait (§4.9).

### String-keyed maps (`Map`) — `core/map.zyl`

`core/map` is a generic association list, `(Map String V)`: keys are
compared with `str-eq`, values may be any type, and lookup returns an
`Option`.

```lisp
(use core/map)
(use core/option)

(defn main ()
  (let m (map-insert (map-insert (map-new) "a" (Some 1)) "b" None)
    (begin
      (match (map-get m "a")
        (Some v (print v))             ; Some(1)
        (None (print "missing")))
      (print m)))                      ; {b: None, a: Some(1)}
  0)
```

### Int maps (`Map`) — `collections/map.zyl`

An association from Int keys to Int values, kept in insertion order.

```lisp
(use collections/map)

(defn main ()
  (let-mut m (map-create-default 10)
    (begin
      (set! m (map-put m 1 100))
      (set! m (map-put m 2 200))
      (set! m (map-put m 1 111))     ; existing key: value replaced
      (print (map-len m))            ; 2
      (print (map-get m 1 0))        ; 111
      (print (map-get m 3 -1))       ; -1 (the default: key missing)
      (print (map-has m 2))          ; 1 (true)
      (set! m (map-remove m 2))
      (print (map-has m 2))))        ; 0 (false)
  0)
```

Lookup is a linear scan, which is fine for the small maps it is meant
for. Entries are kept in insertion order, so iteration is deterministic.
`map-put` on an existing key overwrites the value in the shared buffer,
so, as with a Vec, the old version sees the change too.

`map-remove` compacts the entries in the same shared buffer (as
`set-remove` does), so the old version sees that too.

### Sets (`Set`) — `collections/set.zyl`

```lisp
(use collections/set)

(defn main ()
  (let-mut s (set-create-default 10)
    (begin
      (set! s (set-add s 42))
      (set! s (set-add s 42))        ; duplicate ignored
      (print (set-len s))            ; 1
      (print (set-contains s 42))    ; 1 (true)
      (set! s (set-remove s 42))
      (print (set-len s))))          ; 0
  0)
```

### Lists

`List` is the core ADT `(Cons head tail)` / `Nil`. A list literal
builds one: `(list 1 2 3)`, `[1 2 3]` and the quoted constant
`'(1 2 3)` are all `(Cons 1 (Cons 2 (Cons 3 Nil)))`, with the elements
evaluated left to right and all of one type (Chapter 2, §2.7). `[]` is
`Nil`.

```lisp
(use core/list)

(defn total ((xs (List Int)))
  (match xs
    (Nil 0)
    (Cons h t (+ h (total t)))))

(defn main ()
  (begin
    (print (total [1 2 3]))                  ; 6
    (print (list-length '((1 2) (3))))       ; 2
    (print (Show.show ["a" "b"]))            ; [a, b]
    0))
```

For lists, `collections/collections` has `list-map`, `list-filter`,
`list-fold`, `list-nth`, `list-take`, `list-drop` and more, and an
immutable association list (`assoc-put`, `assoc-get`, ...) that can
hold any value type.

### Slices (`Slice`) — `collections/slice.zyl`

A `Slice` is a window on a Vec's storage: the storage, an offset and a
length. Making a slice or a sub-slice copies nothing, and every read is
checked against the slice's own bounds, so an index past the slice
panics with `E_INDEX_OUT_OF_BOUNDS` even when the Vec has more
elements.

| Function | Result |
|----------|--------|
| `(slice-of-vec v)` | All of `v` |
| `(slice-vec v off len)` | The `len` elements of `v` from `off`; a range outside the Vec is `E_INDEX_OUT_OF_BOUNDS` |
| `(slice-sub s off len)` | The same, within a slice |
| `(slice-take s n)` / `(slice-drop s n)` | The first `n` elements / all but the first `n` (clamped to the slice) |
| `(slice-get s i)` / `(slice-get-or s i default)` | Element `i`; outside the slice, a panic / `default` |
| `(slice-len s)` | The number of elements |
| `(slice-fold s f init)` | `f` applied to an accumulator and each element in order |
| `(slice-to-vec s arena)` | A new Vec in `arena` holding the elements (a copy) |

```lisp
(use collections/vec)
(use collections/slice)

(defn main ()
  (let v (vec-push (vec-push (vec-push (vec-create-default 4) 10) 20) 30)
    (let s (slice-vec v 1 2)                        ; elements 1 and 2, no copy
      (begin
        (print (slice-len s))                       ; 2
        (print (slice-get s 0))                     ; 20
        (print (slice-fold s (fn (a x) (+ a x)) 0)) ; 50
        (print (Show.show (slice-take s 1)))        ; [20]
        (print (vec-len (slice-to-vec s (arena-create 0))))  ; 2 (a copy)
        0))))
```

A slice shares its storage with the Vec, like a Vec version does: an
element later set through a Vec that still uses that storage is visible
through the slice. The slice holds the storage, so region inference
keeps it alive for as long as the slice; an arena reset or destroy
still frees it (see *Arenas* below). `Show` is implemented for `Slice`.

### String views (`StrView`, `Cursor`) — `text/view.zyl`

A `StrView` is a string, an offset and a length. Taking a view, a
sub-view, splitting or trimming copies no bytes. The bounds are checked
once, when a view is made from a `String` (`view-of`, `view-slice`;
a range outside the string is `E_INDEX_OUT_OF_BOUNDS`), and every
other operation stays inside them. `view-to-string` is the one
operation that copies.

| Function | Result |
|----------|--------|
| `(view-of s)` / `(view-slice s off len)` | All of `s` / `len` bytes of `s` from `off` |
| `(view-sub v off len)`, `(view-take v n)`, `(view-drop v n)` | Narrower views (`view-sub` checks its range; take and drop clamp) |
| `(view-len v)`, `(view-is-empty v)` | Length in bytes; whether it is 0 |
| `(view-byte-at v i)` | Byte `i` (0..255), or -1 outside the view |
| `(view-find v byte from)` | Index of the first `byte` at or after `from`, or -1 |
| `(view-eq a b)`, `(view-eq-str v s)`, `(view-compare a b)` | Byte equality; three-way byte order (-1, 0, 1) |
| `(view-starts-with v s)`, `(view-ends-with v s)` | Prefix / suffix test against a String |
| `(view-trim v)`, `view-trim-start`, `view-trim-end` | Without ASCII whitespace (space, tab, `\n`, `\r`) |
| `(view-split v byte)` | The pieces between occurrences of `byte`, as a `(List StrView)` |
| `(view-parse-int v)` | `(Some n)` for a decimal integer with an optional `-` filling the view, else `None` |
| `(view-to-string v)` | A new String with the view's bytes |

`StrView` implements `Show`, `Debug`, `Eq`, `Ord` and `Hash`; its hash
is the hash of the String with the same bytes.

```lisp
(use text/view)

(defn field-total ((fields (List StrView)))
  (match fields
    (Nil 0)
    (Cons f rest
      (+ (match (view-parse-int (view-trim f)) (Some n n) (None 0))
         (field-total rest)))))

(defn main ()
  (let line (view-trim (view-of "  12, 30 ,-2  \n"))
    (begin
      (print (view-len line))                       ; 10
      (print (view-to-string (view-take line 2)))   ; 12
      (print (view-starts-with line "12"))          ; 1 (true)
      (print (field-total (view-split line 44)))    ; 40 (44 is `,`)
      0)))
```

A `Cursor` is a view and a position, for hand-written parsers. A
scanning step returns a `Taken`: the bytes it took and the cursor after
them.

| Function | Result |
|----------|--------|
| `(cursor-of s)` / `(cursor-new v)` | A cursor at the start of a String / a view |
| `(cursor-pos c)`, `(cursor-at-end c)`, `(cursor-rest c)` | Position; whether at the end; the view from the position on |
| `(cursor-peek c)` | The byte at the cursor, or -1 at the end |
| `(cursor-advance c n)` | `n` bytes on, stopping at the end |
| `(cursor-take-while c pred)` | A `Taken` of the bytes for which `pred` holds |
| `(taken-view t)` / `(taken-rest t)` | What was taken / the cursor after it |
| `(cursor-skip-space c)` | Past any ASCII whitespace |
| `(cursor-expect c s)` | `(Some c2)` past `s` if the input starts with it, else `None` |

```lisp
(use text/view)

(defn digit-p ((b Int)) (and (>= b 48) (<= b 57)))

(defn main ()
  (let t (cursor-take-while (cursor-of "8080 /index") digit-p)
    (let c (cursor-skip-space (taken-rest t))
      (begin
        (print (view-to-string (taken-view t)))     ; 8080
        (print (cursor-pos c))                      ; 5
        (print (cursor-peek c))                     ; 47 (`/`)
        (print (match (cursor-expect c "/index")
                 (Some c2 (cursor-at-end c2))
                 (None false)))                     ; 1 (true)
        0))))
```

A view holds its base string, so a view returned from a function keeps
the string alive in the caller's region even though only the view was
returned. The runtime accessors the module uses (`zyl_view_byte`,
`zyl_view_cmp`, `zyl_view_find`, `zyl_view_copy`) trust bounds the view
already checked, so a program outside the standard library may not call
them (`E_FFI_RESTRICTED`); `zyl_view_ok`, the bounds check itself, is
not restricted.

### Arenas: where collections keep their elements

`Vec`, `collections/map`, `collections/set`, `str-intern` and every entry
point in `stdlib/math` take an **arena** argument. An arena is a region
of memory you own: a bump allocator (`allocator/allocator`) that hands
out 16-byte-aligned chunks from growable blocks and frees them only all
at once. Its type is `Arena`, a handle distinct from `Int`: an Int
cannot be passed where an arena is expected.

| Function | What it does |
|----------|--------------|
| `(arena-create block-size)` | A new arena; `block-size` is the bytes per block (below 16 means the 64 KiB default) |
| `(arena-alloc a n)` / `(arena-alloc-zeroed a n)` | `n` bytes from `a` (zeroed for the second); 0 on failure |
| `(arena-used a)` / `(arena-capacity a)` | Bytes handed out / bytes of blocks held |
| `(arena-reset a)` | Frees every block at once; `a` stays usable |
| `(arena-destroy a)` | Frees everything; `a` must not be used again |

**The `arena` argument** of `vec-create`, `map-create` and `set-create`
is an `Arena` from `arena-create`: the collection's storage, and every
reallocation as it grows, comes from that arena. Several collections
may share one arena, and freeing it (`arena-reset`/`arena-destroy`)
frees them all together. Passing `0` is a type error (expected `Arena`,
found `Int`).

`vec-create-default`, `map-create-default` and `set-create-default`
create a new private arena for the one collection. A private arena is
never freed: that is fine for a few long-lived collections, but inside
a loop it leaks one arena per call.

A handle already destroyed is still an `Arena` to the type checker. The
runtime does not check it, and the first allocation from it reads
garbage or crashes.

**The `cap` argument** is the initial capacity in elements. 0 is fine
(the first push allocates room for 16); a negative value means 0; a
larger value avoids reallocations. Growth doubles the capacity and
copies into new storage from the same arena; the old storage stays
allocated until the arena is reset.

```lisp
(use collections/vec)

(defn last-square (n)
  (let a (arena-create 0)               ; one arena for this computation
    (let-mut v (vec-create a n)          ; room for n elements up front
      (begin
        (for (i 0) (< i n) (begin (set! v (vec-push v (* i i))) (set! i (+ i 1))))
        (let last (vec-get v (- n 1))    ; read what we need first
          (begin
            (arena-destroy a)            ; frees v's storage; v must not be used after this
            last))))))
```

Rules that follow from this design:

- **A collection is only valid while its arena lives.** After
  `arena-reset` or `arena-destroy`, every collection built in that arena
  dangles. Return or keep a collection only if its arena outlives the use.
- **An update may share storage with the old value.** `vec-set` and a
  `vec-push` with spare capacity write into the same storage, so the
  previous value sees the change. Rebind to the result (`let-mut` +
  `set!`) and treat the old value as used up.
- **Sending a collection to an actor shares it; it is not copied.**
  Allocation from one arena is locked, so two actors may allocate from
  it safely, but writing to one collection from two actors is a race.
  Give each actor its own arena, or send immutable data.
- **ADT and struct values do not use your arenas.** Region inference
  places a constructor like `(Some 1)` or `(make-Point 1 2)` in the
  call's own frame region, the region its caller chose for the result,
  or the process heap (which lives until the program exits), as §5.5
  describes. Only the functions that take an arena argument allocate
  from one.
- **`core/map` needs no arena.** It is a persistent association list on
  the runtime heap.

## 4.4 Option and Result — Standard ADTs

Defined in `stdlib/core/option.zyl` and `stdlib/core/result.zyl` and
available in every program without a `use`:

```lisp
(deftype Option (Some T) None)
(deftype Result (Ok T) (Err E))
```

### Option Helpers

```lisp
(option-is-some (Some 42))                          ; true
(option-is-some None)                               ; false
(option-unwrap (Some 42) 0)                         ; 42 (0 is the default for None)
(option-map (Some 21) (fn (x) (* x 2)))             ; (Some 42)
(option-map None (fn (x) (* x 2)))                  ; None
(option-flatmap (Some 2) (fn (x) (option-some (* x 5))))   ; (Some 10)
```

### Result Helpers

```lisp
(result-is-ok (Ok 42))                     ; true
(result-is-ok (Err "oops"))                ; false
(result-unwrap (Err "oops") -1)            ; -1 (the default)
(result-map (Ok 21) (fn (x) (* x 2)))      ; (Ok 42)
(result-map (Err "x") (fn (x) (* x 2)))    ; (Err "x")
(result-and-then (Ok 3) (fn (x) (result-ok (* x 10))))   ; (Ok 30)
```

Note the argument order: the Option or Result comes first, the function
second. And note `option-some` and `result-ok` inside the two `fn`s:
they are the core library's function spellings of `Some` and `Ok`.
Applying the constructor directly, `(fn (x) (Some x))`, works the same
way, and so does a named function. `option-to-result`, `result-to-option` and friends (in
`core/core`) convert between the two.

## 4.5 Tuples

The specification has anonymous tuples (`(tuple 1 "hello" 3.14)`);
they are not implemented yet. Use a struct, or a single-variant ADT:

```lisp
(deftype Pair (MkPair A B))

(defn pair-sum (p)
  (match p
    (MkPair a b (+ a b))))
```

## 4.6 Type Aliases

```lisp
(alias UserId Int)
(alias Port Int)
```

Aliases are **transparent** — zero-cost, fully interchangeable with their target type. Use for documentation and domain modeling.

```lisp
(defn next-user ((id UserId))    ; same as ((id Int))
  (+ id 1))
```

## 4.7 Recursive Data Structures

Recursive ADTs need nothing special:

```lisp
(deftype Tree
  (Node T (Tree T) (Tree T))
  (Leaf))

(defn tree-sum (t)
  (match t
    (Leaf 0)
    (Node v l r (+ v (+ (tree-sum l) (tree-sum r))))))

(defn main ()
  (print (tree-sum (Node 1 (Node 2 (Leaf) (Leaf)) (Node 3 (Leaf) (Leaf)))))   ; 6
  0)
```

Every constructed variant is a pointer to its own block, so a
recursive field simply holds a pointer to another block.

## 4.8 Choosing Between Structs and ADTs

| Scenario | Use |
|----------|-----|
| Fixed set of fields, all always present | `defstruct` |
| One of several distinct shapes | `deftype` |
| Variants carry different data | `deftype` |
| Small Int-to-Int table | `Map` |
| Recursive structures | `deftype` (ADT) |

**Rule of thumb:** If you find yourself writing `if (field? x) ... else ...`, you probably want an ADT.

## 4.9 Deriving Traits

`derive` generates impls of `Show`, `Debug`, `Eq`, `Ord`, `Hash` and
`Clone`:

```lisp
(defstruct Person (name String) (age Int))
(derive Person [Show Ord Debug])         ; or (derive Person Show Ord Debug)
(deftype Shape (Circle Float) (Rect Int Int))
(derive Shape Show)

(defn main ()
  (begin
    (print (make-Person "Ann" 30))       ; Person { name: Ann, age: 30 }
    (print (Rect 2 3))                   ; Rect(2, 3)
    (print (Ord.compare (make-Person "Ann" 30) (make-Person "Bob" 25)))  ; -1
    (print (Debug.debug (make-Person "Ann" 30)))  ; Person { name: "Ann", age: 30 }
    0))
```

Every field's type must implement the trait being derived; if one does
not, or the trait is not one of the six, the derive is
`E_TRAIT_NOT_DERIVABLE`. `Ord.compare` orders field by field in
declaration order (variants in declaration order) and returns -1, 0 or
1. `Debug` differs from `Show` in quoting Strings.

`print` of any value whose type has a `Show` impl prints its text; the
standard library provides impls for the primitives, `List`, `Option`,
`Result`, `Vec` and `Map`. A value with no impl prints as a word (a
struct or ADT value prints its address). `==` compares structs and ADT
values field by field, by content, with or without a derived `Eq`
(Chapter 2, §2.6).

## 4.10 Module Imports for Stdlib Types

```lisp
(use collections/vec)           ; vec-create vec-push vec-get ...
(use collections/map)           ; map-create map-put map-get ...
(use collections/set)           ; set-create set-add set-contains ...
(use collections/collections)   ; list-map list-filter assoc-put ...
(use collections/slice)         ; slice-vec slice-get slice-fold ...
(use text/view)                 ; view-of view-split cursor-of ...
```

`Option`, `Result`, `List` and their helpers come from `core/core`,
which every program gets implicitly. A module is named by its path under
`stdlib/`, without the `.zyl`. See Appendix B for the full stdlib
overview and Chapter 25 for modules and packages.

---

## For Experts: Under the Hood

### Struct and ADT Representation

Structs and ADT values share one representation. A struct is a
single-variant ADT whose variant is named after the struct, and every
value is a pointer to a block:

```
[ header ][ tag ][ field 0 ][ field 1 ] ...
```

- Every field is one 8-byte word — an Int, a Float's bit pattern, a Bool,
  or a pointer (a String, another struct, another variant)
- The tag says which variant the block is; `match` dispatches on it
- The header records the block's size, which the runtime's shallow
  comparison reads (used by `==` only for a type with a `Secret` field;
  every other type gets a generated per-type equality function) and
  which in-place reuse checks before writing a new record into a dead
  value's block
- A nullary variant is a block with no fields

Because a field is always one word, a block's layout depends only on
its field count, and a generic ADT needs no per-type layout.

### Where Data Structures Live

| Construction | Where |
|--------------|-------|
| `(let s (Some 42) body)`, where `body` only `match`es on `s` or `print`s it | The function's stack frame |
| A struct or ADT value that does not outlive its call | The call's own region, released when the call returns |
| A struct or ADT value that is returned but goes no further | The region the caller chose for the result |
| Every other struct or ADT value (stored, sent, captured) | The process heap |
| `(vec-create a 10)`, `(map-create-default 10)` | The arena `a`, or a private one |

Region inference decides the placement; anything it cannot prove
short-lived goes to the heap, which is always safe. The heap is
released when the program exits; the regions are released as calls
return. When the compiler proves a value unique (nothing else refers
to it) and dead (nothing uses it afterwards), an update that builds a
new record from it, such as a `vec-push`, may write the new record into
the old value's block instead of allocating (`compiler/reuse.zyl`). Chapter 5 describes the rules, and `with-region` for choosing a
region explicitly.

### Monomorphization of Generic ADTs

```lisp
(Some 42)       ; an Option of Int
(Some "hi")     ; an Option of String
```

The specification gives each instantiation its own canonical name
(`Option_Int`, `Result_Int_String`). The current compiler does not need
per-instance copies: every field is one word, so all instances share the
same constructors, layout and `match` code, and type inference tracks
the type arguments at each use. Instances with different type arguments
coexist in one program without interfering —
`tests/regression/generics-multi-type.zyl` checks exactly that.

Chapter 19 describes monomorphization in full.

---

**Next:** [Chapter 5: Ownership, Regions, and Capability Types](ch05-ownership-regions-capabilities.md) — Zyl's memory model: compile-time capability checks and region inference.
