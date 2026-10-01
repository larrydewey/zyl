# Build provenance: a signed evidential record attached to the binary

## What this is

A binary that a third party holds should carry a record of **what was checked
about it**, signed by whoever vouches for it. The record is CBOR, the
signature is a COSE_Sign1 over that CBOR, and the whole thing is appended to
the binary as a trailer.

The reason it is a trailer on the binary and not a file beside it is the same
reason the verifier is a phase rather than a script: a record that can be
separated from the thing it describes is a claim, and a claim is only as good
as the reader's diligence. Bound to the bytes, it is evidence.

## Why the evidence is the valuable half

The signature and the evidence are independent, and only one of them is
strong:

- **The evidence** — every write through a frame slot lies inside the frame
  that function reserved, over a stated number of sites, with the checks that
  were *not* implemented named as such. This is re-derivable by anyone from
  the binary. It does not depend on the signature at all, and it is the part
  that makes a program safe.
- **The signature** — who vouched. A self-signed record establishes nothing
  beyond "whoever signed this asserts it".

A verifier that collapses the two into one boolean is how a signed-but-unsafe
binary gets waved through, so `zyl verify` reports them separately:

```
EVIDENCE     re-derived from <binary>: 0 violations, 24766 writes, 118506 dynamic
             matches the record: yes
ATTESTATION  COSE_Sign1 valid, kid ed25519:<hex>, trust level: ANCHORED
```

## The chain

1. **Verify.** `compiler/verify.zyl` runs inside `codegen-fns`, so every path
   to an assembly passes through it (`verify/frame_oracle.sh` enforces that
   there is exactly one). V1 bounds and V2 a dynamic-operand census today; V3
   (provenance and bounds for dynamic accesses) and V4 (region liveness) are
   not implemented and are reported as absent rather than as passed.
2. **Record.** A CBOR map: the four inputs of spec §31.12, the resolved graph
   hash, the asm hash, and the evidence.
3. **Sign.** COSE_Sign1, Ed25519 (COSE algorithm `-8`).
4. **Attach.** Appended past the last section of the ELF image.
5. **Verify.** `zyl verify` re-derives the evidence from the binary and
   checks the signature against an anchored key.

## Trailer layout

Appended to the output file. Offsets are from the start of the file.

| offset | size | field |
|---|---|---|
| `T-16` | 8 | magic `ZYLPROV\0` |
| `T-12` | 4 | u32 LE format version, currently 1 |
| `T-8` | 8 | u64 LE length of the COSE blob that follows |
| `T` | len | the COSE_Sign1, CBOR-encoded |

**The hashing rule.** `binary-hash` is BLAKE3 over bytes `[0, T-16)` — the
whole image, excluding the magic onward. Excluding the trailer is what makes
the record self-describing: a reader locates the trailer by its magic, hashes
everything before it, and gets the value the signature commits to. Appending
must therefore be the last thing that happens to the file.

## COSE_Sign1

RFC 9052. A four-element array:

```
[ protected : bstr, unprotected : map, payload : bstr, signature : bstr ]
```

The signature is over the CBOR encoding of the `Sig_structure`, with no
detached content:

```
Sig_structure = [ "Signature1", protected, external_aad = h'', payload ]
```

`protected` is itself a CBOR map, wrapped in a bstr, holding at least
`1: -8` (Ed25519) and `3: -257` (`application/cose` is 52; the content type
for the payload here is `application/cbor`, 60). `unprotected` carries the
`kid` (label 4) so a reader can tell which key was used without decoding the
protected headers.

**Deterministic CBOR is mandatory** (RFC 8949 §4.2.1): shortest-form integers,
definite-length strings, map keys sorted by encoded bytes. The signature is
over bytes, so two encodings of the same record would verify differently, and
a build that is not reproducible cannot be attested reproducibly.

## The record

A CBOR map. Text keys, for legibility; the spec-visible field names match
`zyl.buildinfo` so the two can be compared.

