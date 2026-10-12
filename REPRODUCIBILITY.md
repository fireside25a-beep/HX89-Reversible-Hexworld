# Reproducibility

This repository is designed so that its machine results, transport identities, research manuscript, and thesis can be checked from one source tree.

## Full verification

From the repository root:

```sh
make verify-all
```

The target performs a clean machine rebuild, the complete executable test suite, sanitizer checks, repository audit, the CRTC symbolic and numerical verification suite, scientific-registry regeneration, document compilation, independent mathematics audit, prose checks, and the cross-document consistency audit.

The separately pinned Lean layer is checked with `(cd lean && lean HX89/Chiral.lean)` using Lean 4.30.0. The root `verify-all` target does not invoke Lean; see `lean/README.md` for its theorem scope and concrete-model boundary.

The packaged verification summary is `evidence/verification/FINAL_VERIFICATION.txt`; the captured full run is `evidence/verification/VERIFY_ALL_FINAL.txt`.

## Scientific registries

`tools/generate_scientific_registry.py` executes the canonical proof and regression programs and writes two machine-readable files:

* `scientific/claims.json` records the canonical counts, parameter-domain sizes, regression coordinate, and theorem-status boundaries used by the documents.
* `scientific/equation_registry.json` records the central equations in a normalized source-of-truth form.

`tools/consistency_audit.py` independently rederives the central symbolic identities, compares the registries with generated LaTeX fragments and certificates, checks the implementation maps across languages, checks all ten entropy termination branches, verifies theorem-status wording, and confirms that the compiled documents contain the canonical counts and author identity.

## Documents

```sh
make documents
```

The compiled artifacts are copied to `dist/`:

* `Alex_Moraru_Thesis.pdf`
* `Alex_Moraru_Thesis_Companion.pdf`
* `CRTC_Response_Rigidity.pdf`

Their LaTeX sources remain in `thesis/` and `research/crtc/paper/`.

## Arithmetic monitoring

The CRTC arithmetic monitor may increase numerical precision when finite-precision evaluation overflows, underflows, or merges distinct inputs. It never changes a physical coefficient, adjusts a model to fit the circle, or replaces a failed invariant with a projected value.

## Scientific boundary

The exact response-geometry classification, the microscopic reversor identities, and the Boltzmann-level FHP transport-circle identity are reproducible claims of this tree. Survival of the transport circle under the fully correlated Green-Kubo dynamics of chiral FHP remains an open microscopic question and is not converted into a theorem by the verification machinery.
