# HX89 research note: exact chiral echo, semantic closure, and the transport-kernel defect theorem

## Abstract

HX89 organizes the signal-bootstrapped lattice-gas system into a set of sharply separated mathematical claims. For the canonical byte compiler, the complete `byte -> Polyform -> Bell 202 -> HX0 -> HX89` route is a semantic right inverse on payloads of length `0..4095`. For the deterministic six-channel chiral hex gas, an explicit collision-dressed involution

`Theta_chi = C_-chi P V`

satisfies

`Theta_chi^2 = I`,

`Theta_chi F_chi Theta_chi = F_chi^-1`.

Consequently the exact echo protocol

`Theta_chi F_chi^t Theta_chi F_chi^t = I`

holds for every integer `t` on every finite periodic axial torus. The same reversor yields finite-time correlation reciprocity for `Theta`-parity observables under invariant ensembles. An independent C certificate exhausts all `2^24=16,777,216` states of the complete 2x2 torus for both chiralities, while a separate Python implementation checks larger tori and proves by exact rank reduction that mass plus the two momentum components span the one-body linear collision invariants.

A targeted literature audit rules out several tempting overclaims: FHP hydrodynamics, definite-chirality lattice gases, reversing symmetries and odd viscosity are prior art. A 2026 chiral-FHP analysis by Allocca et al. supplies analytical shear and Hall viscosity formulae. Eliminating its chirality parameter produces an exact transport-circle corollary within that Boltzmann/Chapman-Enskog theory. HX89 machine-checks the circle and its weak-field image in exact `Q(sqrt(3))` arithmetic. The release then sharpens the open problem with an exact isotropic-kernel defect theorem: under an explicitly stated `M=aI+bJ`, `Z=K/(a+ib)` response model, circle failure is exactly equivalent to chirality-dependent drift of the dissipative scalar `a`. Whether that scalar is physically flat after correlation renormalization remains a falsifiable open problem.

## 1. What is proved in HX89

### 1.1 Semantic composition law

For a payload `b`, let `E(b)` be the canonical Polyform produced by `bin/byte-polyform`, `A` its strict bit serialization, `B` successful Bell 202 encode/decode, `L` HX0 bitstream reconstruction and `X` HX89 execution. If `pi_m` selects the `m=|b|` payload bytes emitted by the canonical cells, then

`pi_m(X(L(B(A(E(b)))))) = b`, `0 <= m <= 4095`.

The statement is a semantic right inverse. It does not assert that the HX89 parser preserves arbitrary source formatting. The executable test covers every byte value, deterministic recompilation, the empty input, the 4095-byte arena boundary and rejection of 4096 bytes.

### 1.2 Mirror/chirality conjugacy

Let `F_chi=S C_chi`, with local collision chirality `chi in {-1,+1}`. For the axial reflection

`P:(x,y,i)->(x+y,-y,-i)`

one has

`P C_chi P = C_-chi`

and therefore

`P F_+ P = F_-`.

This pairs the complete microscopic trajectory of one chirality with the reflected trajectory of the opposite chirality.

### 1.3 Collision-dressed chiral echo law

Velocity reversal `V:i->i+3` reverses streaming but commutes with the collision table. The collision-then-stream convention means plain `PV` is not the correct same-time-section reversor. Dressing it by the inverse local collision gives

`Theta_chi = C_-chi P V`.

The local operator identities imply

`Theta_chi^2=I`,

`Theta_chi F_chi Theta_chi=F_chi^-1`.

By induction,

`Theta_chi F_chi^t Theta_chi = F_chi^-t`

and hence

`Theta_chi F_chi^t Theta_chi F_chi^t = I`                    (ECHO)

for every integer `t`. This is an exact digital-fluid echo law: evolve forward for `t`, apply `Theta`, evolve forward for the same `t`, apply `Theta` again, and recover the initial microstate bit-for-bit.

The term "law" here means an exact theorem of the specified automaton, not a new universal law of continuum matter.

### 1.4 Finite-time correlation reciprocity

If a probability measure `mu` is invariant under both `F_chi` and `Theta_chi`, and observables satisfy

`A(Theta q)=eps_A A(q)`, `B(Theta q)=eps_B B(q)`,

then

`<A(F_chi^t q) B(q)>_mu = eps_A eps_B <B(F_chi^t q) A(q)>_mu`.   (REC)

This follows by the change of variables `q -> Theta F_chi^t q`, not by a continuum approximation. It is a concrete finite-map instance of the broader reversing-symmetry/Onsager-Casimir framework, whose general theory predates HX89.

