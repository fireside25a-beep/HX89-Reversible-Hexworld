#!/usr/bin/env python3
"""Independent symbolic audit. This file imports no project CRTC implementation."""
import sympy as s

# Symbols
a, a0, b, x0, A, D, d, eps, c = s.symbols('a a0 b x0 A D d eps c', nonzero=True, real=True)
I = s.I

# 1. Closure-free inverse-response identity.
Z = 1/(a + I*b)
x = s.re(Z.expand(complex=True))
y = s.im(Z.expand(complex=True))
Delta = s.factor(x*x + y*y - (1/a0)*x)
expect = s.factor((a0-a)/(a0*(a*a+b*b)))
assert s.simplify(Delta-expect) == 0
assert s.simplify((x*x+y*y)*(1-(1/a0)*s.re(1/Z)) - Delta) == 0

# 2. C6 shear commutant. Shear doublet rotates through 120 degrees.
sq3=s.sqrt(3)
R=s.Matrix([[-s.Rational(1,2),-sq3/2],[sq3/2,-s.Rational(1,2)]])
x11,x12,x21,x22=s.symbols('x11 x12 x21 x22', real=True)
M=s.Matrix([[x11,x12],[x21,x22]])
sol=s.solve(list(M*R-R*M),(x11,x12,x21,x22), dict=True)
assert sol and s.simplify(sol[0][x11]-x22)==0 and s.simplify(sol[0][x12]+x21)==0

# 3. Published-model FHP circle and spectral inversion.
u=2*sq3*d/3
Ab=s.symbols('Ab', positive=True, real=True)
xb=s.simplify(Ab/(1+u*u)); yb=s.simplify(-Ab*u/(1+u*u))
assert s.simplify(xb*xb+yb*yb-Ab*xb)==0
lam=-D/s.Integer(2)+I*sq3*D*d/3
Zspec=-1/(4*s.conjugate(lam))
Zform=s.simplify(1/(2*D)/(1+u*u) - I*(1/(2*D))*u/(1+u*u))
assert s.simplify(Zspec-Zform)==0

# 4. Achiral curvature formula for parity a even, b odd.
t=s.symbols('t', real=True)
a2,b1=s.symbols('a2 b1', real=True, nonzero=True)
at=a0+a2*t*t/2
bt=b1*t
zt=1/(at+I*bt)
xt=s.re(s.expand_complex(zt)); yt=s.im(s.expand_complex(zt))
x1=s.diff(xt,t); y1=s.diff(yt,t); x2=s.diff(xt,t,2); y2=s.diff(yt,t,2)
k=s.simplify((x1*y2-y1*x2)/(x1*x1+y1*y1)**s.Rational(3,2))
k0=s.simplify(k.subs(t,0))
# With b1>0 orientation. Remove Abs introduced by symbolic norm.
k0p=s.simplify(k0.replace(s.Abs, lambda z:z))
expected_k=-2*a0-a0*a0*a2/(b1*b1)
assert s.simplify(k0p-expected_k)==0

# 5. Quartic drift is a local-curvature false negative but globally non-rigid.
aq=a0+eps*t**4
Deltaq=s.factor((a0-aq)/(a0*(aq*aq+(c*t)**2)))
assert s.simplify(s.diff(aq,t,2).subs(t,0))==0
assert s.simplify(Deltaq.subs(t,s.Rational(1,10))) != 0

# 6. Positive-dissipation OU witness and exact Green-Kubo resolvent.
aou=a0+eps*t*t; bou=c*t
K=s.Matrix([[aou,-bou],[bou,aou]])
C=A*s.eye(2)
noise=s.simplify(K*C+C*K.T)
assert noise == 2*A*aou*s.eye(2)
R=s.simplify(K.inv()*C)
assert s.simplify(K*R-C)==s.zeros(2)
DeltaOU=s.factor((a0-aou)/(a0*(aou*aou+bou*bou)))
assert s.simplify(DeltaOU + eps*t*t/(a0*((a0+eps*t*t)**2+c*c*t*t)))==0

# 7. Same spectrum can give different resolvent matrix element.
L1=s.Matrix([[1,0],[0,2]])
S=s.Matrix([[1,1],[0,1]])
L2=s.simplify(S*L1*S.inv())
g=s.Matrix([[1,0]])
h=s.Matrix([0,1])
r1=s.simplify((g*L1.inv()*h)[0]); r2=s.simplify((g*L2.inv()*h)[0])
assert L1.charpoly().as_expr()==L2.charpoly().as_expr()
assert s.simplify(r1-r2)!=0

print("PASS: independent symbolic audit")
print("  inverse-response defect: PASS")
print("  C6 commutant: PASS")
print("  FHP circle and spectral inversion: PASS")
print("  achiral curvature formula: PASS")
print("  quartic curvature false-negative witness: PASS")
print("  OU Green-Kubo counterexample: PASS")
print("  same-spectrum different-overlap witness: PASS")
