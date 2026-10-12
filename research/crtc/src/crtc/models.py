from __future__ import annotations
from dataclasses import dataclass
import sympy as sp

@dataclass(frozen=True)
class KernelModel:
    a: sp.Expr
    b: sp.Expr
    parameter: sp.Symbol


def rigid_model():
    d = sp.symbols("d", real=True)
    a0, c = sp.symbols("a0 c", positive=True, real=True)
    return KernelModel(a=a0, b=c*d, parameter=d)


def drifting_model():
    d = sp.symbols("d", real=True)
    a0, c, eps = sp.symbols("a0 c eps", positive=True, real=True)
    return KernelModel(a=a0+eps*d*d, b=c*d, parameter=d)


def ou_stationary_covariance(A):
    return A*sp.eye(2)


def ou_noise_covariance(A, a):
    # For dX=-M X dt+B dW with C=A I, BB^T=M C+C M^T=2Aa I.
    return 2*A*a*sp.eye(2)
