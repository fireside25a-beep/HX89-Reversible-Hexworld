#!/usr/bin/env python3
"""Independent oracle for HX89 chiral reciprocity, reversor and echo identities."""
from fractions import Fraction
from pathlib import Path
import random
import subprocess

ROOT = Path(__file__).resolve().parent.parent
DX = (1, 0, -1, -1, 0, 1)
DY = (0, 1, 1, 0, -1, -1)


def collision(s, chi):
    if s == 9: return 18 if chi > 0 else 36
    if s == 18: return 36 if chi > 0 else 9
    if s == 36: return 9 if chi > 0 else 18
    if s == 21: return 42
    if s == 42: return 21
    return s


def reflect_local(s):
    return sum(1 << (-i % 6) for i in range(6) if s & (1 << i))


def reverse_velocity_local(s):
    return sum(1 << ((i + 3) % 6) for i in range(6) if s & (1 << i))


def popcount(s):
    return sum((s >> i) & 1 for i in range(6))


def momentum(s):
    return (sum(DX[i] for i in range(6) if s & (1 << i)),
            sum(DY[i] for i in range(6) if s & (1 << i)))


def step(state, n, chi):
    out = bytearray(n*n)
    for y in range(n):
        for x in range(n):
            s = collision(state[y*n+x], chi)
            for i in range(6):
                if s & (1 << i):
                    out[((y+DY[i]) % n)*n + (x+DX[i]) % n] |= 1 << i
    return out


def unstep(state, n, chi):
    out = bytearray(n*n)
    for y in range(n):
        for x in range(n):
            incoming = sum(state[((y+DY[i]) % n)*n + (x+DX[i]) % n] & (1 << i)
                           for i in range(6))
            out[y*n+x] = collision(incoming, -chi)
    return out


def reflect(state, n):
    out = bytearray(n*n)
    for y in range(n):
        for x in range(n):
            out[(-y % n)*n + ((x+y) % n)] = reflect_local(state[y*n+x])
    return out


def reverse_velocity(state):
    return bytearray(reverse_velocity_local(s) for s in state)


def theta(state, n, chi):
    return bytearray(collision(s, -chi) for s in reflect(reverse_velocity(state), n))


def iterate(state, n, chi, count):
    q = bytearray(state)
    for _ in range(count):
        q = step(q, n, chi)
    return q


def echo(state, n, chi, count):
    # Forward t -> Theta -> forward t -> Theta.
    q = iterate(state, n, chi, count)
    q = theta(q, n, chi)
    q = iterate(q, n, chi, count)
    return theta(q, n, chi)


def rank_fraction(rows):
    a = [[Fraction(v) for v in row] for row in rows]
    r = 0
    for c in range(len(a[0])):
        pivot = next((i for i in range(r, len(a)) if a[i][c]), None)
        if pivot is None:
            continue
        a[r], a[pivot] = a[pivot], a[r]
        q = a[r][c]
        a[r] = [v/q for v in a[r]]
        for i in range(len(a)):
            if i != r and a[i][c]:
                q = a[i][c]
                a[i] = [u-q*v for u, v in zip(a[i], a[r])]
        r += 1
    return r


def main():
    for s in range(64):
        for chi in (-1, +1):
            t = collision(s, chi)
            assert collision(t, -chi) == s
            assert popcount(t) == popcount(s)
            assert momentum(t) == momentum(s)
            assert reflect_local(collision(reflect_local(s), chi)) == collision(s, -chi)
            assert reverse_velocity_local(collision(reverse_velocity_local(s), chi)) == t

    # Exact rank of all occupation-vector changes caused by C_+.
    rows = []
    for s in range(64):
        t = collision(s, +1)
        rows.append([((t >> i) & 1) - ((s >> i) & 1) for i in range(6)])
    assert rank_fraction(rows) == 3
    for basis in ((1,1,1,1,1,1), DX, DY):
        assert all(sum(row[i]*basis[i] for i in range(6)) == 0 for row in rows)

    rng = random.Random(0x89C0C17)
    for n in (3, 4, 5, 7):
        for _ in range(128):
            state = bytearray(rng.randrange(64) for _ in range(n*n))
            assert reflect(step(state, n, +1), n) == step(reflect(state, n), n, -1)
            for chi in (-1, +1):
                th = theta(state, n, chi)
                assert theta(th, n, chi) == state
                assert theta(step(theta(state, n, chi), n, chi), n, chi) == unstep(state, n, chi)
                for t in (0, 1, 2, 3, 7):
                    assert echo(state, n, chi, t) == state

    proof = subprocess.check_output([str(ROOT / "bin/hx89-chiral-proof")], text=True)
    required = (
        "global_states=16777216",
        "dressed_PT_reversor=PASS",
        "echo=PASS",
        "correlation_reciprocity=PASS",
        "both_chiralities=PASS",
    )
    assert all(x in proof for x in required)
    print("PASS: chiral reciprocity, dressed PT reversor, exact echo/correlation law, only 3 one-body linear invariants, independent larger-torus oracle")


if __name__ == "__main__":
    main()
