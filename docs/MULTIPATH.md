# Signal carriers converging at HX0

The same strict one-bit seed streams can enter HX0 through several independently checked representations. Each route must recover the canonical Seed A and semantic image byte for byte before the x86-64 assembler embeds the latter. The standard build executes the memory echo, ETCH comparison, 125-baud FSK, and Bell 202 framed waveform routes. The earlier bipolar PCM path remains tested.

| Path | Source symbols | Transformation | Receiver |
| --- | --- | --- | --- |
| Memory echo | 0/1 bytes | HX0 writes symbol and complement into private memory | HX0 verifies the two architected reads |
| ETCH | XOR encoded canonical bytes | HX0 ETCH program | Byte comparison against Seed A and semantic image |
| Bipolar PCM | 0/1 bytes | ±12000, 64 PCM16 samples at 8 kHz | Strength and signed mean; 125 symbols/s |
| Tone PCM | 0/1 bytes | Continuous 1200/2200 Hz tone, 64 samples at 8 kHz | Quadrature tone energies; 125 symbols/s |
| Bell 202 audio | 0/1 payload bytes | 1200/2200 Hz continuous-phase tone, 40 samples at 48 kHz | 1200 symbols/s, 8N1, CRC32, then HX0 |

`bin/pulse-pcm encode-bell202 bits audio.wav` emits mono PCM16. Logical one (mark) uses 1200 Hz; zero (space) uses 2200 Hz. The carrier phase continues across boundaries. An initial 120 mark symbols give a 100 ms leader. Every payload byte is sent as an asynchronous start zero, eight data bits least significant first, and stop one. A four-byte little-endian IEEE CRC32 of the payload follows as four more 8N1 characters. The payload bytes are individually 0 or 1 because HX0's bit entrance accepts only those values.

`bin/pulse-pcm decode-bell202 audio.wav bits` validates the WAV parameters, tone separation, leader, start/stop bits, binary payload and CRC before writing any recovered payload to the output file. It scans 40 sample-clock offsets for the mark-to-start transition; the test includes a recording shifted by 37 leading samples. The CRC is an HX89 application framing field carried *over* Bell 202 modulation; Bell 202 itself does not define this payload format. A receiving modem can demodulate the standard mark/space signal and deliver 8N1 characters, after which the HX89 CRC check applies. The WAV decoder assumes 48 kHz sampling and a leader starting within one symbol of the file beginning; it does not track arbitrary clock drift over a microphone channel.

The two frequencies and 1200 bit/s rate match the Bell 202 mode specified by CML Microsystems for its compatible modem. The optional 125-symbol/s tone route is a separate HX89 format and is not labeled Bell 202. V.23 uses another tone pair (1300/2100 Hz), so that label is not used for the Bell route.

## A physical signal model that can be measured

At 48 kHz each sample has time coordinate `t=n/48000 s`. The carrier is `s[n] ≈ 12288 sin(2π phase[n]/240)`, with `phase[n+1]=(phase[n]+6) mod 240` for mark and `+11` for space. This models a DAC-ready voltage waveform and, after a loudspeaker, an acoustic pressure waveform proportional to that voltage only under a calibrated transducer assumption. The decoder compares squared sine and cosine correlations at both frequencies. That test is insensitive to carrier phase, unlike the signed-mean heuristic for bipolar levels.

The independent Python oracle measures every emitted UART symbol against direct trigonometric correlations, verifies the phase recurrence sample by sample, applies deterministic inversion/attenuation/Gaussian noise, and checks silence, malformed framing, and a valid-looking but CRC-damaged data tone. The full seed and semantic image also travel through both FSK receivers into the actual HX0 decoder during the build. This is a defined communications experiment with a time axis, frequency, signal energy and noise; the **5D Hexworld coordinates remain an index space**. A physical propagation experiment needs a DAC, channel, ADC and calibration.

`evidence/CHANNEL_SWEEP.csv` records 10 deterministic trials at each of five PCM Gaussian noise standard deviations for a 128-symbol payload. In this run, all 10 payloads survived at σ=3000 counts and all 10 were rejected at σ=6000; none were silently corrupted. These are measurements of this synthetic additive-noise setup, not a promised modem sensitivity or a telephone-line test.

The finite HX89 process does not become an unbounded Turing machine by transporting its seed in sound. Nor does seeded `ENTROPY` acquire an objective function from a modem path. Those require separate machine semantics and evidence, not a change of carrier.

Sources:

- CML Microsystems, [MX614 Bell 202 compatible modem datasheet](https://www.mouser.com/datasheet/2/976/MX614_ds-1627061.pdf), frequency and data-rate specifications.
- ITU-T, [V.23 recommendation](https://www.itu.int/rec/T-REC-V.23-198811-I), distinct 1200-baud tone pair.
- Analog Devices, [tone detection using Goertzel/DFT methods](https://www.analog.com/en/resources/app-notes/using-the-73m2901ce-dtmf-detector.html).
- C. E. Shannon, [*A Mathematical Theory of Communication*](https://onlinelibrary.wiley.com/doi/10.1002/j.1538-7305.1948.tb00917.x), 1948.
