#!/usr/bin/env python3
"""Independent finite-state oracle over the real HX89 process and Polyform I/O."""
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent.parent
VM = ROOT / "bin/hx89"


def run_pair(mode: str, a: int, b: int) -> tuple[int, int]:
    with tempfile.TemporaryDirectory(prefix="hx89-phase-") as directory:
        work = Path(directory)
        source = work / "case.hx"
        source.write_text(
            f"HX87P1\nCELL 0 0 0 0 0 29 0 0 {5*a+b}\n"
            "CELL 1 0 0 0 0 19 0 0 0\n",
            encoding="ascii",
        )
        output = subprocess.check_output(
            [str(VM), f"--phase-{mode}", str(source), "1", "20"],
            cwd=work,
            text=True,
        )
        match = re.search(
            r"^PHASE old=(\d+) qa=(\d+) qb=(\d+) next=(\d+) nqa=(\d+) nqb=(\d+)$",
            output,
            re.MULTILINE,
        )
        assert match, output
        old, aa, bb, next_q, na, nb = map(int, match.groups())
        assert (old, aa, bb) == (5*a+b, a, b), output
        emitted = (work / "hx89.regen").read_text(encoding="ascii")
        record = re.search(r"^CELL 0 0 0 0 0 \d+ 0 0 (\d+)$", emitted, re.MULTILINE)
        assert record, emitted
        assert int(record.group(1)) == next_q == 5*na+nb, (output, emitted)
        return na, nb


def main() -> None:
    forward = {}
    backward = {}
    for a in range(5):
        for b in range(5):
            f = run_pair("forward", a, b)
            r = run_pair("reverse", a, b)
            assert f == ((a+b) % 5, (a+2*b) % 5), (a, b, f)
            assert r == ((2*a-b) % 5, (b-a) % 5), (a, b, r)
            assert run_pair("reverse", *f) == (a, b)
            assert run_pair("forward", *r) == (a, b)
            forward[a, b] = f
            backward[a, b] = r
    assert len(set(forward.values())) == 25
    assert len(set(backward.values())) == 25
    print("PASS: all 25 phase states, both VM directions, oracle, trace, retirement and inverse")


if __name__ == "__main__":
    main()
