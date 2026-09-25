# FFI signature draft: typed signatures for the `zyl_*` runtime surface

Status: draft for sound types phase 2, the "primitive surface" in
`docs/sound-types-design.md`. This is a survey, not an implementation.

Snapshot: HEAD `fa904ba`. The use counts were taken at `52566e0` and
re-checked at `fa904ba`; they are identical. The repository moved while
this survey ran:
- `5c3f0e9` added `stdlib/compiler/ffi_sigs.zyl`, whose `ffi-sig` table
  (strict mode only) holds 5 signatures: `zyl_panic`, `zyl_cstr_len`,
  `zyl_cstr_byte_at`, `zyl_cstr_eq` and `zyl_int_text`. All five match
  this draft. The type column below is written in that table's syntax
  (`"String Int -> Int"`, `"(SMap v)"`, lowercase = shared type
  variable), so rows can be copied in as they are.
- `fa904ba` made `str-eq` a Bool predicate, rewriting its
  `(> (str-eq ..) 0)` call sites. Direct `ffi-call` sites that still
  compare a 0/1 result with 0 are noted per symbol.

Line numbers in `stdlib/compiler/type_annotate.zyl` shift with those
commits, so they are given as approximate (~) next to stable function
names.

## Scope and method

- **What was counted.** Every `(ffi-call "<sym>" ...)` in `*.zyl` under
  `stdlib/`, `selfhost/`, `tools/`, `tests/` and `book/`, skipping
  `archive/` and `.claude/`. There are 168 distinct names in the symbol
  position:
  - 160 `zyl_*` names, used 814 times in total.
  - 5 libc names used only by tests: `abs`, `puts`, `qsort`, `snprintf`
    and `usleep`.
  - 3 false positives from comments (`"sym"`, `"name"`, `"symbol"`).
  - No `ffi-call` spans lines, and no match sits inside a comment.
- **`ffi_*` symbols.** None is called through `ffi-call`. Two, `ffi_pin`
  and `ffi_unpin`, are emitted by lowering as
  `IFfi` (`stdlib/compiler/icnf.zyl:566-567`), so they are not part of
  this surface.
- **Symbols outside the runtime.** Of the 160 `zyl_*` names, 158 are
  defined in `runtime/actor_runtime.c`. The other two:
  - `zyl_abs` is not defined anywhere. It appears only in
    `tests/compile-fail/secret-ffi-unpinned.zyl:9`, which is rejected
    before linking.
  - `zyl_native_double` is the test package's own C
    (`tests/packages-build/native/app/c/fast.c:5`).
- **Removing the timeout.** The trailing timeout argument is not part of
  any signature below.
- **C prototypes.** They are abbreviated with `ll` = `long long`. The
  number after the colon is the line in `runtime/actor_runtime.c`. Every
  C parameter and result is one 64-bit word, and `zyl_panic` takes
  `const char*`.

### Type vocabulary used below

| type | meaning |
|---|---|
| `Int`, `Float`, `Bool`, `String`, `Unit` | As in the design doc. `Float` is the IEEE bit pattern in a word. `Bool` is used only where the C function returns exactly 0/1 **and** every caller uses the result as a condition. Today callers write `(> r 0)`, `(= r 0)` or `(== r 1)`, and those comparisons become the Bool itself. |
| `a` | Only for a result that never returns (`zyl_panic`). |
| `Arena` | Opaque arena handle (`ZylArena*`, `actor_runtime.c:1437`). |
| `Ptr` | Raw address. It can only be handed back to C or to `alloc-*`. |
| `Words` | A word array in `math/words` layout, one value per 8-byte word (`stdlib/math/words.zyl:30-41`). This is the design doc's runtime `(Array Int)`. |
| `StrBuf` | A fixed-capacity, NUL-terminated text buffer that is appended in place (`zyl_str_append*`). It is read back as a String once complete. |
| `(SMap v)` | String-keyed hash map whose values have type `v` (`actor_runtime.c:1802-1860`). |
| `(WVec v)` | Growable vector whose elements have type `v` (`actor_runtime.c:1864-1912`). |
| `(Attr k v)` | Node-address-keyed side table (`actor_runtime.c:1692-1791`). `k` is the node type (`Expr` or `Icnf`). |
| `UF` | Union-find class id (`actor_runtime.c:1732-1784`). It needs `uf-id : UF -> Int`, because `region_inference.zyl:666` orders class ids numerically. |
| `(Cell a)` | Typed mutable global cell, replacing `zyl_cell_*`. |
| `Actor` | Actor id (an index into `g_system.actors`, `actor_runtime.c:2932`). |
| `Fd` | File descriptor. |
| `FileId` | Index into the runtime source registry (`actor_runtime.c:2105-2123`). |
| `FnPtr` | A C code address, from `zyl_ffi_lookup`. |
| `Boxed n =>` | Constraint: `n` is a heap-allocated ADT or struct type. The span table keys on the node's address (`actor_runtime.c:1620-1666`). `zyl_variant_eq`/`zyl_variant_cmp` read the hidden size word at `p-8` (`actor_runtime.c:2542`), so an unboxed Int argument crashes them. |

Tags in the notes column:
- **[clean]**: expressible with primitive types (and `a` for `zyl_panic`).
- **[handle]**: needs one of the opaque handle types or the `Boxed`
  constraint.
- **[ESCAPE]**: the honest type is "any word". A sound checker must remove
  these; see the escape-hatch section below.
- **[sentinel]**: 0 or -1 means "absent". See the sentinel section below.

## Signature table

