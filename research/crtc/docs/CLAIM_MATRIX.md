# Claim matrix

| Claim | Status | Executable evidence / limitation |
|---|---|---|
| The anchored response circle is equivalent to `Re(1/Z)=Re(1/Z0)` | **Proved exactly** | `geometry.py`, `test_rigidity.py` |
| For `Z=1/(a+i b)`, the defect is `(a0-a)/(a0(a^2+b^2))` | **Proved exactly** | symbolic unit test + exact report |
| C6 covariance of the 2D shear doublet implies `aI+bJ` | **Proved exactly** | symbolic commutant rank/solver |
| C6 forces `a` to be chirality independent | **False** | arbitrary even `a(d)` is symmetry-allowed; counterexample |
| Rigid `a` gives the anchored circle for arbitrary `b` | **Proved exactly** | defect identity |
| Quadratic drift changes achiral response curvature | **Proved exactly** | `kappa(0)=-2a0-a0^2 a''(0)/b'(0)^2` |
| Achiral curvature alone decides global CRTC membership | **False** | quartic-drift test has rigid local curvature but leaves circle |
| Any constant-curvature response is CRTC | **False** | explicit different-circle test |
| Published chiral-FHP molecular-chaos coefficients lie on the circle | **Proved from published equations and independent local-rule enumeration** | 64-state derivation + symbolic identity + 9,595 exact rational points |
| CRTC survives the fully correlated chiral-FHP Green--Kubo problem | **Open** | requires additional microscopic/RG identity or exact correlated response |
| C6 + reflection + positive dissipation protect CRTC | **False** | exact stable OU Green--Kubo counterexample |
| There is a nonempty rigid positive-dissipation Green--Kubo class | **Yes** | OU model with `a(d)=a0` |
| There is a nonempty non-rigid positive-dissipation Green--Kubo class | **Yes** | OU model with `a(d)=a0+eps d^2` |
| Membership is decidable from an identified 2D reduced shear spectrum with known normalization/residue | **Yes** | `q_±=a±ib`; finite exact spectral test |
| Membership is decidable from a bare unordered full microscopic spectrum | **False in general** | exact same-spectrum/different-resolvent witness |
| The defect identity is already a Ward identity | **Not established** | no symmetry/conservation law has yet been shown to enforce rigidity |
| The theorem requires a chirality-independent prefactor `A` | **No** | primary theorem uses measured `Q=1/Z`; prefactor drift test |
| The arithmetic monitor repairs physics until CRTC passes | **False by construction** | it changes precision only and preserves coefficients/equations |
