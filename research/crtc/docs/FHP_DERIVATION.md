# Exact chiral-FHP molecular-chaos derivation

The purpose of this module is to verify the published Boltzmann-side witness from the microscopic local rule, independently of the paper's printed algebra.

Primary source: A. A. Allocca et al., *Odd fluids from chiral cellular automata*, arXiv:2606.19431 (2026).

The source gives, at zero imposed magnetic field, the contributing complex shear eigenvalue (their Eq. 21 discussion)

`lambda = -rho/2 (1-rho/6)^3 [1 - i (2 sqrt(3)/3)(p-1/2)]`,

and the kinematic viscosities (their Eqs. 25--26)

`eta = [1/(2 rho (1-rho/6)^3)] / [1+(4/3)(p-1/2)^2] - 1/8`,

`eta_H = -[sqrt(3)/(3 rho (1-rho/6)^3)] (p-1/2) / [1+(4/3)(p-1/2)^2]`.

## Local-rule enumeration

`src/crtc/fhp.py` represents a local site by a six-bit integer.  It enumerates all 64 Boolean occupation states.

- The three opposite two-particle states scatter into the other two zero-momentum pair states with weights `p` and `1-p`.
- The two alternating three-particle zero-momentum states swap deterministically.
- Every other state is unchanged.

The code checks exactly, for all 64 states:

1. outgoing transition weights sum to one;
2. C6 rotation covariance;
3. reflection covariance combined with `p -> 1-p`.

## Molecular-chaos collision map

For channel occupation probabilities `n_0,...,n_5`, each local Boolean state `s` is assigned the product Bernoulli probability

`P(s)=prod_i n_i^(s_i) (1-n_i)^(1-s_i)`.

The expected collision increment `Omega_l(n)` is then obtained by summing the outgoing-minus-incoming channel occupation over all 64 states.

The code differentiates `Omega` exactly, then substitutes homogeneous filling

`n_i=f=rho/6`.

The resulting 6x6 Jacobian is circulant.  Fourier diagonalization gives its six exact eigenvalues.  The shear harmonics `r=2,4` are a complex-conjugate pair, and `tests/test_fhp_exact.py` proves symbolically that the enumerated `r=2` eigenvalue is exactly the published `lambda` above.

This is not a fit to paper data and not a simulation of flow.

## Circle hidden in the published coefficients

Define

`D=rho(1-rho/6)^3`,

`A=1/(2D)`,

`u=(2 sqrt(3)/3)(p-1/2)`.

The shifted complex response is

`Z_B=(eta+1/8)+i eta_H = A(1-i u)/(1+u^2) = A/(1+i u)`.

The source eigenvalue is

`lambda=-(D/2)(1-i u)`,

so

`Z_B=-1/(4 lambda*)`.

The achiral response is `Z_B(p=1/2)=A`, and therefore

`(eta+1/8-A/2)^2 + eta_H^2 = (A/2)^2`.

The exact symbolic report verifies both identities.

## Exact finite grid

To guard against a symbolic implementation mistake, the test suite also evaluates the circle with `fractions.Fraction` on the complete declared grid

- `rho=n/16`, `n=1,...,95`;
- `p=m/100`, `m=0,...,100`.

This is 9,595 exact rational points.  The square of the Hall coordinate is used so the irrational `sqrt(3)` cancels algebraically.  All 9,595 defects are exactly zero.

The symbolic identity, not the finite grid, proves the continuum molecular-chaos circle.
