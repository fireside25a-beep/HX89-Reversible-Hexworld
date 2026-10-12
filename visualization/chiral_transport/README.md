# Chiral Transport Laboratory

This is a local, static visual companion. It contains no HX89 archive, C source,
proof executable, certificate, research data, book source, or private project files.

It renders an independently implemented six-channel triangular-lattice model:

- axial directions `(1,0)`, `(0,1)`, `(-1,1)`, `(-1,0)`, `(0,-1)`, `(1,-1)`;
- `C+ : 9 → 18 → 36 → 9`;
- `C− : 9 → 36 → 18 → 9`;
- `21 ↔ 42` for either handedness;
- site-wise stochastic selection of `C+` with probability `p`;
- a separately labelled molecular-chaos response-circle panel.

Open `dist/index.html` in a modern browser with network access for the standard
Three.js module URLs. Use an HTTPS origin on a WebXR-capable mobile browser to
enable the AR button. AR places the two-dimensional lattice on a real surface;
it does not represent a three-dimensional hydrodynamic model.

The visual code is an explanatory implementation. It is not a numerical
Green–Kubo calculation and makes no continuum-viscosity claim.
