#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
CC=${CC:-cc}
TMP=$(mktemp -d "${TMPDIR:-/tmp}/hx89-sanitize.XXXXXX")
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
SAN='-std=c11 -O1 -g -Wall -Wextra -Werror -fsanitize=address,undefined -fno-omit-frame-pointer'

$CC $SAN -o "$TMP/byte-polyform" src/byte_polyform.c
$CC $SAN -DHX89_CHIRAL_STATE_BITS=18 -o "$TMP/hx89-chiral-proof" src/chiral_law.c
$CC $SAN -o "$TMP/hx89-gas" src/hex_gas.c
$CC $SAN -o "$TMP/pulse-pcm" src/pulse_pcm.c

export ASAN_OPTIONS=${ASAN_OPTIONS:-detect_leaks=0:halt_on_error=1}
export UBSAN_OPTIONS=${UBSAN_OPTIONS:-halt_on_error=1:print_stacktrace=1}

python3 - "$TMP" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1])
p.joinpath('alphabet.bin').write_bytes(bytes(range(256)))
p.joinpath('max.bin').write_bytes(bytes((37*i+11)&255 for i in range(4095)))
PY

"$TMP/byte-polyform" "$TMP/alphabet.bin" "$TMP/alphabet.hx"
"$TMP/byte-polyform" "$TMP/max.bin" "$TMP/max.hx"
"$TMP/hx89-chiral-proof"
"$TMP/hx89-gas" 128 128 100 12345 "$TMP/gas.pgm" "$TMP/gas.hx"
"$TMP/pulse-pcm" encode-bell202 seeds/hx89_seed.bits "$TMP/seed.bell.wav"
"$TMP/pulse-pcm" decode-bell202 "$TMP/seed.bell.wav" "$TMP/seed.bits"
cmp seeds/hx89_seed.bits "$TMP/seed.bits"
printf '%s\n' 'PASS: ASan/UBSan byte compiler, 2^18-state chiral prover sample, 128x128x100 gas and canonical Bell codec'
