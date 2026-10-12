# HX89 memory-echo bootstrap: a two-symbol entrance

The first shared unit is a **state symbol**, represented as 0 or 1. It is not a CPU instruction. HX0 writes every symbol and its complement to private memory, orders the accesses, reads both locations back, verifies the returned state, and only then incorporates the observed bit into the next image byte. The ordinary Hexworld machine consumes that reconstructed canonical image. The optional PCM tool demonstrates another way of supplying the same symbols; the build path uses memory echo and does not depend on sound hardware.

```
0/1 symbols -> HX0 READ_BIT -> ECHO_BIT write/read -> byte accumulator
                                          -> Seed A / HX87SEM3 -> HX89 Hexworld
```

## Exact encoding

`seeds/hx89_seed.bits` and `seeds/hx89_semantics.bits` contain exactly eight bytes of value 0 or 1 for every canonical output byte, most significant bit first. The 73-byte HX0 program is written as inspectable assembler data in `boot/hx0_bitstream.S`; `as` and `objcopy` generate its binary, which the build compares to `seeds/hx0_bitstream.hx0` before executing it. The program uses HX0 `READ_BIT` (11), `ECHO_BIT` (12), and existing stack operations: start an accumulator at zero; eight times double it, observe the next bit through memory echo, and add the observed result; emit the resulting byte; repeat. EOF at a byte boundary halts; EOF inside a byte and any input symbol other than 0 or 1 fail. The same bytecode program is read by all three ISA-specific HX0 entrances.

`ECHO_BIT` checks both stored bit and stored inverse. The x86-64 implementation uses `mfence`, Arm uses `dmb ish`, and RISC-V uses `fence rw,rw` before the reads. These are architectural memory operations on private process memory. A cache or store buffer may satisfy the read; the test demonstrates the machine's architected state response, not a probe of a particular DRAM cell.

The Makefile executes this program to generate `build/hx87_seed.stageA` and `build/hx87_semantics.seed`. It compares them byte-for-byte against canonical files and independently regenerates the same images through the original ETCH path. The assembler embeds `build/hx87_semantics.seed` through its existing `.incbin` location. This is a real build dependency, not a post-build illustration.

`bin/pulse-pcm encode input.bits output.wav` writes a 44-byte RIFF/WAVE header followed by signed mono 8 kHz PCM16. Every bit occupies 64 samples: -12000 for zero and +12000 for one. `bin/pulse-pcm decode input.wav output.bits` checks the format, data length, per-window strength and mean before outputting symbols. The test suite sends both canonical images through the waveform and HX0, then byte-compares the results. This is a deterministic signal-format adapter; a physical microphone or voltage-sampling board needs an actual capture path to produce an equivalent WAV file.

HX89 provides `encode-fsk`/`decode-fsk` for a continuous-phase 125-baud tone and `encode-bell202`/`decode-bell202` for 1200-baud, 8N1 Bell 202 mark/space with an HX89 CRC trailer. The existing polarity decoder is used only for bipolar pulses; both tone routes compare quadrature energy at 1200 and 2200 Hz. The Makefile runs both tone routes through the same HX0 bootstrap and checks byte-for-byte equality. See [MULTIPATH.md](MULTIPATH.md).

## Research connection

Shannon's switching-circuit thesis connects two-state physical switches to Boolean operations. EDSAC's mercury delay lines stored timed acoustic pulses. Fredkin and Toffoli analyze computation with local reversible interactions. Cook proves that Rule 110 can support universal computation under suitable initial conditions. The actionable common point is that the *symbolic dynamics* can be separated from the physical carrier. It does not say that an arbitrary CPU executes the same reset bytes or that an unpowered computer decodes a signal without circuitry.

Other physical routes are genuine research subjects: acoustic logic networks implement several Boolean operations with sound waves, and fluidic logic uses interacting jets or droplets. Those works concern purpose-built physical gates. HX89's PCM adapter is a signal transducer running on an existing computer, not an acoustic or fluidic processor.

Primary/historical sources:

- Claude Shannon, *A Symbolic Analysis of Relay and Switching Circuits*, MIT: https://dspace.mit.edu/entities/publication/2dffdeb7-2862-4575-8a8e-b29fb59319e5
- Computer History Museum, EDSAC delay-line storage: https://www.computerhistory.org/storageengine/edsac-computer-employs-delay-line-storage/
- Fredkin and Toffoli, *Conservative Logic*: https://www.cs.princeton.edu/courses/archive/fall05/frs119/papers/fredkin_toffoli82.pdf
- Matthew Cook, *Universality in Elementary Cellular Automata*: https://www.complex-systems.com/abstracts/v15_i01_a01/
- *Acoustic logic networks realized with non-Hermitian and nonlocal metagratings*, Physical Review Applied: https://journals.aps.org/prapplied/abstract/10.1103/PhysRevApplied.22.024048
- *A brief history of liquid computers*, Philosophical Transactions B: https://pmc.ncbi.nlm.nih.gov/articles/PMC6553589/
