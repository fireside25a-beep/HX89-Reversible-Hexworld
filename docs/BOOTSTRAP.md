# HX87 bootstrap and fixed point

There is no native instruction encoding that x86-64, AArch64 and RV64 all execute directly. HX87 therefore separates physical entrance encoding from portable seed semantics.

## Stage 0  -  ISA entrance

`boot/x86_64/hx0.S`, `boot/aarch64/hx0.S` and `boot/riscv64/hx0.S` implement the same tiny HX0 bytecode machine. HX0 contains only the bootstrap vocabulary needed to reproduce the next stage.

The x86-64 entrance is assembled and executed by the release tests. The other two entrances are cross-assembled as real ELF objects on this host.

## Stage 1  -  ETCH fixed point

`seeds/hx0_etch.hx0` implements the bytewise involution `byte XOR 0xA5`. Executing the generated Stage1 program again produces byte-identical Stage2.

## Stage 2  -  Seed A and semantic image

The build must execute HX0 to reproduce both checked canonical images:

```text
HX0 + hx87_seed.etch      -> build/hx87_seed.stageA
HX0 + hx87_semantics.etch -> build/hx87_semantics.seed
```

The second image begins with `HX87SEM3` and defines Q^2 base/state/bias, the complete opcode count and the opcode-to-primitive map. `bin/hx89` embeds the image generated during that build, not a handwritten duplicate.

## Stage 3  -  HX87 fixed point

Seed A is itself executable HX87. `DUMP` emits the canonical live Polyform. Release tests require:

```text
Seed A -> Seed B -> Seed C
Seed B == Seed C
```

## Stage 4  -  Hexworld

`hexworld_enter` verifies `HX87SEM3` before the first cell can retire. From that point, cells, Q^2 evolution, 5D heads, Conway nodes, entropy, mutation epochs and persistence are the semantic machine. Native acceleration is a disposable physical realization below this layer.

## HX89 0.4 signal entrance

The build now regenerates Seed A and `HX87SEM3` from one-bit symbols using `seeds/hx0_bitstream.hx0`, then byte-compares them with the independent ETCH route. `docs/SIGNAL_BOOTSTRAP.md` specifies the decoder, PCM transducer and evidence. The existing `.incbin` path consumes the bit-reconstructed semantic image.
