#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
rm -rf build/latex-main build/latex-companion
mkdir -p build/latex-main build/latex-companion

# Build thesis in an isolated output directory while keeping source paths stable.
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build/latex-main main.tex >/dev/null
(cd build/latex-main && BIBINPUTS=../..: /usr/bin/bibtex.original main >/dev/null)
(cd build/latex-main && TEXINPUTS=../..: makeglossaries main >/dev/null)
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build/latex-main main.tex >/dev/null
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build/latex-main main.tex >/dev/null
cp build/latex-main/main.pdf Alex_Moraru_Thesis.pdf
cp build/latex-main/main.log results/THESIS_LATEX.log

pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build/latex-companion companion.tex >/dev/null
(cd build/latex-companion && BIBINPUTS=../..: /usr/bin/bibtex.original companion >/dev/null)
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build/latex-companion companion.tex >/dev/null
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build/latex-companion companion.tex >/dev/null
cp build/latex-companion/companion.pdf Alex_Moraru_Thesis_Companion.pdf
cp build/latex-companion/companion.log results/COMPANION_LATEX.log

echo "PASS: thesis and companion PDFs compiled"
