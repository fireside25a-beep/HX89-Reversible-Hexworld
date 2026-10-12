# Canonical byte-Polyform composition lemma

HX89 makes the compiler/loader statement explicit and executable.

Let `E(b)` be the canonical compiler implemented by `bin/byte-polyform`: for a byte string
`b = b0...b(m-1)` with `0 <= m <= 4095`, it emits an `HX87P1` file containing exactly one ordered `EMIT` cell per byte followed by one `HALT` cell. Let `A` convert a file to strict one-bit symbols, `B` be Bell 202 encode/decode, `L` be the HX0 bitstream assembler, and `X` be HX89 execution. Let `pi_m` select the first `m` bytes emitted by those ordered cells after the normal HX89 runtime header.

For every payload in the compiler domain, under a successful Bell decode,

`pi_m(X(L(B(A(E(b)))))) = b`.

This is a semantic right inverse, not a byte-for-byte inverse of arbitrary Polyform text. HX0 reconstructs the canonical Polyform file exactly; HX89 then parses that file and emits the payload semantics. Formatting comments and parser-internal representation are not part of the inverse claim.

## Why the lemma holds

1. `E` is injective on payload semantics because byte `bi` is written as the decimal argument of cell `i`, and positions are strictly increasing.
2. `A` writes the eight bits of every Polyform source byte in order.
3. Bell 202 decoding is required to return those symbols exactly; the existing independent waveform oracle tests synchronization, phase-continuous tones, framing, channel perturbations and CRC rejection.
4. HX0 groups each strict eight-symbol block into the original byte and therefore reconstructs `E(b)` byte for byte.
5. HX89 loads ordered cells and opcode `EMIT` writes the stored byte argument. The following `HALT` prevents execution from extending into another payload cell.

`tests/test_composition.py` executes all 256 possible byte values in one payload, transports the complete generated Polyform through Bell 202 and HX0, checks deterministic recompilation, checks the empty payload, checks the exact 4095-byte arena boundary, and rejects 4096 payload bytes.

The lemma is a software semantics theorem for this compiler/loader class. It does not imply that arbitrary text files, arbitrary malformed Polyforms, or arbitrary noisy channels are invertible.
