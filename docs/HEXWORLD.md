# HX87 Hexworld architecture

HX89 separates the physical host from the semantic machine. It retains a snapshot-persistent, invertible finite phase law when explicitly selected; the legacy law remains the default. Target-guided Q² search uses a finite-torus metric and snapshot-persistent objective.

```text
             PHYSICAL MACHINE
                   |
          microscopic host capsule
                   |
                   v
+------------------------------------------+
|             HX87 HEXWORLD               |
|                                          |
|  Polyforms ---> Hyperpool                |
|       |          |                       |
|       |      Conway No                   |
|       |      Q^2 25-state                |
|       |      5D topology                 |
|       |      mutation epochs             |
|       |      entropy                     |
|       v          v                       |
|       execution frontier                 |
|              |                           |
|       HX87 semantic machine              |
|              |                           |
|        native accelerator                |
+--------------+---------------------------+
               |
               v
              CPU
```

The persisted region between `state_begin` and `state_end` is Hexworld state: cells, heads, Q^2 state, Conway nodes, entropy, framebuffer, mutation epochs, snapshots and native-facet source bytes. Transient generated machine code is intentionally allocated outside that region and is never serialized.

## Semantic authority

The HX0-produced `HX87SEM3` image is verified at Hexworld entry. It defines Q^2 constants, opcode count and opcode-to-primitive binding. A run does not begin unless the image has the expected five-state base, 25 Q^2 states and the complete 39-opcode map.

Every retired cell advances `hexworld_epoch`. The epoch is persisted, so snapshot/resume preserves the machine's mutation history rather than restarting a logical clock.

## Native acceleration

`NATIVE_ACCEL` does not turn the Polyform file buffer into executable memory. It consumes HX87-native IR cells from the 5D field, lowers them into a temporary host realization, changes the page from RW to RX, executes it, removes execute permission, unmaps it and returns the result to Hexworld as an exact surreal integer.

The IR remains the source of truth. The generated host bytes are an optimization artifact.

This makes code/data duality a property of HX87 while leaving physical page permissions to the physical machine.

## RIP-MIRROR

RIP-MIRROR has two simultaneous observations:

1. a temporary five-dimensional head reverses all five direction components and reads the live, already-mutated HX87 cell one step behind the executing head;
2. the physical x86-64 RIP is projected into five hexadecimal lanes for observation.

The physical RIP is never redirected by the mirror. The mirror changes HX87 state, not host control-flow integrity.
