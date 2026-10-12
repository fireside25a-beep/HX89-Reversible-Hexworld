from __future__ import annotations
import sympy as sp

PAIR_STATES = (9, 18, 36)   # opposite two-particle states
TRIPLE_STATES = (21, 42)    # alternating three-particle states


def rotate_state(s: int, k: int = 1) -> int:
    k %= 6
    return ((s << k) | (s >> (6-k))) & 63 if k else s


def reflect_state(s: int) -> int:
    # direction i -> -i mod 6: 0,5,4,3,2,1
    out = 0
    for i in range(6):
        if (s >> i) & 1:
            out |= 1 << ((-i) % 6)
    return out


def pair_next(s: int, direction: int) -> int:
    idx = PAIR_STATES.index(s)
    return PAIR_STATES[(idx + direction) % 3]


def transition_distribution(s: int, p):
    """Published chiral-FHP local rule: p vs 1-p for two-body chirality.

    The orientation convention only changes p <-> 1-p / Hall sign.
    Three-body zero-momentum states are swapped deterministically.
    """
    if s in PAIR_STATES:
        return ((pair_next(s, +1), p), (pair_next(s, -1), 1-p))
    if s == 21:
        return ((42, sp.Integer(1)),)
    if s == 42:
        return ((21, sp.Integer(1)),)
    return ((s, sp.Integer(1)),)


def state_probability(s: int, n):
    q = sp.Integer(1)
    for i in range(6):
        q *= n[i] if ((s >> i) & 1) else (1-n[i])
    return q


def collision_omega(n=None, p=None):
    if n is None:
        n = sp.symbols("n0:6")
    if p is None:
        p = sp.symbols("p", real=True)
    omega = [sp.Integer(0) for _ in range(6)]
    for s in range(64):
        ps = state_probability(s, n)
        dist = transition_distribution(s, p)
        for ell in range(6):
            before = (s >> ell) & 1
            after = sum(w * ((out >> ell) & 1) for out, w in dist)
            omega[ell] += ps * (after-before)
    return tuple(sp.expand(v) for v in omega), tuple(n), p


def homogeneous_jacobian():
    omega, n, p = collision_omega()
    f = sp.symbols("f", real=True)
    sub = {n[i]: f for i in range(6)}
    M = sp.Matrix([[sp.diff(omega[i], n[j]).subs(sub)
                    for j in range(6)] for i in range(6)])
    return sp.simplify(M), f, p


def circulant_eigenvalues():
    M, f, p = homogeneous_jacobian()
    first = [sp.factor(M[0,j]) for j in range(6)]
    zeta = sp.exp(-sp.I*sp.pi/3)
    vals = []
    for r in range(6):
        vals.append(sp.simplify(sp.expand_complex(sum(first[j]*zeta**(r*j) for j in range(6)))))
    return tuple(vals), f, p


def published_shear_lambda(rho, p):
    return sp.factor(-rho/sp.Integer(2) * (1-rho/6)**3 *
                     (1-sp.I*2*sp.sqrt(3)/3*(p-sp.Rational(1,2))))


def boltzmann_response(rho, p):
    D = sp.factor(rho*(1-rho/6)**3)
    A = sp.factor(1/(2*D))
    u = sp.factor(2*sp.sqrt(3)/3*(p-sp.Rational(1,2)))
    eta_shift = sp.factor(A/(1+u*u))
    eta_h = sp.factor(-A*u/(1+u*u))
    eta = sp.factor(eta_shift-sp.Rational(1,8))
    return eta, eta_h, eta_shift, A, u
