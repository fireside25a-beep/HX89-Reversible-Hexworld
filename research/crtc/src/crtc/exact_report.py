from __future__ import annotations
import sympy as sp
from .geometry import (
    anchored_circle_defect, normalized_circle_defect, solve_commutant,
    response_from_inverse, signed_curvature, achiral_curvature,
    inverse_real_from_response, anchored_response_defect,
)
from .fhp import circulant_eigenvalues, published_shear_lambda, boltzmann_response
from .spectral import same_spectrum_different_overlap_witness


def main():
    a0,a,b = sp.symbols("a0 a b", positive=True, real=True)
    defect = anchored_circle_defect(a0,a,b)
    expected = sp.factor((a0-a)/(a0*(a*a+b*b)))
    print("CRTC EXACT STRUCTURAL REPORT")
    print("commutant_solution=", solve_commutant())
    print("inverse_response_defect=", defect)
    print("defect_formula_pass=", sp.simplify(defect-expected)==0)
    print("normalized_defect=", normalized_circle_defect(a0,a,b))

    x,y,x0=sp.symbols("x y x0", real=True, nonzero=True)
    generic = sp.factor(
        anchored_response_defect(x0,x,y)/(x*x+y*y)
        - (1-x0*inverse_real_from_response(x,y))
    )
    print("closure_free_inverse_response_identity=", generic)

    vals,f,p = circulant_eigenvalues()
    rho = sp.symbols("rho", positive=True, real=True)
    lam_pub = published_shear_lambda(rho,p)
    lam_enum = sp.factor(vals[2].subs(f,rho/6))
    print("fhp_64state_shear_lambda=", lam_enum)
    print("fhp_lambda_match=", sp.simplify(lam_enum-lam_pub)==0)

    _,eta_h,xB,A,_ = boltzmann_response(rho,p)
    boltz_def = sp.factor((xB-A/2)**2 + eta_h**2 - (A/2)**2)
    print("boltzmann_circle_identity=", boltz_def)
    print("boltzmann_complex_inversion=", sp.simplify((xB+sp.I*eta_h) + 1/(4*sp.conjugate(lam_pub))))

    d = sp.symbols("d", real=True)
    aa,c = sp.symbols("aa c", positive=True, real=True)
    r=response_from_inverse(aa,c*d)
    k=sp.simplify(signed_curvature(r.x,r.y,d))
    print("rigid_curvature_squared_identity=", sp.factor(k*k-4*aa*aa))
    print("rigid_curvature_orientation_at_anchor=", sp.simplify(k.subs(d,0)))

    a2,b1=sp.symbols("a2 b1", real=True, nonzero=True)
    print("achiral_curvature_formula=", achiral_curvature(aa,a2,b1))

    eps=sp.symbols("eps", positive=True, real=True)
    counter=sp.factor(anchored_circle_defect(aa,aa+eps*d*d,c*d))
    print("positive_dissipation_counterexample_defect=",counter)

    L1,L2,_,r1,r2=same_spectrum_different_overlap_witness()
    print("same_full_spectrum=", L1.eigenvals()==L2.eigenvals())
    print("different_GK_overlap=", r1, r2, r1!=r2)

if __name__ == "__main__":
    main()