```
{
  "kind"        : "provenance",        ; distinguishes from other records
  "format"      : 1,
  "compiler-hash": <bstr>,
  "graph-hash"  : <bstr>,
  "icnf-hash"   : <bstr>,
  "asm-hash"    : <bstr>,
  "binary-hash" : <bstr>,             ; BLAKE3 of the image, per the rule above
  "final-hash"  : <bstr>,             ; §31.12's four inputs, unchanged
  "evidence"    : {
      "functions"  : <uint>,
      "writes"     : <uint>,
      "reads"      : <uint>,
      "dynamic"    : <uint>,         ; counted, not checked
      "unverified" : <uint>,         ; writes whose function stated no frame
      "checks"     : [ "V1 ...", "V2 ...", "V3 not implemented", ... ]
  }
}
```

`final-hash` stays exactly what §31.12 defines — the compiler hash, the graph
hash, the native-object hashes and the ICNF hash, in that order. The evidence
is a separate field and is deliberately **not** folded in: widening that hash
would change the determinism contract rather than describe it.

**No timestamps, no host, no paths.** The project's first non-negotiable is
that the same source and inputs produce identical output, and a build
attestation has to survive the same test or it is decoration. Anything that
varies between two builds of the same inputs does not belong in the record. If
a build time is genuinely wanted it is a caller-supplied parameter, like
`SOURCE_DATE_EPOCH`, and it is hashed into a separate field so that omitting it
still reproduces.

## Trust modes

`zyl verify` is configurable, because this project has no central authority: an
index is a repository the operator chooses to trust, so a single rigid mode
would be wrong. The modes are ordered by what they establish, and the tool
**reports which one it used** — a single `PASS` across modes of very different
strength is worse than no verdict, because it presents the weakest as the
strongest.

| mode | key source | establishes | verdict |
|---|---|---|---|
| `anchored` | supplied **and** bound to a trusted index entry | the package's own key signed this | `VERIFIED` |
| `supplied` | supplied out of band | someone holding that key signed it; nothing binds it to this package | `ATTESTED` |
| `self-asserted` | the record's own `kid` | internal consistency only | `SELF-ASSERTED` |

Mode 3 catches corruption and casual tampering, and catches nothing against a
motivated attacker: anyone holding the binary can re-sign it with a key of
their own. That is a real property and worth having, as long as it is never
reported as `VERIFIED`.

## The verification workflow

`zyl verify <binary>` does all of this, and fails if any step does:

1. Locate the trailer by its magic; reject a truncated or oversized blob.
2. Hash `[0, T-16)` and check it against `binary-hash` in the record.
3. Decode the COSE_Sign1; verify the signature over `Sig_structure` with the
   key the mode selects; reject an unknown or unsupported `alg`.
4. Decode the record; check `final-hash` against the four recorded inputs.
5. **Re-derive the evidence from the binary** — not from any `.s` the build
   happened to leave behind. Recover the instruction stream from `.text`,
   extract the memory operands, and run *both* verifier implementations over
   them. Require zero violations, and require the coverage numbers to match
   the record. A record that disagrees with the binary is worse than no
   record.
6. Report `EVIDENCE` and `ATTESTATION` separately, with the trust level.

Step 5 is the reason the record is worth having, and the reason the verifier's
input cannot stay assembly text. A verifier that only ever saw the `.s` would
be attesting to a file the signer also controls.

**Disassembly uses `objdump -d`.** Writing an x86 disassembler is not the
problem worth solving here: the disassembler is not what is under test, the
verifier is. `tests/scripts/asm_oracle.py` already cross-checks Zyl's own
assembler against GNU as the same way, so this is precedented, and it keeps
the effort on the safety argument. A consequence to state: the instruction
stream comes from a different toolchain than the one that produced the binary,
so step 5 is a cross-check against GNU's decoder rather than a first-principles
one.

## What this does not do

- **It does not make a build reproducible by itself.** It records what was
  checked; reproducibility is §31.12 and the fixed point.
- **It does not verify V3 or V4.** Dynamic accesses are counted, not checked,
  and the record says so in the same words the compiler does.
- **It does not protect against a compromised signer.** Mode 1 narrows that to
  the key's owner; nothing narrows it further without a transparency log.
- **It does not cover concurrency or FFI**, for the reasons in
  `docs/verifier-design.md`.
