#!/usr/bin/env python3
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt
HERE=Path(__file__).resolve().parents[1]
FIG=HERE/'figures'; FIG.mkdir(exist_ok=True)

# Figure 1: exact FHP Boltzmann response arc at rho=3.
rho=3.0; D=rho*(1-rho/6.0)**3; A=1/(2*D)
p=np.linspace(0,1,1001); d=p-.5; u=2*np.sqrt(3)/3*d
x=A/(1+u*u); y=-A*u/(1+u*u)
th=np.linspace(0,2*np.pi,600)
fig,ax=plt.subplots(figsize=(5.6,4.4))
ax.plot(A/2+(A/2)*np.cos(th),(A/2)*np.sin(th),linewidth=1.0,label='anchored circle')
ax.plot(x,y,linewidth=2.0,label='published kinetic arc')
ax.set_xlabel(r'$\bar\eta$'); ax.set_ylabel(r'$\eta_H$'); ax.set_aspect('equal',adjustable='box')
ax.legend(frameon=False); ax.grid(True,linewidth=.3,alpha=.4); fig.tight_layout()
fig.savefig(FIG/'fhp_transport_circle.pdf'); fig.savefig(FIG/'fhp_transport_circle.png',dpi=180); plt.close(fig)

# Figure 2: exact OU defect on the test domain.
a0=1.5; eps=.4; c=.9
d=np.linspace(-.5,.5,1001); a=a0+eps*d*d; b=c*d
defect=(a0-a)/(a0*(a*a+b*b))
fig,ax=plt.subplots(figsize=(5.8,3.8))
ax.plot(d,defect,linewidth=2.0)
ax.axhline(0,linewidth=.7)
ax.set_xlabel(r'$d$'); ax.set_ylabel(r'$\Delta(d)$')
ax.grid(True,linewidth=.3,alpha=.4); fig.tight_layout()
fig.savefig(FIG/'ou_counterexample_defect.pdf'); fig.savefig(FIG/'ou_counterexample_defect.png',dpi=180); plt.close(fig)

# Figure 3: inversion geometry. Vertical inverse-response locus -> circle.
b=np.linspace(-4,4,1201); a0=1.0; z=1/(a0+1j*b)
fig,ax=plt.subplots(figsize=(5.6,4.4))
ax.plot(z.real,z.imag,linewidth=2.0,label=r'$Z=1/(a_0+i b)$')
ax.scatter([1/a0],[0],s=24,label='achiral anchor')
ax.set_xlabel(r'$\mathrm{Re}\,Z$'); ax.set_ylabel(r'$\mathrm{Im}\,Z$'); ax.set_aspect('equal',adjustable='box')
ax.legend(frameon=False); ax.grid(True,linewidth=.3,alpha=.4); fig.tight_layout()
fig.savefig(FIG/'inverse_response_geometry.pdf'); fig.savefig(FIG/'inverse_response_geometry.png',dpi=180); plt.close(fig)
print('PASS: analytic figures regenerated from stated equations')
