#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
fail(){ echo "AUDIT_FAIL: $*" >&2; exit 1; }
pass(){ echo "AUDIT_PASS: $*"; }

# No zero-byte repository files.
EMPTY=$(find . -path './thesis/build' -prune -o -type f -size 0 -print | LC_ALL=C sort || true)
[ -z "$EMPTY" ] || fail "empty files: $EMPTY"
pass "no empty files"

# No unfinished implementation markers in source, bootstrap, tests, seeds or Polyforms.
if grep -RniE --exclude='audit.sh' --exclude='MANIFEST.sha256' \
  '(^|[^A-Za-z])(TODO|FIXME|TBD|PLACEHOLDER|STUB|MOCK)([^A-Za-z]|$)' \
  src boot tests seeds polyforms 2>/dev/null; then
  fail "unfinished implementation marker"
fi
pass "no mock/stub/template/TODO implementation markers"

# Monolith identity and scientific status must be present.
grep -q '^# HX89 - Hexworld Polyform Machine and Chiral Transport Research' README.md || fail "README identity"
[ -s SCIENTIFIC_STATUS.md ] || fail "scientific status missing"
grep -q 'HX87SEM3' docs/MACHINE.md || fail "semantic image identifier"
[ -s thesis/main.tex ] || fail "thesis source missing"
[ -s research/crtc/src/crtc/geometry.py ] || fail "CRTC source missing"
pass "monolith identity consistent"

# Required real implementation files.
for f in \
  boot/x86_64/hx0.S boot/aarch64/hx0.S boot/riscv64/hx0.S boot/hx0_bitstream.S \
  src/hx89_x86_64.S src/pulse_pcm.c seeds/hx0_etch.hx0 seeds/hx0_bitstream.hx0 \
  seeds/hx89_seed.bits seeds/hx89_semantics.bits seeds/hx87_seed.hx \
  seeds/hx87_semantics.seed polyforms/native_accel.hx \
  polyforms/rip_mirror.hx polyforms/surreal_universe.hx \
  docs/HEXWORLD.md docs/SELFHOST.md docs/SIGNAL_BOOTSTRAP.md \
  docs/PHASE_TORUS.md docs/MULTIPATH.md tests/phase_exhaustive.py \
  tests/test_bell202.py tests/measure_channel.py src/hex_gas.c tests/test_hex_gas.py docs/HEX_GAS.md \
  src/byte_polyform.c tests/test_composition.py docs/COMPOSITION_LEMMA.md \
  src/chiral_law.c tests/test_chiral_law.py tests/test_transport_circle.py tests/sanitize.sh docs/CHIRAL_RECIPROCITY.md docs/TRANSPORT_CIRCLE.md docs/RESEARCH_NOTE.md docs/RESEARCH_SCOPE.md docs/TECHNICAL_NOTE.md; do
  [ -s "$f" ] || fail "missing implementation file $f"
done
pass "required implementation files present"

