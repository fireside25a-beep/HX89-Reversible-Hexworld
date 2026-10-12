import unittest
import sympy as sp
from crtc.geometry import (
    universal_normalized_defect, inverse_response_real,
    generalized_circle_image_coefficients, signed_curvature,
)

class TestResponseClassification(unittest.TestCase):
    def test_universal_circle_inverse_equivalence(self):
        x,y=sp.symbols('x y', real=True)
        D=x*x+y*y-x
        # D/|W|^2 = 1-Re(1/W)
        invminus=sp.factor(inverse_response_real(x,y)-1)
        self.assertEqual(sp.factor(invminus + D/(x*x+y*y)),0)

    def test_generalized_kernel_circle_maps_to_generalized_response_circle(self):
        A,h,r,t=sp.symbols('A h r t', positive=True, real=True)
        a=h+r*sp.cos(t); b=r*sp.sin(t)
        den=a*a+b*b
        x=sp.simplify(A*a/den); y=sp.simplify(-A*b/den)
        q2,qx,q0=generalized_circle_image_coefficients(A,h,r)
        self.assertEqual(sp.trigsimp(sp.factor(q2*(x*x+y*y)+qx*x+q0)),0)

    def test_fixed_curvature_alone_is_not_crtc(self):
        t=sp.symbols('t', real=True)
        x=2+sp.cos(t); y=sp.sin(t)
        self.assertEqual(sp.simplify(signed_curvature(x,y,t)),1)
        self.assertNotEqual(sp.trigsimp(universal_normalized_defect(x,y)),0)
