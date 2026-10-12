#!/usr/bin/env python3
"""Exact arithmetic regression for the chiral-FHP transport-circle corollary.

This test does not re-derive hydrodynamics from HX89.  It machine-checks the
algebraic identities obtained from Eqs. (25)-(27) and the shear eigenvalue in
Allocca et al., arXiv:2606.19431, using rational arithmetic in Q(sqrt(3)).
"""
from fractions import Fraction as F


# a + b*sqrt(3), exactly.
def q3(a=0, b=0):
    return (F(a), F(b))


def qadd(x, y): return (x[0] + y[0], x[1] + y[1])
def qneg(x): return (-x[0], -x[1])
def qsub(x, y): return qadd(x, qneg(y))
def qmul(x, y):
    return (x[0]*y[0] + 3*x[1]*y[1], x[0]*y[1] + x[1]*y[0])
def qscale(x, a): return (x[0]*F(a), x[1]*F(a))
def qinv(x):
    den = x[0]*x[0] - 3*x[1]*x[1]
    assert den
    return (x[0]/den, -x[1]/den)
def qdiv(x, y): return qmul(x, qinv(y))
def qzero(x): return x[0] == 0 and x[1] == 0


# Complex numbers whose real and imaginary parts are in Q(sqrt(3)).
def cadd(z, w): return (qadd(z[0], w[0]), qadd(z[1], w[1]))
def cscale(z, a): return (qscale(z[0], a), qscale(z[1], a))
def cmul(z, w):
    return (qsub(qmul(z[0], w[0]), qmul(z[1], w[1])),
            qadd(qmul(z[0], w[1]), qmul(z[1], w[0])))
def cconj(z): return (z[0], qneg(z[1]))
def cinv(z):
    den = qadd(qmul(z[0], z[0]), qmul(z[1], z[1]))
    return (qdiv(z[0], den), qdiv(qneg(z[1]), den))
def cdiv(z, w): return cmul(z, cinv(w))
def ceq(z, w): return qzero(qsub(z[0], w[0])) and qzero(qsub(z[1], w[1]))


def norm2(z):
    return qadd(qmul(z[0], z[0]), qmul(z[1], z[1]))


def coefficients(rho, p):
    d = p - F(1, 2)
    D = rho * (1 - rho/F(6))**3
    assert D != 0
    A = 1 / (2*D)
    den = 1 + F(4, 3)*d*d
    eta_bar = q3(A/den)
    eta = q3(A/den - F(1, 8))
    eta_h = q3(0, -d/(3*D*den))
    return D, A, eta_bar, eta, eta_h


def main():
    count = 0
    for rho2 in range(1, 12):  # rho = 1/2 .. 11/2, excluding singular 0 and 6
        rho = F(rho2, 2)
        for k in range(65):
            p = F(k, 64)
            D, A, eta_bar, eta, eta_h = coefficients(rho, p)

            # Zero-field circle:
            # (eta+1/8-A/2)^2 + eta_H^2 = (A/2)^2.
            zero_centered = (qsub(eta_bar, q3(A/2)), eta_h)
            assert norm2(zero_centered) == q3(A*A/4)

            # Spectral form: Z = eta+1/8+i eta_H = -1/(4 lambda*).
            d = p - F(1, 2)
            lam = (q3(-D/2), q3(0, D*d/3))
            spectral = cscale(cinv(cconj(lam)), F(-1, 4))
            assert ceq((eta_bar, eta_h), spectral)

            # Eq. (27) is a scaled rotation.  After carrying the lattice 1/8
            # shift through the same complex factor, the circle remains exact.
            for B in (F(-1, 4), F(-1, 8), F(0), F(1, 8), F(1, 4)):
                b = B/2
                scale = 1 + b*b
                eta_b = qscale(qadd(eta, qscale(eta_h, b)), 1/scale)
                eta_h_b = qscale(qadd(qscale(eta, -b), eta_h), 1/scale)

                shift = (q3(F(1, 8)/scale), q3(-b*F(1, 8)/scale))
                W = cadd((eta_b, eta_h_b), shift)
                center = (q3(A/(2*scale)), q3(-A*b/(2*scale)))
                centered = (qsub(W[0], center[0]), qsub(W[1], center[1]))
                assert norm2(centered) == q3(A*A/(4*scale))
                count += 1

    print(f"PASS: exact transport-circle and spectral identities over {count} rational (rho,p,B) points in Q(sqrt(3))")


if __name__ == "__main__":
    main()
