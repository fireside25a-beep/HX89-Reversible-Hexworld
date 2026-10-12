# Conway-surreal domain

HX87 values are symbolic Conway objects, not IEEE floating-point numbers and not host reals.

Implemented symbolic constructors are:

- `INT(n)`  -  exact integer.
- `DYAD(n,k)`  -  exact dyadic `n/2^k`.
- `OMEGA`  -  lazy canonical family for `{0,1,2,...|}` without materializing infinitely many options.
- `NEG(x)`  -  symbolic negation.
- `ADD(x,y)`  -  symbolic addition.
- `CUT(l,r)`  -  binary Conway cut, rejected when finite comparison proves `l !< r`.
- `MUL(x,y)`  -  symbolic multiplication expression.
- `RECIP(x)`  -  symbolic reciprocal expression.
- `OMEGAPOW(x)`  -  symbolic `omega^x` expression.

`No` is a proper class, so no physical machine can enumerate it. HX87 therefore implements an open-ended lazy symbolic universe: transfinite forms are constructed and transformed as expression objects, while a concrete run uses finite storage.

`polyforms/surreal_universe.hx` executes the extended constructors and prints `(2*3)`, `1/(2)` and `omega^(3)` without converting any of them to a host float.
