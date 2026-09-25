# Appendix B: Standard Library Overview

Reference for Zyl's standard library modules and what each one
exports. Signatures are taken from the source under `stdlib/`; a
parameter written `(name Type)` carries that annotation in the source,
and a bare name is unannotated.

The standard library is implicit (spec §25): it is the package
`zyl/std`, needs no manifest entry, and every definition in it is
visible to every program. A `use` still names the module you want. The
exception is `core/core`: a program that loads none of `core/core`,
`core/option` or `core/result` gets `core/core` anyway.

Every `use` takes a full path, because a module is a file under
`stdlib/`: `(use core/core)`, not `(use core)`.

## B.1 Core Modules

### `core/core` — Fundamental Helpers

Operators and special forms (`+ - * / %`, `= == != < > <= >=`,
`and or not`, `if cond begin while for match`, `try`, `print`,
`struct-get`, …) are handled by the compiler itself (Appendix C).
`core/core` loads `core/option`, `core/result` and `core/list`, and adds:

```lisp
(use core/core)
;(identity x) (const a _b) (flip f a b) (compose f g) (apply f x)
;(abs x) (max a b) (min a b) (clamp x lo hi) (signum x) (square x) (cube x)
;(xor a b) (nand a b) (nor a b) (implies a b)
;(when pred body) (unless pred body)
;(is-bool x) (is-zero x) (is-even n) (is-odd n)
;(print-int (n Int)) (print-float (f Float)) (print-string (s String)) (print-bool (b Bool))
;(option-to-result opt err) (option-from-result res default)
;(result-to-option res) (result-from-option opt err)
```

`when` and `unless` are ordinary functions, not special forms: both
arguments are evaluated before the call, so the body runs even when the
test fails. Both are `Bool Unit -> Unit`: `(when ok (print "x"))`
type-checks, but prints `x` whatever `ok` is. Use `(if test stmt)` to
evaluate `stmt` only when `test` holds. The predicates (`is-zero`, `is-even`, `xor`, `implies`, …)
return `Bool`.

### `core/show` — The Derivable Traits

```lisp
(trait Show (show (self) String))
(trait Debug (debug (self) String))            ; strings quoted
(trait Eq (eq (self (other Self)) Bool))
(trait Ord (compare (self (other Self)) Int))  ; -1, 0 or 1
(trait Hash (hash (self) Int))                 ; FNV-1a, deterministic
(trait Clone (clone (self) Self))
(trait Secret (wipe (self) Int))
; all six derivable traits: Int, Float, Bool, String here; List, Option,
; Result in core. All but Clone: StrView in text/view.
; Show only: Vec in collections/vec, Slice in collections/slice, Map in core/map
```

Part of the prelude. `print` of a value whose type has a `Show` impl
prints `(Show.show v)`, so `(print (Cons 1 (Cons 2 Nil)))` prints
`[1, 2]`; `(derive T Show Eq ...)` writes the impls for an ADT or
struct. A type that implements `Secret` is secret wherever it appears
and prints as `<secret>`; `impl-not` declarations here forbid it
`Show`, `Debug`, `Eq`, `Ord` and `Hash` impls (Chapter 33).

### `core/option` — Optional Values

```lisp
(use core/option)
(deftype Option (Some T) None)
;(option-some x) (option-none)
;(option-is-some opt) (option-is-none opt)
;(option-unwrap opt default) (option-unwrap-or opt default) (option-expect opt msg)
;(option-map opt f) (option-flatmap opt f)
;(option-and opt other) (option-or opt other) (option-inspect opt f)
```

`option-unwrap` takes a default of the contents' type:
`(option-unwrap opt default)`. A default of another type is
`E_TYPE_MISMATCH`, not a sentinel; when there is no sensible default,
use `option-expect`. `option-is-some` and `option-is-none` return
`Bool`.

### `core/result` — Error Handling

```lisp
(use core/result)
(deftype Result (Ok T) (Err E))
;(result-ok v) (result-err e)
;(result-is-ok res) (result-is-err res)
;(result-unwrap res default) (result-unwrap-or res default) (result-expect res msg)
;(result-map res f) (result-flatmap res f) (result-and-then res f) (result-or-else res f)
;(result-and res other) (result-or res other) (result-inspect res f)
```