| symbol | uses | C prototype | proposed Zyl type | notes/flags |
|---|---|---|---|---|
| zyl_abs | 1 | (not defined) | n/a | Only `tests/compile-fail/secret-ffi-unpinned.zyl:9`, which is rejected by `E_FFI_PIN_REQUIRED` before linking. With a signature table this call would be an unknown-symbol error, so the test needs a real symbol such as `zyl_cstr_len`. |
| zyl_actor_is_alive | 1 | `ll zyl_actor_is_alive(ll actor_id)` :2931 | `Actor -> Bool` | [handle] `stdlib/actor/actor.zyl:38` uses `(== r 1)`. |
| zyl_actor_terminate | 1 | `void zyl_actor_terminate(ll actor_id)` :2942 | `Actor -> Unit` | [handle] The C function returns `void`, but `actor-terminate` (`actor.zyl:48`) returns the call's value, which is a garbage `rax`. Unit makes that unusable. |
| zyl_actor_wait | 1 | `void zyl_actor_wait(ll actor_id)` :2961 | `Actor -> Unit` | [handle] `void`; same garbage-`rax` issue at `actor.zyl:43`. |
| zyl_aes_encrypt_block | 1 | `ll zyl_aes_encrypt_block(ll keybase, ll keybytes, ll inbase, ll outbase)` :2759 | `Words Int Words Words -> Bool` | [handle] The key, input and output are word arrays with one byte per word (`actor_runtime.c:2765-2771`). Returns 1 on success, 0 when AES-NI is missing or the key length is bad. `stdlib/math/crypto/symmetric/aesgcm.zyl:50` tests `(= r 1)`. |
| zyl_aesni_available | 1 | `ll zyl_aesni_available(void)` :2653 | `-> Bool` | [clean] `aes-available` is documented as "Returns: Int", but its callers test `(= .. 0)` (`tests/regression/math-aesgcm.zyl:18`). |
| zyl_arena_alloc | 1 | `ll zyl_arena_alloc(ll arena, ll size)` :1456 | `Arena Int -> Ptr` | [handle][sentinel] Returns 0 on bad size or out of memory. |
| zyl_arena_alloc_zeroed | 1 | `ll zyl_arena_alloc_zeroed(ll arena, ll size)` :1473 | `Arena Int -> Ptr` | [handle][sentinel] Returns 0 on failure. Most `Ptr`s in the tree come from here through `w-alloc` or `arena-alloc-zeroed`, and are then reinterpreted as `Words`, `StrBuf` or String. |
| zyl_arena_capacity | 1 | `ll zyl_arena_capacity(ll arena)` :1545 | `Arena -> Int` | [handle] |
| zyl_arena_create | 1 | `ll zyl_arena_create(ll block_size)` :1437 | `Int -> Arena` | [handle][sentinel] Returns 0 on malloc failure. It should panic rather than return an Option. |
| zyl_arena_destroy | 1 | `void zyl_arena_destroy(ll arena)` :1518 | `Arena -> Unit` | [handle] `void`, but `arena-destroy` returns it (`stdlib/allocator/allocator.zyl:116`). |
| zyl_arena_reset | 1 | `void zyl_arena_reset(ll arena)` :1494 | `Arena -> Unit` | [handle] `void`, but `arena-reset` returns it (`allocator.zyl:111`). |
| zyl_arena_used | 1 | `ll zyl_arena_used(ll arena)` :1536 | `Arena -> Int` | [handle] |
| zyl_argc | 7 | `ll zyl_argc(void)` :3230 | `-> Int` | [clean] |
| zyl_arg_str | 13 | `ll zyl_arg_str(ll i)` :3234 | `Int -> String` | [clean][sentinel] Returns 0 when out of range. Callers guard with `zyl_argc` (`selfhost/driver.zyl:260`, `stdlib/compiler/cli.zyl:579-582`), but `lock.zyl:358` and `sexp_balance.zyl:399` do not. Proposed shape: `Int String -> String` with a default, or `Option String`. |
| zyl_atomic_add | 1 | `ll zyl_atomic_add(ll addr, ll value)` :2884 | `Ptr Int -> Int` | [handle] Returns the new value. An `(Atomic)` handle would be better than a bare `Ptr` (`stdlib/atomic/atomic.zyl:5`). |
| zyl_atomic_cas | 1 | `ll zyl_atomic_cas(ll addr, ll expected, ll new_value)` :2916 | `Ptr Int Int -> Bool` | [handle] `atomic.zyl:69` uses `(== r 1)`. |
| zyl_atomic_fetch_add | 1 | `ll zyl_atomic_fetch_add(ll addr, ll value)` :2923 | `Ptr Int -> Int` | [handle] Returns the old value. |
| zyl_atomic_load | 1 | `ll zyl_atomic_load(ll addr)` :2875 | `Ptr -> Int` | [handle] |
| zyl_atomic_max | 1 | `ll zyl_atomic_max(ll addr, ll value)` :2892 | `Ptr Int -> Int` | [handle] |
| zyl_atomic_min | 1 | `ll zyl_atomic_min(ll addr, ll value)` :2904 | `Ptr Int -> Int` | [handle] |
| zyl_atomic_store | 1 | `ll zyl_atomic_store(ll addr, ll value)` :2879 | `Ptr Int -> Int` | [handle] Returns `value`. |
| zyl_atomic_sub | 1 | `ll zyl_atomic_sub(ll addr, ll value)` :2888 | `Ptr Int -> Int` | [handle] |
| zyl_attr_clear | 6 | `ll zyl_attr_clear(ll t)` :1717 | today `Int -> Unit`; typed `(Attr k v) -> Unit` | [ESCAPE] The table index `t` (0..5) determines key and value types. See "Global handle indexes". |
| zyl_attr_copy | 1 | `ll zyl_attr_copy(ll t, ll dst, ll src)` :1787 | `(Attr k v) k k -> Unit` | [ESCAPE] Indexed by table number. Only `icnf.zyl:458` calls it, on table 1. |
| zyl_attr_get | 12 | `ll zyl_attr_get(ll t, ll node)` :1705 | `(Attr k v) k v -> v` (with a default) | [ESCAPE][sentinel] Returns 0 when absent. The value type depends on the table index: `TaTy`, Int or String. |
| zyl_attr_set | 8 | `ll zyl_attr_set(ll t, ll node, ll val)` :1692 | `(Attr k v) k v -> Unit` | [ESCAPE] `type_annotate.zyl` `ta-set-name` (~2168) even takes the table number as a parameter (2 or 3). |
| zyl_blake3_file_hex | 5 | `ll zyl_blake3_file_hex(ll arena, ll path, ll outbytes)` :3791 | `Arena String Int -> Option String` (or `-> String` plus an error) | [handle][sentinel] Returns 0 when the file cannot be opened. `lock.zyl:360` checks `(> h 0)`. `store.zyl:179`, `store.zyl:301`, `driver.zyl:395` and `driver.zyl:453` do not; they concatenate the result, and `zyl_cstr_concat` quietly treats 0 as "" (`actor_runtime.c:688-689`). |
| zyl_blake3_hex | 6 | `ll zyl_blake3_hex(ll arena, ll src, ll len, ll outbytes)` :3771 | `Arena String Int Int -> String` | [handle] All 6 callers pass `len = -1` (strlen) and 32 bytes (`lock.zyl:324`, `driver.zyl:378`, `driver.zyl:388`, `driver.zyl:437`, `driver.zyl:439`, `driver.zyl:471`). The signature could shrink to `Arena String -> String`. |
| zyl_call_argv | 1 | `ll zyl_call_argv(ll fn, ll argc, ll argv)` :4597 | `FnPtr Int Ptr -> <word>` | [ESCAPE] Calls a foreign address with raw words and returns a raw word (`stdlib/repl/interp.zyl:834`). |
| zyl_cell_get | 3 | `ll zyl_cell_get(ll i)` :4920 | `Int -> <word>` | [ESCAPE] Cell 0 holds an Int; cell 1 holds an `Expr` or 0. See "Global handle indexes". |
| zyl_cell_set | 5 | `ll zyl_cell_set(ll i, ll v)` :4921 | `Int <word> -> Unit` | [ESCAPE] |
| zyl_chdir | 3 | `ll zyl_chdir(ll path)` :3363 | `String -> Int` | [clean] Returns 0 or -1. The result is always ignored (`driver.zyl:200`, `driver.zyl:629`, `repl.zyl:674`). |
| zyl_cstr_byte_at | 84 | `ll zyl_cstr_byte_at(ll ptr, ll i)` :777 | `String Int -> Int` | [clean][sentinel] Returns -1 past the end, which is the lexer's end-of-input test. Int is correct here, not Option. |
| zyl_cstr_cmp | 1 | `ll zyl_cstr_cmp(ll p1, ll p2)` :746 | `String String -> Int` | [clean] Returns -1, 0 or 1. The only caller is `interp.zyl:378`, which passes `val-word`s (Ints, because `VStr` holds an Int, `interp.zyl:58`). |
| zyl_cstr_concat | 1 | `ll zyl_cstr_concat(ll a, ll b)` :686 | `String String -> String` | [clean] Treats 0 as "" (:688-689), which hides upstream sentinels. Typed as String by the type pass already (`ta-ffi-str`, `type_annotate.zyl` ~1237). |
| zyl_cstr_decode | 1 | `ll zyl_cstr_decode(ll arena, ll src, ll start, ll end)` :1218 | `Arena String Int Int -> Option String` | [handle][sentinel] Returns 0 on an invalid or unterminated escape (:1248-1250). `lexer.zyl:324` stores the result unchecked in `TkString`. |
| zyl_cstr_eq | 12 | `ll zyl_cstr_eq(ll p1, ll p2)` :722 | `String String -> Bool` | [clean] Already in `ffi_sigs.zyl`. `str-eq` (`allocator.zyl:163`) returns it as Bool since `fa904ba`. Direct call sites still compare it with 0 (`icnf.zyl:1124`) or use it as a value (`icnf.zyl:1167`). At `interp.zyl:376` the result becomes a `VInt`, the interpreter's Bool representation. |
| zyl_cstr_from_byte | 1 | `ll zyl_cstr_from_byte(ll b)` :4129 | `Int -> String` | [clean] |
| zyl_cstr_from_int | 5 | `ll zyl_cstr_from_int(ll arena, ll value)` :1178 | `Arena Int -> String` | [handle] Same as `zyl_int_text`, but arena-allocated. |
| zyl_cstr_key_matches | 7 | `ll zyl_cstr_key_matches(ll key, ll name)` :733 | `String String -> Bool` | [clean] Callers use `(> r 0)` (`derive.zyl:71`, `type_inference.zyl:24`, ...). |
| zyl_cstr_len | 18 | `ll zyl_cstr_len(ll ptr)` :678 | `String -> Int` | [clean] |
| zyl_cstr_of_word | 6 | `ll zyl_cstr_of_word(ll w)` :4440 | `Int -> a` (identity) | [ESCAPE] An unchecked coerce. Callers: `collections/vec.zyl:13`, `core/show.zyl:54`, `compiler/derive.zyl:186`, `compiler/secret_check.zyl:158`, `repl/interp.zyl:229`, `repl/interp.zyl:667`. |
| zyl_cstr_sanitize | 3 | `ll zyl_cstr_sanitize(ll arena, ll src)` :1190 | `Arena String -> String` | [handle] |
| zyl_cstr_sub | 1 | `ll zyl_cstr_sub(ll arena, ll src, ll start, ll len)` :794 | `Arena String Int Int -> String` | [handle][sentinel] Returns 0 on negative arguments. `lexer.zyl:381` passes checked ranges. |
| zyl_cstr_substr | 4 | `ll zyl_cstr_substr(ll src, ll start, ll len)` :706 | `String Int Int -> String` | [clean] Clamps its range. |
| zyl_cstr_to_int | 6 | `ll zyl_cstr_to_int(ll ptr)` :808 | `String -> Int` | [clean] Returns 0 on overflow, with `errno` set. |
| zyl_cstr_to_int_base | 1 | `ll zyl_cstr_to_int_base(ll ptr)` :839 | `String -> Int` | [clean] |
| zyl_diag_json | 1 | `ll zyl_diag_json(void)` :3286 | `-> Bool` | [clean] `error_report.zyl:178` uses `(> r 0)`. |
| zyl_diag_json_set | 1 | `ll zyl_diag_json_set(ll on)` :3290 | `Bool -> Unit` | [clean] `driver.zyl:605` passes 1. |
| zyl_dirname_cstr | 8 | `ll zyl_dirname_cstr(ll path)` :3239 | `String -> String` | [clean][sentinel] Returns 0 for a null path. **Lifetime:** the result is a thread-local static buffer, valid only until the next call (:3253-3259). `workspace.zyl:47` and `driver.zyl:277` recurse and feed the buffer back in as `path` (a `memcpy` with src == dst). A typed API should return a fresh String. |
| zyl_err_is | 3 | `ll zyl_err_is(ll msg, ll code)` :2053 | `String String -> Bool` | [clean] Only tests use it. `with-region-limits.zyl:33` compares it with `assert-equal .. 1`, which would become `(assert-true ..)`. |
| zyl_exec_cmd | 1 | `ll zyl_exec_cmd(ll cmd)` :3399 | `String -> Int` | [clean] `execl` replaces the process, so the function returns only on failure (-1). Not `a`, because it can return. |
| zyl_f_add | 1 | `ll zyl_f_add(ll a, ll b)` :4838 | `Float Float -> Float` | [clean] Interpreter only (`interp.zyl:401`). |
| zyl_f_cmp | 1 | `ll zyl_f_cmp(ll a, ll b)` :4855 | `Float Float -> Int` | [clean] Returns -1, 0 or 1, and 2 for unordered (NaN). |
| zyl_f_div | 1 | `ll zyl_f_div(ll a, ll b)` :4841 | `Float Float -> Float` | [clean] |
| zyl_ffi_lookup | 2 | `ll zyl_ffi_lookup(ll name)` :4569 | `String -> Option FnPtr` | [handle][sentinel] Returns 0 when the symbol is not found (`interp.zyl:830-833`). `interp.zyl:275` wraps it as `VInt`. |
| zyl_ffi_timed_argv | 1 | `ll zyl_ffi_timed_argv(ll fn, ll name, ll ms, ll argc, ll argv)` :4808 | `FnPtr String Int Int Ptr -> <word>` | [ESCAPE] The interpreter's foreign-call bridge (`interp.zyl:764`). Every argument arrives as a `val-word`. |
| zyl_f_mul | 1 | `ll zyl_f_mul(ll a, ll b)` :4840 | `Float Float -> Float` | [clean] |
| zyl_fnmap_get | 1 | `ll zyl_fnmap_get(ll name)` :4313 | `String -> <word>`; typed `String -> Option Icnf` | [ESCAPE][sentinel] It stores IFn nodes as words. `interp.zyl:196-199` converts back with `zyl_cstr_of_word`. |
| zyl_fnmap_put | 1 | `ll zyl_fnmap_put(ll name, ll value)` :4296 | `String <word> -> Bool`; typed `String Icnf -> Bool` | [ESCAPE] `interp.zyl:220-226` casts the node with `zyl_word_of_cstr`. It keeps the `name` pointer without copying it (:4303), so the name must outlive the map. |
| zyl_fnmap_reset | 1 | `ll zyl_fnmap_reset(void)` :4288 | `-> Unit` | [clean] |
| zyl_f_of_int | 1 | `ll zyl_f_of_int(ll n)` :4863 | `Int -> Float` | [clean] |
| zyl_f_parse | 1 | `ll zyl_f_parse(ll text)` :4832 | `String -> Float` | [clean] |
| zyl_f_rem | 1 | `ll zyl_f_rem(ll a, ll b)` :4845 | `Float Float -> Float` | [clean] |
| zyl_fresh_id | 1 | `ll zyl_fresh_id(void)` :4432 | `-> Int` | [clean] A process-global counter (`icnf.zyl:678`). |
| zyl_f_sub | 1 | `ll zyl_f_sub(ll a, ll b)` :4839 | `Float Float -> Float` | [clean] |
| zyl_f_text | 3 | `ll zyl_f_text(ll bits)` :4867 | `Float -> String` | [clean] `core/show.zyl:31`, `core/show.zyl:36`, `interp.zyl:935`. |
| zyl_getcwd | 4 | `ll zyl_getcwd(void)` :3367 | `-> String` | [clean][sentinel] Returns 0 on failure. It shares the thread-local-buffer lifetime problem of `zyl_dirname_cstr` (:3368). `repl.zyl:671` copies it with `(str-concat dir "")`; `driver.zyl:187` and `driver.zyl:626` do not. |
| zyl_getenv | 15 | `ll zyl_getenv(ll name)` :3277 | `String -> Option String` (or `String String -> String` with a default) | [clean][sentinel] Returns 0 when unset. Callers write `(if (> h 0) h default)`, comparing a String with 0 (`repl/history.zyl:25`, `history.zyl:33`, `history.zyl:37`, `store.zyl:37-40`, `driver.zyl:172-175`, `type_annotate.zyl` ~1730). |
| zyl_global_clear | 1 | `ll zyl_global_clear(void)` :2067 | `-> Unit` | [clean] |
| zyl_heap_alloc | 2 | `ll zyl_heap_alloc(ll size)` :2248 | `Int -> Ptr` | [handle][sentinel] Returns 0 on failure. The interpreter builds cells and argv blocks with it (`interp.zyl:93`, `interp.zyl:840`). |
| zyl_heap_block_p | 1 | `ll zyl_heap_block_p(ll w)` :4214 | `<word> -> Bool` | [ESCAPE] It exists to ask whether an untyped word is a heap pointer (`interp.zyl:163-168`). Only the interpreter needs it; in a typed program the answer is static. |
| zyl_heap_swap | 1 | `ll zyl_heap_swap(ll arena)` :4173 | `Arena -> Arena` | [handle] Passing 0 queries without swapping. Proposed shape: `Option Arena -> Arena`. |
| zyl_intern_name | 2 | `ll zyl_intern_name(ll s)` :4400 | `String -> String` | [clean][sentinel] Returns 0 when the table is half full (:4407). |
| zyl_int_text | 28 | `ll zyl_int_text(ll n)` :4444 | `Int -> String` | [clean] |
| zyl_itest_add | 1 | `ll zyl_itest_add(ll name, ll fn)` :4232 | `String <word> -> Int` | [ESCAPE] `fn` is an interpreter function block (`interp.zyl:787`), and `name` arrives as a `val-word`. Returns -1 when full. |
| zyl_itest_count | 1 | `ll zyl_itest_count(void)` :4239 | `-> Int` | [clean] |
| zyl_itest_fn | 1 | `ll zyl_itest_fn(ll i)` :4244 | `Int -> <word>` | [ESCAPE][sentinel] `interp.zyl:815` wraps the word as `VPtr`. |
| zyl_itest_name | 1 | `ll zyl_itest_name(ll i)` :4240 | `Int -> String` | [clean][sentinel] Returns 0 when out of range. |
| zyl_itest_outcome | 1 | `ll zyl_itest_outcome(ll ok)` :4258 | `Bool -> Unit` | [clean] |
| zyl_itest_reset | 1 | `ll zyl_itest_reset(void)` :4248 | `-> Unit` | [clean] |
| zyl_itest_start | 1 | `ll zyl_itest_start(ll name)` :4252 | `String -> Unit` | [clean] |
| zyl_itest_summary | 1 | `ll zyl_itest_summary(ll passed, ll failed)` :4263 | `Int Int -> Int` | [clean] Returns the exit code, 0 or 1. The result is ignored at `interp.zyl:802`. |
| zyl_json_quote | 6 | `ll zyl_json_quote(ll s)` :3342 | `String -> String` | [clean] |
| zyl_list_files | 1 | `ll zyl_list_files(ll dir, ll suffixes)` :2020 | `String String -> String` | [clean][sentinel] Returns sorted paths joined with newlines, or 0 on allocation failure (:2031). `(List String)` would be better; `driver.zyl:387` splits the text by hand. |
| zyl_list_zyl_files | 1 | `ll zyl_list_zyl_files(ll dir)` :2013 | `String -> String` | [clean][sentinel] Same as `zyl_list_files` (`doc.zyl:42`). |
| zyl_mangle_key | 2 | `ll zyl_mangle_key(ll arena, ll key)` :3869 | `Arena String -> String` | [handle][sentinel] Returns 0 on a null key or malloc failure. |
| zyl_mem_alloc | 1 | `ll zyl_mem_alloc(ll size)` :753 | `Int -> Ptr` | [handle][sentinel] malloc; 0 on failure. |
| zyl_mem_free | 1 | `void zyl_mem_free(ll ptr)` :757 | `Ptr -> Unit` | [handle] `void`. |
| zyl_mem_read | 2 | `ll zyl_mem_read(ll ptr)` :761 | `Ptr -> Int` | [ESCAPE at one site] `allocator.zyl:30` (Int) is honest. `compiler/qualify.zyl:101` reads **Strings** back out of a word table ("The table's words hold Strings", `qualify.zyl:100`). |
| zyl_mem_write | 2 | `ll zyl_mem_write(ll ptr, ll value)` :766 | `Ptr Int -> Int` | [ESCAPE at one site] `qualify.zyl:102` stores Strings (`qualify.zyl:120-121`). |
| zyl_mkdir_p | 1 | `ll zyl_mkdir_p(ll path)` :4107 | `String -> Int` | [clean] Returns 0 or -1. The result is ignored at `history.zyl:86`. |
| zyl_native_double | 1 | (test package C, `fast.c:5`) | `Int -> Int` | [clean] Not runtime: it belongs to a package-native dependency, so an `extern` declaration fits better than an entry in the runtime table. |
| zyl_now_ms | 2 | `ll zyl_now_ms(void)` :4426 | `-> Int` | [clean] Non-deterministic (monotonic clock). Only REPL timing uses it (`repl.zyl:457-459`), and it should stay out of compiled programs. |
| zyl_panic | 142 | `void zyl_panic(const char* msg)` :3039 | `String -> a` | [clean] Never returns: it longjmps or exits. |
| zyl_path_exists | 17 | `ll zyl_path_exists(ll path)` :3266 | `String -> Bool` | [clean] Every caller tests it against 0. |
| zyl_print_float | 1 | `ll zyl_print_float(ll bits)` :4878 | `Float -> Unit` | [clean] |
| zyl_print_int | 2 | `ll zyl_print_int(ll n)` :4876 | `Int -> Unit` | [clean] `interp.zyl:865` also prints a `VPtr` address with it. |
| zyl_print_str | 1 | `ll zyl_print_str(ll s)` :4877 | `String -> Unit` | [clean] `interp.zyl:864` passes a `VStr`'s Int word. |
| zyl_random_fill | 1 | `ll zyl_random_fill(ll addr, ll len)` :2829 | `Ptr Int -> Int` (a **byte** buffer) | [handle] Returns `len` or -1. **Bug at `cli.zyl:529-532`:** see "Findings". It needs a byte-buffer type distinct from `Words`. |
| zyl_random_words | 1 | `ll zyl_random_words(ll base, ll n)` :2810 | `Words Int -> Int` | [handle] Writes one random byte per word. Returns `n` or -1 (`math/rand/crypto.zyl:29`). |
| zyl_region_live_bytes | 5 | `ll zyl_region_live_bytes(void)` :2531 | `-> Int` | [clean] Tests only. |
| zyl_regions_enabled | 1 | `ll zyl_regions_enabled(void)` :4893 | `-> Bool` | [clean] `region_inference.zyl:689` uses `(> r 0)`. |
| zyl_repl_global_set | 1 | `ll zyl_repl_global_set(ll name, ll word)` :2075 | `String <word> -> Unit` | [ESCAPE] Stores a REPL `def` value of any type (`repl/eval.zyl:475`, via `val-word`). |
| zyl_run_bin | 1 | `ll zyl_run_bin(ll path)` :3497 | `String -> Int` | [clean] Returns the exit status or -1. |
| zyl_session_arena | 1 | `ll zyl_session_arena(void)` :4181 | `-> Arena` | [handle] |
| zyl_smap_clear | 7 | `ll zyl_smap_clear(ll mh)` :1853 | `(SMap v) -> Unit` | [handle] |
| zyl_smap_get | 22 | `ll zyl_smap_get(ll mh, ll key)` :1841 | `(SMap v) String v -> v` (with a default) or `(SMap v) String -> Option v` | [handle][sentinel] Returns 0 when absent. Callers rely on 0 as "absent" and also store `count+1` or `packed+1` to keep a real 0 distinguishable (`region_inference.zyl:255-257`, `derive.zyl:41-43`). |
| zyl_smap_global | 20 | `ll zyl_smap_global(ll i)` :1925 | `Int -> (SMap ?)` | [ESCAPE] Maps 0..7 hold different value types, and maps 3, 4 and 5 mix value types **within one map**. See "Global handle indexes". |
| zyl_smap_new | 6 | `ll zyl_smap_new(void)` :1802 | `-> (SMap v)` | [handle] Returns 0 on calloc failure (unchecked). |
| zyl_smap_put | 12 | `ll zyl_smap_put(ll mh, ll key, ll val)` :1823 | `(SMap v) String v -> Unit` | [handle] |
| zyl_source_path | 3 | `ll zyl_source_path(ll fid)` :2120 | `FileId -> String` | [handle] Returns `"<input>"` for an unknown id. |
| zyl_source_register | 2 | `ll zyl_source_register(ll path, ll text)` :2105 | `String String -> FileId` | [handle][sentinel] Returns -1 when the table is full (`ZYL_MAX_SRC_FILES`). |
| zyl_span_col | 3 | `ll zyl_span_col(ll fid, ll off)` :2136 | `FileId Int -> Int` | [handle] Returns 0 when unknown. |
| zyl_span_copy | 21 | `ll zyl_span_copy(ll dst, ll src)` :1661 | `Boxed n, Boxed m => n m -> Unit` | [handle] `dst` and `src` are Ast, Expr or Icnf nodes, often of different types (`icnf.zyl:443` copies Expr to Icnf). |
| zyl_span_file | 27 | `ll zyl_span_file(ll node)` :1651 | `Boxed n => n -> FileId` | [handle][sentinel] Returns -1 when the node has no span. `Option FileId`, or a `Span` record returned together with the offset (the two are always read in pairs). |
| zyl_span_line | 6 | `ll zyl_span_line(ll fid, ll off)` :2126 | `FileId Int -> Int` | [handle] Returns 0 when unknown (`error_report.zyl:195` tests `<= 0`). |
| zyl_span_off | 27 | `ll zyl_span_off(ll node)` :1646 | `Boxed n => n -> Int` | [handle][sentinel] Returns -1 when absent (`region_inference.zyl:670` tests `>= 0`). Always paired with `zyl_span_file`; proposed shape: `n -> Option Span`. |
| zyl_span_offset_at | 1 | `ll zyl_span_offset_at(ll fid, ll line, ll col)` :2212 | `FileId Int Int -> Int` | [handle][sentinel] Returns -1 when out of range. |
| zyl_span_set | 1 | `ll zyl_span_set(ll node, ll off, ll fid)` :1620 | `Boxed n => n Int FileId -> Unit` | [handle] `parser.zyl:99`. |
| zyl_span_snippet | 2 | `ll zyl_span_snippet(ll fid, ll off)` :2187 | `FileId Int -> String` | [handle] Returns "" on failure. The buffer is malloc'd and never freed. |
| zyl_span_snippet_col | 2 | `ll zyl_span_snippet_col(ll fid, ll off)` :2204 | `FileId Int -> Int` | [handle] |
| zyl_str_append | 1 | `ll zyl_str_append(ll dst, ll src)` :3208 | `StrBuf String -> StrBuf` | [handle] `buf-append` (`allocator.zyl:145`). Its callers build a `Ptr` with `arena-alloc-zeroed` and then return it as a String: `str-intern` (`allocator.zyl:185-190`) and `cg-label-new` (`codegen.zyl:187-192`). A typed API needs `strbuf-new : Arena Int -> StrBuf` and `strbuf-text : StrBuf -> String`. |
| zyl_str_append_capped | 4 | `ll zyl_str_append_capped(ll dst, ll src, ll cap)` :3216 | `StrBuf String Int -> StrBuf` | [handle] Callers: `codegen.zyl:170`, `codegen.zyl:176`, `icnf_print.zyl:22`, `doc.zyl:23`. The buffer is returned as a String (`icnf_print.zyl:16-20`, `doc.zyl:26-34`). If the capacity lived in the `StrBuf` handle, the `cap` argument could go. |
| zyl_system_cmd | 4 | `ll zyl_system_cmd(ll cmd)` :3388 | `String -> Int` | [clean] Returns the exit status or -1. |
| zyl_term_flush | 1 | `ll zyl_term_flush(void)` :4100 | `-> Unit` | [clean] |
| zyl_term_height | 1 | `ll zyl_term_height(void)` :4072 | `-> Int` | [clean] |
| zyl_term_is_tty | 1 | `ll zyl_term_is_tty(ll fd)` :3992 | `Fd -> Bool` | [handle] `repl.zyl:54` uses `(= r 1)`. |
| zyl_term_raw_off | 1 | `ll zyl_term_raw_off(void)` :4025 | `-> Int` | [clean] Returns 0 or -1. |
| zyl_term_raw_on | 1 | `ll zyl_term_raw_on(void)` :4006 | `-> Int` | [clean] Returns 0 or -1. |
| zyl_term_read_byte | 1 | `ll zyl_term_read_byte(void)` :4036 | `-> Int` | [clean][sentinel] Returns a byte, -1 on EOF or error, or -2 on EINTR. An ADT such as `(Byte n) EOF Intr Timeout` would be more honest. |
| zyl_term_read_byte_timeout | 3 | `ll zyl_term_read_byte_timeout(ll ms)` :4051 | `Int -> Int` | [clean][sentinel] Adds -3 for a timeout. |
| zyl_term_width | 1 | `ll zyl_term_width(void)` :4065 | `-> Int` | [clean] |
| zyl_term_write | 1 | `ll zyl_term_write(ll s)` :4083 | `String -> Int` | [clean] Returns the bytes written. |
| zyl_uf_find | 1 | `ll zyl_uf_find(ll a)` :1749 | `UF -> UF` | [handle] |
| zyl_uf_level | 1 | `ll zyl_uf_level(ll a)` :1780 | `UF -> Int` | [handle] Returns 2 for an out-of-range id. |
| zyl_uf_new | 1 | `ll zyl_uf_new(ll level)` :1734 | `Int -> UF` | [handle] |
| zyl_uf_raise | 1 | `ll zyl_uf_raise(ll a, ll level)` :1773 | `UF Int -> Unit` | [handle] |
| zyl_uf_reset | 1 | `ll zyl_uf_reset(void)` :1732 | `-> Unit` | [clean] Invalidates every live `UF`. That is safe only because region inference resets once per function (`region_inference.zyl:561`). |
| zyl_uf_union | 1 | `ll zyl_uf_union(ll a, ll b)` :1763 | `UF UF -> UF` | [handle] |
| zyl_val_alloc | 1 | `ll zyl_val_alloc(ll nwords, ll kinds, ll name)` :4340 | `Int Int String -> Ptr` | [ESCAPE] The interpreter forges ADT values from a kinds bitmap (`interp.zyl:136`); the resulting `Ptr` is then used as a value of any ADT. |
| zyl_val_arity | 1 | `ll zyl_val_arity(ll p)` :4379 | `<word> -> Int` | [ESCAPE] Reflection on an untyped block (`interp.zyl:987`). |
| zyl_val_kind | 1 | `ll zyl_val_kind(ll p, ll i)` :4357 | `<word> Int -> Int` | [ESCAPE] Returns a field-kind code 0..3 (`interp.zyl:612`). |
| zyl_val_name | 1 | `ll zyl_val_name(ll p)` :4369 | `<word> -> <word: String or 0>` | [ESCAPE][sentinel] `interp.zyl:980-983` casts the result to String with `zyl_cstr_of_word`. |
| zyl_variant_cmp | 1 | `ll zyl_variant_cmp(ll a, ll b)` :2559 | `Boxed a => a a -> Int` | [handle] Compares header words structurally. The only caller is `interp.zyl:348`, which passes raw words. |
| zyl_variant_eq | 2 | `ll zyl_variant_eq(ll a, ll b)` :2539 | `Boxed a => a a -> Bool` | [handle] `interp.zyl:346-347` passes `val-word`s. |
| zyl_warn_capture | 2 | `ll zyl_warn_capture(ll on)` :3301 | `Bool -> Unit` | [clean] |
| zyl_warn_emit | 5 | `ll zyl_warn_emit(ll msg)` :3307 | `String -> Unit` | [clean] |
| zyl_warn_take | 1 | `ll zyl_warn_take(void)` :3332 | `-> String` | [clean] |
| zyl_word_of_cstr | 2 | `ll zyl_word_of_cstr(ll s)` :4150 | `a -> Int` (identity) | [ESCAPE] `interp.zyl:74` converts String to Int, and `interp.zyl:226` converts an IFn node to Int. |
| zyl_wvec_get | 14 | `ll zyl_wvec_get(ll vh, ll i)` :1884 | `(WVec v) Int -> v` | [handle][sentinel] Returns 0 out of range; callers stay in range. A panicking bounds check would avoid needing a default. |
| zyl_wvec_global | 13 | `ll zyl_wvec_global(ll i)` :1919 | `Int -> (WVec ?)` | [ESCAPE] Vectors 0..7 differ in element type, and 0, 1, 2 and 7 are interleaved tuples or sentinel-encoded sums. See "Global handle indexes". |
| zyl_wvec_len | 7 | `ll zyl_wvec_len(ll vh)` :1897 | `(WVec v) -> Int` | [handle] |
| zyl_wvec_new | 17 | `ll zyl_wvec_new(void)` :1864 | `-> (WVec v)` | [handle] 16 of the 17 calls build `TaSt` (`type_annotate.zyl` `ta-st-new`, ~62-88), whose 26 fields are all declared `Int` (~31). |
| zyl_wvec_pop | 2 | `ll zyl_wvec_pop(ll vh)` :1902 | `(WVec v) -> v` | [handle][sentinel] Returns 0 when empty. |
| zyl_wvec_push | 13 | `ll zyl_wvec_push(ll vh, ll x)` :1870 | `(WVec v) v -> Int` | [handle] Returns the new index, or -1 on out of memory. `ta-fresh` uses the index as the type-variable id (`type_annotate.zyl` ~109). |
| zyl_wvec_set | 2 | `ll zyl_wvec_set(ll vh, ll i, ll x)` :1890 | `(WVec v) Int v -> Unit` | [handle] |
| zyl_wvec_truncate | 9 | `ll zyl_wvec_truncate(ll vh, ll n)` :1908 | `(WVec v) Int -> Unit` | [handle] |
| zyl_zeroize | 2 | `ll zyl_zeroize(ll addr, ll len)` :2860 | `Secret Int -> Int` | [handle] `math/secret/secret.zyl:150` and `secret.zyl:155` take a `Secret` base (a `Words` or byte address). Returns `len`. |

