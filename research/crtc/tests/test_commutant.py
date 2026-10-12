import unittest
import sympy as sp
from crtc.geometry import R120, J, P_REFLECT, shear_kernel, solve_commutant

class TestC6Commutant(unittest.TestCase):
    def test_general_form_commutes(self):
        a,b=sp.symbols('a b', real=True)
        M=shear_kernel(a,b)
        self.assertEqual(sp.simplify(M*R120-R120*M), sp.zeros(2))

    def test_solver_forces_complex_scalar_form(self):
        sol=solve_commutant()
        self.assertTrue(sol)
        # Direct independent algebraic rank check: commutant nullspace has dimension 2.
        x11,x12,x21,x22=sp.symbols('x11 x12 x21 x22')
        X=sp.Matrix([[x11,x12],[x21,x22]])
        expr=X*R120-R120*X
        A,_=sp.linear_eq_to_matrix(list(expr),[x11,x12,x21,x22])
        self.assertEqual(4-A.rank(),2)

    def test_reflection_flips_J(self):
        self.assertEqual(P_REFLECT*J*P_REFLECT, -J)
