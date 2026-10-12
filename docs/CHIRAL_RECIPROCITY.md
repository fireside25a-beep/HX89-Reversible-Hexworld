# Exact chiral reciprocity and collision-dressed PT reversal

This document states the strongest exact microscopic reciprocity result established in HX89. It is a theorem about the finite deterministic lattice gas implemented here. It is **not** presented as a newly established continuum law of ordinary matter.

## Model

A site of the periodic axial hexagonal lattice carries six Boolean velocity channels

`c0=(1,0), c1=(0,1), c2=(-1,1), c3=(-1,0), c4=(0,-1), c5=(1,-1)`.

`C+` maps the zero-momentum pair states `9 -> 18 -> 36 -> 9`, swaps `21 <-> 42`, and fixes the other local states. `C- = C+^-1`. Streaming `S` moves channel `i` by `ci`. One full forward step is

`F_chi = S C_chi`,  `chi in {+1,-1}`.

On an `n x n` torus define geometric reflection

`P: (x,y,i) -> (x+y, -y, -i)  (mod n, mod 6)`

and velocity reversal

`V: (x,y,i) -> (x,y,i+3)`.

The local collision obeys `P C_chi P = C_-chi`. Geometric reflection commutes with streaming, while velocity reversal conjugates streaming to its inverse.

## Theorem 1  -  mirror/chirality reciprocity

For every finite `n x n` torus, every state `q`, every integer `t >= 0`,

`P F_+^t(q) = F_-^t(P q)`.

Equivalently, `P F_+ P = F_-`.

This is exact at the microscopic trajectory level: no ensemble average, continuum limit, low-Mach expansion, molecular-chaos assumption, or fitted coefficient is used. Any reflection-even observable has the same value on mirrored `+/-` trajectories; any reflection-odd observable changes sign.

### Corollary  -  exact finite-time chirality reciprocity

Let `mu` be any initial ensemble invariant under `P`. For an observable `A` with reflection parity `eps_A` (`A(Pq)=eps_A A(q)`, `eps_A=+1` or `-1`), the complete finite-time distribution obeys

`Law_mu[A(F_+^t q)] = Law_mu[eps_A A(F_-^t q)]`.

Therefore every even moment is identical for the two chiralities and every odd moment of a reflection-odd observable changes sign. This is a trajectory-pairing identity, not a linear-response approximation. In any continuum regime that exists, it forces parity-even transport data to be chirality-even and parity-odd transport data to be chirality-odd.

## Theorem 2  -  collision-dressed PT reversor

Define

`Theta_chi = C_-chi P V`.

Then

`Theta_chi^2 = I`

and

`Theta_chi F_chi Theta_chi = F_chi^-1`.

The extra `C_-chi` is required by the collision-then-stream time convention. It shifts the microscopic time section by one collision phase. This produces an exact reversing involution even though a fixed chiral collision table is not invariant under plain reflection or plain velocity reversal separately.

### Proof

The local identities are

`P C_chi P = C_-chi = C_chi^-1`,

`V C_chi V = C_chi`,

and `P` commutes with `V`. Streaming satisfies

`P S P = S`,  `V S V = S^-1`.

Let `K = P V`. Therefore `K C_chi K = C_-chi` and `K S K = S^-1`. Since `K C_chi = C_-chi K`,

`Theta_chi = C_-chi K = K C_chi`,

so `Theta_chi^2 = C_-chi K K C_chi = I`. Finally,

`Theta_chi F_chi Theta_chi`
`= C_-chi K (S C_chi) K C_chi`
`= C_-chi S^-1 C_-chi C_chi`
`= C_-chi S^-1`
`= F_chi^-1`.

The argument is independent of lattice size once the torus admits the stated axial reflection.


### Corollary  -  exact chiral echo law

For every integer `t`, the reversing identity exponentiates to

`Theta_chi F_chi^t Theta_chi = F_chi^-t`.

Therefore

`Theta_chi F_chi^t Theta_chi F_chi^t = I`.

Operationally: evolve the digital fluid forward for `t` steps, apply `Theta_chi`, evolve forward for the same `t`, and apply `Theta_chi` once more. The initial microscopic state is recovered bit for bit. This is exact for the defined automaton and requires no hydrodynamic approximation. It is the strongest compact “law” established by this release; its scope is a reversible finite-state lattice gas, not arbitrary continuum fluids.

### Corollary  -  exact reversing-correlation reciprocity

For any probability measure invariant under both `F_chi` and `Theta_chi`, and observables `A,B` with `Theta` parities `eps_A,eps_B`,

`< A(F_chi^t q) B(q) > = eps_A eps_B < B(F_chi^t q) A(q) >`.

This is the finite deterministic-map form of a reversing-symmetry/Onsager-Casimir-type identity. General reversing symmetries and Onsager reciprocity are established ideas; the release does not claim to have invented them. What is established here is the explicit local `Theta_chi = C_-chi P V` for this split-step gas and its exhaustive executable certificate.

## Machine certificate

`bin/hx89-chiral-proof` checks both local identities on all 64 local states for both chiralities and then enumerates **all 16,777,216 states** of the complete `2 x 2 x 6-bit` torus. For every global state it checks mirror/chirality reciprocity, `Theta^2=I`, the dressed-PT reversing identity against an independently coded inverse step, and the one-step exact echo. It also constructs observables of definite `Theta` parity and exhaustively checks a nonzero finite-time correlation-reciprocity identity for each chirality.

`tests/test_chiral_law.py` is a separate Python implementation. It also checks larger `3x3`, `4x4`, `5x5`, and `7x7` tori on deterministic pseudorandom states, verifies exact echoes for `t=0,1,2,3,7`, and performs exact rational rank reduction on the occupation-change matrix. That rank is three, with mass and the two momentum components spanning the one-body linear collision invariants.

## Scientific scope

The exact theorem is stronger than a fitted simulation observation but narrower than a continuum fluid law. Classic FHP work already establishes hydrodynamic limits for suitable hexagonal lattice gases. Deterministic definite-chirality rules also predate this release, and 2026 work explicitly derives odd viscosity for a chiral FHP automaton. Therefore HX89 does **not** claim discovery of chiral FHP, odd viscosity, Navier-Stokes, or microscopic reversibility.

The candidate original contribution is the explicit finite-trajectory reciprocity/reversor theorem above, tied to an executable exhaustive certificate and to the byte-exact signal-bootstrapped machine path. A publication-level novelty claim still requires independent scholarly review beyond a targeted literature search.
