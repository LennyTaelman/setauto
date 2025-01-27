import Mathlib.Tactic.Tauto
import Mathlib.Data.Set.Basic
import Mathlib.Data.Set.SymmDiff

/-
  This file defines a `tauto_set` tactic and runs a number of tests against it

  This should prove any tautology involving hypotheses and goals of the form
  X ⊆ Y or X = Y, where X, Y are expressions built using ∪, ∩, \, and ᶜ from
  finitely many variables of type Set α. It also unfolds expressions of the form
  Disjoint A B and symmDiff A B.

  Does not deal with strict subsets, as these reduce to statements with an
  existential quantifier.

  See the test examples below for an overview of the scope.
-/

open Lean Elab.Tactic

/-
  The `specialize_all` tactic is a simple tactic that loops over
  all hypotheses in the local context.

  Usage: `specialize_all x`, where `x` is a term. Equivalent to running
  `specialize h x` for all hypotheses `h` where this tactic succeeds.
-/

elab (name := specialize_all) "specialize_all" x:term : tactic => withMainContext do
  for h in ← getLCtx do
    evalTactic (← `(tactic|specialize $(mkIdent h.userName) $x)) <|> pure ()


macro "tauto_set" : tactic => `(tactic|
  · simp_all only [
      Set.diff_eq, Set.disjoint_iff, Set.symmDiff_def,
      Set.ext_iff, Set.subset_def,
      Set.mem_union, Set.mem_compl_iff, Set.mem_inter_iff
    ]
    try intro x
    try specialize_all x
    <;> tauto
)


-- test examples

variable {α : Type} (A B C D E : Set α)


example (h : B ∪ C ⊆ A ∪ A) : B ⊆ A := by tauto_set

example (h: B ∩ B ∩ C ⊇ A) : A ⊆ B := by tauto_set

example (h1 : A ⊆ B ∪ C) (h2 : C ⊆ D): A ⊆ B ∪ D := by tauto_set

example (h1 : A = Aᶜ) : B = ∅ := by tauto_set

example (h1 : A = Aᶜ) : B = C := by tauto_set

example (h1 : A ⊆ Aᶜ \ B) : A = ∅ := by tauto_set

example (h : Set.univ ⊆ ((A ∪ B) ∩ C) ∩ ((Aᶜ ∩ Bᶜ) ∪ Cᶜ)) : D \ B ⊆ E ∩ Aᶜ := by tauto_set

example (h : A ∩ B ⊆ C) (h2 : C ∩ D ⊆ E) : A ∩ B ∩ D ⊆ E := by tauto_set

example (h : E = Aᶜᶜ ∩ Cᶜᶜᶜ ∩ D) : D ∩ (B ∪ Cᶜ) ∩ A = E ∪ (A ∩ Dᶜᶜ ∩ B)ᶜᶜ := by tauto_set

example (h : E ⊇ Aᶜᶜ ∩ Cᶜᶜᶜ ∩ D) : D ∩ (B ∪ Cᶜ) ∩ A ⊆  E ∪ (A ∩ Dᶜᶜ ∩ B)ᶜᶜ := by tauto_set

example (h1 : A = B) : A = B := by tauto_set

example (h1 : A = B) (h2 : B ⊆ C): A ⊆ C := by tauto_set

example (h1 : A ⊆ B \ C) : A ⊆ B := by tauto_set

example (h1 : A ∩ B = Set.univ) : A = Set.univ := by tauto_set

example (h1 : A ∪ B = ∅) : A = ∅ := by tauto_set

example (h1 : Aᶜ ⊆ ∅) : A = Set.univ := by tauto_set

example (h1: Set.univ ⊆ Aᶜ) : A = ∅ := by tauto_set

example : A ∩ ∅ = ∅ := by tauto_set

example : A ∪ Set.univ = Set.univ := by tauto_set

example : A ⊆ Set.univ := by tauto_set

example (h1 : A ⊆ B) (h2: B ⊆ A) : A = B := by tauto_set

example : A ∪ (B ∩ C) = (A ∪ B) ∩ (A ∪ C) := by tauto_set

example : A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C) := by tauto_set

example : A ⊆ (A ∪ B) ∪ C := by tauto_set

example : A ∩ (B ∪ C) ⊆ (A ∩ B) ∪ (A ∩ C) := by tauto_set

example : A ∩ B ⊆ A := by tauto_set

example : A ⊆ A ∪ B := by tauto_set

example (h1 : Set.univ ⊆ A) : A = Set.univ := by tauto_set

example (h1 : B ⊆ A) (h2 : Set.univ ⊆ B): Set.univ = A := by tauto_set

example (h1 : A ⊆ B) (h2 : C ⊆ D) : C \ B ⊆ D \ A := by tauto_set

example (h : A ⊆ B ∧ C ⊆ D) : C \ B ⊆ D \ A := by tauto_set

example (h1 : Disjoint A B) (h2 : C ⊆ A) : Disjoint C (B \ D) := by tauto_set

example : Aᶜᶜᶜ = Aᶜ := by tauto_set

example : A ⊆ Set.univ := by tauto_set

example : ∅ ⊆ A := by tauto_set

example (hA : A ⊆ ∅) : A = ∅ := by tauto_set

example : Aᶜᶜ = A := by tauto_set

example (hAB : A ⊆ B) (hBC : B ⊆ C) : A ⊆ C := by tauto_set

example : (Aᶜ ∪ B ∪ C)ᶜ = Cᶜ ∩ Bᶜ ∩ A := by tauto_set