### libc symbols (tests only; these need `extern` declarations, not runtime entries)

| symbol | uses | where | proposed type |
|---|---|---|---|
| abs | 4 | `tests/regression/ffi-timeout.zyl:17`, `tests/regression/ffi-advanced.zyl:60`, `tests/compile-fail/ffi-missing-timeout.zyl:6`, `tests/compile-fail/ffi-zero-timeout.zyl:4` | `Int -> Int` |
| puts | 2 | `ffi-advanced.zyl:15`, `ffi-advanced.zyl:39` | `String -> Int` |
| qsort | 1 | `tests/regression/c-abi.zyl:34` | `Ptr Int Int FnPtr -> Unit`. The callback is a Zyl function (`_abi-cmp`), so `extern` needs a function-pointer parameter type. |
| snprintf | 2 | `ffi-timeout.zyl:24`, `c-abi.zyl:45` | Variadic, so no fixed arity. `extern` needs either a variadic tail or one declaration per test. |
| usleep | 2 | `ffi-timeout.zyl:7`, `ffi-timeout.zyl:20` | `Int -> Int` |

### Counts (the 158 symbols defined in `actor_runtime.c`)

| class | count | symbols (`zyl_` prefix dropped) |
|---|---|---|
| typed cleanly (primitive types only, plus `a` for `panic`) | **67** | `aesni_available`, `argc`, `arg_str`, `chdir`, `cstr_byte_at`, `cstr_cmp`, `cstr_concat`, `cstr_eq`, `cstr_from_byte`, `cstr_key_matches`, `cstr_len`, `cstr_substr`, `cstr_to_int`, `cstr_to_int_base`, `diag_json`, `diag_json_set`, `dirname_cstr`, `err_is`, `exec_cmd`, `f_add`, `f_cmp`, `f_div`, `f_mul`, `f_of_int`, `f_parse`, `f_rem`, `f_sub`, `f_text`, `fnmap_reset`, `fresh_id`, `getcwd`, `getenv`, `global_clear`, `intern_name`, `int_text`, `itest_count`, `itest_name`, `itest_outcome`, `itest_reset`, `itest_start`, `itest_summary`, `json_quote`, `list_files`, `list_zyl_files`, `mkdir_p`, `now_ms`, `panic`, `path_exists`, `print_float`, `print_int`, `print_str`, `region_live_bytes`, `regions_enabled`, `run_bin`, `system_cmd`, `term_flush`, `term_height`, `term_raw_off`, `term_raw_on`, `term_read_byte`, `term_read_byte_timeout`, `term_width`, `term_write`, `uf_reset`, `warn_capture`, `warn_emit`, `warn_take` |
| needs handle types (or the `Boxed` constraint) | **67** | `actor_is_alive`, `actor_terminate`, `actor_wait`, `aes_encrypt_block`, the 7 `arena_*`, the 8 `atomic_*`, `blake3_file_hex`, `blake3_hex`, `cstr_decode`, `cstr_from_int`, `cstr_sanitize`, `cstr_sub`, `ffi_lookup`, `heap_alloc`, `heap_swap`, `mangle_key`, `mem_alloc`, `mem_free`, `random_fill`, `random_words`, `session_arena`, `smap_clear`, `smap_get`, `smap_new`, `smap_put`, `source_path`, `source_register`, the 9 `span_*`, `str_append`, `str_append_capped`, `term_is_tty`, `uf_find`, `uf_level`, `uf_new`, `uf_raise`, `uf_union`, `variant_cmp`, `variant_eq`, `wvec_get`, `wvec_len`, `wvec_new`, `wvec_pop`, `wvec_push`, `wvec_set`, `wvec_truncate`, `zeroize` |
| escape hatches ("any word") | **24** | `cstr_of_word`, `word_of_cstr`; `smap_global`, `wvec_global`, `attr_get`, `attr_set`, `attr_copy`, `attr_clear`, `cell_get`, `cell_set`; `mem_read`\*, `mem_write`\*; `call_argv`, `ffi_timed_argv`, `fnmap_get`, `fnmap_put`, `itest_add`, `itest_fn`, `repl_global_set`, `heap_block_p`, `val_alloc`, `val_arity`, `val_kind`, `val_name` |

