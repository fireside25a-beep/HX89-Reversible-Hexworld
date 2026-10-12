from __future__ import annotations
import sympy as sp


def rigidity_gap(a_expr, d):
    return sp.simplify(a_expr-a_expr.subs(d,0))


def beta_gap(beta_a_expr, d):
    return sp.simplify(beta_a_expr-beta_a_expr.subs(d,0))


def tangent_to_rigid_manifold(beta_a_expr, d):
    return sp.simplify(beta_gap(beta_a_expr,d)) == 0
