# HX87 machine contract

## Five-dimensional executable space

A live head contains `(x,y,z,w,v)`, signed direction `(dx,dy,dz,dw,dv)`, and an alive flag. Cell lookup compares all five coordinates. `DIR`, `MOVE`, `FORK`, `COLLAPSE`, entropy and RIP-MIRROR act on this actual 5D state; the extra axes are not a renderer trick.

## Q²: 25-state quinary-squared execution

Each cell carries `q = 5*qa + qb`, where `qa,qb in {0,1,2,3,4}`. Retirement computes:

```text
qa' = (qa + qb + 1) mod 5
qb' = (qb + qa + opcode) mod 5
q'  = 5*qa' + qb'
```

The constants are read from the HX0-generated `HX87SEM3` semantic image. `QTRACE` exposes the transition and `QPIX` projects the phase state into the framebuffer.

`--phase-forward` and `--phase-reverse` select an exact finite torus permutation instead of the default retirement formula. The mode is stored in snapshots. See [PHASE_TORUS.md](PHASE_TORUS.md) for the equations and exhaustive verification.

HX89 provides `--target-q N` for `N` from 0 to 24. Each retired cell is compared with the target using cyclic L1 distance on the two base-five digits. Strict improvements are traced; exact equality prints `TARGET_HIT` and ends the run. `ENTROPY` can supply a seeded spatial walk through the actual Polyform while this objective evaluates visited cells. The objective, best score and hit status are serialized in the current snapshot format.

## Mandatory self-modification

After the selected phase evolution, the retiring cell mutates its opcode:

```text
op' = (op + q' + 1) mod opcode_count
```

`MUTNEXT` additionally mutates the next addressed cell before it executes. Program text is therefore live machine state.

## Execution frontier

`FORK` creates another head with an independent 5D direction. The child begins at its first child coordinate so it never re-executes the already-retired/mutated parent `FORK` cell. Heads are processed in canonical index order. `COLLAPSE` kills every other live head.

## RIP-MIRROR

`RIPMIRROR` captures the physical host instruction location, clones the current HX87 head into a temporary probe, reverses all five direction components (the UNO-reverse step), advances the probe once, and observes the live cell at that reflected coordinate. The probe sees post-retirement mutation from earlier cells. Its observed Q² state is mirrored into the current cell as `q := (state_count-1)-q`. The physical RIP is also projected into five hexadecimal lanes for trace observation. The real head is never redirected.

## Entropy

With an explicit seed, entropy is a replayable xorshift64* stream. Without a seed, the runtime obtains an initial word from the host and then uses the same machine stream. `ENTROPY` records word, axis and sign in the trace.

## Hyperpool / persistence

The persisted Hexworld contains cells, heads, surreal stack/nodes, entropy state, step count, mutation epoch, framebuffer, and any literal `NATIVE_RAW` source payload. `SAVE` snapshots this semantic state to `hx89.state`; `--resume` restores it. The transient `native_codegen` workspace is located after `state_end` and is never serialized.

## Native realization

`NATIVE_ACCEL` consumes HX87-native arithmetic IR cells and lowers them into a disposable RW->RX host capsule. The result returns to Hexworld as an exact surreal integer. `NATIVE_RAW` remains the narrower literal-byte NABI0 experiment. See `NATIVE_BRIDGE.md` and `HEXWORLD.md`.
