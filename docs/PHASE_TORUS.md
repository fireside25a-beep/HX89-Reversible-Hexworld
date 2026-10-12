# Reversible finite phase law

HX89 stores each cell's phase as `q = 5a+b`, with `a,b` in the finite field `F₅`. Two optional execution modes replace the **automatic phase update at retirement**. Both run inside the existing Hexworld interpreter, on the same cells, with the same head motion, opcode mutation, persistence and Polyform loader.

| Mode | Arithmetic in `F₅` | Command |
| --- | --- | --- |
| Legacy | `a' = a+b+1`, `b' = b+a+opcode` | `hx89 program.hx 1 100` |
| Forward | `A = a+b`, `B = b+A` | `hx89 --phase-forward program.hx 1 100` |
| Reverse | `b = B-A`, `a = A-b` | `hx89 --phase-reverse program.hx 1 100` |

All operations are modulo five. The forward matrix is `[[1,1],[1,2]]` and its inverse is `[[2,-1],[-1,1]]` modulo five. Its determinant is one, so it permutes all 25 points exactly. This is the finite lattice form of a toral cat map; the 25-state system has periodic orbits, not asymptotic chaos. The optional law applies to the cell's `q`, while other VM transitions (opcode mutation, head movement, I/O, entropy, branching and collapse) retain their existing behavior. **The entire VM is not reversible.**

`QTRACE` prints the predicted next state under the selected law. The actual retirement stores it in the cell. The chosen mode is serialized in the current snapshot image, and the cell-state hash includes the mode when it is enabled. A resumed run restores the recorded mode. The canonical HX0 image, legacy `HX87P1` Polyform bytes, opcode map, offsets, and seed fixed point remain unchanged.

## Verification

`python3 tests/phase_exhaustive.py` starts the assembled HX89 executable on every `F₅²` point in each direction. It checks QTRACE against an independent Python formula, reads the dumped Polyform after retirement, verifies both maps are bijections, and runs forward→reverse and reverse→forward through the executable for every point. `tests/test.sh` additionally checks phase-mode snapshot/resume and the established VM suite. The argument is finite and exhaustive for this 25-state phase law; it is not a proof of unrelated VM behavior.

## Why this law

Arnold's lattice cat map is a studied finite dynamical system; the determinant-one construction makes its inverse explicit. Margolus's reversible cellular automata work motivates separating locally invertible rules from global machine claims. Landauer's original paper concerns physical erasure and heat: a logically reversible phase map by itself does not imply zero-energy hardware. The Computer History Museum's PDP-1 restoration describes human switch entry of a small bootstrap program, illustrating that a two-symbol *alphabet* still needs an ordered program and an instruction receiver. Turing's universal-machine construction similarly distinguishes symbols on a tape from the finite control that interprets them. Entropy alone supplies neither control nor program content.

Primary sources and original project records:

- J. Nance, [*Periods of the discretized Arnold Cat Map and its extension to n dimensions*](https://arxiv.org/abs/1111.2984), 2011.
- N. Margolus, [*Physics-like models of computation*](https://doi.org/10.1016/0167-2789%2884%2990252-5), 1984.
- R. Landauer, [*Irreversibility and Heat Generation in the Computing Process*](https://www.dna.caltech.edu/courses/cs191/paperscs191/landauer1961.pdf), 1961.
- A. M. Turing, [*On Computable Numbers*](https://scholar.archive.org/work/uqkjtz7a3bf2lpohk2fomuvbeu/access/wayback/http%3A//www.cs.virginia.edu/~robins/Turing_Paper_1936.pdf), 1936.
- Computer History Museum, [PDP-1 Restoration Project: Software](https://www.computerhistory.org/pdp-1/software/).
