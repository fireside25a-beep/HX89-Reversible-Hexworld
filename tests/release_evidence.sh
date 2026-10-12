#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p evidence
rm -f evidence/*.actual evidence/*.sha256 evidence/*.txt evidence/*.o evidence/*.ppm evidence/*.state evidence/*.regen evidence/*.seed

sh tests/test.sh | tee evidence/TEST_RESULTS.txt
./bin/hx89 polyforms/hello.anything 1 100 > evidence/hello.actual
./bin/hx89 polyforms/five_dimensional.hx 1 100 > evidence/five_dimensional.actual
./bin/hx89 polyforms/surreal.hx 1 100 > evidence/surreal.actual
./bin/hx89 polyforms/surreal_universe.hx 1 100 > evidence/surreal_universe.actual
./bin/hx89 polyforms/q2_evolution.hx 1 100 > evidence/q2_evolution.actual
./bin/hx89 --phase-forward polyforms/phase_torus.hx 1 100 > evidence/phase_forward.actual
./bin/hx89 --phase-reverse polyforms/phase_torus.hx 1 100 > evidence/phase_reverse.actual
./bin/hx89 polyforms/q2_visual.hx 1 100 > evidence/q2_visual.actual
cp frame.ppm evidence/q2_visual.ppm
./bin/hx89 polyforms/rip_mirror.hx 1 100 > evidence/rip_mirror.actual
./bin/hx89 --native polyforms/native_bridge.hx 1 100 > evidence/native_bridge.actual
./bin/hx89 --native polyforms/native_accel.hx 1 100 > evidence/native_accel.actual
./bin/hx89 polyforms/entropy.hx 12345 100 > evidence/entropy.actual
./bin/hx89 polyforms/self_modify.hx 1 30 > evidence/self_modify.actual
./bin/hx89 polyforms/frontier.hx 1 50 > evidence/frontier.actual
./bin/hx89 polyforms/render2d.hx 1 100 > evidence/render2d.actual
cp frame.ppm evidence/frame.ppm
./bin/hx89 polyforms/snapshot.hx 12345 100 > evidence/snapshot.actual
cp hx89.state evidence/snapshot.state
./bin/hx89 --resume hx89.state 100 > evidence/resume.actual

rm -f hx89.regen
./bin/hx89 seeds/hx87_seed.hx 1 20 > evidence/selfhost_A.actual
cp hx89.regen evidence/hx87_seed_B.regen
./bin/hx89 evidence/hx87_seed_B.regen 1 20 > evidence/selfhost_B.actual
cp hx89.regen evidence/hx87_seed_C.regen
cmp evidence/hx87_seed_B.regen evidence/hx87_seed_C.regen
cp build/hx87_seed.stageA evidence/hx87_seed.stageA.seed
cp build/hx87_semantics.seed evidence/hx87_semantics.stageA.seed
cp build/hx89_seed.fsk.wav evidence/hx89_seed.fsk.wav
cp build/hx89_seed.bell.wav evidence/hx89_seed.bell.wav
cp build/hx89_semantics.bell.wav evidence/hx89_semantics.bell.wav
cp build/hx89_seed.bell.bits evidence/hx89_seed.bell.bits
cp build/hx89_semantics.bell.bits evidence/hx89_semantics.bell.bits
python3 tests/measure_channel.py > evidence/CHANNEL_SWEEP.csv
./bin/hx89-chiral-proof > evidence/chiral_law_certificate.txt
python3 tests/test_transport_circle.py > evidence/transport_circle_certificate.txt
python3 - <<'PY2'
from pathlib import Path
p=bytes(range(256))
Path('evidence/composition_alphabet.bin').write_bytes(p)
PY2
./bin/byte-polyform evidence/composition_alphabet.bin evidence/composition_alphabet.hx > evidence/composition_certificate.txt
./bin/hx89 evidence/composition_alphabet.hx 1 300 > evidence/composition_vm.out
python3 - <<'PY2'
from pathlib import Path
p=Path('evidence/composition_alphabet.hx').read_bytes()
Path('evidence/composition_alphabet.bits').write_bytes(bytes(int(c) for b in p for c in f'{b:08b}'))
PY2
./bin/pulse-pcm encode-bell202 evidence/composition_alphabet.bits evidence/composition_alphabet.bell.wav
./bin/pulse-pcm decode-bell202 evidence/composition_alphabet.bell.wav evidence/composition_alphabet.recovered.bits
# The 256-byte composition carrier is reproducible but ~42 MiB. Verify it, then
# discard only that transient carrier so the source release stays compact.
rm -f evidence/composition_alphabet.bell.wav
./bin/hx0-x86_64 seeds/hx0_bitstream.hx0 < evidence/composition_alphabet.recovered.bits > evidence/composition_alphabet.recovered.hx
cmp evidence/composition_alphabet.hx evidence/composition_alphabet.recovered.hx
./bin/hx89 evidence/composition_alphabet.recovered.hx 1 300 > evidence/composition_transport_vm.out
python3 - <<'PY2'
from pathlib import Path
expected=bytes(range(256))
for name in ('evidence/composition_vm.out','evidence/composition_transport_vm.out'):
    data=Path(name).read_bytes()
    marker=b'HX89 seed=1 cells='
    start=data.index(marker)
    start=data.index(b'\n', start)+1
    assert data[start:start+256] == expected, name
PY2
./bin/hx89-gas 64 64 40 12345 evidence/gas_density.pgm evidence/gas_profile.hx > evidence/gas_certificate.txt
./bin/hx89 evidence/gas_profile.hx 1 66 > evidence/gas_vm.actual
python3 - <<'PY'
from pathlib import Path
import re
s = re.search(rb'(?m)^([0-6]{64})$', Path('evidence/gas_vm.actual').read_bytes()).group(1) + b'\n'
Path('evidence/gas_profile.bits').write_bytes(bytes(int(c) for b in s for c in f'{b:08b}'))
PY
./bin/pulse-pcm encode-bell202 evidence/gas_profile.bits evidence/gas_profile.bell.wav
./bin/pulse-pcm decode-bell202 evidence/gas_profile.bell.wav evidence/gas_profile.audio.bits
cmp evidence/gas_profile.bits evidence/gas_profile.audio.bits
./bin/hx0-x86_64 seeds/hx0_bitstream.hx0 < evidence/gas_profile.audio.bits > evidence/gas_profile.recovered
./bin/hx89-gas 8 8 7 12345 evidence/gas_transport.oracle.pgm evidence/gas_transport.source.hx --image-polyform > evidence/gas_transport.certificate.txt
python3 - <<'PY'
from pathlib import Path
p=Path('evidence/gas_transport.source.hx').read_bytes()
Path('evidence/gas_transport.source.bits').write_bytes(bytes(int(c) for b in p for c in f'{b:08b}'))
PY
./bin/pulse-pcm encode-bell202 evidence/gas_transport.source.bits evidence/gas_transport.bell.wav
./bin/pulse-pcm decode-bell202 evidence/gas_transport.bell.wav evidence/gas_transport.recovered.bits
./bin/hx0-x86_64 seeds/hx0_bitstream.hx0 < evidence/gas_transport.recovered.bits > evidence/gas_transport.recovered.hx
cmp evidence/gas_transport.source.hx evidence/gas_transport.recovered.hx
./bin/hx89 evidence/gas_transport.recovered.hx 1 100 > evidence/gas_transport.vm.out
python3 - <<'PY'
from pathlib import Path
oracle=Path('evidence/gas_transport.oracle.pgm').read_bytes()
vm=Path('evidence/gas_transport.vm.out').read_bytes()
header=b'P5\n8 8\n255\n'
start=vm.find(header)
assert start >= 0, 'transported HX89 image header missing'
emitted=vm[start:start+len(header)+64]
assert len(emitted)==len(header)+64 and emitted==oracle, 'transported HX89 image differs from gas image'
Path('evidence/gas_transport.emitted.pgm').write_bytes(emitted)
PY
./bin/hx0-x86_64 seeds/hx0_bitstream.hx0 < evidence/hx89_semantics.bell.bits > evidence/hx89_semantics.bell.seed
cmp evidence/hx89_semantics.bell.seed seeds/hx87_semantics.seed
./bin/pulse-pcm encode seeds/hx89_seed.bits evidence/hx89_seed.wav
./bin/pulse-pcm decode evidence/hx89_seed.wav evidence/hx89_seed.audio.bits
./bin/hx0-x86_64 seeds/hx0_bitstream.hx0 < evidence/hx89_seed.audio.bits > evidence/hx89_seed.audio.seed
cmp evidence/hx89_seed.audio.seed seeds/hx87_seed.hx

if command -v clang >/dev/null 2>&1; then
  clang --target=aarch64-linux-gnu -c boot/aarch64/hx0.S -o evidence/hx0-aarch64.o
  clang --target=riscv64-linux-gnu -c boot/riscv64/hx0.S -o evidence/hx0-riscv64.o
fi

if command -v readelf >/dev/null 2>&1; then
  readelf -W -l bin/hx89 > evidence/PROGRAM_HEADERS.txt
fi

sha256sum \
  bin/hx89 bin/hx0-x86_64 bin/pulse-pcm bin/hx89-gas bin/byte-polyform bin/hx89-chiral-proof \
  seeds/hx0_bitstream.hx0 seeds/hx89_seed.bits seeds/hx89_semantics.bits \
  seeds/hx0_etch.hx0 seeds/hx0_etch.etch \
  seeds/hx87_seed.hx seeds/hx87_seed.etch \
  seeds/hx87_semantics.seed seeds/hx87_semantics.etch \
  polyforms/native_bridge.hx polyforms/native_accel.hx polyforms/rip_mirror.hx polyforms/q2_evolution.hx polyforms/q2_visual.hx polyforms/surreal_universe.hx \
  tests/phase_exhaustive.py docs/PHASE_TORUS.md polyforms/phase_torus.hx evidence/phase_forward.actual evidence/phase_reverse.actual \
  tests/test_bell202.py tests/measure_channel.py evidence/CHANNEL_SWEEP.csv evidence/hx89_seed.fsk.wav evidence/hx89_seed.bell.wav evidence/hx89_semantics.bell.wav evidence/hx89_semantics.bell.seed \
  tests/test_hex_gas.py src/hex_gas.c evidence/gas_density.pgm evidence/gas_profile.hx evidence/gas_certificate.txt evidence/gas_vm.actual evidence/gas_profile.bell.wav evidence/gas_profile.recovered \
  evidence/gas_transport.oracle.pgm evidence/gas_transport.source.hx evidence/gas_transport.bell.wav evidence/gas_transport.recovered.hx evidence/gas_transport.emitted.pgm \
  src/byte_polyform.c tests/test_composition.py docs/COMPOSITION_LEMMA.md evidence/composition_certificate.txt evidence/composition_alphabet.hx evidence/composition_alphabet.recovered.hx \
  src/chiral_law.c tests/test_chiral_law.py tests/test_transport_circle.py tests/sanitize.sh docs/CHIRAL_RECIPROCITY.md docs/TRANSPORT_CIRCLE.md docs/RESEARCH_NOTE.md docs/RESEARCH_SCOPE.md docs/TECHNICAL_NOTE.md evidence/chiral_law_certificate.txt evidence/transport_circle_certificate.txt \
  evidence/q2_visual.ppm evidence/frame.ppm evidence/hx89_seed.wav evidence/hx89_seed.audio.bits \
  > evidence/SHA256SUMS.sha256

{
  echo "HOST=$(uname -srm)"
  echo "CC=$(${CC:-cc} --version 2>/dev/null | head -1 || true)"
  echo "AS=$(as --version 2>/dev/null | head -1 || true)"
  echo "LD=$(ld --version 2>/dev/null | head -1 || true)"
  echo "CLANG=$(clang --version 2>/dev/null | head -1 || echo NOT_AVAILABLE)"
  echo "NODE=$(node --version 2>/dev/null || echo NOT_AVAILABLE)"
  echo "PYTHON=$(python3 --version 2>/dev/null || echo NOT_AVAILABLE)"
  echo "RUBY=$(ruby --version 2>/dev/null || echo NOT_AVAILABLE)"
  echo "LUA=$(lua -v 2>&1 || echo NOT_AVAILABLE)"
} > evidence/ENVIRONMENT.txt
