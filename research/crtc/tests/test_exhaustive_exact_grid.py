import unittest
from fractions import Fraction

class TestExhaustiveDeclaredExactGrid(unittest.TestCase):
    """Exact rational sweeps over declared finite verification domains.

    These are exhaustive over the finite grids stated here, not over the continuum.
    The continuum identities are separately proved symbolically.
    """

    def test_boltzmann_circle_9595_exact_points(self):
        count=0
        for n in range(1,96):              # rho=n/16, 0<rho<6
            rho=Fraction(n,16)
            D=rho*(1-rho/Fraction(6))**3
            A=1/(2*D)
            for m in range(101):           # p=m/100
                p=Fraction(m,100)
                d=p-Fraction(1,2)
                u2=Fraction(4,3)*d*d
                den=1+u2
                x=A/den
                y2=A*A*u2/(den*den)
                self.assertEqual(x*x+y2-A*x,0)
                count+=1
        self.assertEqual(count,9595)

    def test_positive_dissipation_counterexample_1001_exact_points(self):
        a0=Fraction(3,2)
        eps=Fraction(2,5)
        c=Fraction(9,10)
        count=nonzero=0
        for i in range(-500,501):
            d=Fraction(i,1000)
            a=a0+eps*d*d
            b=c*d
            self.assertGreater(a,0)
            defect=(a0-a)/(a0*(a*a+b*b))
            if d == 0:
                self.assertEqual(defect,0)
            else:
                self.assertLess(defect,0)
                nonzero+=1
            count+=1
        self.assertEqual((count,nonzero),(1001,1000))
