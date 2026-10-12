import unittest
import sympy as sp
from crtc.rg import beta_gap, tangent_to_rigid_manifold

class TestRGCriterion(unittest.TestCase):
    def test_chirality_independent_beta_a_is_tangent(self):
        d,a0,g=sp.symbols('d a0 g', real=True)
        beta=g*a0
        self.assertTrue(tangent_to_rigid_manifold(beta,d))

    def test_b_dependent_beta_generically_breaks_rigidity(self):
        d,a0,c,g=sp.symbols('d a0 c g', nonzero=True, real=True)
        b=c*d
        beta=g*b*b
        self.assertNotEqual(sp.simplify(beta_gap(beta,d)),0)