\* `mem_read` and `mem_write` have an honest `Ptr -> Int` type. They are
escapes only at `compiler/qualify.zyl:101-102`, where they carry Strings.
Once that site moves to `(Array QPair)`, they move to the handle row,
giving 67 / 69 / 22.

The 24 escapes fall into four groups:
- **Raw casts (2):** `cstr_of_word`, `word_of_cstr`.
- **Index-addressed compiler globals (8):** `smap_global`, `wvec_global`,
  the 4 `attr_*` and the 2 `cell_*`. The `attr_*` calls become handle-typed
  once they take a table handle instead of an index.
- **Raw memory carrying Strings (2):** `mem_read`, `mem_write`.
- **REPL interpreter bridges (12):** `call_argv`, `ffi_timed_argv`,
  `fnmap_get`, `fnmap_put`, `itest_add`, `itest_fn`, `repl_global_set`,
  `heap_block_p` and the 4 `val_*`.

Of the 67 handle-typed symbols, `smap_get`, `wvec_get`, `wvec_pop` and the
sentinel-returning allocators also need a default or `Option` (see
"Sentinel conventions" below).

## Findings

1. **The publisher key seed has 32 bits of entropy**
   (`stdlib/compiler/cli.zyl:527-533`).
   - `cli-generate-seed` allocates a **word** array with `(w-alloc arena 32)`,
     which is 32 zeroed 8-byte words (`math/words.zyl:30-31`).
   - It then calls `zyl_random_fill seed 32`, which fills 32 **bytes**,
     that is, words 0..3 only (`actor_runtime.c:2829-2851`).
   - It writes `(w-hex-bytes seed 32)`, which prints the low byte of each
     of the 32 words (`words.zyl:109-110`, `words.zyl:144-152`).
   - The resulting 64-hex-digit Ed25519 seed is 4 random bytes followed by
     28 zero bytes.

   The fix is `zyl_random_words` (one byte per word), as
   `math/rand/crypto.zyl:29` already does, and regenerating any keys made
   with the old code. This is exactly the confusion a `Words`-versus-
   byte-`Ptr` signature would reject.
