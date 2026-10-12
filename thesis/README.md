# Alex Moraru Thesis

This directory contains the thesis, the concise companion document, exact analytic figures, bibliography, glossary definitions, and the verification tools that connect document claims to the executable HX89 and CRTC suites.

## Primary outputs

- `Alex_Moraru_Thesis.pdf`
- `Alex_Moraru_Thesis_Companion.pdf`
- `main.tex` and chapter/appendix sources
- `companion.tex`
- `references.bib`
- `generated/canonical.tex`

## Verification

From the repository root:

```sh
make verify-all
```

The thesis generator reads machine certificates and declared test domains rather than maintaining separate handwritten counts. The independent mathematics audit imports no implementation from `research/crtc/src`.
