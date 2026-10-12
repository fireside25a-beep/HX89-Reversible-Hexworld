# External run traces

This directory preserves the raw CSV traces supplied with the final documentation pass. They are included verbatim so the release does not discard test-side evidence.

The files have no header or schema declaration in the supplied form. HX89 therefore does not infer column semantics, fit a model to them, or use them as proof of the transport-circle conjecture. Any later quantitative claim based on these traces must first document the generator, parameter meaning, units, ensemble, lattice size, observation time and estimator.

Files:

- `raw/s05.csv`
- `raw/s0.25.csv`
- `raw/s0.5.csv`
- `raw/s0.625.csv`

Their integrity is covered by the repository `MANIFEST.sha256`.
