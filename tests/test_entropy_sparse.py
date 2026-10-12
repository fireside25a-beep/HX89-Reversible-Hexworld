#!/usr/bin/env python3
"""Regression for the seeded entropy sparse-field retirement bug.

The ENTROPY opcode chooses one of ten signed directions in the five-dimensional
coordinate field.  Every branch emits one axis letter and then retires once.
Intentional termination must land on a real HALT cell at coordinate +/-2,
not on missing sparse-field storage.
"""
from __future__ import annotations

from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parent.parent
VM = ROOT / "bin" / "hx89"
PROGRAM = ROOT / "polyforms" / "entropy.hx"

# Small deterministic witness set covering every (axis, sign) branch.
WITNESSES = {
    (0, +1): 1,
    (0, -1): 2,
    (1, +1): 4,
    (1, -1): 28,
    (2, +1): 8,
    (2, -1): 5,
    (3, +1): 17,
    (3, -1): 12,
    (4, +1): 13,
    (4, -1): 10,
}


def run(seed: int) -> str:
    proc = subprocess.run(
        [str(VM), str(PROGRAM), str(seed), "100"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    combined = proc.stdout + proc.stderr
    assert proc.returncode == 0, (seed, proc.returncode, combined)
    assert "out of bounds" not in combined.lower(), (seed, combined)
    assert "sparse" not in combined.lower() or "sparse-field" not in combined.lower(), (seed, combined)
    assert "HX89 halt steps=3" in combined, (seed, combined)
    return combined


def parse_direction(output: str) -> tuple[int, int]:
    m = re.search(r"^ENTROPY .* axis=(\d+) sign=(-?\d+)$", output, re.MULTILINE)
    assert m, output
    return int(m.group(1)), int(m.group(2))


def parse_halt_cells() -> set[tuple[int, int, int, int, int]]:
    cells = set()
    for line in PROGRAM.read_text(encoding="ascii").splitlines():
        parts = line.split()
        if len(parts) == 10 and parts[0] == "CELL" and parts[6] == "0":
            cells.add(tuple(map(int, parts[1:6])))
    return cells


def main() -> None:
    halt_cells = parse_halt_cells()
    expected_halts = set()
    for axis in range(5):
        for sign in (-1, +1):
            coord = [0, 0, 0, 0, 0]
            coord[axis] = 2 * sign
            expected_halts.add(tuple(coord))
    assert expected_halts <= halt_cells, (expected_halts - halt_cells)

    observed = {}
    for expected, seed in WITNESSES.items():
        out = run(seed)
        actual = parse_direction(out)
        assert actual == expected, (seed, expected, actual, out)
        observed[actual] = seed

    assert set(observed) == set(WITNESSES)

    # The historical reproducer must specifically select +V and terminate.
    out = run(12345)
    assert parse_direction(out) == (4, +1), out
    assert re.search(r"^VHX89 halt steps=3", out, re.MULTILINE), out

    print("PASS: entropy sparse-field regression seed=12345")
    print("PASS: all 10 signed five-axis entropy exits terminate on explicit HALT cells")


if __name__ == "__main__":
    main()
