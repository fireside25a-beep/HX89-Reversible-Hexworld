# HX89 Lean proof layer

The two modules have different scope:

| Module | Checked claims | Boundary |
| --- | --- | --- |
| [`HX89/Chiral.lean`](HX89/Chiral.lean) | The 64-state collision table, local conservation and symmetries, and an all-time echo theorem conditional on six streaming/index equations | Does not instantiate the concrete torus or Polyform VM |
| [`HX89/Transport.lean`](HX89/Transport.lean) | The commutant of a nontrivial planar rotation, the complex kernel defect identity, zero-defect/flatness equivalence, a conditional beta-flow criterion, and a positive parity-even nonflat witness | Does not derive a correlated Green–Kubo response from the microscopic gas |

`Chiral.lean` uses Lean 4.30.0 alone. `Transport.lean` uses Mathlib pinned by [`lakefile.lean`](lakefile.lean) and [`lake-manifest.json`](lake-manifest.json) to the compatible v4.30.0 release. On Linux, with the pinned Lean toolchain installed:

```sh
cd lean
lake exe cache get
lake build
```

The Mathlib cache is a substantial download. [`TRANSPORT_VERIFICATION.txt`](TRANSPORT_VERIFICATION.txt) records the version, source digest and local compiler result. The original `Chiral.lean` verification is recorded separately in `VERIFICATION.txt`.

## Exact transport assumptions

The rotation is represented as `[[u,-v],[v,u]]` with `v ≠ 0`. The commutant result is direct matrix algebra and includes the shear representation of the nontrivial C₆ rotation. For the response, `Z = K/(a+i b)`, the anchor is nonzero and `a²+b² ≠ 0`. The circle-membership equivalence additionally requires `K ≠ 0`. These are hypotheses, not conclusions from microscopic FHP dynamics.

The beta theorem assumes differentiable scale trajectories, equal beta functions at every scale, and initial flatness. It proves preservation under those assumptions. The parity-even positive counterexample demonstrates why reflection symmetry and positivity cannot supply flatness by themselves.

`DissipativeFlatness` is a parameterized mathematical property with **no theorem that the correlated FHP model satisfies it**. That physical question needs a specified stochastic family, Green–Kubo projection, finite-size/time prescription and limit. The C program checks deterministic endpoint chiralities only. No `sorry`, `admit`, custom axiom, or placeholder proof is used in either module.
