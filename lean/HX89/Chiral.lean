import Lean

/-!
Finite collision table and algebraic lifting for HX89's deterministic endpoint gas.
The separate C certificate checks the concrete toroidal streaming implementation.
This file does not formalize the Polyform VM or the correlated Green–Kubo conjecture.
-/

namespace HX89

abbrev LocalState := Fin 64

def cPlus (s : LocalState) : LocalState :=
  if s == 9 then 18
  else if s == 18 then 36
  else if s == 36 then 9
  else if s == 21 then 42
  else if s == 42 then 21
  else s

def cMinus (s : LocalState) : LocalState :=
  if s == 9 then 36
  else if s == 36 then 18
  else if s == 18 then 9
  else if s == 21 then 42
  else if s == 42 then 21
  else s

def reflect (s : LocalState) : LocalState :=
  Fin.ofNat 64 <|
    (if s.val.testBit 0 then 1 else 0) +
    (if s.val.testBit 1 then 32 else 0) +
    (if s.val.testBit 2 then 16 else 0) +
    (if s.val.testBit 3 then 8 else 0) +
    (if s.val.testBit 4 then 4 else 0) +
    (if s.val.testBit 5 then 2 else 0)

def velocityReverse (s : LocalState) : LocalState :=
  Fin.ofNat 64 <|
    (if s.val.testBit 0 then 8 else 0) +
    (if s.val.testBit 1 then 16 else 0) +
    (if s.val.testBit 2 then 32 else 0) +
    (if s.val.testBit 3 then 1 else 0) +
    (if s.val.testBit 4 then 2 else 0) +
    (if s.val.testBit 5 then 4 else 0)

def occupied (s : LocalState) (channel : Nat) : Int :=
  if s.val.testBit channel then 1 else 0

def particleCount (s : LocalState) : Int :=
  occupied s 0 + occupied s 1 + occupied s 2 +
  occupied s 3 + occupied s 4 + occupied s 5

def momentumX (s : LocalState) : Int :=
  occupied s 0 - occupied s 2 - occupied s 3 + occupied s 5

def momentumY (s : LocalState) : Int :=
  occupied s 1 + occupied s 2 - occupied s 4 - occupied s 5

theorem local_inverse_plus : ∀ s : LocalState, cMinus (cPlus s) = s := by decide
theorem local_inverse_minus : ∀ s : LocalState, cPlus (cMinus s) = s := by decide
theorem plus_conserves_mass :
    ∀ s : LocalState, particleCount (cPlus s) = particleCount s := by decide
theorem minus_conserves_mass :
    ∀ s : LocalState, particleCount (cMinus s) = particleCount s := by decide
theorem plus_conserves_momentum :
    ∀ s : LocalState, momentumX (cPlus s) = momentumX s ∧
      momentumY (cPlus s) = momentumY s := by decide
theorem minus_conserves_momentum :
    ∀ s : LocalState, momentumX (cMinus s) = momentumX s ∧
      momentumY (cMinus s) = momentumY s := by decide
theorem reflect_involution : ∀ s : LocalState, reflect (reflect s) = s := by decide
theorem velocity_involution :
    ∀ s : LocalState, velocityReverse (velocityReverse s) = s := by decide
theorem mirror_chirality :
    ∀ s : LocalState, reflect (cPlus (reflect s)) = cMinus s := by decide
theorem velocity_collision_plus :
    ∀ s : LocalState, velocityReverse (cPlus (velocityReverse s)) = cPlus s := by decide
theorem velocity_collision_minus :
    ∀ s : LocalState, velocityReverse (cMinus (velocityReverse s)) = cMinus s := by decide

/- The global proof is conditional on these exact streaming/index symmetries.
   The checked C program supplies independent finite concrete torus evidence;
   no Lean proof of the concrete torus index arithmetic is claimed. -/
structure EndpointSystem (State : Type) where
  cPlus : State → State
  cMinus : State → State
  stream : State → State
  unstream : State → State
  mirrorVelocity : State → State
  cMinusPlus : ∀ x, cMinus (cPlus x) = x
  cPlusMinus : ∀ x, cPlus (cMinus x) = x
  mirrorInvolution : ∀ x, mirrorVelocity (mirrorVelocity x) = x
  mirrorMinus : ∀ x, mirrorVelocity (cMinus x) = cPlus (mirrorVelocity x)
  mirrorStream : ∀ x, mirrorVelocity (stream x) = unstream (mirrorVelocity x)
  unstreamStream : ∀ x, unstream (stream x) = x

namespace EndpointSystem

variable {State : Type} (m : EndpointSystem State)

def forward (x : State) := m.stream (m.cPlus x)
def backward (x : State) := m.cMinus (m.unstream x)
def theta (x : State) := m.cMinus (m.mirrorVelocity x)

theorem theta_involution (x : State) : m.theta (m.theta x) = x := by
  simp [theta, m.mirrorMinus, m.mirrorInvolution, m.cMinusPlus]

theorem dressed_reversor (x : State) :
    m.theta (m.forward (m.theta x)) = m.backward x := by
  simp [theta, forward, backward, m.cPlusMinus, m.mirrorStream, m.mirrorInvolution]

theorem backward_forward (x : State) : m.backward (m.forward x) = x := by
  simp [backward, forward, m.unstreamStream, m.cMinusPlus]

def iterate (f : State → State) : Nat → State → State
  | 0, x => x
  | n + 1, x => f (iterate f n x)

theorem iterate_succ_right (f : State → State) (n : Nat) (x : State) :
    iterate f (n + 1) x = iterate f n (f x) := by
  induction n with
  | zero => rfl
  | succ n ih =>
    simp only [iterate] at ih ⊢
    rw [ih]

theorem conjugate_iterate (n : Nat) (x : State) :
    m.theta (iterate m.forward n (m.theta x)) = iterate m.backward n x := by
  induction n with
  | zero => simpa [iterate] using m.theta_involution x
  | succ n ih =>
    have commute (y : State) : m.theta (m.forward y) = m.backward (m.theta y) := by
      have h := m.dressed_reversor (m.theta y)
      simpa [m.theta_involution y] using h
    simp only [iterate]
    rw [commute, ih]

theorem iterate_backward_forward (n : Nat) (x : State) :
    iterate m.backward n (iterate m.forward n x) = x := by
  induction n with
  | zero => rfl
  | succ n ih =>
    rw [iterate_succ_right m.backward, iterate]
    rw [m.backward_forward, ih]

theorem echo (n : Nat) (x : State) :
    m.theta (iterate m.forward n (m.theta (iterate m.forward n x))) = x := by
  rw [m.conjugate_iterate]
  exact m.iterate_backward_forward n x

end EndpointSystem
end HX89