example : (Aᶜ ∩ B ∩ Cᶜᶜ)ᶜᶜᶜᶜᶜ = Cᶜ ∪ Bᶜ ∪ ∅ ∪ A ∪ ∅ := by tauto_set

example : D ∩ (B ∪ Cᶜ) ∩ A = (Aᶜᶜ ∩ Cᶜᶜᶜ ∩ D) ∪ (A ∩ Dᶜᶜ ∩ B)ᶜᶜ := by tauto_set

example (h1 : A ⊆ B) (h2 : B ⊆ C) (h3 : C ⊆ D) (h4 : D = E) (h5 : E ⊆ A) :
  (Aᶜ ∩ B ∪ (C ∩ Bᶜ)ᶜ ∩ (Eᶜ ∪ A))ᶜ ∩ (B ∪ Eᶜᶜ)ᶜ =
  (Dᶜ ∩ C ∪ (B ∩ Aᶜ)ᶜ ∩ (Eᶜ ∪ E))ᶜ ∩ (D ∪ Cᶜᶜ)ᶜ := by tauto_set

example (h1 : Set.univ ⊆ A) (h2 : A ⊆ ∅) :
  (Aᶜ ∩ B ∩ Cᶜᶜ)ᶜᶜᶜ = (Aᶜ ∩ B ∪ (C ∩ Dᶜ)ᶜ ∩ (Eᶜ ∪ A))ᶜ ∩ (B ∪ Eᶜᶜ)ᶜ := by tauto_set

example (h1 : A ⊆ B) (h2 : A ⊆ C) (h3 : B ⊆ D) (h4 : C ⊆ D) (h5 : A = D) :
  Bᶜ = Cᶜ := by tauto_set


-- examples from https://github.com/Ivan-Sergeyev/seymour/blob/d8fcfa23336efe50b09fa0939e8a4ec3a5601ae9/Seymour/ForMathlib/SetTheory.lean
-- filtering out those that are not within scope

lemma setminus_inter_union_eq_union {X Y : Set α} : X \ (X ∩ Y) ∪ Y = X ∪ Y := by tauto_set

lemma sub_parts_eq {A E₁ E₂ : Set α} (hA : A ⊆ E₁ ∪ E₂) : (A ∩ E₁) ∪ (A ∩ E₂) = A := by tauto_set

lemma elem_notin_set_minus_singleton (a : α) (X : Set α) : a ∉ X \ {a} := by tauto_set

lemma sub_union_diff_sub_union {A B C : Set α} (hA : A ⊆ B \ C) : A ⊆ B := by tauto_set

lemma singleton_inter_subset_left {X Y : Set α} {a : α} (ha : X ∩ Y = {a}) : {a} ⊆ X := by tauto_set

lemma singleton_inter_subset_right {X Y : Set α} {a : α} (ha : X ∩ Y = {a}) : {a} ⊆ Y := by tauto_set

lemma diff_subset_parent {X₁ X₂ E : Set α} (hX₁E : X₁ ⊆ E) : X₁ \ X₂ ⊆ E := by tauto_set

lemma inter_subset_parent_left {X₁ X₂ E : Set α} (hX₁E : X₁ ⊆ E) : X₁ ∩ X₂ ⊆ E := by tauto_set

lemma inter_subset_parent_right {X₁ X₂ E : Set α} (hX₂E : X₂ ⊆ E) : X₁ ∩ X₂ ⊆ E := by tauto_set

lemma inter_subset_union {X₁ X₂ : Set α} : X₁ ∩ X₂ ⊆ X₁ ∪ X₂ := by tauto_set

lemma subset_diff_empty_eq {A B : Set α} (hAB : A ⊆ B) (hBA : B \ A = ∅) : A = B := by tauto_set

lemma Disjoint.ni_of_in {X Y : Set α} {a : α} (hXY : Disjoint X Y) (ha : a ∈ X) :
    a ∉ Y := by tauto_set

lemma disjoint_of_singleton_inter_left_wo {X Y : Set α} {a : α} (hXY : X ∩ Y = {a}) :
    Disjoint (X \ {a}) Y := by tauto_set

lemma disjoint_of_singleton_inter_right_wo {X Y : Set α} {a : α} (hXY : X ∩ Y = {a}) :
    Disjoint X (Y \ {a}) := by tauto_set

lemma disjoint_of_singleton_inter_both_wo {X Y : Set α} {a : α} (hXY : X ∩ Y = {a}) :
    Disjoint (X \ {a}) (Y \ {a}) := by tauto_set

lemma union_subset_union_iff {A B X : Set α} (hAX : Disjoint A X) (hBX : Disjoint B X) :
    A ∪ X ⊆ B ∪ X ↔ A ⊆ B := by
  constructor
  · intro h; tauto_set
  · intro h; tauto_set

lemma symmDiff_eq_alt (X Y : Set α) : symmDiff X Y = (X ∪ Y) \ (X ∩ Y) := by tauto_set

lemma symmDiff_disjoint_inter (X Y : Set α) : Disjoint (symmDiff X Y) (X ∩ Y) := by tauto_set

lemma symmDiff_empty_eq (X : Set α) : symmDiff X ∅ = X := by tauto_set

lemma empty_symmDiff_eq (X : Set α) : symmDiff ∅ X = X := by tauto_set

lemma symmDiff_subset_ground_right {X Y E : Set α} (hE : symmDiff X Y ⊆ E) (hX : X ⊆ E) : Y ⊆ E := by tauto_set

lemma symmDiff_subset_ground_left {X Y E : Set α} (hE : symmDiff X Y ⊆ E) (hX : Y ⊆ E) : X ⊆ E := by tauto_set
