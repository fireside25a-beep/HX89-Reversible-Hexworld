import unittest
import mpmath as mp
from crtc.monitor import guarded_point, stress_precision_cases

class TestMonitor(unittest.TestCase):
    def test_guarded_identity(self):
        r=guarded_point('1.7','1.31','0.2',force_mp=True)
        self.assertLess(abs(mp.mpf(r['defect'])-mp.mpf(r['predicted'])),mp.mpf('1e-30'))

    def test_overflow_recovery_does_not_change_coefficients(self):
        r=guarded_point('1e308','1e308','1e308',base_dps=60,max_dps=960)
        self.assertEqual(r['mode'],'mpmath')
        self.assertTrue(mp.isfinite(r['defect']))

    def test_declared_precision_stress_suite(self):
        self.assertTrue(stress_precision_cases())
