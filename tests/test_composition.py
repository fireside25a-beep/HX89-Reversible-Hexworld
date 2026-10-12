#!/usr/bin/env python3
"""Independent semantic right-inverse test for byte-polyform -> HX89 and Bell/HX0."""
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent.parent


def run(*args, data=None):
    return subprocess.run([str(a) for a in args], input=data, check=True,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout


def bits(data: bytes) -> bytes:
    return bytes(int(c) for b in data for c in f"{b:08b}")


def extract_payload(transcript: bytes, length: int) -> bytes:
    marker = b"HX89 seed=1 cells="
    start = transcript.find(marker)
    assert start >= 0, "VM header missing"
    line_end = transcript.find(b"\n", start)
    assert line_end >= 0, "VM cell-count line unterminated"
    payload_start = line_end + 1
    payload = transcript[payload_start:payload_start + length]
    assert len(payload) == length, "VM emitted payload truncated"
    return payload


def main():
    compiler = ROOT / "bin/byte-polyform"
    vm = ROOT / "bin/hx89"
    pulse = ROOT / "bin/pulse-pcm"
    hx0 = ROOT / "bin/hx0-x86_64"
    hx0_program = ROOT / "seeds/hx0_bitstream.hx0"

    with tempfile.TemporaryDirectory(prefix="hx89-compose-") as td:
        tmp = Path(td)
        payload = bytes(range(256))
        raw = tmp / "alphabet.bin"
        p1 = tmp / "alphabet.hx"
        p2 = tmp / "alphabet-again.hx"
        raw.write_bytes(payload)
        assert b"status=PASS" in run(compiler, raw, p1)
        run(compiler, raw, p2)
        assert p1.read_bytes() == p2.read_bytes(), "compiler is not deterministic"

        direct = run(vm, p1, 1, 300)
        assert extract_payload(direct, len(payload)) == payload

        source_bits = tmp / "program.bits"
        wave = tmp / "program.wav"
        recovered_bits = tmp / "program.recovered.bits"
        recovered_hx = tmp / "program.recovered.hx"
        source_bits.write_bytes(bits(p1.read_bytes()))
        run(pulse, "encode-bell202", source_bits, wave)
        run(pulse, "decode-bell202", wave, recovered_bits)
        assert recovered_bits.read_bytes() == source_bits.read_bytes(), "Bell symbols changed"
        recovered_hx.write_bytes(run(hx0, hx0_program, data=recovered_bits.read_bytes()))
        assert recovered_hx.read_bytes() == p1.read_bytes(), "HX0 did not reconstruct Polyform"
        transported = run(vm, recovered_hx, 1, 300)
        assert extract_payload(transported, len(payload)) == payload

        empty = tmp / "empty.bin"
        empty_hx = tmp / "empty.hx"
        empty.write_bytes(b"")
        run(compiler, empty, empty_hx)
        out = run(vm, empty_hx, 1, 8)
        assert extract_payload(out, 0) == b""

        max_raw = tmp / "max.bin"
        max_hx = tmp / "max.hx"
        max_payload = bytes((37*i + 11) & 255 for i in range(4095))
        max_raw.write_bytes(max_payload)
        assert b"cells=4096" in run(compiler, max_raw, max_hx)
        max_out = run(vm, max_hx, 1, 4200)
        assert extract_payload(max_out, len(max_payload)) == max_payload, "4095-byte arena boundary failed execution"
        too_big = tmp / "too-big.bin"
        too_big.write_bytes(max_raw.read_bytes() + b"X")
        bad = subprocess.run([str(compiler), str(too_big), str(tmp/"bad.hx")],
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        assert bad.returncode != 0, "compiler accepted >4095-byte payload"

    print("PASS: semantic right inverse for byte alphabet, Bell/HX0 transport, determinism and arena boundaries")


if __name__ == "__main__":
    main()
