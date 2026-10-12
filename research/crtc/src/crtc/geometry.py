from __future__ import annotations
from dataclasses import dataclass
import sympy as sp

I2 = sp.eye(2)
J = sp.Matrix([[0, -1], [1, 0]])
P_REFLECT = sp.diag(1, -1)
# A physical pi/3 rotation acts on the traceless-symmetric shear doublet
# with twice the angle, i.e. 2*pi/3.
R120 = sp.Matrix([[-sp.Rational(1, 2), -sp.sqrt(3)/2],
                  [ sp.sqrt(3)/2, -sp.Rational(1, 2)]])

@dataclass(frozen=True)
class ResponsePoint:
    x: sp.Expr
    y: sp.Expr


def shear_kernel(a, b):
    """Real 2x2 representation of the complex scalar a+i b."""
    return sp.Matrix([[a, -b], [b, a]])


def response_from_inverse(a, b) -> ResponsePoint:
    """Z=1/(a+i b)=x+i y, with y=-b/(a^2+b^2)."""
    den = sp.expand(a*a + b*b)
    return ResponsePoint(sp.simplify(a/den), sp.simplify(-b/den))


def response_xy(A, a, b) -> ResponsePoint:
    """Scaled response Z=A/(a+i b)."""
    r = response_from_inverse(a, b)
    return ResponsePoint(sp.simplify(A*r.x), sp.simplify(A*r.y))


def inverse_response_real(x, y):
    """Re(1/Z) for Z=x+i y (Z != 0)."""
    return sp.simplify(x/(x*x+y*y))


# Backward-compatible alias used by the report.
inverse_real_from_response = inverse_response_real


def anchored_response_defect(x0, x, y):
    """Circle defect for the diameter circle through 0 and x0>0.

    Delta = |Z|^2 - x0 Re Z.
    """
    return sp.factor(x*x+y*y-x0*x)


def universal_normalized_defect(x, y):
    """Defect for the normalized diameter circle |W|^2=Re W."""
    return sp.factor(x*x+y*y-x)


def anchored_circle_defect(a0, a, b):
    """Defect for Z=1/(a+i b), anchored at Z0=1/a0."""
    r = response_from_inverse(a, b)
    return sp.factor(anchored_response_defect(1/a0, r.x, r.y))


def circle_defect(A, a0, a, b):
    """Scaled form for Z=A/(a+i b) with chirality-independent A."""
    r = response_xy(A, a, b)
    return sp.factor(anchored_response_defect(A/a0, r.x, r.y))


def normalized_circle_defect(a0, a, b):
    """Defect for W=Z/Z(0)=a0/(a+i b), for constant prefactor A."""
    den = sp.expand(a*a + b*b)
    wx = sp.simplify(a0*a/den)
    wy = sp.simplify(-a0*b/den)
    return universal_normalized_defect(wx, wy)


def generalized_circle_image_coefficients(A, h, r):
    """Image of the kernel circle (a-h)^2+b^2=r^2 under Z=A/(a+i b).

    If Z=x+i y, the response generalized circle is
      (h^2-r^2)(x^2+y^2) - 2 A h x + A^2 = 0.  To avoid singular special
    cases this function simply returns one proportional coefficient triple
    (q2,qx,q0).
    """
    return (sp.expand(h*h-r*r), -2*A*h, A*A)


def signed_curvature(x, y, t):
    """Signed Euclidean curvature of a regular planar parameterized curve."""
    xp, yp = sp.diff(x, t), sp.diff(y, t)
    xpp, ypp = sp.diff(xp, t), sp.diff(yp, t)
    speed2 = sp.simplify(xp*xp + yp*yp)
    return sp.simplify((xp*ypp - yp*xpp) / sp.Pow(speed2, sp.Rational(3,2)))


def achiral_curvature(a0, a2, b1):
    """Signed curvature at d=0 for Z=1/(a+i b).

    Assumptions: a is even, b is odd, a(0)=a0>0, a''(0)=a2,
    b'(0)=b1>0.  The result is the second-fundamental-form invariant
    divided by the induced metric in this one-dimensional setting.
    """
    return sp.factor(-2*a0 - a0*a0*a2/(b1*b1))


def commutant_equations():
    x11, x12, x21, x22 = sp.symbols("x11 x12 x21 x22", real=True)
    X = sp.Matrix([[x11, x12], [x21, x22]])
    E = sp.expand(X*R120 - R120*X)
    equations = [sp.expand(E[i, j]) for i in range(2) for j in range(2)]
    return X, equations


def solve_commutant():
    X, eqs = commutant_equations()
    x11, x12, x21, x22 = list(X)
    return sp.solve(eqs, [x11, x12, x21, x22], dict=True)
