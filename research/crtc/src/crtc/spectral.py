from __future__ import annotations
import sympy as sp
from .geometry import shear_kernel


def reduced_shear_eigenvalues(a, b):
    M = shear_kernel(a, b)
    return tuple(M.eigenvals().keys())


def reduced_shear_real_part(eigenvalue):
    """CRTC classifier for an already isolated multiplicity-one complex shear mode."""
    return sp.simplify(sp.re(eigenvalue))


def reduced_spectrum_is_rigid(eigenvalues_by_parameter):
    """Exact finite-family check: all identified shear eigenvalues have the same real part.

    This intentionally does not accept a full unordered microscopic spectrum.
    """
    vals = list(eigenvalues_by_parameter)
    if not vals:
        raise ValueError("at least one reduced shear eigenvalue is required")
    r0 = sp.simplify(sp.re(vals[0]))
    return all(sp.simplify(sp.re(v)-r0) == 0 for v in vals[1:])


def c6_commutes(M):
    from .geometry import R120
    return sp.simplify(M*R120-R120*M) == sp.zeros(2)


def parity_covariant(a_expr, b_expr, d):
    even = sp.simplify(a_expr.subs(d, -d)-a_expr) == 0
    odd = sp.simplify(b_expr.subs(d, -d)+b_expr) == 0
    return even and odd


def gk_resolvent_continuous(M, C):
    """Exact integral int_0^inf exp(-M t) C dt = M^{-1} C.

    Valid when Re spectrum(M)>0. This is an algebraic resolvent, not a
    time-stepping simulation.
    """
    return sp.simplify(M.inv()*C)


def same_spectrum_different_overlap_witness():
    """Two similar generators with identical eigenvalues but different fixed-observable
    Green-Kubo matrix elements. This disproves classification from a bare unordered
    full spectrum when projectors/observable overlaps are not supplied.
    """
    L1 = sp.diag(1, 2)
    S = sp.Matrix([[1, 1], [1, -1]])
    L2 = sp.simplify(S*L1*S.inv())
    g = sp.Matrix([1, 0])
    r1 = sp.simplify((g.T*L1.inv()*g)[0])
    r2 = sp.simplify((g.T*L2.inv()*g)[0])
    return L1, L2, g, r1, r2
