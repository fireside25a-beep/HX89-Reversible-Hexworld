import Mathlib.Data.Complex.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Analysis.Calculus.MeanValue

/-!
# Algebraic transport classification

This module is separate from `HX89.Chiral`. It proves the real two-dimensional
commutant calculation and the conditional kernel defect identity. No theorem
here derives a correlated Green–Kubo response from the HX89 gas.
-/

namespace HX89.Transport

structure Mat2 where
  xx : ℝ
  xy : ℝ
  yx : ℝ
  yy : ℝ

@[ext] theorem Mat2.ext (A B : Mat2)
    (hxx : A.xx = B.xx) (hxy : A.xy = B.xy)
    (hyx : A.yx = B.yx) (hyy : A.yy = B.yy) : A = B := by
  cases A
  cases B
  simp_all

def mul (A B : Mat2) : Mat2 :=
  ⟨A.xx * B.xx + A.xy * B.yx, A.xx * B.xy + A.xy * B.yy,
   A.yx * B.xx + A.yy * B.yx, A.yx * B.xy + A.yy * B.yy⟩

def rotation (u v : ℝ) : Mat2 := ⟨u, -v, v, u⟩
def normal (a b : ℝ) : Mat2 := ⟨a, -b, b, a⟩

/-- A nontrivial planar rotation has precisely the `a I + b J` commutant.
The physical shear representation of a C₆ generator is one such rotation;
its off-diagonal sine `v` is nonzero. -/
theorem commutant_normal (X : Mat2) (u v : ℝ) (hv : v ≠ 0)
    (h : mul X (rotation u v) = mul (rotation u v) X) :
    X = normal X.xx X.yx := by
  have hxx := congrArg Mat2.xx h
  have hxy := congrArg Mat2.xy h
  dsimp [mul, rotation] at hxx hxy
  have hs : v * (X.xy + X.yx) = 0 := by nlinarith [hxx]
  have hd : v * (X.yy - X.xx) = 0 := by nlinarith [hxy]
  have hs' : X.xy + X.yx = 0 := (mul_eq_zero.mp hs).resolve_left hv
  have hd' : X.yy - X.xx = 0 := (mul_eq_zero.mp hd).resolve_left hv
  apply Mat2.ext
  · rfl
  · dsimp [normal]; linarith
  · rfl
  · dsimp [normal]; linarith

theorem normal_commutes (a b u v : ℝ) :
    mul (normal a b) (rotation u v) = mul (rotation u v) (normal a b) := by
  ext <;> simp [mul, normal, rotation] <;> ring

noncomputable def response (a b K : ℝ) : ℂ := (K : ℂ) / ⟨a, b⟩
noncomputable def defect (a b K anchor : ℝ) : ℝ :=
  Complex.normSq (response a b K) - (K / anchor) * (response a b K).re

/-- The denominators are explicit: `anchor ≠ 0` and `a²+b² ≠ 0`.
The complex `normSq` is the squared modulus `|Z|²`. -/
theorem kernel_defect (a b K anchor : ℝ) (ha : anchor ≠ 0)
    (hd : a ^ 2 + b ^ 2 ≠ 0) :
    defect a b K anchor = K ^ 2 * (anchor - a) / (anchor * (a ^ 2 + b ^ 2)) := by
  have hnorm : Complex.normSq (response a b K) = K ^ 2 / (a ^ 2 + b ^ 2) := by
    simp [response, Complex.normSq_mk, pow_two]
  have hre : (response a b K).re = K * a / (a ^ 2 + b ^ 2) := by
    simp [response, Complex.div_re, Complex.normSq_mk, pow_two]
  rw [defect, hnorm, hre]
  field_simp

/-- For nonzero `K`, vanishing defect is exactly dissipative flatness. -/
theorem defect_zero_iff (a b K anchor : ℝ) (ha : anchor ≠ 0)
    (hd : a ^ 2 + b ^ 2 ≠ 0) (hK : K ≠ 0) :
    defect a b K anchor = 0 ↔ a = anchor := by
  rw [kernel_defect a b K anchor ha hd]
  constructor
  · intro h
    have hn : K ^ 2 * (anchor - a) = 0 := (div_eq_zero_iff).mp h |>.resolve_right (mul_ne_zero ha hd)
    have : anchor - a = 0 := (mul_eq_zero.mp hn).resolve_left (pow_ne_zero 2 hK)
    linarith
  · intro h
    simp [h]

/-- A mathematically stated open target, parameterized by a *specified* response
family. This is a definition, not a proof about a physical FHP model. -/
def DissipativeFlatness {P : Type*} (a : P → ℝ → ℝ) (anchor : P) : Prop :=
  ∀ p ell, a p ell = a anchor ell

