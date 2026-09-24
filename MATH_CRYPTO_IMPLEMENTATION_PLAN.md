# Zyl Math/Crypto Libraries — Implementation Plan

## Current Status (verified against the code, 2026-09-23)

**Phases 1-5 are implemented; Phase 0's enforcement half is implemented;
Phase 0's codegen half (zeroize on scope exit, debug redaction) is not.**
The plan below is kept as the original design; where the built library
differs, this section is authoritative. The user-facing description of the
library is `docs/math-crypto.md`.

### What exists

| Area | Files | Notes |
|------|-------|-------|
| Word/bit helpers | `stdlib/math/bits.zyl`, `stdlib/math/words.zyl` | Not in the plan. Byte strings are one byte per 8-byte word in arena-backed arrays |
| Secrets | `stdlib/math/secret/secret.zyl` | `ct-eq`/`ct-ne`/`ct-eq-words`/`ct-ne-words`, `ct-select`, `ct-mask`, `ct-eq-bool`, `ct-eq-words-bool`, `declassify`, `zeroize`, `zeroize-bytes`. Plan put this at `stdlib/secret/secret.zyl` |
| Bignum | `stdlib/math/bignum/{bignum,montgomery,barrett,modular}.zyl` | Fixed-width naturals in 24-bit limbs, not the planned `[U64; N]`/`Vec<U64>` `Nat`. `barrett.zyl` is extra |
| RNG | `stdlib/math/rand/{rand,deterministic,crypto}.zyl` | `SystemRng` is `getrandom(2)` with a `/dev/urandom` fallback, stateless and so fork-safe. No Windows path. `ChaCha20Rng` in `deterministic.zyl` |
| Hashes | `stdlib/math/hash/{sha2,sha512,sha3,blake2b,blake3,hmac}.zyl` | SHA-256 and SHA-512 are split into two files; BLAKE2b and HMAC-SHA256 are extra. No `hash.zyl` trait module. BLAKE3 uses the portable compression function |
| Symmetric | `stdlib/math/crypto/symmetric/{chacha20,poly1305,chacha20poly,aesgcm}.zyl` | AES-128/256-GCM, AES-NI only (refuses without it). No `aead.zyl` trait module |
| Asymmetric | `stdlib/math/crypto/asymmetric/{x25519,ed25519,ecdsa,rsa}.zyl` | Curve25519 field arithmetic is pure Zyl, no C helper. ECDSA on P-256, secp256k1, P-384 with RFC 6979 nonces only. RSA-PSS and RSA-OAEP only, keys loaded from components |
| KDFs | `stdlib/math/crypto/kdf/{hkdf,pbkdf2,argon2}.zyl` | HKDF and PBKDF2 are fixed to SHA-256 (`hkdf`, `pbkdf2-sha256`), not parameterized by hash function. Argon2id blocks are real 64-bit words |
| Parent module | `stdlib/math/math.zyl` | `(use math/math)` imports the whole tree |
| C helpers | `runtime/actor_runtime.c` | `zyl_cpuid_features`, `zyl_aesni_available`, `zyl_aes_encrypt_block` (AES-NI via `__attribute__((target))`), `zyl_random_words`/`zyl_random_fill`, `zyl_pin_alloc` (best-effort `mlock`), `zyl_mlock`. No separate `runtime/crypto_*.c` files |
| Secret checker | `stdlib/compiler/secret_check.zyl`, `TCSecret` in `stdlib/compiler/type_system.zyl` | Runs in `compile-run-checks` (`stdlib/compiler/pipeline.zyl`) after `unused-check`; the LSP runs it too (`stdlib/lsp/document_manager.zyl`) |
| Tests | `tests/regression/math-*.zyl` (16 files), `tests/regression/secret-capability.zyl`, `tests/compile-fail/secret-*.zyl` (7 files), `tests/integration/math-protocol.zyl` | `--filter math` selects the math files; the interpreter-vs-codegen diff run skips `math-*` for speed |
| Cross-checks | `verify/sha2.py`, `verify/crypto.py`, `verify/timing.py` | Python references only (no C/OpenSSL references). `timing.py` is dudect-style with a positive control, run by `./run_regression_tests.sh --filter timing` |

