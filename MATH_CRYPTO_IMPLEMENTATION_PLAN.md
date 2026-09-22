# Zyl Math/Crypto Libraries — Implementation Plan

**Status (2026-09-22): implemented, except Phase 0's compiler work.**

`stdlib/math/` now holds the hashes, symmetric and asymmetric
primitives, KDFs, big-number arithmetic and RNGs described below, with
published test vectors in `tests/regression/math-*.zyl` and randomized
cross-verification against Python references in `verify/`. See
`docs/math-crypto.md` for the delivered library and `PROGRESS.md` for
the session that built it.

What this plan describes and the implementation does NOT do:

- **Phase 0's compiler changes** — the `TCSecret` capability kind, the
  CT effect checker, zeroization on scope exit, debug redaction and
  `E_SECRET_*`/`E_CT_VIOLATION` error codes. The library uses explicit
  `zeroize` and the branchless primitives in `math/secret/secret`
  instead, so the runtime behaviour is present but the compiler does
  not enforce it. `zyl_pin_alloc` does now mlock what it returns.
- **Separate `runtime/crypto_*.c` files.** The C helpers live in
  `runtime/actor_runtime.c` under marked sections instead: the link
  command is hardcoded in three places (boot.sh, `cli-link` in
  driver.zyl, `zyl_cc_compile`), and adding files to all of them for
  four functions would have touched the self-hosting path for no gain.
  AES-NI uses per-function `__attribute__((target(...)))` rather than
  per-file compiler flags.
- **BLAKE3 SIMD via FFI.** The portable compression function is used;
  the reference tree structure and XOF are complete.
- **ctgrind/valgrind.** `verify/timing.py` is a dudect-style
  statistical harness with a positive control, wired into
  `run_regression_tests.sh --filter timing`.
- **RSA key generation** and the `RsaKey` trait. Keys are loaded from
  their components; generation needs thousands of exponentiations at
  this arithmetic's speed. Trait dispatch is also not yet wired in the
  compiler, so every module here exposes plain functions.
- **`Secret` trait / user-defined secret types** — same reason.

Four compiler bugs had to be fixed before any of this could run: no
bitwise operators at all, `for` ignoring a non-zero initializer,
`print` truncating Ints to 32 bits, and the AES-NI FFI boundary needing
stack realignment. Those are described in `PROGRESS.md`.

---

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

1. Start **Phase 0**: Implement TSecret capability + Pin region in compiler
   - Add `TCSecret` to `CapKind` ADT
   - Add `CT` (constant-time) effect marker
   - Implement `zeroize!` intrinsic
   - Pin region = mlock'd non-pageable memory
   - CT effect checker: reject secret-dependent branches/loads
2. Add `stdlib/secret/secret.zyl` with `Secret` trait + blanket impl for `TSecret`
3. Verify with unit tests + ctgrind/dudect on compiled output
4. Proceed to Phase 1 infrastructure

---

*Generated: 2026-09-20 (Security audit patch applied)*