`result-unwrap` also takes a default of the `Ok` type. The compiler's
`unwrap` form takes an `Option` only, so a `Result` needs one of these;
`result-expect` panics with your message (Appendix C.7).

### `core/list` — Singly-Linked Lists

```lisp
(use core/list)
(deftype List (Cons T (List T)) Nil)
;(is-nil xs) (list-car xs) (list-cdr xs) (list-rest xs)
;(car xs) (cdr xs) (cadr xs) (caddr xs) (cddr xs)
;(list-length xs) (list-append xs ys) (list-reverse xs) (list-sum xs)
```

`car`/`cdr`/`cadr`/`caddr`/`cddr` are plain functions, not macros: each
takes one argument and evaluates it once, so a macro would buy nothing
and a function can be passed to a higher-order function.

### `core/map` — Persistent Ordered Maps

```lisp
(use core/map)
(deftype MapEntry (ME K V))            ; ME.key, ME.value
(deftype Map (MapC (List (MapEntry K V))))
;(map-new) (map-insert m k v) (map-remove m k)
;(map-get m k) (map-get-or m k default) (map-has m k)
;(map-entries m) (map-size m) (map-is-empty m)
;(map-map-values f m) (map-from-list pairs)
```

An association list of `ME` entries with string keys, compared with
`str-eq`; values may be of any type, `(Map String V)`, and a map prints
as `{k: v, ...}` (newest entry first). Iteration order is deterministic, which is what lets the
compiler use this map internally without breaking reproducible builds.
`map-get` returns an `Option`.
This `Map` is not the arena-backed `Map` of `collections/map`; a
program should load one or the other.

## B.2 Collections

`collections/vec`, `collections/map` and `collections/set` are
arena-backed. `Vec` is generic, `(Vec T)`; `collections/map` and
`collections/set` hold `Int` keys and values. Each holds a pointer, a
length, a capacity and the owning arena; an operation that changes the
contents returns an updated value. The new struct can
share its storage with the old one, so treat the old value as used up.
The first argument of `vec-create`, `map-create` and `set-create` is an
`Arena`, from `(arena-create block-size)`; `0` is an `Int`, not an
arena, and does not type-check. The `-default` constructors take only a
capacity and make a private arena on the spot:
`(vec-create-default 10)`.

### `collections/vec` — Vectors

```lisp
(use collections/vec)
(deftype Vec (VecC (Array T) Int Arena))  ; storage, length, arena
;(vec-create (arena Arena) (cap Int)) (vec-create-default (cap Int))
;(vec-len v) (vec-cap v)
;(vec-get v (i Int))                    ; a T; E_INDEX_OUT_OF_BOUNDS outside the Vec
;(vec-get-or v (i Int) default)         ; a T; default outside the Vec
;(vec-set v (i Int) value)              ; a write at len extends it, up to cap
;(vec-push v value)                     ; reallocates when full
;(vec-pop v) (vec-last v)               ; vec-last of an empty Vec is E_INDEX_OUT_OF_BOUNDS
;(vec-free v)                           ; an empty Vec; storage returns at arena-reset
```

A Vec prints as `[a, b, ...]` (`Show`).

There is no `vec-slice`, `vec-append` or `vec-clear`.

### `collections/map` — Arena-Backed Maps

```lisp
(use collections/map)
(defstruct Map (kptr Words) (vptr Words) (len Int) (cap Int) (arena Arena))
;(map-create (arena Arena) (cap Int)) (map-create-default (cap Int))
;(map-len (m Map)) (map-cap (m Map))
;(map-put (m Map) (k Int) (v Int))
;(map-get (m Map) (k Int) (default Int))
;(map-has (m Map) (k Int)) (map-remove (m Map) (k Int))
;(map-find (m Map) (k Int) (i Int) (len Int))   ; index of k, searching from i
;(map-free (m Map))                     ; an empty Map; storage returns at arena-reset
```

`map-get` takes a default value. There are no `map-keys`, `map-values`
or `map-entries` here; use `core/map` or the association lists in
`collections/collections` when you need them.

### `collections/set` — Sets

