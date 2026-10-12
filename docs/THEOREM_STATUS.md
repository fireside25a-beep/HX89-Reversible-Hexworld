# HX89 scientific status: theorem, derived corollary, open problem

This file is the status ledger for scientific claims in the repository. It is intentionally stricter than release prose. A statement belongs in exactly one tier below.

## Tier I  -  proved for the defined HX89 objects

### I.1 Collision-dressed microscopic reversibility

For the deterministic six-channel gas implemented by `src/chiral_law.c`, chirality is a discrete variable

`chi in {-1,+1}`.

Let `C_chi` be the local collision permutation, `S` toroidal streaming, `F_chi = S C_chi`, `P` the axial reflection used in `docs/CHIRAL_RECIPROCITY.md`, and `V` velocity reversal. Define

`Theta_chi = C_-chi P V`.

The local operator identities imply

`Theta_chi^2 = I`,

`Theta_chi F_chi Theta_chi = F_chi^-1`.

Therefore, for every integer `t`,

`Theta_chi F_chi^t Theta_chi F_chi^t = I`.

This is an all-time theorem on every finite periodic axial torus. It is not inferred from numerical fitting. The standalone C certificate exhaustively checks all `2^24 = 16,777,216` states of the complete 2x2 six-channel torus for both chiralities; an independent Python implementation checks larger tori and multiple echo times.

### I.2 One-body collision invariants

The exact rational elimination in `tests/test_chiral_law.py` gives a three-dimensional space of one-body linear collision invariants. A basis is particle number and the two momentum components. This is a theorem for the collision table used here.

### I.3 Isotropic shear-kernel normal form

Let a real linear operator `M` act on the two-dimensional shear doublet and commute with the nontrivial `C6` rotation. The real commutant of that rotation is

`M = a I + b J`, with `J^2 = -I`.

This is the real two-dimensional form of Schur's lemma: the only rotation-commuting endomorphisms are a scalar dissipative part and a quarter-turn reactive part.

Assume, at fixed density and fixed renormalization scale/scheme, that the complex response can be written

`Z(p) = eta_bar(p) + i eta_H(p) = K / [a(p) + i b(p)]`,

where `K` is real, nonzero and independent of `p`. Let the parity-symmetric anchor be `p_* = 1/2`, for which `b(p_*) = 0`, and write

`a_* = a(p_*)`,  `Z_* = K/a_*`.

Define the anchored circle defect

`Delta(p) = |Z(p)|^2 - Z_* Re Z(p)`.

Direct inversion gives the exact identity

`Delta(p) = K^2 [a_* - a(p)] / { a_* [a(p)^2 + b(p)^2] }`.       (KD)

Consequences, under the stated assumptions:

- arbitrary reactive/odd drift `b(p)` cannot by itself create a circle defect;
- the anchored circle holds exactly iff `a(p) = a_*`;
- inside the `a I + b J` family with a `p`-independent scalar prefactor `K`, there is no third mechanism: circle preservation is equivalent to dissipative flatness.

This is an algebraic theorem. It does **not** prove that a physical Green-Kubo kernel has `a(p)=a_*`, nor that a chosen `K` is unrenormalized or `p`-independent.

## Tier II  -  exact corollary of a published analytical model

Allocca et al., *Odd fluids from chiral cellular automata* (arXiv:2606.19431, 2026), derive the chiral-FHP Boltzmann/Chapman-Enskog transport coefficients. Rewriting those published zero-field expressions gives

`eta_bar = A/(1+u^2)`,

`eta_H   = -A u/(1+u^2)`,

and therefore

`(eta + 1/8 - A/2)^2 + eta_H^2 = (A/2)^2`.

Equivalently, with their shear-sector eigenvalue `lambda`,

`eta_bar + i eta_H = -1/[4 conjugate(lambda)]`.

`tests/test_transport_circle.py` checks this elimination, the spectral identity and the weak-field image exactly in `Q(sqrt(3))`. The algebra is proved; the underlying kinetic-theory coefficients are attributed to the cited work. This tier is not an HX89 claim of new continuum physics.

## Tier III  -  open physical problem

The unresolved question is whether a properly defined correlation-renormalized shear kernel obeys

`a(p) = a(p_*)`

at fixed density and under a specified finite-size/time or renormalization prescription.

`C6` symmetry alone does not force this equality. Parity gives only

`a(p) = a(1-p)`,  `b(p) = -b(1-p)`.

That allows an arbitrary even drift in `a(p)`, including a leading `(p-1/2)^2` term. Thus circularity is stronger than symmetry.

A Ward-identity upgrade would require additional structure beyond `C6`: for example a conservation law, hidden symmetry, exact decoupling, or a vanishing anomalous contribution that makes the dissipative-flat submanifold invariant under renormalization. None of those is proved here.

A convenient RG statement is the following. Let `ell` denote scale and `beta_a(p,ell) = d a(p,ell)/d ell`. The circle-preserving manifold is

`a(p,ell) - a(p_*,ell) = 0` for all `p`.

For it to be RG invariant, a necessary and sufficient local flow condition is

`beta_a(p,ell) - beta_a(p_*,ell) = 0`

whenever the system lies on that manifold. Establishing such a relation from the microscopic theory would be the missing theorem.

## Critical implementation boundary

The HX89 C sources do **not** implement a continuous stochastic chirality parameter `p`. `src/chiral_law.c` and `src/hex_gas.c` implement the two deterministic endpoints `chi=-1` and `chi=+1`. The continuous `p` family appears only in the separately attributed analytical transport formulas used by `tests/test_transport_circle.py`.

Therefore the exhaustive `2^24` machine certificate proves the endpoint automaton theorems; it does not sample or prove the `p`-dependent Green-Kubo conjecture.

## Long-time-tail boundary

Two-dimensional FHP-type cellular-automaton fluids have documented long-time stress correlations. Naitoh, Ernst, and Dufty, *Long-time tails in two-dimensional cellular automata fluids*, Phys. Rev. A 42, 7187 (1990), DOI 10.1103/PhysRevA.42.7187, report an intermediate `1/t` tail and a later self-consistent asymptotic form. These are physical correlation effects, not finite-size noise to be “removed.”

For that reason the open problem should be formulated either with finite `(L,T)` Green-Kubo coefficients or with an explicit running/renormalized transport prescription before taking limits. HX89 does not assume that discrete velocities eliminate the long-time-tail problem.

Odd viscosity is nondissipative in the standard constitutive sense, but this repository does not assume a universal theorem that classical odd viscosity is immune to hydrodynamic fluctuation renormalization. Results for gapped quantum Hall fluids and for classical chiral active fluids are distinct settings and are not conflated here.

## Claim rule

A future paper or release may call the kernel defect identity (KD) a theorem. It may call the correlation-renormalized circle a theorem only after `a(p)=a_*` (or an equivalent Ward/RG statement) has been proved in a specified physical model. Until then the physical statement is a conjecture and every finite-size numerical result is evidence, not proof.
