# Hexagonal particle experiment

`bin/hx89-gas` is an exact, finite Boolean lattice gas. A site on a periodic axial hexagonal grid holds six occupancy bits, one for each velocity `(1,0), (0,1), (-1,1), (-1,0), (0,-1), (1,-1)`. Time is discrete. The initial field is seeded and contains a denser rectangular central perturbation. There is no stochastic operation during evolution.

The local collision rotates the three opposite two-particle pairs in a cycle: `9 → 18 → 36 → 9`. It swaps the two alternating three-particle states `21 ↔ 42`. Every other six-bit state is fixed. These choices make the local map a permutation on all 64 states. Each changed state has the same occupancy and zero axial momentum before and after collision. The map commutes with a 60° rotation of the six velocity channels, checked exhaustively. Streaming translates each occupied velocity channel one periodic lattice step. Since translation is a permutation, global particle count and both axial momentum components are exactly conserved. The inverse step gathers translated channels and applies the inverse collision; repeated inverse steps recover the initial byte array exactly. The chosen pair cycle has a handedness under reflection; rotational covariance alone is not a continuum isotropy proof.

This is an original *implementation and composition* of established lattice-gas ideas, not a newly discovered physical law. The collision rule here is a selected deterministic reversible variant, not a reproduction of every FHP collision or a demonstrated Navier-Stokes limit. A finite state space and exact reverse do not imply a thermodynamic arrow or fluid transport coefficients. The grid is a two-dimensional physical-model slice alongside HX89's separate five-dimensional executable index space; its axial coordinates are not five-dimensional spacetime.

## Connected experiment

```sh
make all
./bin/hx89-gas 64 64 40 12345 density.pgm density.hx
./bin/hx89 density.hx 1 66
make audit
```

The simulator emits the actual evolved particle-density PGM and an `HX87P1` Polyform whose `EMIT` cells encode mean column occupancies as ASCII digits 0-6. HX89 executes these cells to print a measured profile. The release evidence then converts those bytes to binary symbols, modulates them onto the Bell 202 waveform, demodulates, and reconstructs the exact profile through HX0's byte assembler. This ties model state to the existing machine and signal paths, without pretending that the audio waveform itself performs the physics.

The complete image route uses an 8×8 lattice and the `--image-polyform` option. The generated Polyform contains an `EMIT` cell for every PGM header and pixel byte. Its actual source bytes travel as one-bit symbols over Bell 202 audio, are reconstructed by HX0, and only then execute in HX89. The emitted PGM is extracted from that execution trace and compared byte for byte with the independently evolved 8×8 oracle image. HX0 reconstructs the **Polyform file**, not the HX89 executable. The larger 64×64 run supplies a density image and a compact column-profile Polyform.

`tests/test_hex_gas.py` implements collision, initialization and streaming independently in Python, without importing a C header or sharing a compiled library. It exhausts 64 local states for inverse, mass, axial momentum and 60° rotational covariance. Reflection does **not** commute with the chiral pair-cycle collision; the independently checked relation is `R C R = C⁻¹`, where `R` reflects velocity channels and `C` is the local collision. It checks every intermediate conserved total on several grid sizes, compares the entire PGM byte for byte, runs the generated Polyform, and checks the full-image Bell/HX0/HX89 route. The C executable also remeasures conservation every forward tick and reverses the completed run to the initial bytes. For fixed seed `12345`, 64×64, 40 ticks, the release certificate is in `evidence/gas_certificate.txt`; the particle image, machine trace and audio are adjacent.

The check is falsifiable: alter a collision to violate occupancy or momentum, or alter one streaming direction, and the local, global, reverse, or independent grid checks fail. No empirical material, fluid or acoustic parameter is inferred from this simulation. A continuum claim would require a separate scaling study with isotropy, boundary conditions, transport coefficients, uncertainty and comparison to independent physical data. ASan/UBSan instrument the C gas engine in a separate run; they cannot instrument HX89's handwritten assembly, HX0's startup code or JIT instructions.

Research basis:

- Hardy, Pomeau, de Pazzis, [*Time Evolution of a Two-Dimensional Classical Lattice System*](https://doi.org/10.1103/PhysRevLett.31.276), 1973: an early particle lattice and sound correlations.
- Frisch, Hasslacher, Pomeau, [*Lattice-Gas Automata for the Navier-Stokes Equation*](https://doi.org/10.1103/PhysRevLett.56.1505), 1986: the hydrodynamic result for a class of hexagonal Boolean lattice gases, subject to the rules and scaling in that research.
- Margolus, [*Physics-like Models of Computation*](https://doi.org/10.1016/0167-2789(84)90252-5), 1984: exact local reversibility in computation.
