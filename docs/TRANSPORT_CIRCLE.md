# Transport circle: exact algebra, kernel defect theorem, and open Green-Kubo problem

This note deliberately separates three statements with different evidentiary status:

1. an exact circle obtained by eliminating the chirality parameter from the published 2026 chiral-FHP Boltzmann coefficients;
2. a model-independent algebraic defect identity for an isotropic two-dimensional shear doublet;
3. an open question about correlation-renormalized Green-Kubo transport.

The underlying viscosity formulae in Section 1 are from Andrew A. Allocca, Shiva Heidari, Thomas Iadecola, Armin Rahmani, Pouyan Ghaemi and Sriram Ganeshan, *Odd fluids from chiral cellular automata*, arXiv:2606.19431 (2026). HX89 does not claim those formulae as its discovery.

## 1. Published-model transport circle

Write

`D = rho (1-rho/6)^3`,

`d = p-1/2`,

`A = 1/(2D)`,

`u = (2 sqrt(3)/3) d`,

and `eta_bar = eta + 1/8`.

The cited zero-field expressions can be written

`eta_bar = A/(1+u^2)`,

`eta_H   = -A u/(1+u^2)`.

Eliminating `u` gives

`eta_bar^2 + eta_H^2 = A eta_bar`,

or

`(eta + 1/8 - A/2)^2 + eta_H^2 = (A/2)^2`.                 (TC0)

Thus, inside those analytical formulae and at fixed density, the transport pair lies on an arc of a circle centered at `(A/2-1/8,0)` in the `(eta,eta_H)` plane.

This is an exact algebraic corollary of the published kinetic theory. It is not a proof that the fully correlated lattice gas or a laboratory fluid obeys the same circle.

## 2. Spectral form

For the same zero-field theory,

`lambda = -D/2 + i sqrt(3) D d/3`.

Define

`Z = eta_bar + i eta_H`.

Then

`Z = -1/[4 conjugate(lambda)]`.                              (TS)

As `p` varies, the Boltzmann `lambda` lies on a vertical line because `Re(lambda)=-D/2` is independent of `p`. Complex inversion maps that line to the transport circle.

This geometric form motivates the stronger question: does correlation renormalization preserve a vertical dissipative locus, or does it bend it?

## 3. Exact isotropic kernel theorem

Let `M(p)` be a real linear response kernel on the two-dimensional shear doublet. Assume `M` commutes with the nontrivial `C6` rotation. The real commutant is

`M(p) = a(p) I + b(p) J`,  with `J^2=-I`.                    (K1)

Here `a` is the dissipative scalar and `b` is the reactive/odd scalar in this two-component sector.

Assume the complex response at fixed density and fixed scale/scheme has the form

`Z(p) = K/[a(p)+i b(p)]`,                                    (K2)

with a real nonzero prefactor `K` independent of `p`. Let `p_*=1/2` be the parity-symmetric anchor, so `b(p_*)=0`, and define

`a_* = a(p_*)`,  `Z_* = K/a_*`.

The circle through `0` and `Z_*` has equation

`|Z|^2 = Z_* Re Z`.                                          (K3)

Using (K2),

`|Z|^2 = K^2/[a^2+b^2]`,

`Re Z = K a/[a^2+b^2]`.

Therefore its exact defect is

`Delta(p) := |Z|^2 - Z_* Re Z`

`          = K^2 [a_* - a(p)] / {a_* [a(p)^2+b(p)^2]}`.     (KD)

This proves:

**Reactive immunity inside the kernel family.** Changing `b(p)` alone cannot create a nonzero defect.

**Dissipative-flatness equivalence.** Subject to (K1)-(K2) and nonzero denominators,

`Delta(p)=0  <=>  a(p)=a_*`.                                 (EQ)

There is no third possibility inside this family. Circularity is exactly equivalent to a `p`-independent dissipative part.

The theorem is algebraic. It does not assert that the exact physical Green-Kubo response necessarily admits (K2) with a `p`-independent `K`; that is part of the modeling boundary that must be checked in any application.

## 4. What symmetry alone gives

Parity/chirality reversal requires, under the standard identification `p <-> 1-p`,

`a(p)=a(1-p)`,

`b(p)=-b(1-p)`.

Consequently `a` is even about `p=1/2` and `b` is odd. This does **not** imply `a(p)=a_*`. The first allowed dissipative deformation is generically quadratic:

`a(p) = a_* + c_2 (p-1/2)^2 + c_4 (p-1/2)^4 + ...`.

