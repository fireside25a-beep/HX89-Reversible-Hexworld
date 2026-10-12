#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
TMP=${TMPDIR:-/tmp}/hx87-test-$$
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

fail(){ echo "FAIL: $*" >&2; exit 1; }
pass(){ echo "PASS: $*"; }

# 1. HX0 native stage-0 and ETCH fixed point.
./bin/hx0-x86_64 seeds/hx0_etch.hx0 < seeds/hx0_etch.etch > "$TMP/stage1.hx0"
cmp -s "$TMP/stage1.hx0" seeds/hx0_etch.hx0 || fail "HX0 ETCH stage1"
./bin/hx0-x86_64 "$TMP/stage1.hx0" < seeds/hx0_etch.etch > "$TMP/stage2.hx0"
cmp -s "$TMP/stage1.hx0" "$TMP/stage2.hx0" || fail "HX0 fixed point"
pass "HX0 ETCH fixed point"

# HX0 consumes individual binary symbols and reconstructs the machine images.
printf 'HX0\001\002\000\014\003\002\001\014\003\000' > "$TMP/echo.hx0"
./bin/hx0-x86_64 "$TMP/echo.hx0" > "$TMP/echo.out"
printf '\000\001' > "$TMP/echo.expected"
cmp -s "$TMP/echo.out" "$TMP/echo.expected" || fail "memory echo 0/1"
printf 'HX0\001\002\002\014\000' > "$TMP/echo_bad.hx0"
if ./bin/hx0-x86_64 "$TMP/echo_bad.hx0" > "$TMP/echo_bad.out"; then fail "memory echo accepted invalid bit"; fi
./bin/hx0-x86_64 seeds/hx0_bitstream.hx0 < seeds/hx89_seed.bits > "$TMP/from_bits.hx"
cmp -s "$TMP/from_bits.hx" seeds/hx87_seed.hx || fail "bitstream Seed A"
./bin/hx0-x86_64 seeds/hx0_bitstream.hx0 < seeds/hx89_semantics.bits > "$TMP/from_bits.sem"
cmp -s "$TMP/from_bits.sem" build/hx87_semantics.seed || fail "bitstream semantic image"
head -c 599 seeds/hx89_seed.bits > "$TMP/partial.bits"
if ./bin/hx0-x86_64 seeds/hx0_bitstream.hx0 < "$TMP/partial.bits" > "$TMP/partial.hx"; then fail "partial bit group accepted"; fi
cp seeds/hx89_seed.bits "$TMP/invalid.bits"
printf '\002' | dd of="$TMP/invalid.bits" bs=1 seek=3 conv=notrunc 2>/dev/null
if ./bin/hx0-x86_64 seeds/hx0_bitstream.hx0 < "$TMP/invalid.bits" > "$TMP/invalid.hx"; then fail "invalid bit symbol accepted"; fi
pass "memory echo and one-bit HX0 machine reconstruction"

# A real PCM waveform carries the same symbols through a separate transducer.
./bin/pulse-pcm encode seeds/hx89_seed.bits "$TMP/seed.wav"
./bin/pulse-pcm decode "$TMP/seed.wav" "$TMP/seed.audio.bits"
cmp -s "$TMP/seed.audio.bits" seeds/hx89_seed.bits || fail "PCM symbols"
./bin/hx0-x86_64 seeds/hx0_bitstream.hx0 < "$TMP/seed.audio.bits" > "$TMP/seed.audio.hx"
cmp -s "$TMP/seed.audio.hx" seeds/hx87_seed.hx || fail "PCM to HX0 to Seed A"
./bin/pulse-pcm encode seeds/hx89_semantics.bits "$TMP/sem.wav"
./bin/pulse-pcm decode "$TMP/sem.wav" "$TMP/sem.audio.bits"
./bin/hx0-x86_64 seeds/hx0_bitstream.hx0 < "$TMP/sem.audio.bits" > "$TMP/sem.audio.seed"
cmp -s "$TMP/sem.audio.seed" build/hx87_semantics.seed || fail "PCM semantic image"
head -c 43 "$TMP/seed.wav" > "$TMP/short.wav"
if ./bin/pulse-pcm decode "$TMP/short.wav" "$TMP/short.bits" 2> "$TMP/short.err"; then fail "short PCM header accepted"; fi
pass "PCM waveform to one-bit HX0 to live semantic image"

