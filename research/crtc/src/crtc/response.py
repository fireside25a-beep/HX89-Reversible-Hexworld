"""Response-level CRTC classifier independent of kinetic closure."""
from __future__ import annotations
import cmath


def inverse_response(z: complex) -> complex:
    if z == 0:
        raise ZeroDivisionError("CRTC inverse response is undefined at Z=0")
    return 1/z


def crtc_residual(z: complex, z0: complex) -> float:
    """Scale-free residual Re(1/Z)-Re(1/Z0).

    z0 should be the achiral response.  For the parity convention used in the
    paper z0 is real and positive; the function intentionally does not silently
    project it to the real axis.
    """
    return (1/z).real - (1/z0).real


def on_anchored_circle(z: complex, z0: complex, atol: float = 1e-12) -> bool:
    if z == 0 or z0 == 0:
        return False
    if abs(z0.imag) > atol:
        raise ValueError("achiral anchor must be real in the CRTC parity convention")
    x0 = z0.real
    defect = abs(z)**2 - x0*z.real
    scale = max(1.0, abs(z)**2, abs(x0*z.real))
    return abs(defect) <= atol*scale