# The final semantic/native gates must have executed in this tree.
[ -x bin/hx0-x86_64 ] || fail "HX0 binary missing"
[ -x bin/hx89 ] || fail "HX89 binary missing"
[ -x bin/pulse-pcm ] || fail "PCM adapter missing"
[ -x bin/hx89-gas ] || fail "hex-gas binary missing"
[ -x bin/byte-polyform ] || fail "byte compiler missing"
[ -x bin/hx89-chiral-proof ] || fail "chiral proof binary missing"
[ -s evidence/TEST_RESULTS.txt ] || fail "test evidence missing"
grep -q '^ALL TESTS PASS$' evidence/TEST_RESULTS.txt || fail "test evidence not green"
grep -q 'PASS: Hexworld -> native accelerator -> Hexworld return' evidence/TEST_RESULTS.txt || fail "accelerator gate missing"
grep -q 'PASS: RIP-MIRROR reflected 5D live-code observation' evidence/TEST_RESULTS.txt || fail "RIP-MIRROR gate missing"
grep -q 'PASS: HX87 Seed B == Seed C fixed point' evidence/TEST_RESULTS.txt || fail "self-host gate missing"
grep -q 'PASS: memory echo and one-bit HX0 machine reconstruction' evidence/TEST_RESULTS.txt || fail "memory bootstrap gate missing"
grep -q 'PASS: PCM waveform to one-bit HX0 to live semantic image' evidence/TEST_RESULTS.txt || fail "PCM adapter gate missing"
grep -q 'PASS: all 25 phase states, both VM directions, oracle, trace, retirement and inverse' evidence/TEST_RESULTS.txt || fail "phase oracle gate missing"
grep -q 'PASS: phase law persists across snapshot and resume' evidence/TEST_RESULTS.txt || fail "phase snapshot gate missing"
grep -q 'PASS: snapshot rejects invalid phase law' evidence/TEST_RESULTS.txt || fail "phase validation gate missing"
grep -q 'PASS: VM target fitness, entropy-guided walk, early stop and snapshot persistence' evidence/TEST_RESULTS.txt || fail "target search gate missing"
grep -q 'PASS: independent Bell 202 waveform, 1200 baud UART, start sync, CRC and noisy channel' evidence/TEST_RESULTS.txt || fail "Bell waveform gate missing"
grep -q 'PASS: level, 125-baud FSK, Bell 202 and memory echo converge on canonical HX0 images' evidence/TEST_RESULTS.txt || fail "multi-path bootstrap gate missing"
grep -q 'PASS: independent hex-gas conservation/reverse and image Polyform through Bell, HX0 and HX89' evidence/TEST_RESULTS.txt || fail "hex-gas verification missing"
grep -q 'PASS: semantic right inverse for byte alphabet, Bell/HX0 transport, determinism and arena boundaries' evidence/TEST_RESULTS.txt || fail "composition lemma gate missing"
grep -q 'PASS: chiral reciprocity, dressed PT reversor, exact echo/correlation law, only 3 one-body linear invariants, independent larger-torus oracle' evidence/TEST_RESULTS.txt || fail "chiral theorem gate missing"
grep -q 'global_states=16777216' evidence/chiral_law_certificate.txt || fail "exhaustive chiral certificate missing"
grep -q 'echo=PASS' evidence/chiral_law_certificate.txt || fail "exact echo certificate missing"
grep -q 'correlation_reciprocity=PASS' evidence/chiral_law_certificate.txt || fail "correlation reciprocity certificate missing"
grep -q 'both_chiralities=PASS' evidence/chiral_law_certificate.txt || fail "both-chiralities certificate missing"
grep -q 'PASS: exact transport-circle and spectral identities over 3575 rational (rho,p,B) points in Q(sqrt(3))' evidence/TEST_RESULTS.txt || fail "transport-circle gate missing"
grep -q 'PASS: exact transport-circle and spectral identities over 3575 rational (rho,p,B) points in Q(sqrt(3))' evidence/transport_circle_certificate.txt || fail "transport-circle certificate missing"
cmp evidence/composition_alphabet.hx evidence/composition_alphabet.recovered.hx || fail "composition Polyform transport mismatch"
[ -s evidence/gas_density.pgm ] || fail "hex-gas image missing"
[ -s evidence/gas_profile.bell.wav ] || fail "hex-gas waveform missing"
[ -s evidence/gas_transport.bell.wav ] || fail "hex-gas image waveform missing"
cmp evidence/gas_transport.oracle.pgm evidence/gas_transport.emitted.pgm || fail "gas image transport mismatch"
cmp evidence/gas_transport.source.hx evidence/gas_transport.recovered.hx || fail "gas Polyform transport mismatch"
grep -q 'reverse=PASS' evidence/gas_certificate.txt || fail "hex-gas reverse certificate missing"
[ -s evidence/hx89_seed.bell.wav ] || fail "Bell waveform missing"
[ -s evidence/hx89_semantics.bell.seed ] || fail "Bell semantic image missing"
awk -F, 'NR == 1 { next } $1 == 0 && $2 == 10 && $3 == 10 && $4 == 0 && $5 == 0 { clean = 1 }
  $1 == 6000 && $2 == 10 && $3 + $4 + $5 == 10 { noisy = 1 }
  END { exit !(clean && noisy) }' evidence/CHANNEL_SWEEP.csv || fail "channel sweep missing or malformed"
[ -s evidence/phase_forward.actual ] || fail "forward trace missing"
[ -s evidence/phase_reverse.actual ] || fail "reverse trace missing"
[ -s evidence/hx89_seed.wav ] || fail "PCM evidence missing"
pass "repository evidence complete"