# Independent phase-continuous Bell 202 modulation and asynchronous framing.
python3 tests/test_bell202.py || fail "Bell 202 waveform oracle"
cmp -s build/hx89_seed.fsk.bits seeds/hx89_seed.bits || fail "125-baud FSK seed"
cmp -s build/hx89_semantics.fsk.bits seeds/hx89_semantics.bits || fail "125-baud FSK semantics"
cmp -s build/hx89_seed.bell.bits seeds/hx89_seed.bits || fail "Bell 202 seed"
cmp -s build/hx89_semantics.bell.bits seeds/hx89_semantics.bits || fail "Bell 202 semantics"
cmp -s build/hx87_seed.belldecoded seeds/hx87_seed.hx || fail "Bell 202 through HX0 Seed A"
cmp -s build/hx87_semantics.belldecoded seeds/hx87_semantics.seed || fail "Bell 202 through HX0 semantics"
pass "level, 125-baud FSK, Bell 202 and memory echo converge on canonical HX0 images"

python3 tests/test_hex_gas.py || fail "hex-gas independent physical model oracle"
python3 tests/test_composition.py || fail "canonical byte-Polyform composition lemma"
python3 tests/test_chiral_law.py || fail "chiral reciprocity theorem"
python3 tests/test_transport_circle.py || fail "transport-circle exact algebra"
python3 tests/test_entropy_sparse.py || fail "entropy sparse-field termination regression"

# 2. HX0 decodes the canonical HX87 seed and the build used the same Stage-A image.
./bin/hx0-x86_64 seeds/hx0_etch.hx0 < seeds/hx87_seed.etch > "$TMP/hx87_seed.hx"
cmp -s "$TMP/hx87_seed.hx" seeds/hx87_seed.hx || fail "HX0 -> HX87 seed"
cmp -s build/hx87_seed.stageA seeds/hx87_seed.hx || fail "build bootstrap stage A"
cmp -s build/hx87_semantics.seed seeds/hx87_semantics.seed || fail "HX0 semantic image"
pass "HX0 decodes canonical HX87 seed and semantic image"

# 3. HX87 Seed A -> B -> C reaches a canonical fixed point.
rm -f hx89.regen
./bin/hx89 seeds/hx87_seed.hx 1 20 > "$TMP/seedA.out"
cmp -s hx89.regen seeds/hx87_seed.hx || fail "HX87 Seed A -> B"
cp hx89.regen "$TMP/seedB.hx"
./bin/hx89 "$TMP/seedB.hx" 1 20 > "$TMP/seedB.out"
cmp -s hx89.regen "$TMP/seedB.hx" || fail "HX87 Seed B -> C"
pass "HX87 Seed B == Seed C fixed point"

# 4. Content-first extension independence.
./bin/hx89 polyforms/hello.anything 1 100 > "$TMP/hello.out"
grep -q '^HX87$' "$TMP/hello.out" || fail "extension-agnostic hello"
pass "extension-agnostic Polyform"

# 5. True five-axis traversal.
./bin/hx89 polyforms/five_dimensional.hx 1 100 > "$TMP/5d.out"
grep -q '^ZWVY$' "$TMP/5d.out" || fail "five-dimensional traversal"
pass "five-dimensional traversal"

# 6. Symbolic Conway constructions, never converted to IEEE floating point.
./bin/hx89 polyforms/surreal.hx 1 100 > "$TMP/surreal.out"
grep -q '^{0|1}$' "$TMP/surreal.out" || fail "Conway cut"
grep -q '^(omega+1)$' "$TMP/surreal.out" || fail "omega+1"
pass "symbolic Conway surreal operations"

