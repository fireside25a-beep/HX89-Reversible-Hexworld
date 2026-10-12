# Explicit positive-dissipation Green--Kubo counterexample

A classification theorem is useful only if the non-rigid side is nonempty under physically meaningful constraints.  This file gives an exact correlated linear stochastic witness.

## Model

Let `X(t)` be a real two-component shear variable satisfying the stationary Ornstein--Uhlenbeck equation

`dX = -K(d) X dt + B(d) dW`,

where `d=p-p0` and

`K(d)=a(d)I+b(d)J`,

`a(d)=a0+eps d^2`,

`b(d)=c d`,

with `a0>0`, `eps>0`, `c>0` and `J^2=-I`.

Choose stationary covariance

`C=<XX^T>=A I`, `A>0`.

The Lyapunov equation requires

`B B^T = K C + C K^T = 2 A a(d) I`,

which is positive definite for every `d`.

## Positive dissipation and stability

The symmetric part is

`(K+K^T)/2=a(d)I>0`.

For any nonzero real shear vector `v`,

`v^T[(K+K^T)/2]v=a(d)|v|^2>0`.

The eigenvalues are `a(d)±i b(d)`, so the process is exponentially stable because their real parts are positive.

The antisymmetric `bJ` part is reactive: it rotates the shear doublet and does not contribute to this quadratic dissipation form.

## Symmetry

Every `aI+bJ` commutes with the C6 shear representation.  Since `a` is even and `b` odd in `d`, reflection conjugation maps `K(d)` to `K(-d)`.  The witness therefore obeys the same reduced C6/reflection structure used by the rigidity theorem.

## Exact Green--Kubo response

The stationary correlation matrix is

`<X(t)X(0)^T>=exp[-K t] C` for `t>=0`.

Because the real parts of the eigenvalues of `K` are positive,

`R(d)=integral_0^infinity exp[-K t] C dt = K^-1 C = A K^-1`.

No time discretization or numerical trajectory is involved.

After dividing the known scalar covariance factor `A`, the complex response is

`Z(d)=1/[a(d)+i b(d)]`.

Its exact CRTC defect is

`Delta(d) = - eps d^2 / {a0[(a0+eps d^2)^2+c^2 d^2]}`.

Hence

- `Delta(0)=0`,
- `Delta(d)<0` for every `d!=0`,
- the model remains stable and strictly positive-dissipation everywhere.

This is a direct witness that C6/reflection covariance plus positive dissipation does not force circle rigidity.

## Exact finite sweep

`tests/test_exhaustive_exact_grid.py` uses rational arithmetic with

`a0=3/2`, `eps=2/5`, `c=9/10`

on 1,001 equally spaced rational chirality values from `-1/2` to `1/2`.  All 1,001 points have positive `a`; the achiral point has zero defect and all 1,000 nonzero-chirality points have strictly negative defect.

The symbolic formula proves the continuum statement; the grid is an independent executable regression test over a declared finite domain.
