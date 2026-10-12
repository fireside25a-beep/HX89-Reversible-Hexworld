# Self-monitoring arithmetic verifier

The “machine looking at the machine” component is implemented as an arithmetic certifier, not as an adaptive physics engine.

## Rule

The monitor is allowed to change only the **numerical representation** used to evaluate a fixed expression.  It may not change model coefficients, add regularizers to the equation, alter a failed point, or search parameter space until the circle appears.

For fixed `a0,a,b`, it evaluates

`Z=1/(a+i b)`

and computes the circle defect in two algebraically equivalent ways:

`Delta_direct = |Z|^2-(1/a0) Re Z`,

`Delta_identity = (a0-a)/[a0(a^2+b^2)]`.

A result is certified only when these agree within a precision-dependent tolerance.

## Fast path

Binary64 is attempted first.  The monitor rejects the fast path when it detects any of the following:

- nonfinite input or intermediate value;
- overflow in `a^2+b^2`;
- underflow to a singular denominator;
- a nonzero input collapsing to zero;
- two distinct decimal coefficients coalescing to the same binary64 value in a way that can erase `a0-a`;
- nonfinite output;
- failure of the two-form identity check.

## Recovery path

On rejection, the same decimal coefficients are re-evaluated with `mpmath` arbitrary precision.  Precision is doubled until the direct/identity forms agree and successive evaluations stabilize, up to the declared maximum precision.

The stress suite contains explicit overflow, underflow and catastrophic-input-coalescence cases.  All are required to trigger arbitrary-precision recovery.

## Why this is not proof by repair

The monitor never replaces `a(d)` with `a0`, never projects a point onto the circle, and never modifies `b(d)` or the response.  A drifting model remains off-circle after recovery.  The monitor's only purpose is to prevent floating-point pathologies from creating false evidence for or against the exact symbolic theorem.