```lisp
(use collections/set)
(defstruct Set (ptr Words) (len Int) (cap Int) (arena Arena))
;(set-create (arena Arena) (cap Int)) (set-create-default (cap Int))
;(set-len (s Set)) (set-cap (s Set))
;(set-contains (s Set) (k Int)) (set-add (s Set) (k Int)) (set-remove (s Set) (k Int))
;(set-find (s Set) (k Int) (i Int))
```

There is no `set-union`, `set-intersect` or `set-diff`.

### `collections/collections` — Association Lists and List Helpers

```lisp
(use collections/collections)
(deftype Assoc (Empty) (AssocNode K V (Assoc K V)))
;(assoc-empty) (assoc-put k v m) (assoc-get k default m) (assoc-has k m)
;(assoc-remove k m) (assoc-size m) (assoc-keys m) (assoc-values m)
;(assoc-map f m) (assoc-fold f acc m)
;(list-map f xs) (list-filter pred xs) (list-fold f acc xs)
;(list-take n xs) (list-drop n xs) (list-nth n xs) (list-set idx val xs)
;(list-contains x xs) (list-range lo hi) (list-count pred xs)
```

Note the argument order: the collection comes last (`(list-nth n xs)`,
`(assoc-get k default m)`).

### `collections/slice` — Zero-Copy Slices of a Vec

```lisp
(use collections/slice)
(deftype Slice (SliceC (Array T) Int Int))   ; storage, offset, length
;(slice-of-vec v) (slice-vec v (off Int) (len Int))
;(slice-sub s (off Int) (len Int)) (slice-take s (n Int)) (slice-drop s (n Int))
;(slice-len s) (slice-get s (i Int)) (slice-get-or s (i Int) default)
;(slice-fold s f init) (slice-to-vec s (arena Arena))
```

Making a slice copies nothing; `slice-to-vec` copies. A range or index
outside the slice is `E_INDEX_OUT_OF_BOUNDS` (`slice-get-or` returns the
default instead; take and drop clamp). The slice shares the Vec's
storage and keeps it alive (Chapter 4). `Show` is implemented.

### `text/view` — String Views and a Parsing Cursor

```lisp
(use text/view)
(deftype StrView (StrViewC String Int Int))   ; base, offset, length
(deftype Cursor (CursorC StrView Int))        ; input, position
(deftype Taken (TakenC StrView Cursor))       ; bytes taken, cursor after
;(view-of (s String)) (view-slice (s String) (off Int) (len Int))
;(view-sub (v StrView) (off Int) (len Int)) (view-take v (n Int)) (view-drop v (n Int))
;(view-len v) (view-is-empty v) (view-byte-at v (i Int)) (view-find v (byte Int) (from Int))
;(view-eq a b) (view-eq-str v (s String)) (view-compare a b)
;(view-starts-with v (prefix String)) (view-ends-with v (suffix String))
;(view-trim v) (view-trim-start v) (view-trim-end v)
;(view-split v (byte Int)) (view-parse-int v) (view-to-string v)
;(cursor-of (s String)) (cursor-new (v StrView)) (cursor-view c) (cursor-pos c)
;(cursor-at-end c) (cursor-rest c) (cursor-peek c) (cursor-advance c (n Int))
;(cursor-take-while c pred) (cursor-skip-space c) (cursor-expect c (s String))
;(taken-view t) (taken-rest t)
```

The bounds are checked once, when a view is made from a String
(`E_INDEX_OUT_OF_BOUNDS`); after that nothing is copied until
`view-to-string`. `view-byte-at` and `cursor-peek` return -1 outside
the view, `view-find` -1 when the byte is absent, `view-parse-int` an
`(Option Int)`, `cursor-expect` an `(Option Cursor)`. `StrView`
implements `Show`, `Debug`, `Eq`, `Ord` and `Hash` (the same hash as the
equal String). The raw runtime accessors behind it are standard-library
only (`E_FFI_RESTRICTED`).

## B.3 Concurrency

### `actor/actor` — Actor System

`spawn` and `send` are compiler special forms. `actor/actor` wraps them
and adds lifecycle operations backed by the C runtime:

```lisp
(use actor/actor)
;(actor-spawn closure) (actor-send actor message)
;(actor-send-with-timeout actor message timeout)   ; Result; timeout not yet used
;(actor-is-alive actor) (actor-wait actor) (actor-terminate actor)
```