# 7. All 25 Q² states are accepted by the real VM.
a=0
while [ "$a" -lt 5 ]; do
  b=0
  while [ "$b" -lt 5 ]; do
    cat > "$TMP/q.hx" <<QEOF
HX87P1
CELL 0 0 0 0 0 11 $a $b 0
CELL 1 0 0 0 0 0 0 0 0
QEOF
    ./bin/hx89 "$TMP/q.hx" 1 20 > "$TMP/q.out"
    if grep -q 'QSET requires' "$TMP/q.out"; then fail "Q2 state $a,$b"; fi
    b=$((b+1))
  done
  a=$((a+1))
done
pass "all 25 Q² elementary states"

# 8. Exact Q² evolution equation is executable machine state.
./bin/hx89 polyforms/q2_evolution.hx 1 20 > "$TMP/qe.out"
grep -q '^Q2 old=0 qa=0 qb=0 next=9 nqa=1 nqb=4$' "$TMP/qe.out" || fail "Q2 evolution equation"
pass "Q² recurrence qa'=(qa+qb+1)%5; qb'=(qb+qa+op)%5"

# The reversible law runs through the actual VM retirement and dump paths.
python3 tests/phase_exhaustive.py || fail "reversible phase oracle"
./bin/hx89 --phase-forward polyforms/phase_torus.hx 1 20 > "$TMP/phase-forward.out"
./bin/hx89 --phase-reverse polyforms/phase_torus.hx 1 20 > "$TMP/phase-reverse.out"
grep -q '^PHASE old=7 qa=1 qb=2 next=15 nqa=3 nqb=0$' "$TMP/phase-forward.out" || fail "forward trace"
grep -q '^PHASE old=7 qa=1 qb=2 next=1 nqa=0 nqb=1$' "$TMP/phase-reverse.out" || fail "reverse trace"

# Resume must retain the transition law from the serialized state image.
./bin/hx89 --phase-forward polyforms/snapshot.hx 12345 100 > "$TMP/phase-save.out"
./bin/hx89 --resume hx89.state 100 > "$TMP/phase-resume.out"
P1=$(sed -n 's/.*hash=\([0-9a-f]*\)$/\1/p' "$TMP/phase-save.out" | tail -1)
P2=$(sed -n 's/.*hash=\([0-9a-f]*\)$/\1/p' "$TMP/phase-resume.out" | tail -1)
[ -n "$P1" ] && [ "$P1" = "$P2" ] || fail "phase resume law"
pass "phase law persists across snapshot and resume"

