#!/usr/bin/env python3
"""Independent 1200-baud waveform/framing oracle and deterministic channel checks."""
import math
from pathlib import Path
import random
import struct
import subprocess
import tempfile
import wave
import zlib

ROOT = Path(__file__).resolve().parent.parent
TOOL = ROOT / "bin/pulse-pcm"
FS = 48000
PER = 40
LEADER = 120


def invoke(mode, inp, out, success=True):
    result = subprocess.run([str(TOOL), mode, str(inp), str(out)],
                            capture_output=True, check=False)
    assert (result.returncode == 0) == success, (mode, result.stderr)


def read_wave(path):
    with wave.open(str(path), "rb") as w:
        assert (w.getnchannels(), w.getsampwidth(), w.getframerate()) == (1, 2, FS)
        count = w.getnframes()
        samples = struct.unpack("<" + "h"*count, w.readframes(count))
    return list(samples)


def write_wave(path, samples):
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(FS)
        w.writeframes(struct.pack("<" + "h"*len(samples), *samples))


def independent_symbol(samples):
    energies = []
    for hz in (2200, 1200):
        s = sum(v*math.sin(2*math.pi*hz*j/FS) for j, v in enumerate(samples))
        c = sum(v*math.cos(2*math.pi*hz*j/FS) for j, v in enumerate(samples))
        energies.append(s*s+c*c)
    return int(energies[1] > energies[0])


def main():
    symbols = bytes([0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0])
    with tempfile.TemporaryDirectory(prefix="hx89-bell-") as directory:
        root = Path(directory)
        inp, signal, out = (root/x for x in ("bits", "signal.wav", "decoded.bits"))
        inp.write_bytes(symbols)
        invoke("encode-bell202", inp, signal)
        pcm = read_wave(signal)
        frames = [pcm[j:j+PER] for j in range(0, len(pcm), PER)]
        assert len(frames) == LEADER + 10*(len(symbols)+4)
        expected = [1]*LEADER
        payload_crc = zlib.crc32(symbols).to_bytes(4, "little")
        for byte in symbols+payload_crc:
            expected.extend([0] + [(byte >> k)&1 for k in range(8)] + [1])
        assert [independent_symbol(f) for f in frames] == expected
        # Independent continuous-phase oscillator with a different sine implementation.
        phase = 0
        for j, bit in enumerate(expected):
            step = 6 if bit else 11
            for k in range(PER):
                ideal = 12288*math.sin(2*math.pi*phase/240)
                assert abs(pcm[j*PER+k]-ideal) <= 7
                phase = (phase+step)%240
        invoke("decode-bell202", signal, out)
        assert out.read_bytes() == symbols
        assert pcm != [0]*len(pcm)

        rng = random.Random(2026)
        noisy = [max(-32768, min(32767, round(-0.5*s+rng.gauss(0, 600)))) for s in pcm]
        altered = root/"noisy.wav"
        write_wave(altered, noisy)
        invoke("decode-bell202", altered, out)
        assert out.read_bytes() == symbols

        # Captured audio can start between sample clocks of the carrier.
        shifted = root/"shifted.wav"
        write_wave(shifted, [0]*37 + pcm + [0]*17)
        invoke("decode-bell202", shifted, out)
        assert out.read_bytes() == symbols

        zero = root/"silent.wav"
        write_wave(zero, [0]*len(pcm))
        invoke("decode-bell202", zero, out, success=False)

        broken = pcm.copy()
        # The first UART stop symbol is forced to a clean space tone.
        pos = (LEADER+9)*PER
        broken[pos:pos+PER] = [round(12000*math.sin(2*math.pi*2200*j/FS))
                               for j in range(PER)]
        damaged = root/"bad-stop.wav"
        write_wave(damaged, broken)
        invoke("decode-bell202", damaged, out, success=False)

        flipped = pcm.copy()
        # A valid but wrong mark replaces a space in the first data byte.
        pos = (LEADER+1)*PER
        flipped[pos:pos+PER] = [round(12000*math.sin(2*math.pi*1200*j/FS))
                                for j in range(PER)]
        corrupt = root/"wrong-data.wav"
        write_wave(corrupt, flipped)
        invoke("decode-bell202", corrupt, out, success=False)
        assert out.read_bytes() == b""  # CRC gate precedes the output write.

        invoke("decode-fsk", signal, out, success=False)
        print("PASS: independent Bell 202 waveform, 1200 baud UART, start sync, CRC and noisy channel")


if __name__ == "__main__":
    main()
