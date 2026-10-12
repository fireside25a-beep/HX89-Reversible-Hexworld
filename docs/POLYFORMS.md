# Polyforms

A Polyform is an artifact whose HX87 meaning is selected by content, never by filename suffix. `.hx`, `.iet`, `.lua`, `.js`, `.save`, `.dat`, or an arbitrary extension may all carry HX87 content.

## Canonical cell form

```text
HX87P1
CELL x y z w v op a b q
```

Coordinates address the real five-dimensional sparse field. `q` is one of the 25 Q^2 states.

## Cross-syntax facet

`polyforms/polyform.universal` uses assignments that are simultaneously accepted by HX87 and, on the verification host, real Node.js, Python, Ruby, Bash and Dash interpreters. The syntax is also Lua-compatible and is tested when Lua is installed.

External-language compatibility is evidence-based: a facet is counted only when the independent interpreter actually accepts the physical artifact.

## Native facets

`NATIVE_RAW` is the literal-byte NABI0 research facet described in `NATIVE_BRIDGE.md`.

`NATIVE_ACCEL` is different: the Polyform contains HX87-native IR cells, not preassembled x86. The physical host representation is generated transiently from the semantic cells and is never the canonical program.