Combining this expansion with (KD) shows that a leading even drift produces a leading quadratic circle defect. Thus a measured `d^2`, `d=p-1/2`, signature is a natural falsification channel; it is not itself proof of any particular mode-coupling formula.

## 5. Green-Kubo formulation that survives 2D long-time tails

The old wording “remove long-time-tail corrections” was too loose. Long-time tails are physical. In two-dimensional FHP cellular automata, Naitoh, Ernst, and Dufty found an intermediate `1/t` tail and a later self-consistent asymptotic tail in Green-Kubo correlations (Phys. Rev. A 42, 7187, 1990; DOI 10.1103/PhysRevA.42.7187).

Accordingly, define finite-scale coefficients first:

`eta_GK(L,T,p,rho)`,  `eta_H_GK(L,T,p,rho)`.

Or, equivalently, define a running shear kernel

`M_{L,T}(p,rho) = a_{L,T}(p,rho) I + b_{L,T}(p,rho) J`

in a stated projection and normalization convention.

The physically meaningful circle question at that scale is then

`a_{L,T}(p,rho) ?= a_{L,T}(1/2,rho)`.                        (CRTC-a)

If a controlled renormalized limit exists, the same statement can be asked for the running/renormalized `a_R` rather than for a naively finite thermodynamic-limit viscosity.

This formulation avoids pretending that a known hydrodynamic tail is a nuisance to subtract away.

## 6. RG/Ward criterion for a future proof

Let `ell` be a renormalization scale and

`beta_a(p,ell) = d a(p,ell)/d ell`.

The circle-preserving submanifold is

`a(p,ell) - a(p_*,ell) = 0` for every `p`.

It is invariant under RG flow exactly when

`beta_a(p,ell) - beta_a(p_*,ell) = 0`                       (RG)

on that submanifold. A genuine Ward identity or hidden symmetry that forces (RG) would upgrade the physical circle from conjecture to theorem. `C6` and parity alone do not provide it.

## 7. Weak-field image of the published circle

For the cited weak-field transformation, with `b_B=B/2`,

`eta_B + i eta_H_B = (eta + i eta_H)/(1+i b_B)`.

Carry the discrete-time `1/8` shift through the same factor and define

`W_B = (eta_B + i eta_H_B) + 1/[8(1+i b_B)]`.

Then `W_B = Z/(1+i b_B)`, so (TC0) maps to

`|W_B - A/[2(1+i b_B)]|^2 = A^2/[4(1+b_B^2)]`.             (TCB)

This is again an exact transformation of the published analytical circle, not an independent Green-Kubo result.

## 8. Machine check of the published-model algebra

`tests/test_transport_circle.py` uses exact arithmetic in `Q(sqrt(3))`, without floating-point tolerances. It verifies (TC0), (TS) and (TCB) over

- `rho = 1/2, 1, ..., 11/2`,
- `p = k/64`, `k=0,...,64`,
- `B in {-1/4,-1/8,0,1/8,1/4}`.

That is 3,575 exact `(rho,p,B)` triples for the weak-field identity, in addition to the zero-field and spectral identities.

The test certifies the algebraic elimination and transformations. It does not simulate the stochastic `p` family and does not prove a correlation-renormalized transport law.

## 9. Critical implementation boundary

The executable HX89 gas has no continuous `p` parameter. `src/chiral_law.c` and `src/hex_gas.c` implement only the two deterministic chiralities `chi=-1` and `chi=+1`; the collision contains no RNG interpolation between them.

The symbol `p` occurs in this repository only in the analytical transport regression and documentation for the cited stochastic/kinetic family. Therefore:

- the microscopic reciprocity and echo theorem applies to the deterministic endpoint automata;
- the Boltzmann circle is an attributed analytical corollary;
- the Green-Kubo dissipative-flatness question is open and requires a separately specified continuous family or another controlled interpolation.

## 10. What is and is not proved

Proved here:

- the exact endpoint microscopic reversor and all-time echo;
- the rank-three one-body invariant space;
- the kernel defect identity (KD) and equivalence (EQ), subject to their explicit assumptions;
- the exact algebraic circle corollary of the published 2026 Boltzmann formulas.

Not proved here:

- `a(p)=a_*` for a correlation-renormalized chiral fluid;
- a Ward identity enforcing dissipative flatness;
- a universal non-renormalization theorem for classical odd viscosity;
- existence of a finite infinite-volume 2D Green-Kubo shear viscosity under every prescription;
- a continuous-`p` stochastic dynamics in the HX89 C sources.

The open target is now precise: prove or falsify dissipative flatness in a specified correlated chiral model.
