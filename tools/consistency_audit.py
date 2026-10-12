#!/usr/bin/env python3
from __future__ import annotations
import json, re, subprocess, sys
from pathlib import Path
import sympy as sp

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'research/crtc/src'))
from crtc.fhp import published_shear_lambda, boltzmann_response
from crtc.geometry import anchored_circle_defect, achiral_curvature

errors=[]
def ok(cond,msg):
    if not cond: errors.append(msg)
def read(rel): return (ROOT/rel).read_text(encoding='utf-8')
def compact(s): return re.sub(r'\s+','',s).replace('\\left','').replace('\\right','')

# 1. Independent implementations of the deterministic chiral collision keep the same maps.
csrc,psrc,hsrc=read('src/chiral_law.c'),read('tests/test_chiral_law.py'),read('src/hex_gas.c')
for state in (9,18,36,21,42):
    ok(str(state) in csrc and str(state) in psrc and str(state) in hsrc,f'collision state {state} missing')
for token in ('chirality > 0 ? 18 : 36','chirality > 0 ? 36 : 9','chirality > 0 ? 9 : 18'):
    ok(token in csrc,f'C collision mapping changed: {token}')
for token in ('18 if chi > 0 else 36','36 if chi > 0 else 9','9 if chi > 0 else 18'):
    ok(token in psrc,f'Python collision mapping changed: {token}')

# 2. Sparse termination is explicit, while genuine sparse-field errors remain live.
ent=read('polyforms/entropy.hx')
for axis in range(5):
    for sign in (-2,2):
        c=['0']*5; c[axis]=str(sign)
        ok('CELL '+' '.join(c)+' 0 0 0 0' in ent,f'missing explicit entropy HALT {tuple(c)}')
ok('fell out of the sparse field' in read('src/hx89_x86_64.S'),'sparse-field diagnostic removed')

# 3. Central executable mathematics agrees symbolically with independently stated formulas.
rho,p=sp.symbols('rho p', positive=True, real=True)
d=p-sp.Rational(1,2); D=rho*(1-rho/6)**3; u=2*sp.sqrt(3)*d/3; A=1/(2*D)
lam=-D/2*(1-sp.I*u)
ok(sp.simplify(published_shear_lambda(rho,p)-lam)==0,'FHP lambda mismatch')
eta,eta_h,x,A2,u2=boltzmann_response(rho,p)
ok(sp.simplify(A2-A)==0 and sp.simplify(u2-u)==0,'FHP normalization mismatch')
ok(sp.factor((x-A/2)**2+eta_h**2-(A/2)**2)==0,'FHP circle mismatch')
ok(sp.simplify((x+sp.I*eta_h)+1/(4*sp.conjugate(lam)))==0,'FHP spectral inversion mismatch')
a0,a,b=sp.symbols('a0 a b', positive=True, real=True)
ok(sp.simplify(anchored_circle_defect(a0,a,b)-(a0-a)/(a0*(a*a+b*b)))==0,'inverse-response defect mismatch')
a2,b1=sp.symbols('a2 b1', real=True, nonzero=True)
ok(sp.simplify(achiral_curvature(a0,a2,b1)-(-2*a0-a0*a0*a2/(b1*b1)))==0,'curvature mismatch')

# 4. Machine-readable claims must equal the generated thesis macros and certificates.
claims=json.loads(read('scientific/claims.json'))
canon=read('thesis/generated/canonical.tex')
macro_map={
 'HXTransportGridPoints':claims['transport']['canonical_exact_parameter_triples'],
 'HXLocalStates':claims['machine']['chiral_local_states'],
 'HXGlobalStates':claims['machine']['chiral_global_states'],
 'CRTCUnitTests':claims['transport']['crtc_tests'],
 'CRTCBoltzmannGridPoints':claims['transport']['crtc_exact_rational_points'],
 'CRTCCounterGridPoints':claims['transport']['counterexample_exact_points'],
 'CRTCCounterOffCircle':claims['transport']['counterexample_nonzero_defects'],
}
for macro,value in macro_map.items():
    m=re.search(r'\\newcommand\{\\'+re.escape(macro)+r'\}\{([^}]*)\}',canon)
    ok(bool(m),f'missing generated macro {macro}')
    if m:
        got=int(m.group(1).replace(',',''))
        ok(got==value,f'{macro}={got} but registry={value}')
ch=read('evidence/chiral_law_certificate.txt'); tc=read('evidence/transport_circle_certificate.txt')
ok(f"global_states={claims['machine']['chiral_global_states']}" in ch,'chiral certificate count drift')
ok(f"over {claims['transport']['canonical_exact_parameter_triples']} rational" in tc,'transport certificate count drift')

