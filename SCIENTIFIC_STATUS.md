# HX89 scientific status and evidence

This document states what the repository establishes directly, what is inherited from cited literature, and what remains open.

## Exact machine results

The HX0 path reconstructs the canonical seed and semantic image from strict one-bit streams and independently checks the same bytes through the ETCH route. The signal path additionally verifies bipolar PCM, 125-baud FSK, and 1200-baud Bell 202 framing, synchronization, CRC behavior, noisy-channel recovery, and reconstruction through HX0.

The byte-to-Polyform compiler is checked as a semantic right inverse through execution and through the Bell 202 transport path. Payload boundaries and deterministic replay are included in the test suite.

The six-channel deterministic hexagonal lattice gas has exact local particle and momentum conservation and an explicit inverse collision rule. The implemented endpoint chiral dynamics has a collision-dressed reversing involution. The repository proves the corresponding operator identities and certifies the complete 2 x 2 torus state space for both chiralities. The exhaustive global state count is 16,777,216.

The Lean 4 layer under `lean/` compiles the local 64-state collision, conservation, mirror and velocity identities and proves an all-time abstract echo theorem from declared streaming/indexing assumptions. The concrete torus indexing has not been instantiated as a Lean `EndpointSystem`; its finite certificate remains the independent C/Python verification. See `lean/README.md` for the exact formal boundary.

The entropy Polyform uses explicit HALT cells at every signed two-step axis endpoint. Seed 12345 therefore terminates intentionally at its selected endpoint rather than falling out of the sparse field. Genuine missing-cell execution remains an error in the virtual machine.

## Transport results

The zero-field shear and Hall viscosity formulas used for the stochastic chiral-FHP kinetic model are attributed to Allocca et al., *Odd fluids from chiral cellular automata*, arXiv:2606.19431 (2026). The repository independently reconstructs the local molecular-chaos collision map, verifies the shear eigenvalue, and checks the resulting transport-circle algebra with exact arithmetic.

The response-rigidity module proves a closure-free geometric identity for every nonzero complex response with a real positive parity-symmetric anchor. It shows that anchored circle membership is exactly equivalent to constancy of the real part of the measured inverse response. The `C6` shear commutant is `aI+bJ`; this symmetry form does not force the dissipative coordinate `a` to remain constant.

A stationary two-component Ornstein-Uhlenbeck process supplies an exact Green-Kubo resolvent with positive dissipation and the same reduced rotational/reflection covariance. A drifting real inverse-response coordinate leaves the anchored circle by the exact defect formula. This is a counterexample to protection by symmetry and positivity alone. It is not a surrogate simulation of the FHP automaton.

## Open physical question

The fully correlated chiral FHP Green-Kubo problem remains open in this repository. A model-specific proof or falsification must determine whether the real part of the inverse shear response is independent of chirality under a stated finite-size, finite-time, finite-frequency, or renormalization prescription. Two-dimensional long-time tails are treated as physical response structure, not as a numerical error to subtract away.

No Ward identity protecting the transport circle is claimed. A Ward interpretation would require an identified microscopic symmetry or conservation law that enforces the rigidity condition.

## Reproducibility

Run:

```sh
make verify-all
```

The command regenerates executable evidence, runs sanitizers and exact tests, verifies the CRTC module, rebuilds the scientific claim/equation registry, compiles the thesis and companion, and runs the cross-document consistency audit. The final verification record is written under `evidence/verification/`.