2. **Results of C `void` functions are used as values.** These functions
   return `void`, and Zyl reads whatever is in `rax`:
   - `zyl_arena_reset`, returned by `arena-reset` (`allocator.zyl:111`)
   - `zyl_arena_destroy` (`allocator.zyl:116`)
   - `zyl_actor_wait` (`actor.zyl:43`)
   - `zyl_actor_terminate` (`actor.zyl:48`)
   - `zyl_mem_free`

   Typing them `Unit` closes the hole. So would making them return 0.
3. **An unchecked sentinel reaches the token stream.** `zyl_cstr_decode`
   returns 0 for an invalid escape (`actor_runtime.c:1248-1250`), and
   `lexer.zyl:324` puts it straight into `TkString`. `zyl_cstr_concat`
   and friends treat a null String as "" (`actor_runtime.c:688`), so the
   error disappears.
4. **Borrowed static buffers are returned as Strings.**
   `zyl_dirname_cstr` and `zyl_getcwd` return thread-local buffers that
   the next call overwrites (`actor_runtime.c:3256`, `actor_runtime.c:3368`).
   The signature should promise a fresh String, and the runtime should
   copy into the result region.
5. **The allocation list in region inference must stay in step with the
   signature table.** `region_inference.zyl` (~318-340) keeps its own list
   of runtime symbol names by allocation behaviour
   (`zyl_variant_field` 2, `zyl_attr_get`, `zyl_smap_global`,
   `zyl_wvec_global`, `zyl_cstr_len`, `zyl_cstr_eq`, `zyl_diag_json` 0,
   ...). The signature table should carry that allocation class, so the
   two cannot drift apart.