# 5. Central equation registry must be represented in the actual thesis/paper sources.
# Regexes intentionally permit harmless TeX spacing/parentheses differences while fixing symbols and signs.
texts={
 'thesis':compact('\n'.join(read(str(p.relative_to(ROOT))) for p in sorted((ROOT/'thesis/chapters').glob('*.tex')))+read('thesis/companion.tex')),
 'paper':compact(read('research/crtc/paper/main.tex')),
 'proofs':compact(read('thesis/appendices/A_proofs.tex')),
}
patterns={
 'rigidity':r'RePart\\!?' + r'\\?left?\(?\\frac1\{Z\(p\)\}\)?=RePart\\!?' + r'\\?left?\(?\\frac1\{Z\(p_0\)\}\)?',
}
# Use compact literal anchors for equations whose TeX conventions are stable in this tree.
required_literals={
 'thesis':[
  r'\Delta(p)=|Z(p)|^2-x_0\RePartZ(p)',
  r'\frac{\Delta}{|Z|^2}=1-x_0\RePart\!\left(\frac1Z\right)',
  r'\Delta(p)=\frac{a_0-a(p)}{a_0\left[a(p)^2+b(p)^2\right]}',
  r'M=aI+bJ',
  r'\kappa(0)=-2a_0-\frac{a_0^2a_2}{b_1^2}',
  r'\Theta_\chiF_\chi\Theta_\chi=F_\chi^{-1}',
  r'\Theta_\chiF_\chi^t\Theta_\chiF_\chi^t=I',
 ],
 'paper':[
  r'\frac{\Delta}{|Z|^2}=1-x_0\Ree\frac{1}{Z}',
  r'\Delta=\frac{a_0-a}{a_0(a^2+b^2)}',
  r'X=aI+bJ',
  r'\kappa(0)=-2a_0-\frac{a_0^2a_2}{b_1^2}',
 ],
 'proofs':[
  r'\kappa(0)=-2a_0-\frac{a_0^2a_2}{b_1^2}',
  r'\lambda=-\frac{D}{2}+i\frac{\sqrt3D}{3}d',
 ],
}
for group,lits in required_literals.items():
    t=texts[group]
    for lit in lits:
        # Normalize the literal with the same rules before matching as text.
        needle=compact(lit)
        ok(needle in t,f'{group} lost canonical equation fragment: {lit}')

# 6. The status boundary must remain explicit in every public scientific document.
for rel in ['README.md','SCIENTIFIC_STATUS.md','docs/THEOREM_STATUS.md','docs/TRANSPORT_CIRCLE.md','thesis/chapters/08_discussion.tex','thesis/chapters/09_conclusion.tex','thesis/companion.tex','research/crtc/paper/main.tex']:
    low=read(rel).lower().replace('---','-').replace('--','-')
    ok('open' in low and ('green-kubo' in low or 'green kubo' in low),f'{rel} lost open Green-Kubo boundary')
for rel in ['SCIENTIFIC_STATUS.md','docs/TRANSPORT_CIRCLE.md','thesis/chapters/06_rigidity.tex','thesis/chapters/08_discussion.tex','thesis/companion.tex','research/crtc/paper/main.tex']:
    low=read(rel).lower()
    ok('ward' in low and ('not' in low or 'does not' in low),f'{rel} lost Ward-identity boundary')

# 7. No historical monolith-release prose remains in authored user-facing documents.
for rel in ['README.md','SCIENTIFIC_STATUS.md']+[str(p.relative_to(ROOT)) for p in (ROOT/'docs').glob('*.md')]:
    txt=read(rel)
    ok(not re.search(r'\b(?:version\s+|HX89\s+)0\.[5-8](?:\.0)?\b',txt,re.I),f'{rel} contains stale release-history prose')

# 8. Compiled documents must exist and carry the canonical numerical claims.
for rel in ['dist/Alex_Moraru_Thesis.pdf','dist/Alex_Moraru_Thesis_Companion.pdf','dist/CRTC_Response_Rigidity.pdf']:
    p=ROOT/rel
    ok(p.exists() and p.stat().st_size>10000,f'missing compiled document {rel}')
    if p.exists():
        try:
            out=subprocess.check_output(['pdftotext',str(p),'-'],text=True,errors='replace')
        except Exception:
            out=''
        ok('Alex Moraru' in out,f'{rel} missing author text')
        if 'Thesis' in rel:
            for token in ['16,777,216','3,575','9,595','1,001']:
                ok(token in out,f'{rel} missing canonical token {token}')

if errors:
    print('CONSISTENCY_AUDIT_FAIL')
    for e in errors: print(' -',e)
    raise SystemExit(1)
print('CONSISTENCY_AUDIT_PASS')
