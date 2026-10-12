# Literature boundary for the transport claim

This note records only the literature facts needed to prevent category errors in the transport discussion.

## Chiral FHP coefficients

Andrew A. Allocca, Shiva Heidari, Thomas Iadecola, Armin Rahmani, Pouyan Ghaemi and Sriram Ganeshan, *Odd fluids from chiral cellular automata*, arXiv:2606.19431 (2026), construct a parity-breaking FHP generalization and derive odd-viscous hydrodynamics. HX89 uses their analytical coefficient formulas only as an external input for the algebraic elimination in `docs/TRANSPORT_CIRCLE.md`.

## Two-dimensional long-time tails

Toyoaki Naitoh, Matthieu H. Ernst, and James W. Dufty, *Long-time tails in two-dimensional cellular automata fluids*, Phys. Rev. A 42, 7187 (1990), DOI 10.1103/PhysRevA.42.7187, apply mode-coupling theory to the two-dimensional FHP lattice gas and find long-time algebraic stress correlations. This is direct evidence that discrete velocities do not, by themselves, eliminate the long-time-tail problem.

The consequence for HX89 is methodological: a Green-Kubo circle must be posed at finite size/time or in an explicit running/renormalized scheme before a limit is claimed.

## Odd viscosity

J. E. Avron, R. Seiler and P. G. Zograf, *Viscosity of Quantum Hall Fluids*, Phys. Rev. Lett. 75, 697 (1995), DOI 10.1103/PhysRevLett.75.697, relate nondissipative viscosity of gapped quantum Hall fluids to adiabatic curvature.

Debarghya Banerjee, Anton Souslov, Alexander G. Abanov and Vincenzo Vitelli, *Odd viscosity in chiral active fluids*, Nature Communications 8, 1573 (2017), DOI 10.1038/s41467-017-01378-7, derive a dissipationless odd-viscosity term for classical chiral active fluids.

Those results establish important odd-viscosity structures in distinct physical settings. This repository does **not** promote them into a universal statement that the classical chiral-FHP odd coefficient is protected against every hydrodynamic fluctuation or long-time-tail renormalization. Such a non-renormalization statement would need its own theorem in the model under study.

## Reversing symmetry

J. S. W. Lamb and G. R. W. Quispel, *Reversing k-symmetries in dynamical systems*, Physica D 73, 277-304 (1994), DOI 10.1016/0167-2789(94)90101-5, is part of the established reversing-symmetry literature. HX89's contribution is not the invention of reversibility, but the explicit collision-dressed reversor for its split-step automaton and the corresponding machine certificate.

## Claim discipline

The repository uses the following vocabulary:

- **theorem**: proved from the stated HX89 definitions or from explicitly stated abstract assumptions;
- **machine certificate**: exhaustive or exact computational verification on the stated finite domain;
- **derived corollary**: exact algebra applied to externally published formulas;
- **conjecture/open problem**: a physical statement not implied by the established symmetries and not proved by the finite certificates.
