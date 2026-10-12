#!/usr/bin/env python3
"""Deterministic AWGN channel measurement using the shipped Bell decoder."""
from pathlib import Path
import random
import struct
import subprocess
import tempfile
import wave

ROOT = Path(__file__).resolve().parent.parent
TOOL = ROOT / "bin/pulse-pcm"


def samples(path):
    with wave.open(str(path), "rb") as w:
        assert (w.getnchannels(), w.getsampwidth(), w.getframerate()) == (1, 2, 48000)
        count = w.getnframes()
        return list(struct.unpack("<" + "h"*count, w.readframes(count)))


def write_wave(path, data):
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(48000)
        w.writeframes(struct.pack("<" + "h"*len(data), *data))


def main():
    payload = bytes(random.Random(0x89 + i).randrange(2) for i in range(128))
    print("noise_rms_pcm_counts,trials,correct_payload,crc_or_signal_reject,undetected_wrong_payload")
    with tempfile.TemporaryDirectory(prefix="hx89-channel-") as directory:
        work = Path(directory)
        src, wav, received = (work/x for x in ("symbols.bits", "carrier.wav", "received.bits"))
        src.write_bytes(payload)
        subprocess.run([str(TOOL), "encode-bell202", str(src), str(wav)], check=True)
        base = samples(wav)
        for sigma in (0, 600, 1500, 3000, 6000):
            correct = reject = wrong = 0
            for trial in range(10):
                rng = random.Random((sigma << 16)+trial)
                noisy = [max(-32768, min(32767, round(s+rng.gauss(0, sigma))))
                         for s in base]
                channel = work/"channel.wav"
                write_wave(channel, noisy)
                result = subprocess.run([str(TOOL), "decode-bell202", str(channel),
                                         str(received)], capture_output=True)
                if result.returncode:
                    reject += 1
                elif received.read_bytes() == payload:
                    correct += 1
                else:
                    wrong += 1
            print(f"{sigma},10,{correct},{reject},{wrong}")
            assert correct+reject+wrong == 10
            if sigma == 0:
                assert correct == 10


if __name__ == "__main__":
    main()