`spawn` takes a zero-argument closure, `(spawn (fn () ...))`, and
returns an `Actor`; `send`, `actor-is-alive`, `actor-wait` and
`actor-terminate` take one, and `actor-is-alive` returns `Bool`. The
actor reads messages with the `(receive)` form and names itself with
`(actor-self)`, also an `Actor` (Chapter 9). `receive` is not
type-checked yet: its result takes whatever type its use needs, until
typed channels replace mailboxes. `actor-wait`
stops an actor and joins its thread. When `main` returns, the program
drains every mailbox and stops all actors; the runtime's
`zyl_actor_wait_all`, reachable through `ffi-call` (the compiler's
signature table types it), does the same earlier. Using this module from a package requires
the `actor` capability (§31.9).

### `atomic/atomic` — Atomic Operations on Addresses

```lisp
(use atomic/atomic)
;(atomic-load addr) (atomic-store addr value)
;(atomic-add addr value) (atomic-sub addr value)
;(atomic-max addr value) (atomic-min addr value)
;(atomic-cas addr expected new_value) (atomic-fetch-add addr value)
;(atomic-incr addr) (atomic-decr addr)
```

For atomics on a byte buffer, use the `bytebuf-atomic-*` forms
(Appendix C.12).

## B.4 FFI

### `ffi/ffi` — Foreign Function Interface Helpers

`ffi-call`, `ffi-pin` and `ffi-unpin` are compiler special forms.
`ffi/ffi` adds four thin wrappers:

```lisp
(use ffi/ffi)
;(ffi-pin-value value) (ffi-unpin-value pointer)
;(ffi-safe-call result) (ffi-pin-call-unpin result)
```

Using this module from a package requires the `ffi` capability.

## B.5 Low-Level

### `allocator/allocator` — Memory, Arenas and Strings

```lisp
(use allocator/allocator)
;(alloc-malloc size) (alloc-free ptr)
;(alloc-read-int addr) (alloc-write-int addr value) (alloc-int value)
;(alloc-incr addr) (alloc-decr addr) (alloc-strlen ptr)
;(arena-create block-size) (arena-alloc arena size) (arena-alloc-zeroed arena size)
;(arena-reset arena) (arena-destroy arena) (arena-used arena) (arena-capacity arena)
;(str-len ptr) (str-length s) (str-concat a b) (str-substring s start len)
;(str-eq p1 p2) (str-intern arena s) (buf-append dst src)
;(error msg)
```

`str-eq` compares contents and returns a `Bool`, so it is a condition
by itself: `(if (str-eq a b) ...)`. `alloc-read-int` and
`alloc-write-int` read and write `Int`s only. `buf-append` appends at
the end of the NUL-terminated string already in `dst`. `error` panics
with `msg`: it unwinds to the nearest `try`, or prints `PANIC: msg` and
exits with status 1.

## B.6 I/O

### `io/io` — File and Buffer I/O

`file-open`, `file-read`, `file-write`, `file-close` and `read-line` are
compiler special forms; file handles are `Int` descriptors, and
`file-open`'s mode is a string literal (`"r"`, `"w"`, `"a"`, optionally
with `+` or `b`). `io/io`
adds named helpers, buffered output and an output trait:

```lisp
(use io/io)
;(io-file-open-read path) (io-file-open-write path) (io-file-open-append path)
;(io-file-read handle count) (io-file-write handle data) (io-file-close handle)
;(io-read-line) (io-newline)
;(io-print x) (io-print-int n) (io-print-string s) (io-print-float f)
;(io-safe-read handle count) (io-safe-write handle data) (io-safe-close handle)
(defstruct Stdout (fd Int))                    ; (make-stdout)
(defstruct StringBuffer (buf (Ref StrBuf)) (len (Ref Int)) (cap (Ref Int))
  (arena Arena) (fd Int))                      ; (make-string-buffer)
;(string-buffer-str sb) (string-buffer-len sb) (string-buffer-destroy sb)
(trait OutputStream
  (write (self) (chunk String) Int)
  (flush (self) Int))                          ; implemented for Stdout and StringBuffer
```

Call a trait method by its qualified name: `(OutputStream.write out "text")`.
There is no `file-seek`, `file-tell` or `file-size`. Using this module
from a package requires the `io` capability.

