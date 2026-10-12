import Lake
open Lake DSL

package hx89Proofs where

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.30.0"

@[default_target]
lean_lib HX89 where
  roots := #[`HX89.Chiral, `HX89.Transport]
