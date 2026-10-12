#!/usr/bin/env python3
from pathlib import Path
import re, sys

ROOT=Path(__file__).resolve().parents[1]
files=[ROOT/'README.md', ROOT/'SCIENTIFIC_STATUS.md', ROOT/'REPRODUCIBILITY.md']
files += sorted((ROOT/'docs').glob('*.md'))
files += [ROOT/'thesis'/'main.tex', ROOT/'thesis'/'companion.tex']
files += sorted((ROOT/'thesis'/'chapters').glob('*.tex'))
files += sorted((ROOT/'thesis'/'appendices').glob('*.tex'))
files += [ROOT/'research'/'crtc'/'paper'/'main.tex']

banned=[
    'groundbreaking','revolutionary','game-changing','game changing','transformative',
    'unprecedented','remarkable breakthrough','paradigm shift','unlock','delve','nobel',
    'world-changing','world changing','astonishing','incredible result','cutting-edge',
    'cutting edge','state-of-the-art','state of the art','seamlessly','breakthrough',
    'ai-generated','ai generated','as an ai','this thesis leverages',
]
stock=[
    r'\bin conclusion, it is important to note\b',
    r'\bit is worth noting that\b',
    r'\bin today\'?s rapidly evolving\b',
]
errors=[]
for p in files:
    if not p.exists():
        continue
    txt=p.read_text(encoding='utf-8')
    rel=p.relative_to(ROOT)
    for ch,name in [('–','en dash'),('—','em dash'),('−','unicode minus')]:
        if ch in txt:
            errors.append(f'{rel}: contains {name}')
    low=txt.lower()
    for phrase in banned:
        if phrase in low:
            errors.append(f'{rel}: promotional or generation phrase {phrase!r}')
    for pat in stock:
        if re.search(pat,low):
            errors.append(f'{rel}: stock prose pattern {pat}')
if errors:
    print('STYLE_LINT_FAIL')
    print('\n'.join(' - '+e for e in errors))
    raise SystemExit(1)
print(f'STYLE_LINT_PASS files={len([p for p in files if p.exists()])}')