### Phase status

| Phase | Status |
|-------|--------|
| 0 — `TCSecret`, secret checker, error codes | Done |
| 0 — CT effect in the type system | Not done: the checker is a syntactic taint walk, not a type-level effect |
| 0 — zeroize on scope exit, `print`/panic redaction | Not done: needs codegen hooks. `print` of a secret is rejected (`E_SECRET_DEBUG`) instead |
| 0 — ctgrind/valgrind on compiled output | Not done: `verify/timing.py` is the substitute |
| 1.1 Bignum | Done (different representation, see above) |
| 1.2 RNG | Done for Linux; no Windows `BCryptGenRandom`; no TestU01/PractRand run |
| 1.3 Hash | Done except BLAKE3 SIMD |
| 2 Symmetric | Done |
| 3 Asymmetric | Done except RSA key generation |
| 4 KDF | Done, SHA-256 only for HKDF/PBKDF2 |
| 5 Parent module and integration | Done: `math.zyl` plus `tests/integration/math-protocol.zyl`; there is no `math_tests.zyl` or `tests/math/` |
| Trait layer (`Rng`, `CryptoRng`, `Hash`, `Aead`, `RsaKey`, `Secret`) | Not done: every module exposes plain functions. The compiler has trait dispatch (`stdlib/compiler/trait_dispatch.zyl`, which picks an impl by the receiver's runtime tag), but the library was not built around it |
| `CryptoError` ADT | Not done: failures are reported per function (e.g. `-1`, `None`, `0`) |

### How the secret checker behaves

A parameter annotated `Secret` — `(k Secret)` or `(k (Secret Int))` —
seeds a taint that propagates through lets, calls, arithmetic and
constructors, interprocedurally via a secret-returning-function fixpoint.
It rejects:

| Shape | Code |
|-------|------|
| `if`/`while`/`for`/`cond` condition, `match` subject derived from a Secret | `E_CT_VIOLATION` |
| Secret in the index argument of `w-get`/`w-set`/`list-nth`/`vec-get`/`alloc-read-int`/…, or a byte load/store offset | `E_CT_VIOLATION` |
| Secret operand of `/` or `mod` (variable-latency divider) | `E_CT_VIOLATION` |
| Secret reaching `print` | `E_SECRET_DEBUG` |
| Secret reaching `spawn`, `send` or `file-write` | `E_SECRET_ESCAPE` |
| Secret passed to `ffi-call` without `ffi-pin` | `E_FFI_PIN_REQUIRED` |
| Secret consumed into a public result with no `zeroize` (warning) | `E_ZEROIZE_MISSING` |

`declassify` is the one explicit way out, along with
`ct-eq-bool`/`ct-eq-words-bool`, which are recognised as declassifying by
name so an AEAD can act on its own tag verdict.

**Main limitation:** only `stdlib/math/secret/secret.zyl` carries `Secret`
annotations. Taint crosses a call boundary only where the callee's own
parameters are annotated, so the AEAD, KDF, signature and bignum entry
points are not yet under the checker, and an unannotated helper launders a
secret.

### Why the C helpers live in `actor_runtime.c`

The link command is built in several places (`boot.sh`, `cli-link` in
`selfhost/driver.zyl`, `zyl_cc_compile` in the runtime), and adding
per-primitive C files to all of them would have touched the self-hosting
path for a handful of functions. AES-NI uses per-function
`__attribute__((target(...)))` instead of per-file compiler flags. (The
runtime also has its own C BLAKE3, `zyl_blake3_hex`, used by the package
system for content hashes; it is separate from `stdlib/math/hash/blake3.zyl`
and agrees with it on test vectors.)

Four compiler bugs had to be fixed before the library could run: no
bitwise operators at all, `for` ignoring a non-zero initializer, `print`
truncating Ints to 32 bits, and the AES-NI FFI boundary needing stack
realignment. Those are described in `PROGRESS.md`.

---

# Original Plan

The rest of this document is the plan as written before implementation.
File names, the trait layer, the C helper files and the FFI catalog below
describe the intended design, not the built library; see the status tables
above.

## Overview

Build a complete cryptography and math standard library in pure Zyl, with FFI to C helpers for hardware-accelerated primitives (AES-NI, CPUID, Curve25519 field ops, BLAKE3 SIMD). All code verified against test vectors and cross-checked with Python/C references. **Constant-time execution is mandatory for all secret-dependent operations.**

---

## Final Decisions

| Decision | Choice |
|----------|--------|
| **Module structure** | `stdlib/math/` parent with submodules |
| **TSecret** | Builtin capability (`TCSecret`) + `Secret` trait for user types |
| **RNG** | Two traits: `CryptoRng` + `DeterministicRng` (both extend `Rng`) |
| **Bignum** | Inferred `Nat` — heuristic: ≤512 bits → stack array `[U64; N]`, else heap `Vec<U64>`; **constant-time ops required** |
| **SystemRng** | FFI to `/dev/urandom` via `zyl_file_read_c` (portable); **getrandom(2) on Linux, BCryptGenRandom on Windows** |
| **Hash priority** | SHA-2, SHA-3, BLAKE3 (full reference port + FFI SIMD) |
| **AES** | **AES-NI only (constant-time); T-tables REMOVED — cache-timing vulnerable** |
| **ChaCha20-Poly1305** | Pure Zyl (both); **constant-time verified** |
| **Argon2 memory** | TSecret + Heap (variable mem_cost); **zeroize on dealloc** |
| **Curve params** | Hardcoded + property test vs spec |
| **Test vectors** | Embedded in Zyl test files (S-expr) |
| **RSA sizes** | 2048/3072/4096 optimized + arbitrary via trait; **PKCS#1 v1.5 DEPRECATED (Bleichenbacher)** |
| **ECDSA curves** | secp256k1, secp256r1, secp384r1; **RFC 6979 deterministic nonces MANDATORY** |
| **Curve25519** | Pure Zyl + FFI for FE25519 mul/square/invert; **FFI constant-time required** |
| **BLAKE3 SIMD** | FFI to C SIMD helpers (`blake3_compress_avx2` etc.); **constant-time** |
| **KDF hash** | Parameterized: `(hkdf hash-fn ikm salt info len)` |
| **TSecret zeroize** | On scope exit (like Rust `Drop`); **explicit `zeroize!` intrinsic for early wipe** |
| **Debug redaction** | Compiler redacts TSecret capability; `Secret` trait for user types; **redact in panic/crash dumps** |
| **Crypto errors** | Unified `CryptoError` ADT; **constant-time error paths, no secret-dependent branching** |
| **Side-channel testing** | Timing test harness (statistical leakage detection); **dudect + ctgrind + valgrind** |
| **Test runner** | Extend `run_regression_tests.sh --filter math` |
| **Constant-time comparison** | Builtin `ct-eq` / `ct-ne` for MAC/tag verification |
| **Domain separation** | Mandatory for all hash-based constructions (HKDF, signatures, etc.) |

---

## Module Structure

```
stdlib/math/
├── math.zyl              # Parent module, re-exports all submodules
├── secret/
│   └── secret.zyl        # Secret trait + blanket impl for TSecret
├── bignum/
│   ├── bignum.zyl        # Nat type (inferred), limb ops (constant-time)
│   ├── montgomery.zyl    # Montgomery reduction (constant-time)
│   └── modular.zyl       # ModExp, ModInv, CRT, prime gen (constant-time)
├── rand/
│   ├── rand.zyl          # Rng trait (next-u64, fill-bytes)
│   ├── deterministic.zyl # DeterministicRng trait + ChaCha20Rng (20-round)
│   └── crypto.zyl        # CryptoRng trait + SystemRng (FFI entropy, cross-platform)
├── hash/
│   ├── hash.zyl          # Hash trait + common; ct-eq/ct-ne builtins
│   ├── sha2.zyl          # SHA-256, SHA-512 (RFC 6234; constant-time)
│   ├── sha3.zyl          # SHA3-256, SHA3-512, SHAKE128/256 (FIPS 202)
│   └── blake3.zyl        # BLAKE3 full reference port + FFI SIMD (constant-time)
├── crypto/
│   ├── symmetric/
│   │   ├── aead.zyl      # Aead trait (encrypt, decrypt, key-len, nonce-len, tag-len)
│   │   ├── chacha20poly.zyl
│   │   └── aesgcm.zyl    # AES-GCM (AES-NI ONLY; constant-time)
│   ├── asymmetric/
│   │   ├── ed25519.zyl   # Ed25519 (RFC 8032; RFC 6979 nonces)
│   │   ├── x25519.zyl    # X25519 (RFC 7748; input validation)
│   │   ├── ecdsa.zyl     # ECDSA over secp256k1/r1, secp384r1 (RFC 6979 nonces)
│   │   └── rsa.zyl       # RSA-PSS, RSA-OAEP only; 2048/3072/4096 + arbitrary via RsaKey trait
│   └── kdf/
│       ├── hkdf.zyl      # HKDF (RFC 5869); domain-separated
│       ├── pbkdf2.zyl    # PBKDF2 (RFC 8018); parameterized hash
│       └── argon2.zyl    # Argon2id (RFC 9106); TSecret + Heap; zeroize on dealloc
```

---

## Phase 0: Compiler Foundation (TSecret + Pin Region)

**Goal:** Implement TSecret capability and Pin region for FFI — required foundation for all crypto.

### Files to Modify

| File | Changes |
|------|---------|
| `stdlib/compiler/type_system.zyl` | Add `TCSecret` to `CapKind` ADT; add `CT` (constant-time) effect marker |
| `stdlib/compiler/type_inference.zyl` | TSecret unification, subtyping (`TSecret <: TCap`), FFI_Pinnable checking; **CT effect propagation** |
| `stdlib/compiler/region_inference.zyl` | Pin region assignment for FFI args + TSecret values; **Pin = non-pageable, mlocked** |
| `stdlib/compiler/icnf.zyl` | `IFfiPin`/`IFfiUnpin` lowering, zeroize IR nodes; **CT effect on IR nodes** |
| `stdlib/compiler/codegen.zyl` | `ffi_pin`/`ffi_unpin` codegen, zeroize emission, debug redaction; **CT codegen: no secret-dependent branches, no secret-dependent memory access** |
| `stdlib/compiler/error_codes.zyl` | New errors: `E_FFI_PIN_REQUIRED`, `E_FFI_TYPE_NOT_PINNABLE`, `E_SECRET_ESCAPE`, `E_SECRET_DEBUG`, `E_ZEROIZE_MISSING`, `E_CT_VIOLATION` |

### New Library File

| File | Purpose |
|------|---------|
| `stdlib/secret/secret.zyl` | `Secret` trait + blanket impl for `TSecret` capability types; `zeroize!` intrinsic |

### Verification
- Unit tests for secret capability flow
- Zeroize on scope exit + explicit `zeroize!`
- Debug redaction (`print` shows `<secret>`); **panic/crash dump redaction**
- FFI Pin enforcement (mlock verification)
- **CT effect checker: reject secret-dependent branches/loads**
- **ctgrind/valgrind verification on compiled output**

---

## Phase 1: Core Infrastructure

### 1.1 Bignum (`stdlib/math/bignum/`)

| File | Purpose |
|------|---------|
| `bignum.zyl` | `Nat` type (inferred: stack `[U64; N]` for ≤512 bits, `Vec<U64>` for larger), limb ops (add/sub/mul/div/mod/shl/shr/cmp); **all ops constant-time (CT effect)** |
| `montgomery.zyl` | Montgomery reduction, `MontgomeryNat` wrapper; **constant-time** |
| `modular.zyl` | ModExp, ModInv, CRT, prime generation helpers; **constant-time; Miller-Rabin with fixed bases** |

**Verification:** Wycheproof vectors, OpenSSL `bn_test` parity; **ctgrind + dudect on all secret-dependent ops**.

### 1.2 RNG (`stdlib/math/rand/`)

| File | Purpose |
|------|---------|
| `rand.zyl` | `Rng` trait (`next-u64`, `fill-bytes`); **`try-fill-bytes` for fallible entropy** |
| `deterministic.zyl` | `DeterministicRng` trait + `ChaCha20Rng` impl (20-round); **proper seeding from CryptoRng** |
| `crypto.zyl` | `CryptoRng` trait + `SystemRng` impl (FFI → `getrandom(2)` Linux, `BCryptGenRandom` Windows, `/dev/urandom` fallback); **reseed on fork** |

**Verification:** TestU01/PractRand on `ChaCha20Rng`; NIST DRBG vectors; **fork-safety test**.

### 1.3 Hash (`stdlib/math/hash/`)

| File | Purpose |
|------|---------|
| `hash.zyl` | `Hash` trait (`update`, `finalize`, `block-len`, `output-len`); **`ct-eq`/`ct-ne` builtins for tag compare** |
| `sha2.zyl` | SHA-256, SHA-512 (RFC 6234); **constant-time** |
| `sha3.zyl` | SHA3-256, SHA3-512, SHAKE128/256 (FIPS 202); **constant-time** |
| `blake3.zyl` | BLAKE3 full reference port (tree hashing) + FFI to C SIMD helpers; **constant-time SIMD** |

**Verification:** NIST SHAVS vectors, RFC test vectors, BLAKE3 test suite; **dudect on all implementations**.

---

## Phase 2: Symmetric Crypto (`stdlib/math/crypto/symmetric/`)

| File | Purpose |
|------|---------|
| `aead.zyl` | `Aead` trait (`encrypt`, `decrypt`, `key-len`, `nonce-len`, `tag-len`); **decrypt uses `ct-eq` for tag verify** |
| `chacha20poly.zyl` | ChaCha20-Poly1305 (RFC 8439) — pure Zyl; **constant-time** |
| `aesgcm.zyl` | AES-GCM (NIST SP 800-38D) — **AES-NI ONLY (constant-time); T-tables REMOVED** |

**C Helpers (`runtime/crypto_aes.c`):**
- `cpuid_features()` → U64 bitmask (AES-NI, CLMUL detection)
- `aesni_available()`, `aesni_encrypt_block()`, `aesni_decrypt_block()`, `aesni_key_expand()`
- **All functions constant-time; no secret-dependent branches/memory access**
- Called via `ffi-call` with Pin region, 1000 timeout; **mlock'd key buffer**

**Verification:** NIST GCM/CCM test vectors, RFC 8439 ChaCha20-Poly1305 vectors; **dudect on decrypt path**.

---

## Phase 3: Asymmetric Crypto (`stdlib/math/crypto/asymmetric/`)

| File | Purpose |
|------|---------|
| `ed25519.zyl` | Ed25519 (RFC 8032) — pure Zyl + FFI for FE25519 field ops; **RFC 6979 deterministic nonces; clamping enforced** |
| `x25519.zyl` | X25519 (RFC 7748) — same field ops; **input validation (low-order point check); constant-time** |
| `ecdsa.zyl` | ECDSA over secp256k1, secp256r1 (P-256), secp384r1 (P-384); **RFC 6979 deterministic nonces MANDATORY** |
| `rsa.zyl` | **RSA-PSS, RSA-OAEP ONLY**; 2048/3072/4096 optimized + arbitrary via `RsaKey` trait; **PKCS#1 v1.5 REMOVED (Bleichenbacher)**; **constant-time CRT/Montgomery** |

**C Helpers (`runtime/crypto_curve25519.c`):**
- `fe25519_mul()`, `fe25519_square()`, `fe25519_invert()`
- `curve25519_scalar_mul()` (for X25519)
- **All functions constant-time; no secret-dependent branches**
- Called via `ffi-call` with Pin region; **mlock'd scalar buffer**

**Verification:** RFC 8032/7748 test vectors, Wycheproof ECDSA/RSA suites; **dudect on all signing/decryption paths**.

## Phase 4: KDF (`stdlib/math/crypto/kdf/`)

| File | Purpose |
|------|---------|
| `hkdf.zyl` | HKDF (RFC 5869) — parameterized: `(hkdf hash-fn ikm salt info len)`; **domain-separated labels** |
| `pbkdf2.zyl` | PBKDF2 (RFC 8018) — parameterized hash; **constant-time HMAC compare** |
| `argon2.zyl` | Argon2id (RFC 9106) — `TSecret` + Heap memory, configurable mem/time/lanes; **zeroize on dealloc; mlock memory** |

**Verification:** RFC test vectors, Argon2 reference vectors; **dudect on password-dependent paths**.

---

## Phase 5: Parent Module & Integration

| File | Purpose |
|------|---------|
| `stdlib/math/math.zyl` | Parent module, re-exports all submodules |
| `stdlib/math/math_tests.zyl` | Cross-module integration tests |

---

## FFI Helper Catalog

| C File | Functions | Called From |
|--------|-----------|-------------|
| `runtime/crypto_cpuid.c` | `cpuid_features()` → U64 bitmask | `math/rand/crypto.zyl`, `math/crypto/symmetric/aesgcm.zyl` |
| `runtime/crypto_aes.c` | `aesni_available`, `aesni_encrypt_block`, `aesni_decrypt_block`, `aesni_key_expand` | `math/crypto/symmetric/aesgcm.zyl` |
| `runtime/crypto_curve25519.c` | `fe25519_mul`, `fe25519_square`, `fe25519_invert`, `curve25519_scalar_mul` | `math/crypto/asymmetric/ed25519.zyl`, `x25519.zyl` |
| `runtime/crypto_blake3.c` | `blake3_compress_avx2`, `blake3_compress_sse41`, `blake3_hash` | `math/hash/blake3.zyl` |
| `runtime/crypto_rng.c` | `sysrandom_getrandom`, `sysrandom_bcrypt` | `math/rand/crypto.zyl` |

**FFI Pattern:** All use `ffi-pin` for args, `ffi-call` with 1000 timeout, `TSecret` capability on secret args. **All C helpers MUST be constant-time (verified with ctgrind/dudect). Pin = mlock'd non-pageable memory.**

---

## Testing Strategy

### Per-Primitive
- Embedded test vectors in Zyl test files (S-expressions)
- Property tests: round-trip encrypt/decrypt, sign/verify, hash consistency
- Known-answer tests from NIST/RFC/Wycheproof
- **Constant-time verification: ctgrind (valgrind) + dudect on all secret-dependent paths**

### Cross-Verification
- `verify/<primitive>.py` — Python reference using `hashlib`, `cryptography`, `pyca`
- `verify/<primitive>.c` — C reference using OpenSSL/libsodium
- CI runs both against Zyl output

### Timing Harness (Side-Channel)
- Statistical leakage detection (dudect-style)
- Many iterations per test; detects timing variance
- **ctgrind (valgrind-based constant-time analysis) on all primitives**
- **valgrind memcheck for zeroize verification**
- Integrated into `run_regression_tests.sh --filter math`

### Integration
- `tests/math/integration.zyl` — Full protocol simulations (TLS-like handshake, JWT sign/verify, encrypted file format)
- **Fork-safety tests for SystemRng**
- **Key erasure tests: verify secrets zeroized after use**

---

## Dependencies

```
Phase 0 (TSecret + Pin)
    │
    ├─→ Phase 1.1 (Bignum)
    │         │
    │         ├─→ Phase 2 (Symmetric) ── AES-GCM needs AES-NI FFI
    │         │
    │         ├─→ Phase 3 (Asymmetric)
    │         │      ├─→ Ed25519/X25519 need Curve25519 FFI
    │         │      ├─→ ECDSA needs bignum + modular
    │         │      └─→ RSA needs bignum + modular
    │         │
    │         └─→ Phase 4 (KDF)
    │                ├─→ HKDF/PBKDF2 need Hash
    │                └─→ Argon2 needs TSecret + Heap
    │
    ├─→ Phase 1.2 (RNG)
    │         └─→ SystemRng needs entropy FFI
    │
    └─→ Phase 1.3 (Hash)
              └─→ BLAKE3 needs SIMD FFI
```

---

## Estimated Effort

| Phase | Zyl LOC | C Helper LOC | Test Vectors | Est. Days |
|-------|---------|--------------|--------------|-----------|
| 0 (TSecret + Pin) | ~500 | 0 | 30 | 3 |
| 1.1 (Bignum) | ~1000 | 0 | 100 | 5 |
| 1.2 (RNG) | ~500 | ~100 | 50 | 3 |
| 1.3 (Hash) | ~2500 | ~250 | 200 | 9 |
| 2 (Symmetric) | ~800 | ~200 | 100 | 5 |
| 3 (Asymmetric) | ~2200 | ~300 | 300 | 12 |
| 4 (KDF) | ~1100 | ~100 | 80 | 6 |
| 5 (Integration) | ~400 | 0 | 50 | 3 |
| **Total** | **~9000** | **~950** | **~910** | **~46** |

---

## Open Implementation Questions (Resolved)

1. **Pin region for FFI** → Implement in Phase 0 (required for TSecret + crypto FFI); **Pin = mlock'd non-pageable**
2. **Bignum representation** → Heuristic: ≤512 bits → stack array, else heap vec; **constant-time ops mandatory**
3. **BLAKE3 SIMD** → FFI to C SIMD helpers; **constant-time verified**
4. **Cross-platform entropy** → FFI to `getrandom(2)` Linux, `BCryptGenRandom` Windows, `/dev/urandom` fallback; **fork-safe**
5. **RSA arbitrary sizes** → `RsaKey` trait with key-gen, sign, verify, encrypt, decrypt; **PKCS#1 v1.5 REMOVED**
6. **TSecret zeroize** → On scope exit (like Rust `Drop`); **explicit `zeroize!` intrinsic for early wipe**
7. **Debug redaction** → Compiler redacts TSecret; `Secret` trait for user types; **panic/crash dump redaction**
8. **Crypto errors** → Unified `CryptoError` ADT; **constant-time error paths**
9. **Argon2** → Pure Zyl (~500 LOC); **mlock memory; zeroize on dealloc**
10. **BLAKE3 scope** → Full reference port (tree hashing, SIMD via FFI); **constant-time**
11. **Side-channel testing** → Timing test harness (statistical); **dudect + ctgrind + valgrind**
12. **Test runner** → Extend `run_regression_tests.sh --filter math`
13. **Constant-time comparison** → Builtin `ct-eq` / `ct-ne` for MAC/tag verification
14. **Domain separation** → Mandatory for all hash-based constructions
15. **ECDSA/Ed25519 nonces** → RFC 6979 deterministic nonces MANDATORY
16. **X25519 input validation** → Low-order point check required

## Next Steps

Phase 0's enforcement half and Phases 1-5 are done. What remains, in
the order it is worth doing:

1. **Annotate the rest of `stdlib/math`.** Taint only crosses a call
   boundary where the callee's parameters are annotated, so the key
   arguments of the AEADs, the KDFs, the signature schemes and the
   bignum modular paths each need `Secret` to bring them under the
   checker. Expect genuine findings: any `if` on key material in that
   code is a leak the pass now names.
2. **Zeroization on scope exit** — a codegen epilogue that erases
   secret-typed frame slots, turning `E_ZEROIZE_MISSING` from a warning
   into an unnecessary one.
3. **Debug redaction** — `print` of a secret emitting `<secret>` rather
   than being rejected, and the same in panic/crash dumps.
4. **RSA key generation**, and the trait layer (`RsaKey`, a `Secret`
   trait for user-defined secret types, `Rng`/`Hash`/`Aead`). The
   compiler's trait dispatch (`stdlib/compiler/trait_dispatch.zyl`)
   dispatches on a receiver's runtime tag; whether that is sufficient for
   these traits has not been evaluated.
5. **BLAKE3 SIMD via FFI**, the one primitive still on its portable
   compression function.

---

*Plan generated 2026-09-20; status section updated 2026-09-23.*