## 2. Machine evidence

The C checker `bin/hx89-chiral-proof` is independent of the production gas source. Locally it enumerates all 64 site states for both chiralities and verifies inverse collision, mass conservation, both momentum components, reflection/chirality conjugacy and velocity-reversal commutation. Globally it enumerates all 16,777,216 states of the 2x2x6-bit torus and checks mirror conjugacy, `Theta^2=I`, the reversing identity, the one-step exact echo and a constructed even/odd correlation reciprocity identity for both chiralities.

`tests/test_chiral_law.py` independently implements the map, checks deterministic random states on 3x3, 4x4, 5x5 and 7x7 tori, exercises echo times `0,1,2,3,7`, and performs exact rational rank reduction of all local occupation changes. `tests/sanitize.sh` rebuilds the C proof with ASan/UBSan and runs a real `2^18`-state global prefix in addition to all 64 local states; the optimized non-sanitized proof remains the exhaustive `2^24` certificate.

The exhaustive 2x2 enumeration is a machine certificate for that finite state space. The all-size theorem does not come from extrapolating those 2x2 results; it follows from the operator proof above.

## 3. Literature boundary

The 1986 FHP work already established that appropriate deterministic Boolean hexagonal lattice gases recover Navier-Stokes hydrodynamics. Later literature developed lattice-gas transport, Green-Kubo relations and generalized reciprocity. Yepez, Seeley and Margolus discussed deterministic definite-chirality lattice-gas automata in the 1990s. General reversing symmetries were formalized by Lamb and Quispel. Odd/Hall viscosity has an extensive literature, including chiral active fluids.

Most importantly for this release, Allocca et al. (2026) construct a chiral FHP automaton with unequal clockwise/counter-clockwise two-body scattering and derive analytical ordinary and Hall viscosities, verified against Poiseuille-flow simulations. Therefore HX89 does not claim to have discovered chiral FHP, parity breaking, microscopic reversibility, Navier-Stokes emergence or odd viscosity.

The narrowly defensible HX89 contribution is the explicit collision-dressed reversor for this split-step deterministic rule, its exact echo/correlation consequences, the executable exhaustive certificate, and integration with the semantic signal-bootstrap closure.

## 4. Transport-circle corollary

For the zero-field formulas of Allocca et al., define

`D=rho(1-rho/6)^3`, `A=1/(2D)`, `d=p-1/2`, `u=(2sqrt(3)/3)d`,

`eta_bar=eta+1/8`.

Their transport coefficients can be rewritten

`eta_bar=A/(1+u^2)`,

`eta_H=-Au/(1+u^2)`.

Therefore

`(eta+1/8-A/2)^2 + eta_H^2 = (A/2)^2`.                     (CIRCLE)

At fixed density the Boltzmann transport pair lies on a circle arc as chirality is varied. Equivalently, if `lambda` is the complex shear collision eigenvalue,

`eta_bar+i eta_H = -1/(4 conjugate(lambda))`.

The circle is therefore the complex inversion image of the fixed-real-part shear-eigenvalue line. In the weak magnetic-field formula the same complex variable is divided by `1+iB/2`, producing a scaled and rotated circle. `tests/test_transport_circle.py` verifies these identities without floating point over 3,575 rational `(rho,p,B)` triples in `Q(sqrt(3))`.

This is an algebraic corollary of published coefficients, not evidence that HX89 discovered a new physical law. The literature search performed for this repository did not identify this exact circle parametrization, but absence from a targeted search is not a priority proof.

## 5. Kernel defect theorem and the physical open problem

The transport geometry can be sharpened without pretending that the correlated fluid has already been solved. On the real two-dimensional shear doublet, `C6` covariance forces any commuting linear kernel into

`M(p)=a(p)I+b(p)J`, with `J^2=-I`.

Assume at fixed density and fixed scale/scheme that the complex response is

`Z(p)=eta_bar(p)+i eta_H(p)=K/[a(p)+i b(p)]`,

with real nonzero `K` independent of `p`. At the parity-symmetric anchor `p_*=1/2`, write `a_*=a(p_*)` and use `b(p_*)=0`. The circle through `0` and `K/a_*` has exact defect

`Delta(p)=|Z|^2-(K/a_*) Re Z`

`        =K^2[a_*-a(p)]/{a_*[a(p)^2+b(p)^2]}`.             (DEFECT)