## B.7 Testing

### `testing/testing` — Test Helpers

The testing forms (`test`, `test-suite`, `assert-equal`, `assert-true`,
`assert-false`, `assert-fail`, `test-property`, `setup`, `teardown`,
`run-tests`, `test-compile`) are compiler special forms (Appendix
C.14). `testing/testing` adds:

```lisp
(use testing/testing)
;(test-run test-name test-body) (test-suite-run suite-name tests)
;(assert-equal-values expected actual) (assert-true-value value)
;(assert-false-value value) (assert-fail-expr expr)
;(property-int name gen-fn property-fn) (property-bool name gen-fn property-fn)
;(property-string name gen-fn property-fn) (property-float name gen-fn property-fn)
```

> `test-count`, `run-tests-filtered`, `run-tests-parallel` and
> `run-tests-with-timeout` exist only as **placeholders** that call
> `error` until runtime support lands. The `property-*` helpers build on
> `test-property`, which is itself a stub today.

## B.8 Mathematics and Cryptography (stdlib/math/)

About 7,600 lines of pure Zyl: hashes, AEADs, elliptic curves, RSA, key
derivation, big-number arithmetic and random number generation. Only
AES (hardware AES-NI), system entropy and the volatile zeroing behind
`zeroize` call into C. `(use math/math)` loads the whole tree.

Byte strings are passed as an address and a length, and most functions
take the arena to allocate their result in as the first argument.

| Module | Main entry points |
|---|---|
| `math/bits` | `add32`, `sub32`, `mul32`, `shl32`, `shr32`, `rotl32`, `rotr32`, `not32`, `rotl64`, `rotr64`, `not64`, `u64-lt`/`gt`/`le`/`ge`, `byte-of`, `be-pack32`, `le-pack32`, masks |
| `math/words` | `(w-alloc arena n)`, `w-get`, `w-set`, `w-fill`, `w-copy`, `w-from-string`, `w-from-hex`, `w-hex-bytes`, `w-hex-words` |
| `math/secret/secret` | `ct-mask`, `ct-is-zero`, `ct-is-nonzero`, `ct-select`, `ct-eq`, `ct-ne`, `ct-eq-words`, `ct-ne-words`, `ct-eq-bool`, `ct-eq-words-bool`, `declassify`, `(zeroize base n)`, `zeroize-bytes` |
| `math/bignum/bignum` | fixed-width naturals: `bn-alloc`, `bn-add`, `bn-sub`, `bn-mul`, `bn-sqr`, `bn-eq`, `bn-lt`, `bn-from-bytes-be`/`le`, `bn-to-bytes-be`/`le`, `bn-bit-length` |
| `math/bignum/montgomery` | `mont-mul`, `mont-to`, `mont-from`, constant-time `mont-exp` |
| `math/bignum/barrett` | `barrett-reduce` by a fixed modulus |
| `math/bignum/modular` | `mod-add`, `mod-sub`, `mod-inverse-prime` (Fermat), `mr-probably-prime` (Miller–Rabin) |
| `math/rand/rand` | `rand-u64-from-bytes`, `rand-below` |
| `math/rand/crypto` | `getrandom(2)` entropy: `sysrng-fill`, `sysrng-bytes`, `sysrng-next-u64`, `sysrng-key32` |
| `math/rand/deterministic` | seeded ChaCha20 generator: `chacharng-new`, `chacharng-from-int`, `chacharng-bytes`, `chacharng-fill`, `chacharng-next-u64`, `chacharng-below` |
| `math/hash/sha2` | SHA-256: `(sha256-bytes arena msg len)`, `sha256-hex-of-string` |
| `math/hash/sha512` | SHA-512: `sha512-bytes`, `sha512-hex-of-string` |
| `math/hash/sha3` | `sha3-256-bytes`, `sha3-512-bytes`, `shake128-bytes`, `shake256-bytes`, hex helpers |
| `math/hash/blake2b` | `blake2b` (keyed, variable output), `blake2b-512`, `blake2b-hex-of-string` |
| `math/hash/blake3` | `(blake3-hash arena msg len outlen)`, `blake3-hex-of-string` |
| `math/hash/hmac` | `hmac-sha256`, `hmac-sha256-verify` |
| `math/crypto/symmetric/chacha20` | `chacha20-block`, `chacha20-xor` |
| `math/crypto/symmetric/poly1305` | `poly1305-mac`, `poly1305-verify` |
| `math/crypto/symmetric/chacha20poly` | ChaCha20-Poly1305: `aead-encrypt`, `aead-decrypt` |
| `math/crypto/symmetric/aesgcm` | AES-GCM: `aes-available`, `gcm-encrypt`, `gcm-decrypt`, `gcm-seal`, `gcm-open` |
| `math/crypto/asymmetric/x25519` | `x25519`, `x25519-public`, `x25519-basepoint`, `x25519-checked` |
| `math/crypto/asymmetric/ed25519` | `ed25519-public-key`, `ed25519-sign`, `ed25519-verify` |
| `math/crypto/asymmetric/ecdsa` | curves `ec-p256`, `ec-secp256k1`, `ec-p384`; `ecdsa-public-key`, `ecdsa-sign` (RFC 6979 nonces), `ecdsa-verify` |
| `math/crypto/asymmetric/rsa` | `rsa-public-key`, `rsa-private-key`, `rsa-oaep-encrypt`/`decrypt`, `rsa-pss-sign`/`verify` |
| `math/crypto/kdf/hkdf` | `hkdf`, `hkdf-extract`, `hkdf-expand` |
| `math/crypto/kdf/pbkdf2` | `pbkdf2-sha256` |
| `math/crypto/kdf/argon2` | `argon2id-hash` |

