import unittest
import sympy as sp
from crtc.geometry import (
    anchored_circle_defect, anchored_response_defect, circle_defect,
    normalized_circle_defect, response_from_inverse, response_xy,
    inverse_response_real, signed_curvature, achiral_curvature,
)

class TestRigidity(unittest.TestCase):
    def test_exact_inverse_response_defect_identity(self):
        a0,a,b=sp.symbols('a0 a b', positive=True, real=True)
        got=anchored_circle_defect(a0,a,b)
        want=sp.factor((a0-a)/(a0*(a*a+b*b)))
        self.assertEqual(sp.simplify(got-want),0)

    def test_scaled_defect_identity(self):
        A,a0,a,b=sp.symbols('A a0 a b', positive=True, real=True)
        got=circle_defect(A,a0,a,b)
        want=sp.factor(A**2*(a0-a)/(a0*(a*a+b*b)))
        self.assertEqual(sp.simplify(got-want),0)

    def test_response_level_equivalence_no_fixed_prefactor(self):
        x,y,x0=sp.symbols('x y x0', nonzero=True, real=True)
        s=x*x+y*y
        defect=anchored_response_defect(x0,x,y)
        # Delta/s = 1 - x0 Re(1/Z).
        self.assertEqual(sp.factor(defect/s - (1-x0*inverse_response_real(x,y))),0)

    def test_constant_inverse_real_is_circle_for_arbitrary_reactive_part(self):
        a0,b=sp.symbols('a0 b', positive=True, real=True)
        self.assertEqual(sp.simplify(anchored_circle_defect(a0,a0,b)),0)

    def test_drifting_inverse_real_breaks_anchored_circle(self):
        a0,c,eps,d=sp.symbols('a0 c eps d', positive=True, real=True)
        a=a0+eps*d*d; b=c*d
        D=sp.factor(anchored_circle_defect(a0,a,b))
        self.assertEqual(sp.simplify(D + eps*d*d/(a0*(a*a+b*b))),0)

    def test_rigid_curvature(self):
        a0,c,d=sp.symbols('a0 c d', positive=True, real=True)
        r=response_from_inverse(a0,c*d)
        k=sp.factor(signed_curvature(r.x,r.y,d))
        self.assertEqual(k,-2*a0)

    def test_achiral_curvature_quadratic_drift(self):
        a0,c,eps,d=sp.symbols('a0 c eps d', positive=True, real=True)
        a=a0+eps*d*d; b=c*d
        r=response_from_inverse(a,b)
        k0=sp.simplify(sp.limit(signed_curvature(r.x,r.y,d),d,0))
        want=achiral_curvature(a0,2*eps,c)
        self.assertEqual(sp.simplify(k0-want),0)

    def test_local_curvature_does_not_decide_global_membership(self):
        # Quartic drift has a''(0)=0, so achiral curvature equals the rigid value,
        # yet it leaves the circle for every nonzero d.
        a0,c,eps,d=sp.symbols('a0 c eps d', positive=True, real=True)
        a=a0+eps*d**4; b=c*d
        r=response_from_inverse(a,b)
        k0=sp.simplify(sp.limit(signed_curvature(r.x,r.y,d),d,0))
        self.assertEqual(k0,-2*a0)
        self.assertNotEqual(sp.factor(anchored_circle_defect(a0,a,b)),0)

    def test_prefactor_drift_is_caught_by_actual_inverse_response(self):
        # For Z=A(d)/(a+i b), the response invariant is Re(1/Z)=a/A.
        d=sp.symbols('d', real=True)
        a0,c,g=sp.symbols('a0 c g', positive=True, real=True)
        A=1+g*d*d
        r=response_xy(A,a0,c*d)
        qreal=sp.factor(inverse_response_real(r.x,r.y))
        self.assertEqual(sp.simplify(qreal-a0/A),0)
        self.assertNotEqual(sp.simplify(qreal-a0),0)
