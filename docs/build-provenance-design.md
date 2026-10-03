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
binary gets waved through, so `zyl verify` reports them separately, and within
the evidence it says which claims it **re-derived** from the file in front of
it and which it can only repeat from the record (**attested**):

```
zyl verify   ./provverify
TRAILER      at 262144: format 1, COSE_Sign1 of 692 bytes, accounting for every byte after the image
EVIDENCE     binary-hash    re-derived over [0, 262144): matches the record
             compiler-hash  re-derived from this verifier's own image: the same compiler
             buildinfo      ./provverify.buildinfo: all six hashes agree with the record, and final-hash recomputes from its four inputs
             census         attested, not re-derived: the image also holds the runtime, which the build's census never covered
                            functions 112, writes 2214, reads 6020, dynamic 9014, unverified 0
                            V1 frame-slot bounds: ok, covered 2214 sites
                            V2 dynamic-operand census: ok, covered 9014 sites
                            V3 provenance and bounds: not implemented
                            V4 region liveness: not implemented
ATTESTATION  COSE_Sign1 valid under kid ed25519:d75a98…511a
             trust: anchored -- the key pinned for package acme/provverify at ~/.zyl/keys/acme_provverify
VERDICT      VERIFIED
```

## What is re-derived, and what is only attested

This is the decision the first handoff asked for, and it is weaker than the
design first assumed. Three facts about the artifact decide it:

1. **Zyl's ELF has no sections and no symbols.** The compiler's own linker
   emits program headers only, so there is no `.text` to recover an
   instruction stream from; `objdump -d` disassembles nothing. The executable
   `PT_LOAD` can be disassembled as raw bytes, but there are no function
   boundaries in it.
2. **The frame bound is not in the image.** V1's `# frame N` is an assembler
   comment, present in the `.s` and nowhere else. `compiler/verify.zyl`
   measured four ways of recovering it from the code and every one produced
   thousands of false positives.
3. **The image holds more than the census covered.** The census ran over the
   program's assembly; the linked image also holds the runtime (`rt.zo`). A
   recount over the executable segment would differ from every honest record,
   and a recount that subtracted the runtime would be trusting a second input
   nobody signed.

So the census — functions, writes, reads, dynamic, unverified, and the four
check lines — is **attested**: the signer's claim about what the compiler
checked, carried inside the signature and repeated by `zyl verify` in those
words. What `zyl verify` **re-derives** is everything the file in front of it
can answer for:

| claim | re-derived from |
|---|---|
| `binary-hash` | BLAKE3 over `[0, T-16)` of the file being verified |
| `compiler-hash` | BLAKE3 of the verifier's own image; equal means the chain from this binary to a verifiable compiler closes with no further assumption, unequal is reported as *a different compiler*, not as a failure |
| `compiler-hash`, `graph-hash`, `objects-hash`, `icnf-hash`, `asm-hash`, `final-hash` | `<binary>.buildinfo`, when it is beside the binary: each compared with the record, and `final-hash` recomputed from the four input strings that file carries (§31.12 hashes the strings, so the record alone cannot recompute it) |

A buildinfo that disagrees with the trailer is a **failure**: the two describe
one build, and a reader who found them apart would have to pick one to
believe. No buildinfo is weaker and is said so — the fields it would have
checked are called attested — but is not a failure.

The way to move the census from attested to re-derived is to put the frame
table in the image: a `.zyl_frames` section of (function offset, frame size)
pairs emitted by codegen and recovered by magic, plus the runtime's own census
recorded at `rt-cache` time so the recount has something to compare against.
That is a change to `codegen.zyl`, `asm_x86.zyl` and `elf_link.zyl`, a
section in every binary and a reseed; it is recorded in `PROGRESS.md` as open
work and nothing in the record or the report pretends it has been done.

## The chain

1. **Verify.** `compiler/verify.zyl` runs inside `codegen-fns`, so every path
   to an assembly passes through it (`verify/frame_oracle.sh` enforces the
   structural half: `cg-buffer`, the one place generated text is extracted,
   has exactly one reader, and the function containing it calls
   `verify-asm`). V1 bounds and V2 a dynamic-operand census today; V3
   (provenance and bounds for dynamic accesses) and V4 (region liveness) are
   not implemented and are reported as absent rather than as passed.
2. **Record.** A CBOR map: the four inputs of spec §31.12, the resolved graph
   hash, the asm hash, and the evidence.
3. **Sign.** COSE_Sign1, Ed25519 (COSE algorithm `-8`).
4. **Attach.** Appended after the last byte of the image (`zyl build
   --sign-with <key>`; an unsigned build is byte-identical to before).
