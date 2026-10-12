#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
mkdir -p "$ROOT/dist"

python3 "$ROOT/thesis/tools/generate_fragments.py"
python3 "$ROOT/thesis/tools/make_figures.py"
sh "$ROOT/thesis/tools/build_docs.sh"
make -C "$ROOT/research/crtc" paper >/dev/null

cp "$ROOT/thesis/Alex_Moraru_Thesis.pdf" "$ROOT/dist/Alex_Moraru_Thesis.pdf"
cp "$ROOT/thesis/Alex_Moraru_Thesis_Companion.pdf" "$ROOT/dist/Alex_Moraru_Thesis_Companion.pdf"
cp "$ROOT/research/crtc/paper/main.pdf" "$ROOT/dist/CRTC_Response_Rigidity.pdf"

for f in "$ROOT/dist/Alex_Moraru_Thesis.pdf" "$ROOT/dist/Alex_Moraru_Thesis_Companion.pdf" "$ROOT/dist/CRTC_Response_Rigidity.pdf"; do
  test -s "$f"
  pdfinfo "$f" >/dev/null
  pdftotext "$f" - >/dev/null
done

echo DOCUMENT_BUILD_PASS