## Sentinel conventions (0 or -1 means "absent")

A typed API needs a default parameter, `Option`, or a panic for each of
these.

**Returns 0 where the success value is a pointer, handle or String.**
These need `Option` or a default:
- `zyl_getenv`: callers write `(> h 0)`.
- `zyl_arg_str`
- `zyl_getcwd`
- `zyl_dirname_cstr` (null input)
- `zyl_list_files`, `zyl_list_zyl_files`
- `zyl_blake3_file_hex`
- `zyl_blake3_hex` (null input)
- `zyl_cstr_decode`
- `zyl_cstr_sub`, `zyl_cstr_substr`, `zyl_cstr_to_int`: null input only
- `zyl_mangle_key`
- `zyl_intern_name` (table full)
- `zyl_ffi_lookup`
- `zyl_itest_name`, `zyl_itest_fn`
- `zyl_val_name`
- `zyl_fnmap_get`
- `zyl_smap_get`, `zyl_attr_get`, `zyl_cell_get`
- `zyl_wvec_get` (out of range), `zyl_wvec_pop` (empty)
- `zyl_arena_create`, `zyl_arena_alloc`, `zyl_arena_alloc_zeroed`
- `zyl_mem_alloc`, `zyl_heap_alloc`
- `zyl_smap_new`, `zyl_wvec_new` (calloc failure)

Allocation failures should panic rather than become `Option`.

**Callers encode a real 0 by storing `x+1`.** A typed map with `Option`
removes these offsets:
- region summaries: `packed+1` (`region_inference.zyl:585`, read at
  `region_inference.zyl:255-257`)
- secret masks: `mask+1` (`secret_check.zyl:149`, read at `derive.zyl:41-43`)
- attr 4: `level+1`, `idx+1` and `flags+4` (see below)

**List-valued maps where 0 means absent and is not `Nil`:**
- smap 0: `(if (= raw 0) Nil ...)` at `derive.zyl:186`,
  `secret_check.zyl:156` and `type_annotate.zyl` `ta-field-exprs` (~557)
- smap 1: `(if (= old 0) Nil old)` in `ta-add-impl` (~477), and
  `(= impls 0)` at `icnf.zyl:1222`

**Returns -1 where the success value is an Int or an id:**
- `zyl_span_off`, `zyl_span_file` (no span)
- `zyl_span_offset_at`
- `zyl_source_register` (table full)
- `zyl_wvec_push` (out of memory)
- `zyl_itest_add` (full)
- `zyl_random_fill`, `zyl_random_words`
- `zyl_system_cmd`, `zyl_run_bin`, `zyl_exec_cmd`, `zyl_chdir`,
  `zyl_mkdir_p`, `zyl_term_raw_on`, `zyl_term_raw_off` (failure)

**Deliberate multi-valued results.** Keep these as Int or model them as a
small ADT:
- `zyl_cstr_byte_at`: -1 at the end, which is the lexer's
  end-of-input test.
- `zyl_term_read_byte`: -1 or -2.
- `zyl_term_read_byte_timeout`: -3 for a timeout.
- `zyl_f_cmp`: 2 for unordered.
- `zyl_span_line`, `zyl_span_col`: 0 when unknown.
- `zyl_uf_level`: 2 for an unknown class.

## Escape hatches and how to remove them

### `zyl_cstr_of_word` / `zyl_word_of_cstr` (identity casts)

