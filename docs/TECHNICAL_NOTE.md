# Exact Chirality Reciprocity and Signal-Bootstrapped Closure in HX89

## Abstract

HX89 isolates two exact statements that can be proved without fitting a continuum model. First, the fixed-chirality six-velocity Boolean lattice gas has an explicit parity/chirality conjugacy and a collision-dressed reversing involution. These identities hold for every state and every time on every finite periodic axial torus. Second, the canonical byte-to-Polyform compiler is a semantic right inverse of HX89 emission, and this identity survives the complete Polyform -> Bell 202 waveform -> HX0 reconstruction -> HX89 execution route. The repository provides an exhaustive C certificate over all `2^24 = 16,777,216` states of the complete 2x2 torus, an independent Python oracle on larger tori, all-256-byte transport, the 4095-byte execution boundary, and ASan/UBSan checks of the C components.

These are exact results for the specified automaton and machine. They are not claims of a new universal continuum equation, a new Navier-Stokes limit, or a laboratory law of matter.

## 1. Microscopic model

At each lattice site, six Boolean occupations correspond to axial velocities

`c0=(1,0), c1=(0,1), c2=(-1,1), c3=(-1,0), c4=(0,-1), c5=(1,-1)`.

The positive-chirality local collision `C+` acts on the zero-momentum two-particle states by

`9 -> 18 -> 36 -> 9`,

and swaps the zero-momentum three-particle states

`21 <-> 42`.

All other local states are fixed. `C- = C+^-1`. Streaming `S` moves each occupied channel along its velocity. One full step is

`F_chi = S C_chi`, with `chi in {+1,-1}`.

Because both the local collision and toroidal streaming are permutations, every finite HX89 gas is an exact finite-state permutation system.

## 2. Exact chiral reciprocity law

Define the axial reflection

`P: (x,y,i) -> (x+y,-y,-i)`

with coordinates reduced modulo the torus size and channel index modulo six. Direct local evaluation gives

`P C_chi P = C_-chi`,

while geometry gives

`P S P = S`.

Therefore

`P F_chi P = F_-chi`.

By induction, for every integer `t >= 0`,

`P F_chi^t = F_-chi^t P`.

This is the exact chirality-reciprocity law used by this release. It pairs every trajectory of one handedness with the reflected trajectory of the opposite handedness, state by state and at identical time.

### Finite-time statistical corollary

Let an initial probability measure `mu` satisfy `P_* mu = mu`. If an observable has parity `A(Pq)=eps_A A(q)`, then

`Law_mu[A(F_+^t q)] = Law_mu[eps_A A(F_-^t q)]`.

Thus the entire distribution, not merely a linear-response coefficient, is constrained. Reflection-even statistics coincide between opposite chiralities. Reflection-odd statistics reverse sign.

This implies a necessary symmetry rule for any hydrodynamic limit derived from this microscopic dynamics: parity-even transport functions must be even under chirality reversal, whereas parity-odd transport functions must be odd. The statement constrains a continuum theory if one exists; it does not by itself prove the continuum limit.

## 3. Collision-dressed PT reversibility

Let velocity reversal be

`V: (x,y,i) -> (x,y,i+3)`.

Then `V C_chi V = C_chi`, `V S V = S^-1`, and `P` commutes with `V`. Put `K=PV` and define

`Theta_chi = C_-chi P V`.

The split-step convention matters: plain `PV` maps the collision phase to the opposite chirality but does not by itself reverse the collision-then-stream step at the same time section. The compensating `C_-chi` changes that section by one local collision phase.

Using `K C_chi K=C_-chi` and `K S K=S^-1`, one obtains

`Theta_chi^2 = I`

and

`Theta_chi F_chi Theta_chi = F_chi^-1`.

Hence a fixed-chirality HX89 gas has an explicit local reversing involution despite the microscopic collision table not being invariant under reflection alone.

### Correlation corollary

For a measure invariant under both `F_chi` and `Theta_chi`, and observables with `Theta` parities `eps_A` and `eps_B`,

`<A(F_chi^t q) B(q)> = eps_A eps_B <B(F_chi^t q) A(q)>`.

This is an exact finite-map reversing-symmetry identity of Onsager-Casimir type. General reversing symmetries and Onsager reciprocity are established theory; the specific contribution established here is the explicit split-step operator for this automaton and its executable certificate.

## 4. Machine proof boundary

`bin/hx89-chiral-proof` independently implements forward and inverse dynamics and checks:

- all 64 local states for conservation, inverse collision and symmetry identities;
- all 16,777,216 global states of the complete 2x2x6-bit torus;
- mirror/chirality conjugacy;
- `Theta_chi^2=I`;
- `Theta_chi F_chi Theta_chi=F_chi^-1`.

`tests/test_chiral_law.py` separately checks the algebra on deterministic samples of 3x3, 4x4, 5x5 and 7x7 tori and performs exact rational elimination of the one-body occupation-change matrix. Its nullspace has dimension three and is spanned by particle number and the two momentum components.

The exhaustive 2x2 enumeration is a machine certificate for that complete finite state space. The all-size theorem comes from the local operator identities; it is not inferred statistically from the 2x2 enumeration.

## 5. Semantic composition theorem

For a byte string `b` of length at most 4095, let `E(b)` be the canonical Polyform emitted by `byte-polyform`: one ordered `EMIT` cell per byte followed by one `HALT` cell. Let `M` be HX89 execution restricted to the emitted byte stream. Then

`M(E(b)) = b`.

Let `A` be deterministic Bell-202 encoding, `D` its verified decoder on the generated carrier, and `L` the HX0 bitstream loader that reconstructs the Polyform bytes. On the canonical encoded class used by this release,

