#!/usr/bin/env python3
from pathlib import Path
import re, sys
ROOT=Path(__file__).resolve().parents[1]
files=[ROOT/'main.tex', ROOT/'companion.tex']+list((ROOT/'chapters').glob('*.tex'))+list((ROOT/'appendices').glob('*.tex'))
banned=[
    'groundbreaking','revolutionary','game-changing','game changing','transformative',
    'unprecedented','remarkable breakthrough','paradigm shift','unlock','delve',
    'nobel','world-changing','world changing','astonishing','incredible result',
    'cutting-edge','cutting edge','state-of-the-art','state of the art',
    'seamlessly','breakthrough',
]
errors=[]
for p in files:
    if not p.exists(): continue
    txt=p.read_text(encoding='utf-8')
    for ch,name in [('–','en dash'),('—','em dash'),('−','unicode minus')]:
        if ch in txt: errors.append(f'{p.relative_to(ROOT)}: contains {name}')
    low=txt.lower()
    for word in banned:
        if word in low: errors.append(f'{p.relative_to(ROOT)}: promotional phrase {word!r}')
    # Reject stock machine-writing transitions and self-reference to generation process.
    for pat in [r'\b(in conclusion, it is important to note)\b', r'\bthis thesis leverages\b', r'\bai[- ]generated\b']:
        if re.search(pat, low): errors.append(f'{p.relative_to(ROOT)}: style-pattern {pat}')
if errors:
    print('\n'.join(errors)); sys.exit(1)
print(f'PASS: prose lint across {len([p for p in files if p.exists()])} authored TeX files')
