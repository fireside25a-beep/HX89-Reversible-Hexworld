# CRTC response rigidity

This repository isolates and tests a structural statement about the complex shear/Hall response of a two-dimensional chiral fluid.  It does **not** assume that the full correlated chiral-FHP Green--Kubo problem already satisfies the circle.  Instead it proves an exact response-level classification, identifies the extra condition required for circle survival, verifies the published molecular-chaos FHP witness from the microscopic collision rule, and supplies a positive-dissipation Green--Kubo counterexample outside the rigid class.

## Core theorem

Let

`Z(p) = eta_shift(p) + i eta_H(p)`

be a nonzero complex response and let the achiral response be `Z0=x0>0`.  The parity-anchored CRTC circle is

`(Re Z - x0/2)^2 + (Im Z)^2 = (x0/2)^2`,

or equivalently `|Z|^2-x0 Re Z=0`.

Define the **actual inverse response**

`Q(p)=1/Z(p)=a(p)+i b(p)`.

Then, identically,

`|Z|^2-x0 Re Z = |Z|^2 [1 - x0 Re(1/Z)]`.

Since `x0=1/a0`, `a0=Re(1/Z0)`, the anchored circle condition is therefore

`CRTC  <=>  Re(1/Z(p)) = Re(1/Z0)`.

This statement contains no molecular-chaos closure and no fixed susceptibility or overlap prefactor.  It is a pure complex-geometric classification wherever `Z != 0`.

For the common reduced kernel form `Q=a+i b`, the defect becomes

`Delta = (a0-a) / [a0(a^2+b^2)]`.

Thus arbitrary motion of the reactive coordinate `b` stays on the anchored circle if and only if the dissipative inverse-response coordinate `a` is rigid.

## Symmetry and what it does not prove

On the two-dimensional traceless-symmetric shear doublet, a physical 60-degree rotation acts as a 120-degree rotation.  The real commutant is exactly

`span{I,J}`, with `J^2=-I`.

Hence C6 covariance restricts a reduced inverse response to `aI+bJ`.  Reflection about the achiral point makes `a` even in chirality and `b` odd.  **C6 does not force `a` to be constant.**  Circle survival is an additional dynamical/spectral condition.

## Curvature classification

The response curve is an immersed curve in the `(eta_shift, eta_H)` plane.  For parity-even `a(d)`, parity-odd `b(d)`, `d=p-1/2`, `a(0)=a0>0`, `b'(0)=b1>0`, and `a''(0)=a2`, the signed achiral curvature is

`kappa(0) = -2 a0 - a0^2 a2 / b1^2`.

The rigid class has constant signed curvature `-2a0` and radius `1/(2a0)`.  Quadratic dissipative drift changes the second fundamental form immediately.  A quartic drift is an explicit stress test showing that local curvature at the achiral point alone does **not** decide global CRTC membership; the exact global classifier is `Re(1/Z)=constant`.

## Exact FHP source check

The code independently enumerates all 64 local Boolean collision states of the chiral FHP rule in Allocca et al. (2026), differentiates the molecular-chaos collision map at homogeneous filling, diagonalizes the circulant shear block, and recovers the published complex eigenvalue exactly:

`lambda = -rho/2 (1-rho/6)^3 [1 - i (2 sqrt(3)/3)(p-1/2)]`.

Using the published zero-field viscosities it then verifies

`Z_B = eta + 1/8 + i eta_H = -1/(4 lambda*)`

and the corresponding circle identity symbolically.  A separate exact rational sweep checks 9,595 declared `(rho,p)` grid points without floating-point arithmetic.

## Positive-dissipation Green--Kubo counterexample

The counterexample is a stationary two-component Ornstein--Uhlenbeck shear process

`dX = -K(d)X dt + B(d)dW`,

with

`K(d)=[a0+eps d^2]I + c d J`, `a0,eps,c>0`.

Its symmetric part is strictly positive, it is C6 covariant and reflection covariant, and with stationary covariance `C=A I` its exact Green--Kubo integral is

`integral_0^infinity exp(-Kt) C dt = K^-1 C`.

The normalized inverse response has real part `a0+eps d^2`, so the circle defect is nonzero for every `d != 0`.  The exact rational counterexample sweep checks 1,001 chirality points, 1,000 of which are off-circle with positive dissipation.

This proves that isotropy/C6 plus positive dissipation does not by itself protect CRTC beyond molecular chaos.

## Spectral decision rule: precise scope

If the relevant two-dimensional shear sector has already been isolated and its response residue/normalization is known, the pair `a±ib` decides membership algebraically: constant `a` is the rigid class.  No time-domain simulation is required.

A bare unordered spectrum of a larger microscopic generator is not sufficient in general.  The repository includes two similar matrices with identical eigenvalues but different Green--Kubo matrix elements for the same observable, proving that projectors/observable overlaps can matter.

## Self-monitoring arithmetic

`crtc.monitor` evaluates the exact defect by two algebraically equivalent routes.  It starts with binary64 and detects nonfinite arithmetic, singularity, overflow/underflow and input-coalescence cancellation.  If certification fails, it recomputes the **same coefficients and same equations** with arbitrary precision.  It never changes `a`, `b`, the response, or the physical model to make a test pass.

## Verification

```sh
python3 -m venv .venv
. .venv/bin/activate
python3 -m pip install -r requirements.txt
make all
```

`make all` runs the complete unit suite, exact symbolic report, finite exact-grid checks through the unit suite, and the self-monitoring arithmetic sweep.  The captured verification output is in `results/VERIFICATION.txt`.  `make paper` rebuilds the included manuscript PDF when a LaTeX installation is available.

The strongest statements, qualifications and literature provenance are separated into:

- `docs/THEOREM.md`
- `docs/CURVATURE.md`
- `docs/COUNTEREXAMPLE.md`
- `docs/GREEN_KUBO_SCOPE.md`
- `docs/FHP_DERIVATION.md`
- `docs/WARD_IDENTITY_EVALUATION.md`
- `docs/CLAIM_MATRIX.md`
- `docs/NOVELTY_CHECK.md`
- `REFERENCES.md`

## Status

The repository proves a complete **anchored-response classification** and gives exact witnesses on both sides.  It does **not** prove that the fully correlated chiral-FHP thermodynamic-limit Green--Kubo response is in the rigid class.  Establishing that stronger model-specific statement requires an additional microscopic identity/controlled renormalization argument, or a direct exact evaluation of the appropriate correlated reduced response.
