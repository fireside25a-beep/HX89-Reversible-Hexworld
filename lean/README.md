# HX89 Lean 4 proof layer

This is a standalone Lean 4.30.0 source file with no Mathlib dependency:

```sh
cd lean
lean HX89/Chiral.lean
```

The source [`HX89/Chiral.lean`](HX89/Chiral.lean) compiles without `sorry`, `admit`, or added axioms. `by decide` closes finite universal propositions over every one of the 64 local six-bit states. Its table is the rule in `src/chiral_law.c`: positive chirality `9 → 18 → 36 → 9`, negative chirality its inverse, and `21 ↔ 42` for either handedness. It proves both local inverse directions, particle and axial momentum conservation, reflection and velocity involutions, mirror/chirality conjugacy, and velocity/collision compatibility.

The second section formalizes the split-step implication. An `EndpointSystem` supplies five maps (`cPlus`, `cMinus`, `stream`, `unstream`, `mirrorVelocity`) and six explicit equations for their inverses and symmetries. Under those assumptions, Lean derives:

- `theta_involution`: `Θ² = I`;
- `dressed_reversor`: `Θ F Θ = F⁻¹`;
- `echo`: `Θ Fᵗ Θ Fᵗ = I` for every natural `t`.

The abstract `EndpointSystem` **is not instantiated here for the concrete toroidal lattice**. In particular, Lean has not checked its spatial index arithmetic, full C program, Polyform VM, or 2²⁴-state torus enumeration. The C certificate and Python oracle test the concrete implementation independently. The all-size mathematical derivation and its physical limits are in [`docs/CHIRAL_RECIPROCITY.md`](../docs/CHIRAL_RECIPROCITY.md).

Neither the stochastic continuous-`p` model nor the conjectured correlated Green–Kubo transport rigidity is proved by this Lean file.

The actual local compile result and toolchain version for this release are recorded in [`VERIFICATION.txt`](VERIFICATION.txt). The official [Lean installation guide](https://lean-lang.org/install/manual/) describes how to obtain the pinned toolchain.
