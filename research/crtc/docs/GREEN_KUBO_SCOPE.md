# Green--Kubo scope and the meaning of “beyond molecular chaos”

## What the structural theorem actually needs

The response-level theorem starts from the measured or otherwise well-defined complex response

`Z=eta_shift+i eta_H`

at a specified frequency, finite size, cutoff or renormalization scale.  It classifies the anchored circle by

`Re(1/Z)=constant`.

That statement is independent of how `Z` was obtained.  A Green--Kubo calculation, a kinetic closure, an exact finite Markov generator, or another linear-response method can all supply `Z`.

## Green--Kubo response is a matrix element, not merely a list of eigenvalues

In a finite-dimensional linear relaxation problem with generator `L` and observable/source vectors, a static Green--Kubo quantity has resolvent structure schematically of the form

`<g, L^{-1} h>`

on the nonconserved subspace.  Spectral eigenvalues enter, but so do the projectors and overlaps of `g` and `h` with the eigenmodes.

The repository therefore distinguishes two claims:

1. **Identified reduced shear block.**  If symmetry and microscopic analysis isolate the exact two-dimensional shear block and the response normalization/residue is known, its complex pair `a±ib` determines the inverse response.  Circle membership is then decidable algebraically from `a`, without integrating trajectories in time.
2. **Bare full spectrum.**  An unordered list of eigenvalues of a larger microscopic operator is insufficient in general.  `same_spectrum_different_overlap_witness()` gives two similar generators with identical spectra but distinct resolvent matrix elements for the same fixed observable.

This is why the repository does not claim “the collision spectrum always decides CRTC” without qualification.

## Correlations and self-energy language

Beyond molecular chaos, correlations can be represented formally by a frequency/scale-dependent effective inverse response or self-energy in the shear sector.  C6 still restricts an isotropic two-component shear response to the complex-scalar form

`Q_eff=a_eff I+b_eff J`

provided that the effective response remains local in that reduced sector and no additional slow variables enlarge the block.

The structural question becomes exact:

`Does Re Q_eff(p) remain equal to Re Q_eff(p0)?`

If yes, the correlated response remains on the anchored circle.  If no, it leaves the circle.  The theorem does not require that the correction to `b_eff` be small.

If additional hydrodynamic variables mix into the response, one should first compute the actual scalar complex response `Z` after the required projection/elimination, then apply the closure-free criterion `Re(1/Z)=constant`.

## Two-dimensional long-time tails

Two-dimensional fluids are special because hydrodynamic long-time tails can make the zero-frequency/infinite-system shear transport coefficient scale dependent or divergent.  Naitoh, Ernst, and Dufty found algebraic long-time tails in the two-dimensional FHP cellular automaton, including an intermediate `1/t` regime and a slower asymptotic form.

Therefore an unqualified statement about a finite thermodynamic-limit `eta_GK(omega=0)` is unsafe.  The clean structural formulation is scale-by-scale or at finite regulator:

`Z_L(omega,p)` or `Z_ell(p)` lies on the anchored circle iff `Re[1/Z_L(omega,p)]` is chirality independent relative to the achiral anchor at the same `L,omega,ell`.

A divergent common scale does not by itself decide the normalized circle question; the chirality dependence of the inverse response does.

## What would prove model-specific CRTC survival

For the correlated chiral-FHP automaton, a genuine proof of survival would require one of the following:

- an exact microscopic identity forcing the chirality-dependent part of `Re(1/Z)` to vanish;
- a controlled RG calculation showing the rigid manifold is invariant at every scale;
- an exact finite-size/frequency resolvent calculation followed by a controlled limiting argument;
- or another nonperturbative derivation of the same invariant.

The present repository supplies the classifier, the molecular-chaos witness and a correlated counterexample, but it does not manufacture such a missing identity.