noncomputable def betaDefect {P : Type*} (a : P → ℝ → ℝ) (anchor p : P) (ell : ℝ) : ℝ :=
  deriv (a p) ell - deriv (a anchor) ell

/-- Local tangency of the flat manifold is exactly equality of the two beta
functions at the specified scale. This does not assert that the microscopic
dynamics supplies that equality. -/
theorem tangent_iff {P : Type*} (a : P → ℝ → ℝ) (anchor p : P) (ell : ℝ)
    (hp : DifferentiableAt ℝ (a p) ell)
    (hanchor : DifferentiableAt ℝ (a anchor) ell) :
    deriv (fun t => a p t - a anchor t) ell = 0 ↔
      betaDefect a anchor p ell = 0 := by
  change deriv (a p - a anchor) ell = 0 ↔ _
  rw [deriv_sub hp hanchor]
  rfl

/-- Equality of beta functions at every scale preserves an initially flat
family, provided every scale trajectory is differentiable. -/
theorem flatness_of_beta {P : Type*} (a : P → ℝ → ℝ) (anchor : P) (ell₀ : ℝ)
    (hdiff : ∀ p, Differentiable ℝ (a p))
    (hinit : ∀ p, a p ell₀ = a anchor ell₀)
    (hbeta : ∀ p ell, betaDefect a anchor p ell = 0) :
    DissipativeFlatness a anchor := by
  intro p ell
  have heq : ∀ x, deriv (a p) x = deriv (a anchor) x := by
    intro x
    have h := hbeta p x
    dsimp [betaDefect] at h
    linarith
  have hf : Differentiable ℝ (fun x => a p x - a anchor x) :=
    (hdiff p).sub (hdiff anchor)
  have hzero : ∀ x, deriv (fun t => a p t - a anchor t) x = 0 := by
    intro x
    change deriv (a p - a anchor) x = 0
    rw [deriv_sub (hdiff p x) (hdiff anchor x)]
    linarith [heq x]
  have hc := is_const_of_deriv_eq_zero hf hzero ell ell₀
  linarith [hinit p]

/-- Flatness itself implies equal beta functions under differentiability.
This is a mathematical flow criterion, not an RG derivation from the gas. -/
theorem beta_of_flatness {P : Type*} (a : P → ℝ → ℝ) (anchor : P)
    (h : DissipativeFlatness a anchor) :
    ∀ p ell, betaDefect a anchor p ell = 0 := by
  intro p ell
  have heq : a p = a anchor := funext (fun x => h p x)
  simp [betaDefect, heq]

theorem flatness_iff_beta {P : Type*} (a : P → ℝ → ℝ) (anchor : P) (ell₀ : ℝ)
    (hdiff : ∀ p, Differentiable ℝ (a p))
    (hinit : ∀ p, a p ell₀ = a anchor ell₀) :
    DissipativeFlatness a anchor ↔ ∀ p ell, betaDefect a anchor p ell = 0 :=
  ⟨beta_of_flatness a anchor, flatness_of_beta a anchor ell₀ hdiff hinit⟩

/-- A positive parity-even dissipative function need not be flat. -/
noncomputable def parityCounterexample (p : ℝ) : ℝ := 1 + (p - 1 / 2) ^ 2

theorem parityCounterexample_even (p : ℝ) :
    parityCounterexample (1 - p) = parityCounterexample p := by
  unfold parityCounterexample
  ring

theorem parityCounterexample_positive (p : ℝ) : 0 < parityCounterexample p := by
  unfold parityCounterexample
  nlinarith [sq_nonneg (p - 1 / 2)]

theorem parityCounterexample_not_flat :
    parityCounterexample 0 ≠ parityCounterexample (1 / 2) := by
  norm_num [parityCounterexample]

/-- With odd reactive part `b = 0` and `K = 1`, the same parity-symmetric
positive family fails the anchored circle at `p = 0`. -/
theorem parityCounterexample_defect_nonzero :
    defect (parityCounterexample 0) 0 1 (parityCounterexample (1 / 2)) ≠ 0 := by
  intro h
  have ha : parityCounterexample (1 / 2) ≠ 0 := by
    norm_num [parityCounterexample]
  have hd : (parityCounterexample 0) ^ 2 + (0 : ℝ) ^ 2 ≠ 0 := by
    norm_num [parityCounterexample]
  have hf := (defect_zero_iff (parityCounterexample 0) 0 1
    (parityCounterexample (1 / 2)) ha hd (by norm_num)).mp h
  exact parityCounterexample_not_flat hf

end HX89.Transport