Hence, inside this explicitly stated kernel family, odd/reactive renormalization `b(p)` cannot by itself destroy the circle. The anchored circle holds if and only if the dissipative scalar is flat: `a(p)=a_*`. This is an algebraic theorem and is independent of the detailed Boltzmann parameterization.

The physical open problem is exactly the missing equality `a(p)=a_*` for a correlation-renormalized chiral fluid. `C6` and parity do not imply it: they only require `a(p)=a(1-p)` and `b(p)=-b(1-p)`, allowing an even drift such as `c_2(p-1/2)^2`. A Ward-identity proof would need additional structure that makes the dissipative-flat submanifold invariant under renormalization.

The Green-Kubo question must also respect two-dimensional long-time tails. Naitoh, Ernst, and Dufty explicitly found algebraic long-time correlations in the two-dimensional FHP cellular automaton. Therefore the clean formulation uses finite `(L,T)` coefficients or a stated running/renormalized kernel before taking limits; the tail is physical, not an error bar to be “removed.”

Finally, the executable HX89 gas has no continuous stochastic `p`. `src/chiral_law.c` and `src/hex_gas.c` implement only `chi=+1` and `chi=-1`. The continuous `p` family belongs to the separately attributed analytical model used by the transport regression. The endpoint machine certificate must not be presented as a simulation of the `p`-family.

See `docs/THEOREM_STATUS.md` and `docs/TRANSPORT_CIRCLE.md` for the formal statement and assumptions.

## 6. Why this is stronger than the previous demo

The earlier closed loop showed an engineered end-to-end identity: gas state -> image -> Polyform -> acoustic carrier -> HX0 reconstruction -> HX89 execution -> identical image. The integrated repository includes a theorem layer. The signal path now has a stated semantic composition law; the chiral automaton has an explicit reversing involution and exact echo; and the continuum-facing transport observation is separated into a proved algebraic corollary and an open physical conjecture. Each claim has a matching test or a clearly stated missing experiment.

## 7. Reproducibility commands

From the release root:

```sh
make clean all
make check
make audit
make sanitize
```

The release package includes the C and Python proof implementations, generated evidence, exact transport-circle certificate and SHA-256 manifest. No placeholder result is used as evidence.

## References

- U. Frisch, B. Hasslacher, Y. Pomeau, “Lattice-Gas Automata for the Navier-Stokes Equation,” *Physical Review Letters* 56, 1505 (1986), DOI 10.1103/PhysRevLett.56.1505.
- J. W. Dufty, M. H. Ernst, “Green-Kubo relations for lattice gas cellular automata,” *J. Phys. Chem.* 93, 7015-7019 (1989), DOI 10.1021/j100356a026.
- T. Naitoh, M. H. Ernst, J. W. Dufty, “Long-time tails in two-dimensional cellular automata fluids,” *Physical Review A* 42, 7187 (1990), DOI 10.1103/PhysRevA.42.7187.
- R. Schmitz, J. W. Dufty, “Positivity of transport coefficients for cellular automata,” *Physical Review A* 41, 4294 (1990), DOI 10.1103/PhysRevA.41.4294.
- J. Yepez, G. P. Seeley, N. Margolus, “Lattice-Gas Automata Fluids on Parallel Supercomputers,” arXiv:comp-gas/9403005 (1994).
- J. S. W. Lamb, G. R. W. Quispel, “Reversing k-symmetries in dynamical systems,” *Physica D* 73, 277-304 (1994), DOI 10.1016/0167-2789(94)90101-5.
- H. Chen, “Entropy, fluctuation and transport in lattice gas systems with generalized semi-detailed balance,” *J. Plasma Phys.* 57, 175-185 (1997), DOI 10.1017/S0022377896005314.
- D. A. Wolf-Gladrow, *Lattice-Gas Cellular Automata and Lattice Boltzmann Models*, Springer (2000), DOI 10.1007/b72010.
- J.-P. Rivet, J. P. Boon, *Lattice Gas Hydrodynamics*, Cambridge University Press (2001), DOI 10.1017/CBO9780511524707.
- J. E. Avron, R. Seiler, P. G. Zograf, “Viscosity of Quantum Hall Fluids,” *Physical Review Letters* 75, 697 (1995), DOI 10.1103/PhysRevLett.75.697.
- D. Banerjee, A. Souslov, A. G. Abanov, V. Vitelli, “Odd viscosity in chiral active fluids,” *Nature Communications* 8, 1573 (2017), DOI 10.1038/s41467-017-01378-7.
- A. A. Allocca et al., “Odd fluids from chiral cellular automata,” arXiv:2606.19431 (2026).
