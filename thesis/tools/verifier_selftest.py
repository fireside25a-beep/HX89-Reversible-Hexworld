#!/usr/bin/env python3
"""Negative-control tests for the thesis consistency gates.

The script deliberately introduces three temporary faults, requires the relevant
checker to reject each one, and restores the original bytes in a finally block.
A final clean pass proves restoration succeeded.
"""
from __future__ import annotations
import json, subprocess, sys
from pathlib import Path

THESIS = Path(__file__).resolve().parents[1]
ROOT = THESIS.parent
PY = sys.executable


def run_expect_fail(cmd, needle: str):
    p = subprocess.run(cmd, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if p.returncode == 0:
        raise SystemExit(f"negative control unexpectedly passed: {' '.join(map(str, cmd))}")
    if needle not in p.stdout:
        raise SystemExit(f"negative control failed for the wrong reason; expected {needle!r}\n{p.stdout[-2000:]}")


def mutate_file(path: Path, transform, cmd, needle: str):
    original = path.read_bytes()
    try:
        text = original.decode('utf-8')
        changed = transform(text)
        if changed == text:
            raise SystemExit(f"self-test mutation did not change {path}")
        path.write_text(changed, encoding='utf-8')
        run_expect_fail(cmd, needle)
    finally:
        path.write_bytes(original)


def main():
    # 1. Equation symbol/sign drift must be rejected by the equation registry.
    chapter = THESIS / 'chapters' / '06_rigidity.tex'
    mutate_file(
        chapter,
        lambda s: s.replace('a_0-a(p)', 'a_0+a(p)', 1),
        [PY, str(THESIS/'tools/equation_registry.py'), '--check'],
        'equation registry drift',
    )

    # 2. A stale finite-domain certificate must be rejected by the source generator.
    cert = ROOT / 'evidence' / 'transport_circle_certificate.txt'
    mutate_file(
        cert,
        lambda s: s.replace('3575 rational', '3574 rational', 1),
        [PY, str(THESIS/'tools/generate_fragments.py'), '--check'],
        'transport count mismatch',
    )

    # 3. Compiled equation-number drift must be rejected independently of source hashes.
    reg = THESIS / 'generated' / 'equation_registry.json'
    original = reg.read_bytes()
    try:
        data = json.loads(original)
        key = sorted(data['equations'])[0]
        data['equations'][key]['number'] = 'VERIFIER_SENTINEL'
        reg.write_text(json.dumps(data, indent=2, sort_keys=True)+'\n', encoding='utf-8')
        run_expect_fail(
            [PY, str(THESIS/'tools/equation_registry.py'), '--check'],
            'equation registry drift',
        )
    finally:
        reg.write_bytes(original)

    # Restoration itself is checked, not assumed.
    subprocess.run([PY, str(THESIS/'tools/equation_registry.py'), '--check'], cwd=ROOT, check=True)
    subprocess.run([PY, str(THESIS/'tools/generate_fragments.py'), '--check'], cwd=ROOT, check=True)
    print('PASS: verifier negative controls reject equation, certificate, and numbering drift; restoration=PASS')


if __name__ == '__main__':
    main()
