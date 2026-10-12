# Literature and novelty check

## Established ingredients

The literature already contains the major physical ingredients separately:

- Allocca et al. (2026) derive the chiral-FHP collision eigenvalue and analytical shear/Hall viscosities, and compare them with automaton simulations.
- Epstein and Mandadapu (2020) derive Green--Kubo relations for isotropic two-dimensional nonequilibrium viscous fluids, including odd viscosity.
- Hargus et al. (2020) test odd/shear Green--Kubo relations against nonequilibrium molecular dynamics in active fluids.
- Banerjee et al. (2017) describe odd viscosity as a nondissipative transverse response in chiral active fluids.
- Fruchart et al. (2023) connect odd transport to non-Hermitian/chiral linearized collision operators.
- Bradlyn, Goldstein and Read (2012) give first-principles viscosity Kubo formulas and genuine Ward identities.
- Naitoh, Ernst and Dufty (1990) show long-time tails in the two-dimensional FHP cellular automaton.
- Eren, Fruchart and Vitelli (2026) analyze hydrodynamic variables and response coefficients using the collision-operator spectrum in a collisional odd-fluid kinetic model.

## Combination isolated here

This repository isolates the following combination:

1. the diameter-circle hidden in the published zero-field chiral-FHP Boltzmann coefficients;
2. the closure-free equivalence between that anchored circle and a constant real part of the **actual inverse response** `1/Z`;
3. the exact C6 commutant reduction of the shear doublet to `aI+bJ`;
4. the exact defect formula separating reactive motion from dissipative inverse-response drift;
5. a curvature formula for the second fundamental form at the achiral point, together with an explicit quartic-drift warning showing that local curvature is not a global classifier;
6. an RG tangency condition for scale-by-scale survival;
7. an explicit stable, positive-dissipation, C6/reflection-covariant Green--Kubo counterexample;
8. a precise distinction between an identified reduced spectral block and a bare full spectrum.

Targeted searches of the sources listed in `REFERENCES.md` did not locate this exact anchored-circle/inverse-response classification.  That is a **novelty lead**, not a proof of priority.  A publication claim should still be preceded by a systematic bibliographic search and expert comparison with adjacent response-geometry and memory-matrix literature.

## Most important negative result

The source checks do **not** support the statement “C6 protects the circle.”  C6 supplies the complex-scalar two-coordinate form; it does not freeze the real inverse-response coordinate.  The explicit OU witness demonstrates this constructively.

## Strongest next result

The model-specific breakthrough would be to identify a microscopic conservation law, exact resolvent relation or controlled RG mechanism that enforces

`Re[1/Z_ell(p)] = Re[1/Z_ell(p0)]`

for the correlated chiral-FHP model at every relevant scale.  If such a mechanism exists, it would upgrade the current classification from “exact partition with witnesses” to “exact protection in a specific interacting model.”