# The actual VM has a target, a finite torus fitness, and early stopping.
./bin/hx89 --target-q 9 polyforms/q2_evolution.hx 1 20 > "$TMP/target.out"
grep -q '^SEARCH step=1 head=0 q=9 fitness=0 target=9$' "$TMP/target.out" || fail "target fitness"
grep -q '^TARGET_HIT q=9 step=1 head=0$' "$TMP/target.out" || fail "target stop"
./bin/hx89 --phase-forward --target-q 15 polyforms/phase_torus.hx 1 20 > "$TMP/target-phase.out"
grep -q '^TARGET_HIT q=15 step=1 head=0$' "$TMP/target-phase.out" || fail "target phase"
./bin/hx89 --target-q 7 polyforms/entropy.hx 12345 20 > "$TMP/target-entropy.out"
grep -q '^ENTROPY step=0 ' "$TMP/target-entropy.out" || fail "target entropy step"
grep -q '^TARGET_HIT q=7 step=1 head=0$' "$TMP/target-entropy.out" || fail "target entropy stop"
if ./bin/hx89 --target-q 25 polyforms/entropy.hx 1 20 > /dev/null; then fail "out-of-range target accepted"; fi
if ./bin/hx89 --target-q wrong polyforms/entropy.hx 1 20 > /dev/null; then fail "nonnumeric target accepted"; fi
./bin/hx89 --target-q 17 polyforms/snapshot.hx 12345 100 > "$TMP/target-save.out"
./bin/hx89 --resume hx89.state 100 > "$TMP/target-resume.out"
T1=$(sed -n 's/.*hash=\([0-9a-f]*\)$/\1/p' "$TMP/target-save.out" | tail -1)
T2=$(sed -n 's/.*hash=\([0-9a-f]*\)$/\1/p' "$TMP/target-resume.out" | tail -1)
[ -n "$T1" ] && [ "$T1" = "$T2" ] || fail "target resume"
pass "VM target fitness, entropy-guided walk, early stop and snapshot persistence"
cp hx89.state "$TMP/phase-invalid.state"
# Version-six snapshot prefix: phase_mode is the fifteenth qword, byte 112.
printf '\003\000\000\000\000\000\000\000' | dd of="$TMP/phase-invalid.state" bs=1 seek=112 conv=notrunc 2>/dev/null
if ./bin/hx89 --resume "$TMP/phase-invalid.state" 100 > "$TMP/phase-invalid.out"; then fail "invalid phase mode accepted"; fi
grep -q 'snapshot rejected' "$TMP/phase-invalid.out" || fail "invalid phase diagnostic"
pass "snapshot rejects invalid phase law"

# 9. Q² visual projection makes a deterministic 25-state framebuffer.
rm -f frame.ppm
./bin/hx89 polyforms/q2_visual.hx 1 100 > "$TMP/qvis.out"
[ -s frame.ppm ] || fail "Q2 frame missing"
QVIS=$(sha256sum frame.ppm | awk '{print $1}')
[ "$QVIS" = "840a66bae537812cf2cc46a874aca19626a447bdc9fad799578dfd750f1fdb7e" ] || fail "Q2 frame hash"
pass "Q² deterministic visual phase-space projection"

# 10. Explicit neighbor mutation changes future code.
./bin/hx89 polyforms/self_modify.hx 1 30 > "$TMP/mutate.out"
grep -q '^MHX89 halt' "$TMP/mutate.out" || fail "MUTNEXT"
pass "runtime self-modification"

# 11. Frontier fork/collapse is executable; child begins at first child coordinate.
./bin/hx89 polyforms/frontier.hx 1 50 > "$TMP/frontier.out"
grep -q '^XYHX89 halt' "$TMP/frontier.out" || fail "frontier"
grep -q 'heads=2' "$TMP/frontier.out" || fail "forked head count"
pass "multi-head frontier and collapse"

# 12. RIP-MIRROR UNO-reverses a temporary 5D head and observes mutated live code.
./bin/hx89 polyforms/rip_mirror.hx 1 30 > "$TMP/rip.out"
grep -q '^RIP5_MIRROR=(0,0,0,0,0)$' "$TMP/rip.out" || fail "RIP mirror coordinate"
grep -q '^RIP5_OBSERVE op=8 q=6$' "$TMP/rip.out" || fail "RIP mirror live observation"
pass "RIP-MIRROR reflected 5D live-code observation"

# 13. Exact raw Polyform bytes cross the passive/active boundary through W^X.
./bin/hx89 --native polyforms/native_bridge.hx 1 20 > "$TMP/native.out"
grep -q '^NATIVE_RIP_BRIDGE return=42 bytes=6$' "$TMP/native.out" || fail "native RIP bridge"
TAIL=$(tail -c 6 polyforms/native_bridge.hx | od -An -tx1 -v | tr -d ' \n')
[ "$TAIL" = "b82a000000c3" ] || fail "native payload bytes"
pass "Polyform-originated x86-64 bytes executed by host RIP"

