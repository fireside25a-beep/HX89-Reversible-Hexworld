#!/usr/bin/env python3
from __future__ import annotations
import importlib.util, json, os, re, subprocess, sys
from pathlib import Path
import sympy as sp

ROOT = Path(__file__).resolve().parents[1]
SCI = ROOT / 'scientific'
SCI.mkdir(exist_ok=True)


def run(args, env=None):
    p = subprocess.run(args, cwd=ROOT, text=True, capture_output=True, check=True, env=env)
    return p.stdout + p.stderr

# Machine certificates are executed from this tree.
chiral = run([str(ROOT/'bin/hx89-chiral-proof')])
m = re.search(r'local_states=(\d+) global_states=(\d+).*?corr_minus=(-?\d+)/(-?\d+) corr_plus=(-?\d+)/(-?\d+)', chiral)
if not m:
    raise SystemExit('unable to parse chiral certificate')
local_states, global_states, cm1, cm2, cp1, cp2 = map(int, m.groups())

transport = run([sys.executable, 'tests/test_transport_circle.py'])
m = re.search(r'over\s+(\d+)\s+rational', transport)
if not m:
    raise SystemExit('unable to parse transport-circle certificate')
transport_points = int(m.group(1))

entropy = run([sys.executable, 'tests/test_entropy_sparse.py'])
em = re.search(r'seed=(\d+).*?all\s+(\d+)\s+signed five-axis', entropy, re.S)
if not em:
    raise SystemExit('unable to parse entropy regression certificate')
entropy_seed, entropy_branches = map(int, em.groups())
entropy_run = run([str(ROOT/'bin/hx89'), 'polyforms/entropy.hx', str(entropy_seed), '100'])
dm = re.search(r'axis=(\d+) sign=(-?\d+)', entropy_run)
if not dm:
    raise SystemExit('unable to parse entropy direction')
axis, sign = map(int, dm.groups())
entropy_coord = [0,0,0,0,0]
entropy_coord[axis] = 2*sign

# CRTC test count from a real unittest run.
env = dict(os.environ)
env['PYTHONPATH'] = str(ROOT/'research/crtc/src')
crtc = run([sys.executable, '-m', 'unittest', 'discover', '-s', 'research/crtc/tests', '-v'], env=env)
m = re.search(r'Ran\s+(\d+)\s+tests?', crtc)
if not m or '\nOK' not in crtc:
    raise SystemExit('CRTC unittest suite failed')
crtc_tests = int(m.group(1))

# Exact finite-grid definitions are imported from the test module itself.
spec = importlib.util.spec_from_file_location('grid_cert', ROOT/'research/crtc/tests/test_exhaustive_exact_grid.py')
mod = importlib.util.module_from_spec(spec)
assert spec and spec.loader
spec.loader.exec_module(mod)
# The module deliberately exposes tests, not constants, so recompute from the source domains
# and verify the declared assertions are still present.
grid_src=(ROOT/'research/crtc/tests/test_exhaustive_exact_grid.py').read_text()
compact=re.sub(r'\s+','',grid_src)
for token in ['range(1,96)','range(101)','range(-500,501)','self.assertEqual(count,9595)','self.assertEqual((count,nonzero),(1001,1000))']:
    if token not in compact:
        raise SystemExit(f'CRTC grid source changed: {token}')
crtc_grid = len(range(1,96))*len(range(101))
counter_grid = len(range(-500,501))
counter_nonzero = counter_grid-1

# Symbolically verify the registry equations against the executable CRTC definitions.
sys.path.insert(0, str(ROOT/'research/crtc/src'))
from crtc.fhp import published_shear_lambda, boltzmann_response
from crtc.geometry import anchored_circle_defect, achiral_curvature, shear_kernel, R120

rho,p=sp.symbols('rho p', positive=True, real=True)
d=p-sp.Rational(1,2)
D=rho*(1-rho/6)**3
u=2*sp.sqrt(3)*d/3
A=1/(2*D)
lam=-D/2*(1-sp.I*u)
if sp.simplify(published_shear_lambda(rho,p)-lam)!=0:
    raise SystemExit('published shear eigenvalue drift')
eta,eta_h,x,A2,u2=boltzmann_response(rho,p)
if any(sp.simplify(v)!=0 for v in [A2-A,u2-u,(x-A/2)**2+eta_h**2-(A/2)**2,(x+sp.I*eta_h)+1/(4*sp.conjugate(lam))]):
    raise SystemExit('FHP response identity drift')

a0,a,b=sp.symbols('a0 a b', positive=True, real=True)
if sp.simplify(anchored_circle_defect(a0,a,b)-(a0-a)/(a0*(a*a+b*b)))!=0:
    raise SystemExit('response defect drift')
