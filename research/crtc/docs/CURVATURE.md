# Response curvature and the second fundamental form

Let `d=p-p0` and write the measured inverse response as

`Q(d)=a(d)+i b(d)`, `Z(d)=1/Q(d)`.

Reflection symmetry gives `a` even and `b` odd.  Assume

- `a(0)=a0>0`,
- `b(0)=0`,
- `b'(0)=b1>0` so the curve is regular at the achiral point,
- `a''(0)=a2`.

For a planar curve `r(d)=(x(d),y(d))`, the signed curvature is

`kappa=(x' y''-y' x'')/(x'^2+y'^2)^(3/2)`.

Direct differentiation of `Z=1/(a+i b)` gives

`kappa(0) = -2 a0 - a0^2 a2/b1^2`.         (C1)

For a one-dimensional immersed submanifold of the Euclidean response plane, the scalar second fundamental form is the normal component of the second derivative; after division by the induced metric, (C1) is the signed curvature invariant.

## Rigid class

If `a(d)=a0`, complex inversion of the vertical line `Re Q=a0` gives

`(x-1/(2a0))^2+y^2=1/(4a0^2)`.

The radius is `R=1/(2a0)`, hence

`kappa=-1/R=-2a0`

with the orientation convention `b'(0)>0` used in the code.  The sign reverses if the curve orientation is reversed; the magnitude is geometric.

## Quadratic drift

For

`a(d)=a0+eps d^2`, `b(d)=c d`,

we have `a2=2eps`, `b1=c`, so

`kappa(0)=-2a0-2 a0^2 eps/c^2`.

Thus the second fundamental form detects the leading even dissipative drift.

## Why local curvature is not the whole theorem

Consider instead

`a(d)=a0+eps d^4`, `b(d)=c d`.

Then `a''(0)=0`, so `kappa(0)=-2a0`, exactly the rigid achiral curvature.  Nevertheless, for every nonzero `d`,

`Delta=(a0-a)/[a0(a^2+b^2)] != 0`.

Therefore a single curvature measurement at the achiral point cannot classify global CRTC membership.  This explicit test is included in `tests/test_rigidity.py`.

The complete structural statement is global: the response is on the anchored CRTC circle exactly when `Re(1/Z)` is constant.  Constant nonzero curvature on an entire connected regular branch, plus the same anchor, tangent/orientation and circle radius, recovers the same circle; without those anchor data, constant curvature merely says “some circle.”
