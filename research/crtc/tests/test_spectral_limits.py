import unittest
import sympy as sp
from crtc.spectral import (
    same_spectrum_different_overlap_witness, reduced_shear_eigenvalues,
    reduced_spectrum_is_rigid,
)

class TestSpectralClaims(unittest.TestCase):
    def test_reduced_two_dimensional_spectrum_decides_a_and_b(self):
        a,b=sp.symbols('a b', real=True)
        vals=reduced_shear_eigenvalues(a,b)
        self.assertEqual(set(vals),{a-sp.I*b,a+sp.I*b})

    def test_reduced_family_rigidity_is_decidable_without_time_simulation(self):
        a0,c=sp.symbols('a0 c', positive=True, real=True)
        vals=[a0+sp.I*c*q for q in (-2,-1,0,1,2)]
        self.assertTrue(reduced_spectrum_is_rigid(vals))
        vals[4]=a0+1+2*sp.I*c
        self.assertFalse(reduced_spectrum_is_rigid(vals))

    def test_unordered_full_spectrum_is_not_enough_for_gk_overlap(self):
        L1,L2,g,r1,r2=same_spectrum_different_overlap_witness()
        self.assertEqual(L1.eigenvals(),L2.eigenvals())
        self.assertNotEqual(r1,r2)
