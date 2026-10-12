#!/usr/bin/env python3
from pathlib import Path
import re, subprocess, sys, hashlib
T=Path(__file__).resolve().parents[1]
R=T.parent

# Generated source must be current.
subprocess.run([sys.executable, str(T/'tools/generate_fragments.py'), '--check'], check=True)

tex_files=[T/'main.tex',T/'companion.tex']+sorted((T/'chapters').glob('*.tex'))+sorted((T/'appendices').glob('*.tex'))
text='\n'.join(p.read_text(encoding='utf-8') for p in tex_files)

# Labels must be unique. Every explicit ref key must exist in the thesis sources.
labels=re.findall(r'\\label\{([^}]+)\}',text)
if len(labels)!=len(set(labels)):
    dup=sorted({x for x in labels if labels.count(x)>1})
    raise SystemExit(f'duplicate LaTeX labels: {dup}')
labelset=set(labels)
refs=[]
for pat in [r'\\eqref\{([^}]+)\}',r'\\ref\{([^}]+)\}',r'\\cref\{([^}]+)\}',r'\\Cref\{([^}]+)\}']:
    for m in re.finditer(pat,text):
        refs.extend(x.strip() for x in m.group(1).split(','))
missing=sorted(set(refs)-labelset)
if missing:
    raise SystemExit(f'missing LaTeX labels: {missing}')

# Citation keys must all exist in the bibliography.
bib=(T/'references.bib').read_text(encoding='utf-8')
bibkeys=set(re.findall(r'@[A-Za-z]+\{([^,]+),',bib))
cites=[]
for m in re.finditer(r'\\cite\w*\{([^}]+)\}',text):
    cites.extend(x.strip() for x in m.group(1).split(','))
missing_cites=sorted(set(cites)-bibkeys)
if missing_cites:
    raise SystemExit(f'missing bibliography keys: {missing_cites}')

# Core source/evidence correspondence.
transport=(R/'evidence/transport_circle_certificate.txt').read_text()
chiral=(R/'evidence/chiral_law_certificate.txt').read_text()
for phrase in ['3575 rational', 'Q(sqrt(3))']:
    if phrase not in transport: raise SystemExit(f'transport certificate missing {phrase!r}')
for phrase in ['local_states=64','global_states=16777216','echo=PASS','correlation_reciprocity=PASS']:
    if phrase not in chiral: raise SystemExit(f'chiral certificate missing {phrase!r}')

# Logs from compiled documents may not contain unresolved references or citations.
for logname in ['THESIS_LATEX.log','COMPANION_LATEX.log']:
    p=T/'results'/logname
    if not p.exists(): raise SystemExit(f'missing compiled log {logname}')
    low=p.read_text(errors='replace').lower()
    bad=['undefined references','undefined citations','citation `','reference `']
    # The generic strings citation/reference are considered only when followed by undefined in common TeX output.
    if 'there were undefined references' in low or 'there were undefined citations' in low or re.search(r'(citation|reference) [`\'\"]?[^\n]+ undefined',low):
        raise SystemExit(f'unresolved references in {logname}')

# Compiled PDFs must contain the canonical generated numbers and title.
for pdf in [T/'Alex_Moraru_Thesis.pdf',T/'Alex_Moraru_Thesis_Companion.pdf']:
    if not pdf.exists() or pdf.stat().st_size < 10000:
        raise SystemExit(f'missing or implausibly small PDF: {pdf.name}')
    out=subprocess.check_output(['pdftotext',str(pdf),'-'],text=True,errors='replace')
    if 'Alex Moraru' not in out: raise SystemExit(f'{pdf.name}: title/author text missing')
    for token in ['16,777,216','3,575','9,595','1,001']:
        if token not in out: raise SystemExit(f'{pdf.name}: canonical token {token} missing')

# The exact theorem and open problem language must both be present.
if 'Fully correlated chiral FHP preserves CRTC' not in text:
    raise SystemExit('claim matrix missing correlated FHP claim')
if 'Open' not in (T/'appendices/E_claim_matrix.tex').read_text():
    raise SystemExit('open physical status lost')

print(f'PASS: cross-document consistency; labels={len(labels)} citations={len(set(cites))} bibliography={len(bibkeys)}')