| site | what it forges | replacement |
|---|---|---|
| `collections/vec.zyl:13` (`vec-cast`, used by `vec-elem` and `vec-make` at `vec.zyl:19-24`) | A stored word read back as any element type `T`, plus a phantom `T` built from 0. | The design doc's runtime `(Array a)` with typed `array-get` and `array-set`. `Vec` then wraps `(Array a)` and needs no phantom field. |
| `core/show.zyl:54` (`Hash Float`) | A Float reinterpreted as an Int to hash its bits. | A primitive `zyl_f_bits : Float -> Int` (the bit pattern). This is honest, not a cast. |
| `compiler/derive.zyl:186`, `compiler/secret_check.zyl:158` | An smap 0 value read back as `(List Expr)`. | A typed `def` of `(SMap (List Expr))`; see smap 0 below. |
| `repl/interp.zyl:74` (`in-word-of-str`), `repl/interp.zyl:667` (`in-str-of-word`) | Interpreter strings are `VStr Int` (`interp.zyl:58`), converted to and from String. | Make `VStr String` and `VPtr Ptr`, and give `VFlt` a Float (`interp.zyl:55-60`). The interpreter's `(> (str-eq ..) 0)` sites then take real Strings, and `zyl_cstr_eq`/`zyl_cstr_cmp` are called on Strings. |
| `repl/interp.zyl:226`, `repl/interp.zyl:229` (`in-word-of-fn`, `in-fn-of-word`) | IFn nodes stored in the runtime fnmap as words. | Replace `zyl_fnmap_*` with an `(SMap Icnf)` (or `(SMap Int)` holding an index into a `(WVec Icnf)`), built with the typed `smap-*` API. |

### Interpreter bridges

The functions here are `zyl_call_argv`, `zyl_ffi_timed_argv`,
`zyl_itest_add`, `zyl_itest_fn`, `zyl_repl_global_set`,
`zyl_heap_block_p` and the four `zyl_val_*`. The design doc already
decides that "the interpreter stops forging values from words". In
concrete terms:

- **Foreign calls.** Replace `zyl_call_argv` and `zyl_ffi_timed_argv`
  with one typed marshalling entry. For example,
  `zyl_ffi_call_vals : String Int (Array FfiArg) -> FfiArg`, where
  `(deftype FfiArg (FInt Int) (FFlt Float) (FStr String) (FPtr Ptr))`.
  The runtime unpacks the tags. The interpreter learns the result type
  from the callee's signature, taken from the same signature table the
  checker uses, instead of the hand-kept `in-ffi-returns-str` list
  (`interp.zyl:873-890`).
- **Interpreted ADT values.** Values built by `zyl_val_alloc` and read by
  `zyl_val_kind`, `zyl_val_name` and `zyl_val_arity` should be a Zyl ADT
  such as `(VCon String (List Val))`, held in the interpreter. That
  removes all four `val_*` symbols and `zyl_heap_block_p`. What is left
  is compiled-code interop: a REPL `def` read by compiled code through
  `zyl_repl_global_get`. That needs a typed boundary, for example
  `zyl_repl_global_set : String FfiArg -> Unit`, with the declared type
  checked on read.
- **Tests.** `zyl_itest_*` holding interpreter function words becomes a
  Zyl-side `(WVec (Pair String Val))`. Only `itest_start`, `itest_outcome`
  and `itest_summary`, the printing functions, stay in the runtime.

### `zyl_mem_read` / `zyl_mem_write` storing Strings (`compiler/qualify.zyl:100-102`)

`SymTab` (`qualify.zyl:90`) is a sorted array of `(name, key)` String
pairs stored in raw words. Replace it with `(Array QPair)` (`QPair` is
already declared at `qualify.zyl:85`), using `array-get` and
`array-set`. The allocator's own `alloc-read-int`/`alloc-write-int`
(`allocator.zyl:29-35`) stay `Ptr -> Int` and `Ptr Int -> Int`.

### `zyl_smap_global N`, `zyl_wvec_global N`, `zyl_attr_* N`, `zyl_cell_* N`

The general recipe:

1. Add a module, for example `stdlib/compiler/tables.zyl`, used by every
   pass that shares a table. It holds one typed top-level `def` per
   index:

   ```
   (def field-types (smap-new))
   ```

   This works today because a `def` is eager and caches its value by
   canonical key (`expr_inner.zyl:575-577`), so every use gets the same
   handle.
2. For **cells**, which are mutable scalars, `def` alone is not enough:
   `def` is immutable by spec R7. Add a runtime-backed `(Cell a)` with
   `cell-new : a -> (Cell a)`, `cell-get : (Cell a) -> a` and
   `cell-set : (Cell a) a -> Unit`, then use
   `(def strict-mode (cell-new false))` and
   `(def current-node (cell-new None))`.
3. For **attr tables**, add a runtime call that allocates a fresh table,
   `zyl_attr_new : -> (Attr k v)`, instead of the 6 fixed slots
   (`ZYL_ATTR_TABLES 6`, `actor_runtime.c:1671`). Then declare, for
   example, `(def expr-type (attr-new))`. `attr-get` takes a default of
   type `v`.
4. **Split maps whose value type varies by key prefix** into one map per
   value type. These are maps 3, 4 and 5, and wvecs 0, 1, 2 and 7; the
   next section gives the split for each.
5. Delete `zyl_smap_global`, `zyl_wvec_global`, `zyl_cell_get` and
   `zyl_cell_set`, and change `zyl_attr_*` to take the table handle
   instead of an index.

## Global handle indexes

`ZYL_GLOBAL_HANDLES` is 8 (`actor_runtime.c:1915`). All 8 smaps and all 8
wvecs are in use.

### `zyl_smap_global i`

| i | key -> value | writers | readers / clearers | typed replacement |
|---|---|---|---|---|
| 0 | variant/constructor name -> declared field type Exprs (`(List Expr)`; 0 means absent) | `expr_inner.zyl:1741-1744` (`record-field-types`) | `type_annotate.zyl` (`TaSt` field 15 `ta-fieldtys`, ~78 and ~557), `derive.zyl:185-186`, `secret_check.zyl:155-158`; cleared at `pipeline.zyl:73` | `(def field-types : (SMap (List Expr)))`; `smap-get` with default `Nil`. |
| 1 | dotted trait method (`Trait.m`) -> impls `(List (Pair String String))` (type, mangled name) | `type_annotate.zyl` `ta-add-impl` (~475-477) | `type_annotate.zyl` (`TaSt` field 17 `ta-impls`, ~80; `(> (ta-sget ..) 0)` ~1067), `icnf.zyl:1221-1224`; cleared in `type_annotate.zyl` (~1740) | `(SMap (List (Pair String String)))`. The `(> list 0)` truth test becomes `(not (nil? ..))`. |
| 2 | top-level `def` name -> 1 (a set) | `expr_inner.zyl:605` | `expr_inner.zyl:580` (`def-key-p`); cleared at `expr_inner.zyl:583` | `(SMap Bool)` or a `(Set String)`. |
| 3 | **Mixed.** Short method `m` -> Int count; `m#i` -> String (the i-th dotted method) | `type_annotate.zyl` `ta-mtab-add` (~928-933) | `type_annotate.zyl` `ta-method-*` (~960-985); cleared in `type_annotate.zyl` (~1741) | A single `(SMap (List String))` from short name to dotted methods (list order = insertion order, as the `#i` keys give today). This removes the count key. |
| 4 | **Mixed.** Secret shapes: `t|T` 1, `k|C` 1, `c|C` mask+1, `f|f` 1/2, `w|fn` 1, `any` 1 (all Int), and `L` -> String, the current label | `secret_check.zyl:73`, `secret_check.zyl:107`, `secret_check.zyl:123`, `secret_check.zyl:147-149`, `secret_check.zyl:174-175`, `secret_check.zyl:214` | `secret_check.zyl:71`, `secret_check.zyl:80`, `secret_check.zyl:106`, `secret_check.zyl:179-196`, `secret_check.zyl:382`, `secret_check.zyl:534`, `secret_check.zyl:971`; `derive.zyl:38-45`; `codegen.zyl:1771`; cleared at `secret_check.zyl:112` | Move `L` to a `(Cell String)`. The rest become separate typed maps: `secret-types : (SMap Bool)` (`t|`), `secret-ctors : (SMap Bool)` (`k|`), `secret-masks : (SMap Int)` (`c|`, no +1), `secret-fields : (SMap FieldSecrecy)` (`f|` 1/2), `wipe-fns : (SMap Bool)` (`w|`), `any-secret : (Cell Bool)`. The label prefix in the key can stay a String. |
| 5 | **Mixed.** impl-not data: `i|T|Y` 1, `l|lbl` 1, `p|T|X` 1 (Int flags), `n#c` and `n#` Int counts, and `n#i` -> String label | `module_resolver.zyl:1021`, `module_resolver.zyl:1077`, `module_resolver.zyl:1089-1092`, `module_resolver.zyl:1104`; cleared at `module_resolver.zyl:967` | `module_resolver.zyl:1062`, `module_resolver.zyl:1085-1087`; `secret_check.zyl:69-87`; `derive.zyl:49` | `impl-pairs : (SMap Bool)` (`i|`), `protected : (SMap Bool)` (`p|`), `neg-labels : (WVec String)` (replacing `n#`, `n#c` and `n#i`), and the `l|` dedupe set `(SMap Bool)`. |
| 6 | Contract profile: `"profile"` -> String (0 means unset, default `"strict"`), `"local"` -> String or 0 | `driver.zyl:607`; `expr_inner.zyl:357`, `expr_inner.zyl:360` | `expr_inner.zyl:325-331`; `driver.zyl:371` | Two cells: `contract-profile : (Cell (Option String))` and `contract-local : (Cell (Option String))`. |
| 7 | function name -> region summary `packed+1` (Int) | `region_inference.zyl:585`, `region_inference.zyl:612` | `region_inference.zyl:255-257`; cleared at `region_inference.zyl:690` | `(SMap Int)` with `Option`, removing the +1. |

