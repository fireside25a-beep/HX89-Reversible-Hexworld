#!/usr/bin/env python3
"""Independent lattice, VM, audio and HX0 oracle for the hex gas route."""
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent.parent
DX = (1, 0, -1, -1, 0, 1)
DY = (0, 1, 1, 0, -1, -1)


def call(*args, input=None):
    return subprocess.run([str(a) for a in args], input=input, capture_output=True,
                          check=True).stdout


def collision(s, inverse=False):
    if s in (9, 18, 36):
        return (36 if s == 9 else 9 if s == 18 else 18) if inverse else (
            18 if s == 9 else 36 if s == 18 else 9)
    return 63 ^ s if s in (21, 42) else s


def invariant(s):
    bits = [i for i in range(6) if s & (1 << i)]
    return len(bits), sum(DX[i] for i in bits), sum(DY[i] for i in bits)


def random_step(s):
    mask = (1 << 64) - 1
    s ^= s >> 12
    s ^= (s << 25) & mask
    s ^= s >> 27
    return s & mask, (s * 2685821657736338717) & mask


def initial(w, h, seed):
    state = bytearray(w * h)
    for y in range(h):
        for x in range(w):
            cx, cy = 2*x-w+1, 2*y-h+1
            middle = 16*cx*cx < w*w and 16*cy*cy < h*h
            for i in range(6):
                seed, v = random_step(seed)
                if v & 3 < (3 if middle else 1):
                    state[y*w+x] |= 1 << i
    return state


def step(state, w, h):
    new = bytearray(len(state))
    for y in range(h):
        for x in range(w):
            s = collision(state[y*w+x])
            for i in range(6):
                if s & (1 << i):
                    new[((y+DY[i]) % h)*w+(x+DX[i]) % w] |= 1 << i
    return new


def unstep(state, w, h):
    previous = bytearray(len(state))
    for y in range(h):
        for x in range(w):
            incoming = sum(state[((y+DY[i]) % h)*w+(x+DX[i]) % w] & (1 << i)
                           for i in range(6))
            previous[y*w+x] = collision(incoming, True)
    return previous


def rotate(state, n):
    rotated = bytearray(len(state))
    for y in range(n):
        for x in range(n):
            s = state[y*n+x]
            t = ((s << 1) & 63) | (s >> 5)
            rotated[((x+y) % n)*n+(-y) % n] = t
    return rotated


def total(state):
    return tuple(sum(invariant(s)[i] for s in state) for i in range(3))


def reflected(s):
    return sum(1 << (-i % 6) for i in range(6) if s & (1 << i))


def main():
    gas = ROOT / "bin/hx89-gas"
    assert b"64/64" in call(gas, "--verify-local")
    for s in range(64):
        assert collision(collision(s), True) == s
        assert invariant(collision(s)) == invariant(s)
        rotated = ((s << 1) & 63) | (s >> 5)
        mapped = collision(s)
        assert collision(rotated) == (((mapped << 1) & 63) | (mapped >> 5))
        assert reflected(collision(reflected(s))) == collision(s, True)
    rotation_sample = initial(11,11,54321)
    assert rotate(step(rotation_sample,11,11),11) == step(rotate(rotation_sample,11),11,11)
    with tempfile.TemporaryDirectory(prefix="hx89-gas-") as tmp:
        tmp = Path(tmp)
        for w, h, ticks, seed in ((8, 9, 0, 1), (11, 8, 1, 42),
                                  (16, 13, 7, 12345), (64, 64, 40, 12345)):
            pgm, poly = tmp / "gas.pgm", tmp / "gas.hx"
            report = call(gas, w, h, ticks, seed, pgm, poly)
            assert b"reverse=PASS" in report
            state = initial(w, h, seed)
            first = state[:]
            start = total(state)
            for _ in range(ticks):
                state = step(state, w, h)
                assert total(state) == start
            reverse = state[:]
            for _ in range(ticks):
                reverse = unstep(reverse, w, h)
            assert reverse == first
            assert pgm.read_bytes() == (f"P5\n{w} {h}\n255\n".encode() +
                                        bytes(42 * s.bit_count() for s in state))
            profile = bytes(48 + (sum(state[y*w+x].bit_count() for y in range(h))
                            + h//2)//h for x in range(w)) + b"\n"
            machine = call(ROOT / "bin/hx89", poly, 1, w+2)
            assert re.search(rb"(?m)^"+profile.rstrip(b"\n")+rb"$", machine)
            if w == 8:
                image_poly = tmp/"image.hx"
                call(gas,w,h,ticks,seed,pgm,image_poly,"--image-polyform")
                symbols = bytes(int(c) for byte in image_poly.read_bytes()
                                for c in f"{byte:08b}")
                src, wav, decoded = tmp/"poly.bits",tmp/"poly.wav",tmp/"poly.recovered.bits"
                src.write_bytes(symbols)
                call(ROOT/"bin/pulse-pcm","encode-bell202",src,wav)
                call(ROOT/"bin/pulse-pcm","decode-bell202",wav,decoded)
                recovered = call(ROOT/"bin/hx0-x86_64",ROOT/"seeds/hx0_bitstream.hx0",
                                 input=decoded.read_bytes())
                assert recovered == image_poly.read_bytes()
                transport = tmp/"transport.hx"
                transport.write_bytes(recovered)
                emitted = call(ROOT/"bin/hx89",transport,1,w*h+32)
                image = pgm.read_bytes()
                assert emitted.count(image) == 1
            if (w == 64):
                # Run the actual VM output through the Bell waveform and HX0
                # byte assembler; each independently decoded path must agree.
                symbols = bytes(int(c) for byte in profile for c in f"{byte:08b}")
                src, wav, decoded = tmp/"bits", tmp/"profile.wav", tmp/"decoded"
                src.write_bytes(symbols)
                call(ROOT / "bin/pulse-pcm", "encode-bell202", src, wav)
                call(ROOT / "bin/pulse-pcm", "decode-bell202", wav, decoded)
                assert decoded.read_bytes() == symbols
                assert call(ROOT / "bin/hx0-x86_64", ROOT/"seeds/hx0_bitstream.hx0",
                            input=decoded.read_bytes()) == profile
        for args in (("7","8","1","1"), ("8","8","-1","1"),
                     ("8","8","1","0"), ("8","8","1x","1")):
            result = subprocess.run([str(gas), *args, str(tmp/"a"), str(tmp/"b")],
                                    capture_output=True, check=False)
            assert result.returncode != 0
        oversized = subprocess.run([str(gas),"128","128","0","1",str(tmp/"a"),
                                    str(tmp/"b"),"--image-polyform"],
                                   capture_output=True,check=False)
        assert oversized.returncode != 0  # HX89's 4096-cell arena.
    print("PASS: independent hex-gas conservation/reverse and image Polyform through Bell, HX0 and HX89")


if __name__ == "__main__":
    main()
