import unittest
import sympy as sp
from crtc.geometry import shear_kernel, anchored_circle_defect, P_REFLECT
from crtc.models import ou_stationary_covariance, ou_noise_covariance
from crtc.spectral import gk_resolvent_continuous, c6_commutes

class TestPositiveDissipationCounterexample(unittest.TestCase):
    def test_ou_exact_gk_positive_dissipation_and_symmetry(self):
        A,a0,c,eps,d=sp.symbols('A a0 c eps d', positive=True, real=True)
        a=a0+eps*d*d; b=c*d
        M=shear_kernel(a,b)
        C=ou_stationary_covariance(A)
        Q=ou_noise_covariance(A,a)
        self.assertEqual((M+M.T)/2, a*sp.eye(2))
        self.assertEqual(Q,2*A*a*sp.eye(2))
        self.assertTrue(c6_commutes(M))
        # Reflection plus d -> -d covariance.
        self.assertEqual(sp.simplify(P_REFLECT*M*P_REFLECT - M.subs(d,-d)),sp.zeros(2))
        R=gk_resolvent_continuous(M,C)
        self.assertEqual(sp.simplify(R-A*M.inv()),sp.zeros(2))
        # Normalize by A: Z/A=1/(a+i b), so the exact CRTC defect is nonzero.
        defect=sp.factor(anchored_circle_defect(a0,a,b))
        self.assertNotEqual(defect,0)
        self.assertEqual(sp.simplify(defect + eps*d*d/(a0*(a*a+b*b))),0)

    def test_stability_and_positive_entropy_quadratic_form(self):
        a,b,x1,x2=sp.symbols('a b x1 x2', positive=True, real=True)
        M=shear_kernel(a,b)
        x=sp.Matrix([x1,x2])
        diss=sp.expand((x.T*((M+M.T)/2)*x)[0])
        self.assertEqual(sp.simplify(diss-a*(x1*x1+x2*x2)),0)
        self.assertEqual({sp.re(v) for v in M.eigenvals()}, {a})