# 14. The NABI0 decoder rejects syscall/control-flow payloads instead of creating RWX shellcode.
{
  printf 'HX87P1\nCELL 0 0 0 0 0 27 0 0 0\nCELL 1 0 0 0 0 0 0 0 0\nNATIVE_RAW 3\n'
  printf '\017\005\303'
} > "$TMP/native_bad.hx"
./bin/hx89 --native "$TMP/native_bad.hx" 1 20 > "$TMP/native_bad.out"
grep -q 'NABI0 rejected unsafe native byte sequence' "$TMP/native_bad.out" || fail "NABI0 rejection"
pass "native bridge W^X/straight-line ABI gate"

# Untrusted Polyforms cannot request host code execution without an explicit opt-in.
./bin/hx89 polyforms/native_bridge.hx 1 20 > "$TMP/native_default.out"
grep -q '^HX89: native execution requires --native; head stopped$' "$TMP/native_default.out" || fail "native default gate"
if grep -q '^NATIVE_RIP_BRIDGE' "$TMP/native_default.out"; then fail "native code ran by default"; fi
./bin/hx89 polyforms/native_accel.hx 1 20 > "$TMP/accel_default.out"
grep -q '^HX89: native execution requires --native; head stopped$' "$TMP/accel_default.out" || fail "accelerator default gate"
pass "native realization disabled by default"

# 15. Seeded entropy is replayable.
./bin/hx89 polyforms/entropy.hx 12345 100 > "$TMP/e1.out"
./bin/hx89 polyforms/entropy.hx 12345 100 > "$TMP/e2.out"
cmp -s "$TMP/e1.out" "$TMP/e2.out" || fail "entropy replay"
grep -q '^ENTROPY ' "$TMP/e1.out" || fail "entropy trace"
pass "seeded entropy replay"

# 16. Framebuffer path writes a real PPM.
rm -f frame.ppm
./bin/hx89 polyforms/render2d.hx 1 100 > "$TMP/frame.out"
[ -s frame.ppm ] || fail "frame missing"
[ "$(wc -c < frame.ppm | tr -d ' ')" -eq 12301 ] || fail "frame size"
head -c 2 frame.ppm | grep -q 'P6' || fail "frame header"
pass "2D framebuffer output"

# 17. Executable-state save/resume reaches identical final cell hash.
rm -f hx89.state
./bin/hx89 polyforms/snapshot.hx 12345 100 > "$TMP/save.out"
[ -s hx89.state ] || fail "snapshot missing"
./bin/hx89 --resume hx89.state 100 > "$TMP/resume.out"
H1=$(sed -n 's/.*hash=\([0-9a-f]*\)$/\1/p' "$TMP/save.out" | tail -1)
H2=$(sed -n 's/.*hash=\([0-9a-f]*\)$/\1/p' "$TMP/resume.out" | tail -1)
[ -n "$H1" ] && [ "$H1" = "$H2" ] || fail "resume hash"
pass "executable-state persistence"

# Reject short snapshots and in-range-length snapshots with invalid arena counts.
head -c 16 hx89.state > "$TMP/truncated.state"
if ./bin/hx89 --resume "$TMP/truncated.state" 100 > "$TMP/truncated.out"; then fail "truncated snapshot accepted"; fi
grep -q 'snapshot rejected' "$TMP/truncated.out" || fail "truncated snapshot diagnostic"
cp hx89.state "$TMP/count.state"
printf '\001\020\000\000\000\000\000\000' | dd of="$TMP/count.state" bs=1 seek=8 conv=notrunc 2>/dev/null
if ./bin/hx89 --resume "$TMP/count.state" 100 > "$TMP/count.out"; then fail "oversized cell count accepted"; fi
grep -q 'snapshot rejected' "$TMP/count.out" || fail "invalid count diagnostic"
pass "snapshot length and arena bounds"