`L(D(A(bits(E(b))))) = E(b)`.

Therefore

`M(L(D(A(bits(E(b)))))) = b`.

This is a semantic right inverse. It intentionally does not claim recovery of arbitrary source formatting or arbitrary Polyform text, because HX89 loads semantic records rather than preserving irrelevant textual layout.

The test suite executes the complete byte alphabet `0..255`, the empty payload, deterministic recompilation, the full signal route, the exact 4095-byte arena boundary, and rejection at 4096 bytes.

## 6. Closed physics-observation loop

The gas route composes the deterministic microscopic evolution with an observation map `G` that emits a density PGM. The image bytes are compiled into an executable Polyform, transported as Bell-202 audio, reconstructed by HX0, and executed by HX89. For the certified fixture,

`HX89(HX0(BellDecode(BellEncode(Compile(G(gas)))))) = G(gas)`

byte for byte.

This closes an exact signal-bootstrapped observation loop. What is recovered is the observable image emitted by the gas run, not the hidden microscopic gas state unless that state itself is chosen as the payload.

## 7. Novelty boundary

The fixed-chirality FHP endpoint is not new. Deterministic definite-chirality hexagonal lattice gases, the three-state cyclic collision, microscopic reversibility, hydrodynamic coarse-graining, and odd/Hall viscosity all have prior literature. In particular, 2026 work derives odd viscosity for chiral FHP collisions and explicitly notes that parity and time reversal are separately broken while their product is preserved.

General reversing involutions are also established in dynamical-systems theory, and Onsager reciprocity in lattice gases has a mature literature. The candidate research contribution in HX89 is therefore deliberately narrower:

1. the explicit collision-dressed reversing operator for this exact split-step rule;
2. its all-state local proof plus exhaustive whole-system machine certificate;
3. exact finite-time chirality-distribution reciprocity;
4. the composition of that physical automaton with a byte-exact executable/audio/bootstrap closure path.

No claim of priority should be made until a domain expert has independently searched the literature and checked the proof. The repository makes the result falsifiable and reproducible now rather than inflating it into an unsupported universal-fluid claim.

## 8. Reproducibility

Run:

```sh
make clean all
make check
make sanitize
make audit
```

The decisive machine lines are:

`CHIRAL_LAW_PASS local_states=64 global_states=16777216 mirror_chirality=PASS theta_involution=PASS dressed_PT_reversor=PASS`

and

`PASS: semantic right inverse for byte alphabet, Bell/HX0 transport, determinism and arena boundaries`.

## 8. Exact echo and correlation certificate

The collision-dressed reversor immediately yields the all-time microscopic echo

`Theta_chi F_chi^t Theta_chi F_chi^t = I`.

The C proof program now checks the local identities for both chiralities and exhausts all `2^24` states of the 2x2 torus for `Theta^2`, the dressed reversing identity and the one-step echo. On the same complete state space it constructs one `Theta`-even and one `Theta`-odd observable and verifies the corresponding finite-time correlation reciprocity with nonzero integer sums. The independent Python oracle exercises echo times `0,1,2,3,7` on larger tori. The all-time statement itself follows algebraically from the one-step reversor and is not inferred from finite enumeration.

## 9. Transport-circle corollary, kernel theorem, and open problem

A separate continuum-facing result is documented in `docs/TRANSPORT_CIRCLE.md`. Rewriting the 2026 chiral-FHP Boltzmann viscosity formulae with `eta_bar=eta+1/8`, `D=rho(1-rho/6)^3`, `A=1/(2D)` and `u=(2sqrt(3)/3)(p-1/2)` gives

`eta_bar=A/(1+u^2)`, `eta_H=-Au/(1+u^2)`,

and hence

`(eta+1/8-A/2)^2 + eta_H^2 = (A/2)^2`.

The corresponding complex quantity satisfies `eta_bar+i eta_H=-1/[4 conjugate(lambda)]`, so the circle is the inversion image of the shear-eigenvalue line. The weak-field formula maps the circle by multiplication with `1/(1+iB/2)`. `tests/test_transport_circle.py` checks the zero-field circle, spectral identity and weak-field circle exactly over 3,575 rational parameter triples in `Q(sqrt(3))`. These coefficient formulae are from Allocca et al. (arXiv:2606.19431); their physics is not presented as an HX89 discovery.

The new algebraic sharpening is independent of that parameterization. For any real two-dimensional shear kernel commuting with `C6`, write `M=aI+bJ`, `J^2=-I`. If, at fixed density and fixed scale/scheme, `Z=K/(a+ib)` with `K` independent of chirality, and `a_*=a(1/2)`, then

`|Z|^2 - (K/a_*) Re Z = K^2(a_*-a)/[a_*(a^2+b^2)]`.

Thus reactive/odd drift cannot create the anchored-circle defect. Inside this family, the circle holds exactly iff `a(p)=a_*`. That equivalence is proved; the physical equality is not.

`C6` and parity only force `a(p)=a(1-p)` and `b(p)=-b(1-p)`. They permit a quadratic dissipative drift. The missing physics theorem would have to supply an additional Ward identity, hidden symmetry, conservation law, exact decoupling or RG constraint that keeps the dissipative-flat manifold invariant.

Two implementation boundaries are explicit. First, the C gas implements only deterministic `chi=+1/-1`; it contains no continuous stochastic `p`. Second, two-dimensional FHP fluids have known long-time tails, so a correlated transport statement must specify finite size/time or a running/renormalized Green-Kubo prescription. No result in this repository proves the correlation-renormalized physical circle.
