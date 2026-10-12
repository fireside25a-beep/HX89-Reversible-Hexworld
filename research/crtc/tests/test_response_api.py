import unittest
from crtc.response import crtc_residual, on_anchored_circle

class TestResponseAPI(unittest.TestCase):
    def test_circle_and_inverse_classifier_agree(self):
        z0=1/2
        for b in (-3,-1,-0.25,0,0.25,1,3):
            z=1/complex(2,b)
            self.assertAlmostEqual(crtc_residual(z,z0),0.0,places=12)
            self.assertTrue(on_anchored_circle(z,z0))

    def test_drift_rejected(self):
        z0=1/2
        z=1/complex(2.1,0.4)
        self.assertNotAlmostEqual(crtc_residual(z,z0),0.0,places=12)
        self.assertFalse(on_anchored_circle(z,z0))