# 18. Same Polyform executes under several independent language engines.
./bin/hx89 polyforms/polyform.universal 1 100 > "$TMP/poly.hx87"
grep -q '^POLY$' "$TMP/poly.hx87" || fail "HX87 polyglot facet"
for tool in node python3 ruby bash dash lua; do
  if command -v "$tool" >/dev/null 2>&1; then
    "$tool" polyforms/polyform.universal >/dev/null 2>&1 || fail "polyglot $tool"
    pass "polyglot syntax executes under $tool"
  fi
done

# 19. AArch64/RV64 Stage-0 sources cross-assemble when Clang exists.
if command -v clang >/dev/null 2>&1; then
  clang --target=aarch64-linux-gnu -c boot/aarch64/hx0.S -o "$TMP/aarch64.o" || fail "AArch64 assemble"
  clang --target=riscv64-linux-gnu -c boot/riscv64/hx0.S -o "$TMP/riscv64.o" || fail "RV64 assemble"
  pass "AArch64 and RV64 Stage-0 cross-assembly"
fi

# 20. Hexworld semantic image is live and versioned.
./bin/hx89 polyforms/hello.anything 1 100 > "$TMP/hexworld.out"
grep -q '^HEXWORLD_ENTER semantic=HX87SEM3 dims=5 q2=25 epoch=0$' "$TMP/hexworld.out" || fail "Hexworld semantic entry"
pass "HX87SEM3 Hexworld entry gate"

# 21. Extended symbolic Conway constructors remain symbolic.
./bin/hx89 polyforms/surreal_universe.hx 1 100 > "$TMP/surreal_universe.out"
grep -q '^(2\*3)$' "$TMP/surreal_universe.out" || fail "surreal multiplication"
grep -q '^1/(2)$' "$TMP/surreal_universe.out" || fail "surreal reciprocal"
grep -q '^omega^(3)$' "$TMP/surreal_universe.out" || fail "surreal omega power"
pass "extended lazy Conway expression universe"

# 22. HX87-native IR is lowered into a transient host realization and returns to No.
./bin/hx89 --native polyforms/native_accel.hx 1 100 > "$TMP/accel.out"
grep -q '^NATIVE_ACCEL epoch=1 ir=4 bytes=24 result=122 ' "$TMP/accel.out" || fail "native accelerator"
grep -q '^122$' "$TMP/accel.out" || fail "native accelerator surreal return"
grep -q '^HEXWORLD epoch=2 cells=8 heads=1 surreal=1 entropy=0000000000000001$' "$TMP/accel.out" || fail "Hexworld state after native acceleration"
pass "Hexworld -> native accelerator -> Hexworld return"

# 23. Native IR cannot execute directly as ordinary cells.
cat > "$TMP/ir_direct.hx" <<'QEOF'
HX87P1
CELL 0 0 0 0 0 34 7 0 0
CELL 1 0 0 0 0 0 0 0 0
QEOF
./bin/hx89 "$TMP/ir_direct.hx" 1 20 > "$TMP/ir_direct.out"
grep -q '^HX89: native IR cell executed outside NATIVE_ACCEL$' "$TMP/ir_direct.out" || fail "direct native IR guard"
pass "native accelerator IR is context-bound"

# 24. Physical executable uses a non-executable process stack.
if command -v readelf >/dev/null 2>&1; then
  readelf -W -l bin/hx89 > "$TMP/phdrs.txt"
  grep -q 'GNU_STACK.*RW ' "$TMP/phdrs.txt" || fail "GNU_STACK not RW/non-X"
  if grep -q 'GNU_STACK.*RWE' "$TMP/phdrs.txt"; then fail "executable stack"; fi
  pass "non-executable host stack"
fi

# 25. Semantic and generated-native hashes are deterministic for seeded execution.
./bin/hx89 --native polyforms/native_accel.hx 1 100 > "$TMP/accel2.out"
cmp -s "$TMP/accel.out" "$TMP/accel2.out" || fail "native acceleration replay"
pass "native lowering deterministic replay"

echo "ALL TESTS PASS"