### `zyl_wvec_global i`

| i | element type | writers | readers / clearers | typed replacement |
|---|---|---|---|---|
| 0 | Type-variable bindings: 0 unbound, 1 poisoned, otherwise a `TaTy` (sentinel-encoded sum, `type_annotate.zyl` ~116) | `type_annotate.zyl` `ta-fresh` (~109), union-find `ta-wset` | `type_annotate.zyl` (`TaSt` field 0 `ta-vars`, ~64), `ta-kind`/`ta-scalar` (~1754-1777, called from `icnf.zyl:444-445`); cleared in `type_annotate.zyl` (~1739) | `(WVec TaBind)` with `(deftype TaBind TaUnbound TaPoisoned (TaBound TaTy))`. Poisoning goes away in phase 4 anyway. |
| 1 | Region sites as **interleaved triples** (Icnf node, `UF` class, Int scope) | `region_inference.zyl:268-270` | `region_inference.zyl:571`, `region_inference.zyl:650-652`; truncated at `region_inference.zyl:562` | `(WVec RgSite)` with `(deftype RgSite (RgSite Icnf UF Int))`. |
| 2 | Stack-buffer sites as **interleaved pairs** (Icnf node, `UF` class) | `region_inference.zyl:445-446` | `region_inference.zyl:623`, `region_inference.zyl:631-632`; truncated at `region_inference.zyl:621` | `(WVec (Pair Icnf UF))`. |
| 3 | Per with-region scope, the first class id created in it (`UF`) | `region_inference.zyl:294` | `region_inference.zyl:293`, `region_inference.zyl:667` (compared with `>=` against `uf_find`); truncated at `region_inference.zyl:563` | `(WVec UF)`, plus `uf-id : UF -> Int` for the ordering. |
| 4 | Open scope stack (Int scope indexes) | `region_inference.zyl:295`, pop at `region_inference.zyl:297` | `region_inference.zyl:287-288`; truncated at `region_inference.zyl:565` | `(WVec Int)`. |
| 5 | Codegen: frame offset of each with-region scope header (Int) | `codegen.zyl:508-516` | `codegen.zyl:475`; never cleared (overwritten per index) | `(WVec Int)`. |
| 6 | IRegion node of each scope (`Icnf`) | `region_inference.zyl:299` | `region_inference.zyl:672`; truncated at `region_inference.zyl:564` | `(WVec Icnf)`. |
| 7 | Num-class notes as **interleaved triples** (Expr node, `TaTy`, Int class 1/2); new in the strict-mode work | `type_annotate.zyl` `ta-note-num` (~703-708) | `type_annotate.zyl` `ta-check-num` (~710-723); truncated in `type_annotate.zyl` (~1732) | `(WVec NumNote)` with `(deftype NumNote (NumNote Expr TaTy NumClass))`. |

### Attr tables (`zyl_attr_* t`, `ZYL_ATTR_TABLES 6`)

All six are cleared together in `type_annotate.zyl` (~1733-1738).

| t | key -> value | set | read | typed replacement |
|---|---|---|---|---|
| 0 | `Expr` -> `TaTy` (the node's inferred type; 0 means none) | `type_annotate.zyl` `ta-rec` (~111) | `type_annotate.zyl` `ta-attr` (~102), `ta-kind`/`ta-scalar`, called by `icnf.zyl:444-445` | `(Attr Expr TaTy)`, whose `attr-get` returns `Option TaTy`. |
| 1 | `Icnf` -> Int codegen kind (1 String, 2 Float, from `ta-kind-of-ty`, `type_annotate.zyl` ~1781; 0 means unrecorded) | `icnf.zyl:450` (`ic-mark-kind`), `icnf.zyl:458` (`attr_copy`) | `icnf.zyl:456`, `codegen.zyl:274`, `icnf_print.zyl:77`, `repl/interp.zyl:259` | `(Attr Icnf ValKind)` with `(deftype ValKind KStr KFlt)` and an `Option` result. |
| 2 | `Expr` -> String (the callee the type pass resolved: trait impl, specialization, or ADT equality function) | `type_annotate.zyl` `ta-set-name node 2` (~943, ~2151-2159) | `ta-renamed` (~2237), used by `icnf.zyl:1107` and `icnf.zyl:1111` | `(Attr Expr String)` with `Option`. |
| 3 | `Expr` -> String (the `show` function used to print a value) | `type_annotate.zyl` `ta-set-name node 3` (~2164) | `ta-print-show` (~2238), used by `icnf.zyl:1306` | `(Attr Expr String)`. Tables 2 and 3 share the `ta-set-name` helper, which takes the table number as data; typed handles make that a handle parameter. |
| 4 | `Icnf` -> Int, **three encodings by node kind**: on an allocation site, `level+1` (1 frame, 2 result, 3 heap) or `4+scope` (`region_inference.zyl:656`, `region_inference.zyl:659`); on an `IRegion`, `scope idx+1` (`region_inference.zyl:298`); on an `IFn`, `flags+4` (`region_inference.zyl:582`) | `region_inference.zyl:298`, `region_inference.zyl:582`, `region_inference.zyl:656`, `region_inference.zyl:659` | `codegen.zyl:456` (`cg-region-flags`, `-4`), `codegen.zyl:461` (`cg-site-level`), `codegen.zyl:482` (`-1`), `icnf_print.zyl:78` | Split into `site-region : (Attr Icnf SiteRegion)` with `(deftype SiteRegion RFrame RResult RHeap (RScope Int))`, `region-scope-idx : (Attr Icnf Int)` and `fn-region-flags : (Attr Icnf Int)`, each with `Option` instead of the +1/+4 offsets. The ICNF printer (`icnf_print.zyl:78`) prints the raw word, and its output feeds the ICNF hash (commit ac3042e), so the printed form must be kept stable or the hash rebased. |
| 5 | `Icnf` -> Bool (the scalar mark: the node's type is Int, Bool or Float) | `icnf.zyl:444` | `region_inference.zyl:498` | `(Attr Icnf Bool)`, default `false`. The design doc's region-safety argument rests on this table ("Region safety" section). |

### Cells (`zyl_cell_* i`, 16 slots, `actor_runtime.c:4919-4921`)

Only `type_annotate.zyl` uses cells. Slots 2..15 are unused.

| i | contents | set | read | typed replacement |
|---|---|---|---|---|
| 0 | Strict-types mode, 0 or 1 (from `ZYL_STRICT_TYPES`) | `type_annotate.zyl` (~1730) | `ta-strict-p` (~158) | `(def strict-types (cell-new false))`: `(Cell Bool)`. |
| 1 | The innermost `Expr` being typed, or 0 for none (used to locate `W_TYPE_STRICT`) | `ta-expr` (~641-644, save and restore), `ta-check-num` (~720), reset (~1731) | `ta-strict` (~160-166) | `(def current-node (cell-new None))`: `(Cell (Option Expr))`. |

### Other runtime singletons (not indexed, but with the same shape)

- `zyl_uf_*` is one global union-find table, reset per function. A typed
  `UF` handle is enough. A value-level `(UFTable)` would allow nesting,
  which nothing needs today.
- `zyl_fnmap_*`, `zyl_itest_*` and `zyl_repl_global_set` are covered
  under "Interpreter bridges".
- `zyl_source_register` and `zyl_span_*` form a global registry keyed by
  node address. A typed `FileId` and the `Boxed n =>` key constraint are
  enough, and it is a probe-only hash table, as `AGENTS.md` requires.
