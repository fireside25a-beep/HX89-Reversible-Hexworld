# CRTC response-rigidity theorem

## 1. Response-level statement

Let `Z(p)=x(p)+i y(p)` be a nonzero complex transport response on a connected chirality interval and let the achiral point be `p0`, with parity convention

`Z(p0)=x0>0`.

The anchored CRTC circle is the circle having the segment from `0` to `x0` as diameter:

`(x-x0/2)^2+y^2=(x0/2)^2`.

Equivalently,

`Delta = x^2+y^2-x0 x = 0`.                 (1)

Define the measured inverse response

`Q=1/Z=a+i b`,                              (2)

so

`a = x/(x^2+y^2) = Re(1/Z)`.                (3)

Dividing (1) by `|Z|^2` gives the exact identity

`Delta/|Z|^2 = 1-x0 a`.                     (4)

At the achiral point, `a0=1/x0`.  Therefore

**Theorem A (global rigidity).**  Wherever `Z != 0`,

`Z(p) lies on the anchored CRTC circle`

if and only if

`Re[1/Z(p)] = a0 = Re[1/Z(p0)]`.            (5)

No collision model, molecular-chaos approximation, fixed relaxation amplitude, or time-domain simulation is used in this equivalence.

The result is a binary partition for membership in this **specific anchored circle**.  There is no third membership class: every nonsingular response point either satisfies (5) or it does not.

## 2. Kernel-coordinate defect

When `Q=a+i b`, inversion gives

`Z=(a-i b)/(a^2+b^2)`.

Substitution into (1), with `x0=1/a0`, yields

`Delta = (a0-a)/[a0(a^2+b^2)]`.             (6)

Thus the reactive coordinate `b` can vary arbitrarily without leaving the circle if `a=a0`.  Any point for which `a!=a0` lies off the anchored circle.

If one uses a model-dependent decomposition `Z=A/(alpha+i beta)`, then the invariant coordinate is not `alpha` by itself but

`Re(1/Z)=alpha/A`.                           (7)

This is why the response-level formulation is stronger than a fixed-`A` kinetic closure.

## 3. C6 commutant theorem

The two independent components of a two-dimensional traceless-symmetric shear tensor transform under a physical rotation by angle `theta` as a vector rotated by `2 theta`.  Under the generator of C6, `theta=pi/3`, the shear doublet therefore sees a nontrivial rotation by `2pi/3`.

Let `R` be that real 2x2 rotation.  Solving

`XR=RX`                                      (8)

for an arbitrary real matrix `X` gives a two-dimensional commutant:

`X=a I+b J`, `J=[[0,-1],[1,0]]`, `J^2=-I`.  (9)

The exact symbolic solver in `tests/test_commutant.py` verifies the nullity is two.

If reflection maps `d=p-p0` to `-d`, with shear-space reflection `P`, then `PJP=-J`; hence covariance gives

`a(-d)=a(d)`, `b(-d)=-b(d)`.                (10)

C6 and reflection reduce the allowed response structure to two scalar functions, but they do **not** force `a(d)=a0`.

## 4. Global circle classification versus curvature

The rigid inverse-response line

`Re Q=a0`                                   (11)

is mapped by complex inversion to the anchored circle.  This is a special case of the Möbius fact that generalized circles (circles and lines in the extended complex plane) map to generalized circles.

Consequently, “the response has constant curvature” is not by itself equivalent to CRTC: a different circle also has constant curvature.  The achiral anchor, parity tangent and the specific diameter-circle equation are essential.

For local curvature, see `CURVATURE.md`.

## 5. Scale/RG criterion

At scale `ell`, let the measured inverse response be

`Q_ell(d)=a_ell(d)+i b_ell(d)`.

The CRTC rigid manifold is

`G_ell(d)=a_ell(d)-a_ell(0)=0` for all `d`.  (12)

If the scale flow is `partial_ell a=beta_a`, then an infinitesimal necessary and sufficient tangency condition on that manifold is

`beta_a(d)-beta_a(0)=0` for all `d`.         (13)

C6 preserves the two-coordinate form `(a,b)`.  It does not supply (13).  A genuine microscopic protection principle would have to do so.

## 6. Spectrum criterion and its limit

For an **identified reduced shear block** exactly represented by (9), the eigenvalues are

`q_±=a±i b`.                                (14)

If this block is the actual inverse response (or its known proportionality/residue has been divided out), CRTC membership is decidable from the reduced spectral data by testing whether `Re q_±` is chirality independent.

This statement must not be extended to a bare unordered spectrum of a large microscopic operator.  Green--Kubo observables are resolvent matrix elements and can depend on spectral projectors/overlaps.  `tests/test_spectral_limits.py` contains an exact same-spectrum/different-response witness.

## 7. Model-specific status

For the molecular-chaos chiral FHP calculation of Allocca et al., the published shear mode and viscosities satisfy the rigid circle exactly; `FHP_DERIVATION.md` reproduces this from an independent 64-state local-rule enumeration.

For an explicit correlated linear stochastic process with positive dissipation, the rigid condition can fail; `COUNTEREXAMPLE.md` gives that witness.

Therefore the theorem classifies what a beyond-molecular-chaos response **would have to satisfy** for CRTC to survive.  It does not, by geometry alone, establish which class the fully correlated chiral-FHP model occupies.