a2,b1=sp.symbols('a2 b1', real=True, nonzero=True)
if sp.simplify(achiral_curvature(a0,a2,b1)-(-2*a0-a0*a0*a2/(b1*b1)))!=0:
    raise SystemExit('curvature formula drift')
X=sp.Matrix(sp.symbols('x11 x12 x21 x22')).reshape(2,2)
if sp.simplify(shear_kernel(a,b)*R120-R120*shear_kernel(a,b)) != sp.zeros(2):
    raise SystemExit('C6 commutant representative drift')

claims = {
    'project':'HX89',
    'author':'Alex Moraru',
    'machine':{
        'chiral_local_states':local_states,
        'chiral_global_states':global_states,
        'corr_minus_ab':cm1,
        'corr_minus_ba':cm2,
        'corr_plus_ab':cp1,
        'corr_plus_ba':cp2,
        'entropy_regression_seed':entropy_seed,
        'entropy_regression_coordinate':entropy_coord,
        'entropy_signed_branches':entropy_branches,
    },
    'transport':{
        'canonical_exact_parameter_triples':transport_points,
        'crtc_exact_rational_points':crtc_grid,
        'counterexample_exact_points':counter_grid,
        'counterexample_nonzero_defects':counter_nonzero,
        'crtc_tests':crtc_tests,
    },
    'status':{
        'microscopic_reversor':'proved from local identities and machine certified on the complete 2x2 torus',
        'transport_circle_boltzmann':'exact derived corollary of published molecular-chaos coefficients',
        'response_rigidity_classification':'proved exactly for nonzero complex response with the stated anchor',
        'green_kubo_survival_in_correlated_fhp':'open',
        'ward_identity_protection':'not established',
    }
}
(SCI/'claims.json').write_text(json.dumps(claims,indent=2,sort_keys=True)+'\n')

equations={
 'fhp_D':r'D=\rho\left(1-\tfrac{\rho}{6}\right)^3',
 'fhp_A':r'A=\frac{1}{2D}',
 'fhp_u':r'u=\frac{2\sqrt3}{3}\left(p-\tfrac12\right)',
 'fhp_eta_shifted':r'\bar\eta=\frac{A}{1+u^2}',
 'fhp_eta_h':r'\eta_{\mathrm H}=-\frac{Au}{1+u^2}',
 'transport_circle':r'(\eta+\tfrac18-\tfrac A2)^2+\eta_{\mathrm H}^2=(\tfrac A2)^2',
 'fhp_lambda':r'\lambda=-\frac{D}{2}\left(1-i u\right)',
 'fhp_complex_response':r'Z_{\mathrm B}=\bar\eta+i\eta_{\mathrm H}=\frac{A}{1+i u}=-\frac{1}{4\lambda^*}',
 'anchored_circle':r'(x-\tfrac{x_0}{2})^2+y^2=(\tfrac{x_0}{2})^2',
 'response_defect':r'\Delta=x^2+y^2-x_0x',
 'inverse_response':r'Q=\frac1Z=a+ib',
 'normalized_defect':r'\frac{\Delta}{|Z|^2}=1-x_0\operatorname{Re}\!\left(\frac1Z\right)',
 'rigidity':r'\operatorname{Re}\!\left(\frac1{Z(p)}\right)=\operatorname{Re}\!\left(\frac1{Z(p_0)}\right)',
 'kernel_defect':r'\Delta=\frac{a_0-a}{a_0(a^2+b^2)}',
 'commutant':r'M=aI+bJ,\qquad J=\begin{pmatrix}0&-1\\1&0\end{pmatrix},\qquad J^2=-I',
 'curvature':r'\kappa(0)=-2a_0-\frac{a_0^2a^{\prime\prime}(0)}{[b^{\prime}(0)]^2}',
 'reversor':r'\Theta_\chi F_\chi\Theta_\chi=F_\chi^{-1}',
 'echo':r'\Theta_\chi F_\chi^t\Theta_\chi F_\chi^t=I',
 'ou_kernel':r'K(d)=(a_0+\epsilon d^2)I+cdJ',
 'ou_noise':r'BB^T=2A(a_0+\epsilon d^2)I',
 'ou_defect':r'\Delta(d)=-\frac{\epsilon d^2}{a_0\{(a_0+\epsilon d^2)^2+c^2d^2\}}',
}
(SCI/'equation_registry.json').write_text(json.dumps(equations,indent=2,sort_keys=True)+'\n')
print('SCIENTIFIC_REGISTRY_PASS')
print(json.dumps(claims,sort_keys=True))