The `secret` capability (§31.9) guards `math/secret`: a package must
declare it to use that module or the `Secret` type. Chapter 34 covers
the representation conventions, the deliberate omissions and how the
library was verified.

## B.9 The REPL (stdlib/repl/)

`zyl repl` is built from these modules; `tools/repl.zyl` is only a thin
`main` that calls `repl-main`.

| Module | Purpose |
|---|---|
| `repl.zyl` | The session loop and the `:` commands (`:help`, `:quit`, `:history`, `:defs`, `:doc`, `:type`, `:time`, `:load`, `:save`, `:reset`, `:clear`) |
| `eval.zyl` | Turning an entry into a program, the `Session` it accumulates, and the `.zyl-session` file |
| `interp.zyl` | The ICNF interpreter that evaluates each entry |
| `reader.zyl` | Reading a complete form: continuation lines, completion, history search |
| `line_editor.zyl` | The line editor's pure state and edits |
| `highlight.zyl` | Syntax colouring of the input line |
| `history.zyl` | Persistent history |
| `terminal.zyl` | Raw mode, terminal size, key decoding, ANSI sequences |

## B.10 Language Server (stdlib/lsp/)

The language server is a Zyl program like any other, built from these
modules and entered through `selfhost/lsp_main.zyl`:

| Module | Purpose |
|---|---|
| `lsp_types.zyl` | LSP protocol types |
| `json_rpc.zyl` | JSON-RPC 2.0 framing over stdio |
| `vfs.zyl` | Document text and edit application |
| `document_manager.zyl` | Per-document analysis cache and diagnostics |
| `compiler_bridge.zyl` | Compiler data to LSP types; the symbol table |
| `source_index.zyl` | Position tracking by text scan |
| `builtins.zyl` | The built-in and special-form table behind hover and completion |
| `capability_registry.zyl` | `ServerCapabilities` |
| `workspace.zyl` | Multi-root folders, workspace symbol search |
| `repl_integration.zyl` | Evaluating a document by compiling and running it with the `zyl` CLI; backs the `zyl.evalDocument` command (`workspace/executeCommand`) |
| `lsp_server.zyl` | The request loop |
| `services/*.zyl` | hover, goto definition, completion, document symbols, semantic tokens, code actions, call hierarchy, inlay hints, signature help |

Chapter 35 covers what the server provides and what it cannot.

## B.11 Compiler (stdlib/compiler/)

The 41 modules of the self-hosted compiler. `selfhost/driver.zyl`
reaches them through ordinary `(use compiler/...)` imports, and the
compiler is built from that entry file like any program.

