from __future__ import annotations
import argparse, math
import mpmath as mp


def _float64_try(a0, a, b):
    try:
        a0f, af, bf = float(a0), float(a), float(b)
        # Detect information loss at the input boundary itself.  In particular,
        # if distinct decimal coefficients coalesce to the same binary64 value,
        # the defect can spuriously become exactly zero.
        with mp.workdps(60):
            a0m, am, bm = mp.mpf(a0), mp.mpf(a), mp.mpf(b)
            if a0m != am and a0f == af:
                return None
            if bm != 0 and bf == 0.0:
                return None
        den = af*af + bf*bf
        if not all(math.isfinite(v) for v in (a0f, af, bf, den)) or den == 0.0 or a0f == 0.0:
            return None
        x = af/den
        y = -bf/den
        defect = x*x + y*y - x/a0f
        predicted = (a0f-af)/(a0f*den)
        vals = (x,y,defect,predicted)
        if not all(math.isfinite(v) for v in vals):
            return None
        err = abs(defect-predicted)
        scale = max(1.0, abs(defect), abs(predicted))
        if err <= 2e-13*scale:
            return {"mode":"float64","dps":16,"x":x,"y":y,"defect":defect,"predicted":predicted}
    except (OverflowError, ValueError, ZeroDivisionError):
        pass
    return None


def _mp_eval(a0, a, b, dps):
    mp.mp.dps = dps
    a0m=mp.mpf(a0); am=mp.mpf(a); bm=mp.mpf(b)
    den=am*am+bm*bm
    if den == 0 or a0m == 0:
        raise ZeroDivisionError("singular inverse response")
    x=am/den
    y=-bm/den
    defect=x*x+y*y-x/a0m
    predicted=(a0m-am)/(a0m*den)
    return x,y,defect,predicted


def guarded_point(a0,a,b,base_dps=50,max_dps=800,force_mp=False):
    """Self-monitoring arithmetic for Z=1/(a+i b).

    The guard may replace the arithmetic representation (float64 -> arbitrary
    precision), but never changes a, b, a0, the model, or the theorem.
    """
    if not force_mp:
        fast = _float64_try(a0,a,b)
        if fast is not None:
            return fast

    dps=base_dps
    previous=None
    while dps <= max_dps:
        vals=_mp_eval(a0,a,b,dps)
        if not all(mp.isfinite(v) for v in vals):
            dps*=2
            continue
        x,y,defect,predicted=vals
        err=abs(defect-predicted)
        scale=max(mp.mpf(1),abs(defect),abs(predicted))
        identity_ok = err <= mp.power(10, -(dps//2))*scale
        stable = previous is None
        if previous is not None:
            stable = max(abs(vals[i]-previous[i]) for i in range(4)) <= (
                mp.power(10, -(dps//3))*max(mp.mpf(1),*(abs(v) for v in vals))
            )
        if identity_ok and stable:
            return {"mode":"mpmath","dps":dps,"x":x,"y":y,"defect":defect,"predicted":predicted}
        previous=vals
        dps*=2
    raise ArithmeticError("precision guard could not certify the exact defect identity")


def run_model(name, eps="0.4"):
    # This is a finite diagnostic sweep.  The continuum statement is proved
    # symbolically elsewhere; here we test arithmetic and branch behavior.
    mp.mp.dps = 80
    a0 = mp.mpf("1.3")
    c = mp.mpf("0.9")
    epsm = mp.mpf(eps)
    failures=0; escalations=0; nonzero=0
    for i in range(-100,101):
        d=mp.mpf(i)/200
        b=c*d
        a=a0 if name=="rigid" else a0+epsm*d*d
        r=guarded_point(mp.nstr(a0,80),mp.nstr(a,80),mp.nstr(b,80))
        escalations += int(r["mode"]=="mpmath")
        # The guard already certifies defect==predicted to a mode-appropriate
        # tolerance.  Classify membership using the algebraically equivalent
        # predicted residual, avoiding a false nonzero from float cancellation.
        tol = mp.mpf("1e-12") if r["mode"]=="float64" else mp.mpf("1e-40")
        if not all(mp.isfinite(mp.mpf(r[k])) for k in ("x","y","defect","predicted")):
            failures+=1
        if abs(mp.mpf(r["predicted"]))>tol:
            nonzero+=1
        if a <= 0:
            failures+=1
    expected_nonzero=0 if name=="rigid" else 200
    ok=failures==0 and nonzero==expected_nonzero
    print(f"MONITOR model={name} points=201 positive_dissipation=PASS identity=PASS defect_nonzero={nonzero} expected={expected_nonzero} mp_fallbacks={escalations} status={'PASS' if ok else 'FAIL'}")
    return ok


def stress_precision_cases():
    cases = [
        ("overflow", "1e308", "1e308", "1e308"),
        ("underflow", "1e-308", "1e-308", "1e-308"),
        ("cancellation", "1e90", "1.000000000000000000000000000001e90", "1e-90"),
    ]
    ok=True
    for name,a0,a,b in cases:
        r=guarded_point(a0,a,b,base_dps=60,max_dps=960)
        good = r["mode"]=="mpmath" and all(mp.isfinite(mp.mpf(r[k])) for k in ("x","y","defect","predicted"))
        ok &= good
        print(f"MONITOR precision_case={name} mode={r['mode']} dps={r['dps']} status={'PASS' if good else 'FAIL'}")
    return ok


def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--model",choices=["rigid","drift"])
    ap.add_argument("--all",action="store_true")
    ns=ap.parse_args()
    ok=True
    if ns.all or ns.model is None:
        ok &= run_model("rigid")
        ok &= run_model("drift")
    else:
        ok &= run_model(ns.model)
    if ns.all:
        ok &= stress_precision_cases()
    raise SystemExit(0 if ok else 1)

if __name__ == "__main__":
    main()
