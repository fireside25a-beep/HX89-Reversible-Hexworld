#!/usr/bin/env python3
"""Lock thesis equations to their source bodies and compiled LaTeX numbers.

The registry is intentionally mechanical. It does not prove the equations; that is
handled by independent_math_audit.py and the executable CRTC/HX89 suites. It
prevents a verified equation from silently drifting in symbol, sign, coefficient,
or document numbering after the scientific checks have passed.
"""
from __future__ import annotations
import argparse, hashlib, json, re
from pathlib import Path

THESIS = Path(__file__).resolve().parents[1]
REGISTRY = THESIS / "generated" / "equation_registry.json"
SOURCE_FILES = sorted((THESIS / "chapters").glob("*.tex")) + sorted((THESIS / "appendices").glob("*.tex"))
AUX = THESIS / "build" / "latex-main" / "main.aux"

EQ_RE = re.compile(r"\\begin\{(equation|align)\*?\}(.*?)\\end\{\1\*?\}", re.S)
LABEL_RE = re.compile(r"\\label\{(eq:[^}]+)\}")
AUX_RE = re.compile(r"\\newlabel\{(eq:[^}]+)\}\{\{([^}]*)\}\{")


def normalize_body(body: str) -> str:
    body = re.sub(r"(?m)(?<!\\)%.*$", "", body)
    body = LABEL_RE.sub("", body)
    body = re.sub(r"\s+", "", body)
    return body


def collect_equations():
    out = {}
    for path in SOURCE_FILES:
        text = path.read_text(encoding="utf-8")
        for match in EQ_RE.finditer(text):
            raw = match.group(2)
            lm = LABEL_RE.search(raw)
            if not lm:
                continue
            label = lm.group(1)
            if label in out:
                raise SystemExit(f"duplicate equation label in registry scan: {label}")
            norm = normalize_body(raw)
            out[label] = {
                "file": str(path.relative_to(THESIS)),
                "sha256": hashlib.sha256(norm.encode("utf-8")).hexdigest(),
            }
    return out


def collect_numbers():
    if not AUX.exists():
        raise SystemExit(f"compiled aux missing: {AUX}; run make thesis first")
    text = AUX.read_text(encoding="utf-8", errors="replace")
    return {m.group(1): m.group(2) for m in AUX_RE.finditer(text) if not m.group(1).endswith("@cref")}


def current_registry():
    equations = collect_equations()
    numbers = collect_numbers()
    missing = sorted(set(equations) - set(numbers))
    extra = sorted(set(numbers) - set(equations))
    if missing:
        raise SystemExit(f"compiled equation labels missing from aux: {missing}")
    if extra:
        raise SystemExit(f"aux contains unknown equation labels: {extra}")
    for label in equations:
        equations[label]["number"] = numbers[label]
    return {
        "schema": 1,
        "equation_count": len(equations),
        "equations": dict(sorted(equations.items())),
    }


def main():
    ap = argparse.ArgumentParser()
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--write", action="store_true")
    g.add_argument("--check", action="store_true")
    ns = ap.parse_args()
    cur = current_registry()
    if ns.write:
        REGISTRY.parent.mkdir(parents=True, exist_ok=True)
        REGISTRY.write_text(json.dumps(cur, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        print(f"PASS: wrote equation registry with {cur['equation_count']} labeled equations")
        return
    if not REGISTRY.exists():
        raise SystemExit("equation registry missing")
    saved = json.loads(REGISTRY.read_text(encoding="utf-8"))
    if saved != cur:
        saved_eq = saved.get("equations", {})
        cur_eq = cur.get("equations", {})
        labels = sorted(set(saved_eq) | set(cur_eq))
        diffs=[]
        for label in labels:
            if saved_eq.get(label) != cur_eq.get(label):
                diffs.append(f"{label}: saved={saved_eq.get(label)} current={cur_eq.get(label)}")
        raise SystemExit("equation registry drift:\n" + "\n".join(diffs[:20]))
    print(f"PASS: equation registry exact; equations={cur['equation_count']} source_hashes=PASS compiled_numbers=PASS")


if __name__ == "__main__":
    main()