| Module | Purpose |
|--------|---------|
| `lexer.zyl` | Tokenizer |
| `parser.zyl` | Parser |
| `ast.zyl` | AST definitions |
| `expr_inner.zyl` | ExprInner ADT and the post-processor from raw AST |
| `sexp_balance.zyl` | S-expression balance check, with line/column tracking |
| `macro_expand.zyl` | Macro expansion |
| `resolver.zyl` | Name resolution |
| `module_resolver.zyl` | Module and package resolution; splices the program |
| `qualify.zyl` | Canonical symbol keys (§31.2) |
| `capability_check.zyl` | Package capability enforcement (§31.9) |
| `type_system.zyl` | Shared declarations: `Pair` and the `Region` family |
| `type_annotate.zyl` | The type checker: Hindley–Milner inference, trait resolution, per-type instances; every type error is reported |
| `ffi_sigs.zyl` | The type of every `zyl_*` runtime function reached through `ffi-call` |
| `node_tables.zyl` | Typed side tables that later passes attach to AST and ICNF nodes |
| `derive.zyl` | `derive` expansion for Show, Debug, Eq, Ord, Hash and Clone, with the field check |
| `region_inference.zyl` | Stack promotion of non-escaping variants and escape analysis over ICNF |
| `lift_impls.zyl` | Impl method lifting |
| `closure_inline.zyl` | Closure inlining (retired; identity pass) |
| `icnf.zyl` | ICNF lowering |
| `icnf_print.zyl` | Canonical ICNF text, for the build's ICNF hash |
| `optimization.zyl` | Safe-only optimizations: constant folding, dead branches, inlining of small functions (`ZYL_INLINE=0` turns it off) |
| `reuse.zyl` | In-place reuse of a unique, dead value's block for the value built from it |
| `mir.zyl` | The native backend's machine IR, liveness and linear-scan register allocation |
| `codegen.zyl` | x86-64 code generation: through MIR for each function the native backend supports (`ZYL_MIR=0` turns it off), by the older stack-machine emitter for the rest |
| `pipeline.zyl` | The pass sequence from source to assembly |
| `error_codes.zyl` | The error-code catalog |
| `error_report.zyl` | Error formatting and source snippets |
| `duplicate_check.zyl` | Duplicate definitions |
| `arity_check.zyl` | Call arity |
| `mutability_check.zyl` | Mutability and capability rules |
| `exhaustiveness_check.zyl` | Match exhaustiveness |
| `secret_check.zyl` | The `Secret` capability's constant-time obligations |
| `unused_check.zyl` | Unused and shadowed bindings (warnings) |
| `package.zyl` | `zyl.pkg` manifests |
| `workspace.zyl` | Workspaces |
| `mvs.zyl` | Minimal Version Selection |
| `lock.zyl` | `zyl.lock` |
| `index.zyl` | The package index and Ed25519 verification |
| `store.zyl` | The content store and canonical archives |
| `cli.zyl` | The `zyl` subcommands and linking |
| `doc.zyl` | Markdown from source comments (`zyl doc`) |

## B.12 Finding Stdlib Source

All stdlib source is in `stdlib/`:

```
stdlib/
├── core/          core.zyl, option.zyl, result.zyl, list.zyl, map.zyl
├── collections/   collections.zyl, vec.zyl, map.zyl, set.zyl, slice.zyl
├── text/          view.zyl
├── actor/         actor.zyl
├── atomic/        atomic.zyl
├── allocator/     allocator.zyl
├── ffi/           ffi.zyl
├── io/            io.zyl
├── testing/       testing.zyl, test_test_harness.zyl
├── math/          bits.zyl, words.zyl, math.zyl
│   ├── secret/, bignum/, rand/, hash/
│   └── crypto/{symmetric,asymmetric,kdf}/
├── repl/          *.zyl
├── lsp/           *.zyl, services/*.zyl
├── mlib/          deep.zyl (a code-generation stress fixture)
└── compiler/      *.zyl (41 files)
```

The compiler resolves stdlib modules against its own bundle directory —
`build/boot/stdlib/` for a build tree, `~/.zyl/stdlib/` (or
`$ZYL_HOME/stdlib/`) for an installed one — and your own modules
against your source file's directory or package. If a `use` of a
stdlib module is reported as `E_MODULE_NOT_FOUND`, check that the
bundle directory's `stdlib/` is present and current.