5. **Verify.** `zyl verify <binary>` re-derives what the file can answer for,
   repeats the rest as attested, checks the signature under the key the trust
   mode selects, and reports the two halves apart.

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
  "objects-hash": <bstr>,             ; BLAKE3 of the native-objects TEXT (see below)
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

Three of §31.12's inputs are already `blake3:` hashes; the fourth is the text
`zyl.buildinfo` records as `(native-objects ...)` — one `("path" "blake3:…")`
per object, or nothing. The record's `objects-hash` is **BLAKE3 of that text**
(BLAKE3 of the empty string for a build with no native code), so every hash
field is 32 bytes of hash and `zyl verify` can recompute it from the buildinfo.
An earlier record pushed the text itself through the hex decoder, which gave a
well-formed 32-byte field that was a hash of nothing; no reader existed to
notice.

Every hash field is exactly 32 bytes. A hash that is absent on the build side
— the graph hash of a build with no lock — is zero-padded, and the reader
reports 32 zero bytes rather than guessing; the buildinfo beside it records the
empty string, which is how the two are told apart.

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
**reports which one it used**, with where the key came from — a single `PASS`
across modes of very different strength is worse than no verdict, because it
presents the weakest as the strongest.

| mode | flag | key source | establishes | verdict |
|---|---|---|---|---|
| `anchored` | `--package <name>` | the key pinned for that package on first fetch (§31.8, `~/.zyl/keys/<name>`) | the package's own publisher signed this | `VERIFIED` |
| `supplied` | `--key <hex\|file>` | a public key the caller got some other way | someone holding that key signed it; nothing binds it to this binary | `ATTESTED` |
| `self-asserted` | neither | the record's own `kid` | internal consistency only | `SELF-ASSERTED` |

The verdict word is the mode's and never a stronger one. `--anchored` turns
anything but the first mode into a failure, for a script that must not accept
a weaker verdict by accident; a `--package` whose key is not pinned is an
error, not a fall-through to a weaker mode. The exit status is 0 for any of
the three verdicts and 1 for `FAILED` or `UNSIGNED`; a script that wants only
`VERIFIED` passes `--anchored`.

Mode 3 catches corruption and casual tampering, and catches nothing against a
motivated attacker: anyone holding the binary can re-sign it with a key of
their own. That is a real property and worth having, as long as it is never
reported as `VERIFIED`.

## The verification workflow

`zyl verify <binary> [--key k] [--package p] [--anchored]` does all of this
(`prov-verify` in `compiler/provenance.zyl`; the driver only picks the mode),
and fails if any step does:

1. Locate the trailer by its magic in the last KiB of the file; require the
   format it knows, and require the blob to account for exactly the bytes
   after the header — one byte short or long is reported as truncated or
   extended, before any cryptography runs.
2. Require the blob to have the shape this tree's COSE module emits, and the
   payload to be a provenance record of a known format.
3. **Evidence.** Hash `[0, T-16)` and compare with `binary-hash`. Hash the
   verifier's own image and compare with `compiler-hash`. Read
   `<binary>.buildinfo` if it is there, compare its six hashes with the
   record's, and recompute `final-hash` from the four input strings it
   carries. Repeat the census as attested, in that word.
4. **Attestation.** Verify the signature over `Sig_structure` under the key
   the mode selects; the kid must equal that key.
5. Report `EVIDENCE` and `ATTESTATION` on separate lines, name the trust mode
   and where its key came from, and give the mode's verdict word.

The record is read by a CBOR reader (`encoding/cbor.zyl`, keyed lookup with
every offset checked against the blob's extent) rather than by a positional
walk: a first positional draft found five bugs in its own traversal, one of
which inverted a bounds test and made it refuse every well-formed record while
passing every test it had, because every test asked only whether it refuses.
`tests/cbor_test.zyl` and `tests/provenance_test.zyl` state the "does it say
yes" case first for that reason, and `tests/scripts/prov-verify.sh` drives the
command end to end: the three modes, then one change at a time — a flipped
byte in the image, a truncated and an extended trailer, a stale buildinfo, a
key that signed nothing, an unsigned binary — each required to move the
verdict.

## What this does not do

- **It does not make a build reproducible by itself.** It records what was
  checked; reproducibility is §31.12 and the fixed point.
- **It does not re-derive the census.** The frame bound is not in the image
  and the image holds the runtime the census never saw; see "What is
  re-derived, and what is only attested". The report says *attested*.
- **It does not verify V3 or V4.** Dynamic accesses are counted, not checked,
  and the record says so in the same words the compiler does.
- **It does not protect against a compromised signer.** Mode 1 narrows that to
  the key's owner; nothing narrows it further without a transparency log.
- **It does not cover concurrency or FFI**, for the reasons in
  `docs/verifier-design.md`.
