# HX89 execution policy

By default, a Polyform is interpreted through the Hexworld state and both host native paths are disabled. `--native` at process launch explicitly enables `NATIVE_RAW` and `NATIVE_ACCEL` for that run. The prior NABI0 validation and RW→RX transitions remain in effect when enabled. The policy flag lives outside serialized machine state, so a resumed snapshot cannot turn it on.

Snapshots must have the exact serialized byte count, the HX89 version magic, and bounded cell, head, stack, node and raw-native counts. Treat snapshots and Polyforms as untrusted process inputs; this build is not a hardened OS sandbox and uses host file operations. Execute untrusted data under the host's normal process isolation.
