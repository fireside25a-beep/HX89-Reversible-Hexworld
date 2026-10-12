# HX87 self-hosting contract

HX87 uses source-as-machine-image semantics: a canonical Polyform is both readable source and executable machine state. There is therefore no hidden second bytecode format whose compiler must be trusted.

The bootstrap fixed-point chain is:

```text
physical ISA entrance
        |
        v
       HX0
        |
        +--> canonical HX87 Seed A
        |
        +--> HX87SEM3 semantic image
                 |
                 v
              Hexworld
                 |
                 v
          Seed A executes DUMP
                 |
                 v
              Seed B
                 |
                 v
          Seed B executes DUMP
                 |
                 v
              Seed C

             B == C
```

`DUMP` is the canonical self-image emitter. Because the executable representation is the canonical Polyform itself, the fixed point demonstrates regeneration of a canonical live machine image: a live HX87 image regenerates the next executable HX87 image without translating through C, Python, Rust, Lua, JavaScript, or another application language.

HX0 does not implement HX87 gameplay/runtime semantics. It establishes the canonical seed and semantic image. The physical host carrier supplies file I/O, memory mapping, terminal/file rendering services and the primitive operations needed to realize Hexworld on a physical CPU. Persistent semantics remain in the Hexworld state and HX87SEM3 image; transient native acceleration is never serialized as authoritative state.

The release test `HX87 Seed B == Seed C fixed point` verifies this chain byte-for-byte.

This fixed point does not constitute a compiler that constructs the physical host runtime from two bytes.
