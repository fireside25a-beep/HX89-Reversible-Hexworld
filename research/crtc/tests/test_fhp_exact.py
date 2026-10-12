import unittest
import sympy as sp
from crtc.fhp import (transition_distribution, rotate_state, reflect_state,
                      circulant_eigenvalues, published_shear_lambda, boltzmann_response)

class TestFHPExact(unittest.TestCase):
    def test_all_64_transition_probabilities_normalize(self):
        p=sp.symbols('p', real=True)
        for s in range(64):
            self.assertEqual(sp.simplify(sum(w for _,w in transition_distribution(s,p))),1)

    def test_c6_covariance_all_64_states(self):
        p=sp.symbols('p', real=True)
        for s in range(64):
            lhs=sorted((rotate_state(o),sp.expand(w)) for o,w in transition_distribution(s,p))
            rhs=sorted((o,sp.expand(w)) for o,w in transition_distribution(rotate_state(s),p))
            self.assertEqual(lhs,rhs)

    def test_reflection_conjugates_p_to_one_minus_p_all_64(self):
        p=sp.symbols('p', real=True)
        for s in range(64):
            lhs=sorted((reflect_state(o),sp.expand(w)) for o,w in transition_distribution(s,p))
            rhs=sorted((o,sp.expand(w)) for o,w in transition_distribution(reflect_state(s),1-p))
            self.assertEqual(lhs,rhs)

    def test_enumerated_collision_jacobian_recovers_published_shear_eigenvalue(self):
        vals,f,p=circulant_eigenvalues()
        rho=sp.symbols('rho', positive=True, real=True)
        got=sp.factor(vals[2].subs(f,rho/6))
        want=published_shear_lambda(rho,p)
        self.assertEqual(sp.simplify(got-want),0)
        self.assertEqual(sp.simplify(vals[4].subs(f,rho/6)-sp.conjugate(want)),0)

    def test_published_boltzmann_circle_exact(self):
        rho,p=sp.symbols('rho p', positive=True, real=True)
        eta,eta_h,x,A,u=boltzmann_response(rho,p)
        self.assertEqual(sp.factor((x-A/2)**2+eta_h**2-(A/2)**2),0)

    def test_complex_inversion_identity(self):
        rho,p=sp.symbols('rho p', positive=True, real=True)
        _,eta_h,x,A,u=boltzmann_response(rho,p)
        lam=published_shear_lambda(rho,p)
        Z=sp.simplify(x+sp.I*eta_h)
        self.assertEqual(sp.simplify(Z + 1/(4*sp.conjugate(lam))),0)
