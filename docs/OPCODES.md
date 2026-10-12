# HX89 opcodes

The numeric opcode is first mapped through the HX0-generated `HX87SEM3` semantic image. Every retiring cell then undergoes the selected Q² phase evolution and mandatory opcode mutation. The default is the legacy recurrence; `--phase-forward` and `--phase-reverse` choose the exact inverse pair documented in `PHASE_TORUS.md`.

| op | name | action |
|---:|---|---|
| 0 | HALT | kill current head |
| 1 | EMIT | output low byte of `a` |
| 2 | DIR | zero direction, set axis `a` to signed step `b` |
| 3 | FORK | clone head; child starts one step along axis `a`, step `b` |
| 4 | SINT | push exact surreal integer `a` |
| 5 | SDYAD | push exact dyadic `a/2^b` |
| 6 | SOMEGA | push symbolic lazy `omega` |
| 7 | SNEG | symbolic negation |
| 8 | SADD | symbolic addition |
| 9 | SCUT | validated binary Conway cut |
| 10 | SPRINT | print symbolic surreal expression |
| 11 | QSET | set Q^2 state from base-5 digits `(a,b)` |
| 12 | ENTROPY | choose one of ten signed 5D directions |
| 13 | MUTNEXT | mutate the next addressed cell |
| 14 | COLLAPSE | kill all heads except current |
| 15 | PIX | write RGB `a` at current X/Y modulo 64 |
| 16 | CLEAR | clear framebuffer to RGB `a` |
| 17 | FRAME | write `frame.ppm` |
| 18 | SAVE | save post-retirement executable state |
| 19 | DUMP | emit canonical live Polyform to `hx87.regen` |
| 20 | NOP | explicit no-op; still evolves/mutates on retirement |
| 21 | MOVE | add `b` to coordinate axis `a` immediately |
| 22 | GETCHAR | read one host byte and push exact surreal integer |
| 23 | IFZERO_DIR | if top finite surreal is zero, set direction |
| 24 | HASH | print canonical live-state hash |
| 25 | NOP25 | inert Q^2 phase primitive |
| 26 | RIPMIRROR | reverse-probe live 5D code and mirror observed Q^2; also expose five RIP hex lanes |
| 27 | NATIVE | validated legacy `NATIVE_RAW` register-only x86-64 facet |
| 28 | QPIX | project Q^2 plus 5D coordinate state to framebuffer |
| 29 | QTRACE | print the selected phase transition (`Q2` in legacy mode, `PHASE` in either reversible mode) |
| 30 | SMUL | construct symbolic surreal multiplication node |
| 31 | SRECIP | construct symbolic surreal reciprocal node |
| 32 | SOMEGAPOW | construct symbolic `omega^(x)` node |
| 33 | NATIVE_ACCEL | consume following HX87 IR cells and execute a transient native realization |
| 34 | NIMM | accelerator IR: `eax := imm32` |
| 35 | NADD | accelerator IR: `eax := eax + imm32` |
| 36 | NXOR | accelerator IR: `eax := eax xor imm32` |
| 37 | NMUL | accelerator IR: `eax := eax * imm32` |
| 38 | HEXSTAT | print current Hexworld epoch/state summary |

Opcodes 34-37 are semantic IR and are only valid when consumed by `NATIVE_ACCEL`. Direct execution kills the current head rather than silently treating native IR as ordinary HX87 instructions.
