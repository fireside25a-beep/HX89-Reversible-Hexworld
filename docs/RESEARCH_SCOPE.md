# Research scope and novelty audit

HX89 deliberately separates what is established in the literature from what this repository proves itself.

## Established background that must not be claimed as new

- Hardy, Pomeau and de Pazzis introduced early lattice-gas dynamics in 1973.
- Frisch, Hasslacher and Pomeau showed that suitable deterministic hexagonal Boolean lattice gases recover Navier-Stokes hydrodynamics in the macroscopic limit (Phys. Rev. Lett. 56, 1505, 1986; DOI 10.1103/PhysRevLett.56.1505).
- Frisch et al. developed the systematic lattice-gas hydrodynamic expansion in 1987.
- Yepez, Seeley and Margolus discussed deterministic definite-chirality hexagonal lattice gases and reversibility in the 1990s (arXiv:comp-gas/9403005 and related monograph material).
- Micci and Yepez use the same three-state cyclic two-body collision matrix, together with its transpose on alternating steps, in Phys. Rev. E 92, 033302 (2015), DOI 10.1103/PhysRevE.92.033302.
- Wolf-Gladrow, *Lattice-Gas Cellular Automata and Lattice Boltzmann Models* (Springer, 2000, DOI 10.1007/b72010) treats detailed/semi-detailed balance and the standard statistical-mechanical framework.
- Rivet and Boon, *Lattice Gas Hydrodynamics* (Cambridge University Press, 2001, DOI 10.1017/CBO9780511524707) is a standard monograph on microdynamics, Chapman-Enskog analysis, fluctuations and hydrodynamic regimes.
- Banerjee, Souslov, Abanov and Vitelli established odd viscosity in chiral active fluids (Nature Communications 8, 1573, 2017; DOI 10.1038/s41467-017-01378-7).
- Allocca, Heidari, Iadecola, Rahmani, Ghaemi and Ganeshan, *Odd fluids from chiral cellular automata* (arXiv:2606.19431, June 2026), explicitly analyze a chiral FHP model: unequal clockwise/counter-clockwise two-body scattering breaks parity and time reversal while preserving their product, and their coarse-grained hydrodynamics contains odd viscosity.
- Eren, Fruchart and Vitelli, Phys. Rev. E 114, 024109 (2026), derive hydrodynamics of collisional odd fluids from kinetic theory.
- Lamb and Quispel developed the general theory of reversing symmetries for discrete dynamical systems (Physica D 73, 277-304, 1994; DOI 10.1016/0167-2789(94)90101-5). Thus a reversing involution as a mathematical concept is not new.
- Hudong Chen derived entropy, fluctuation, transport and Onsager reciprocity results for lattice gases satisfying generalized semi-detailed balance (J. Plasma Phys. 57, 175-185, 1997; DOI 10.1017/S0022377896005314).
- Naitoh, Ernst, and Dufty analyzed long-time tails in the two-dimensional FHP cellular automaton (Phys. Rev. A 42, 7187, 1990; DOI 10.1103/PhysRevA.42.7187), so long-time correlations are a physical part of the Green-Kubo problem rather than artifacts to discard.

These results mean that calling the HX89 fixed-chirality `9 -> 18 -> 36` collision, parity breaking, odd viscosity, or reversible lattice-gas dynamics a new law would be incorrect.

## What this repository establishes directly

1. A canonical byte compiler and semantic right-inverse composition through Polyform -> Bell 202 -> HX0 -> HX89, with all 256 byte values and arena boundaries executed.
2. An exact mirror/chirality conjugacy for the deterministic gas.
3. An exact collision-dressed PT reversing involution for the complete split-step dynamics.
4. An exhaustive global machine certificate on all `2^24 = 16,777,216` states of a 2x2 torus, plus an independent larger-torus oracle.
5. The exact all-time echo identity `Theta_chi F_chi^t Theta_chi F_chi^t=I`, with an exhaustive one-step finite-state certificate and independent multi-time larger-torus checks.
6. A concrete finite-time correlation-reciprocity certificate for observables with definite `Theta` parity on the complete 2x2 state space.
7. Exact rank-three one-body linear collision invariants: mass and the two momentum components.
8. An exact algebraic transport-circle corollary obtained from the published 2026 chiral-FHP Boltzmann viscosity formulae, machine-checked in `Q(sqrt(3))`; this is attributed, not claimed as independent fluid physics.
9. An abstract isotropic-kernel theorem: if `M=aI+bJ` and `Z=K/(a+ib)` with chirality-independent `K`, then the anchored circle defect is `K^2(a_*-a)/[a_*(a^2+b^2)]`. Thus reactive drift `b` cannot break the circle; within this family the circle holds iff the dissipative scalar `a` is chirality-independent.

The symmetry, echo and kernel-defect identities are mathematical theorems under their stated assumptions. The repository does not label them a universal law of fluids, a continuum result, or a laboratory discovery. The physical upgrade - whether a correlation-renormalized chiral fluid satisfies `a(p)=a(1/2)` under a specified finite-size/time or RG prescription - remains open. Two-dimensional FHP long-time tails are treated as physical correlations, not artifacts to be removed. See `docs/THEOREM_STATUS.md`, `docs/TRANSPORT_CIRCLE.md`, and `docs/LITERATURE_BOUNDARY.md`.
