/* HX89 signal adapter: bipolar level pulses, 125-baud FSK (64 samples per
 * symbol), and 1200-baud Bell 202 FSK (40 samples per symbol with 8N1).
 * Physical microphone/line-in capture is external to this file format tool.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum { SAMPLES_PER_BIT = 64, BELL_SAMPLES = 40, BELL_LEADER = 120,
       MAX_BITS = 65536, WAV_HEADER = 44 };

/* Fixed Q10 sine on a 240-sample ring. Steps 6 and 11 at 48 kHz give
 * 1200 and 2200 Hz; a 60-sample offset is the quadrature carrier.
 */
static const int16_t quarter240[61] = {
      0, 27, 54, 80, 107, 134, 160, 187, 213, 239,
    265, 291, 316, 342, 367, 392, 416, 441, 465, 489,
    512, 535, 558, 580, 602, 623, 644, 665, 685, 705,
    724, 743, 761, 779, 796, 812, 828, 844, 859, 873,
    887, 900, 912, 924, 935, 946, 956, 965, 974, 982,
    989, 996, 1002, 1007, 1011, 1015, 1018, 1021, 1023, 1024,
    1024
};
static int16_t sine240(unsigned phase) {
    phase %= 240u;
    if (phase <= 60u) return quarter240[phase];
    if (phase <= 120u) return quarter240[120u-phase];
    if (phase <= 180u) return (int16_t)-quarter240[phase-120u];
    return (int16_t)-quarter240[240u-phase];
}

static void put16(unsigned char *p, uint16_t v);

/* Bell 202 async stream: 120 mark bits of leader for 100 ms, then
 * one start, eight LSB-first data, one stop per binary-symbol byte.
 */
static int emit_tone(FILE *out, int bit, unsigned count, unsigned *phase,
                     int bell) {
    unsigned char samples[SAMPLES_PER_BIT*2];
    for (unsigned j = 0; j < count; ++j) {
        unsigned step = bell ? (bit ? 6u : 11u) : (bit ? 36u : 66u);
        put16(samples + 2*j, (uint16_t)(int16_t)(12*sine240(*phase)));
        *phase = (*phase + step) % 240u;
    }
    return fwrite(samples, 1, count*2u, out) == count*2u ? 0 : 1;
}
static int emit_uart_byte(FILE *out, unsigned byte, unsigned *phase) {
    if (emit_tone(out, 0, BELL_SAMPLES, phase, 1)) return 1;
    for (unsigned j = 0; j < 8; ++j)
        if (emit_tone(out, (byte >> j)&1u, BELL_SAMPLES, phase, 1)) return 1;
    return emit_tone(out, 1, BELL_SAMPLES, phase, 1);
}
static uint32_t crc_update(uint32_t crc, unsigned byte) {
    crc ^= byte;
    for (unsigned i = 0; i < 8; ++i)
        crc = (crc >> 1) ^ ((crc & 1u) ? 0xedb88320u : 0u);
    return crc;
}

static uint16_t u16(const unsigned char *p) {
    return (uint16_t)((unsigned)p[0] | ((unsigned)p[1] << 8));
}
static uint32_t u32(const unsigned char *p) {
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) |
           ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}
static void put16(unsigned char *p, uint16_t v) {
    p[0] = (unsigned char)v; p[1] = (unsigned char)(v >> 8);
}
static void put32(unsigned char *p, uint32_t v) {
    p[0] = (unsigned char)v; p[1] = (unsigned char)(v >> 8);
    p[2] = (unsigned char)(v >> 16); p[3] = (unsigned char)(v >> 24);
}

static int encode(FILE *in, FILE *out, int mode) {
    unsigned char header[WAV_HEADER] = {0};
    unsigned char samples[SAMPLES_PER_BIT * 2];
    long size;
    if (fseek(in, 0, SEEK_END) || (size = ftell(in)) < 0 ||
        size > MAX_BITS || fseek(in, 0, SEEK_SET)) return 1;
    uint32_t data_size = mode == 2 ?
        (uint32_t)(((size+4)*10 + BELL_LEADER)*BELL_SAMPLES*2) :
        (uint32_t)size*SAMPLES_PER_BIT*2u;
    memcpy(header, "RIFF", 4); put32(header + 4, 36u + data_size);
    memcpy(header + 8, "WAVEfmt ", 8); put32(header + 16, 16);
    put16(header + 20, 1); put16(header + 22, 1);
    put32(header + 24, mode == 2 ? 48000 : 8000);
    put32(header + 28, mode == 2 ? 96000 : 16000);
    put16(header + 32, 2); put16(header + 34, 16);
    memcpy(header + 36, "data", 4); put32(header + 40, data_size);
    if (fwrite(header, 1, sizeof header, out) != sizeof header) return 1;
    unsigned phase = 0;
    uint32_t crc = UINT32_MAX;
    if (mode == 2)
        for (unsigned j = 0; j < BELL_LEADER; ++j)
            if (emit_tone(out, 1, BELL_SAMPLES, &phase, 1)) return 1;
    for (long i = 0; i < size; ++i) {
        int bit = fgetc(in);
        if (bit != 0 && bit != 1) return 1;
        if (mode == 2) {
            crc = crc_update(crc, (unsigned)bit);
            if (emit_uart_byte(out, (unsigned)bit, &phase)) return 1;
            continue;
        }
        for (int j = 0; j < SAMPLES_PER_BIT; ++j) {
            int16_t sample = mode == 1 ? (int16_t)(12*sine240(phase)) :
                                   (bit ? 12000 : -12000);
            put16(samples + 2*j, (uint16_t)sample);
            if (mode == 1) phase = (phase + (bit ? 36u : 66u)) % 240u;
        }
        if (fwrite(samples, 1, sizeof samples, out) != sizeof samples) return 1;
    }
    if (mode == 2) {
        crc = ~crc;
        for (unsigned j = 0; j < 4; ++j)
            if (emit_uart_byte(out, (crc >> (8*j))&255u, &phase)) return 1;
    }
    return ferror(in) || ferror(out);
}

static int decode_tone(const unsigned char *samples, unsigned count, int bell) {
    int64_t sin0 = 0, cos0 = 0, sin1 = 0, cos1 = 0;
    unsigned step0 = bell ? 11u : 66u, step1 = bell ? 6u : 36u;
    for (unsigned j = 0; j < count; ++j) {
        int16_t s = (int16_t)u16(samples + 2*j);
        unsigned p0 = (j*step0) % 240u, p1 = (j*step1) % 240u;
        sin0 += (int64_t)s*sine240(p0);
        cos0 += (int64_t)s*sine240((p0+60u)%240u);
        sin1 += (int64_t)s*sine240(p1);
        cos1 += (int64_t)s*sine240((p1+60u)%240u);
    }
    __int128 e0 = (__int128)sin0*sin0 + (__int128)cos0*cos0;
    __int128 e1 = (__int128)sin1*sin1 + (__int128)cos1*cos1;
    __int128 winner = e0 > e1 ? e0 : e1;
    __int128 loser = e0 > e1 ? e1 : e0;
    if (winner < (__int128)1000000000000000LL || winner < 4*loser)
        return -1;
    return e1 > e0 ? 1 : 0;
}

/* Recover the UART start edge after the mark leader. A captured WAV may
 * begin up to 39 samples before the carrier. Each candidate clock phase is
 * validated by all leader symbols, UART start/stop bits and payload CRC.
 */
static int decode_bell(FILE *in, FILE *out, uint32_t data) {
    unsigned char *samples = malloc(data ? data : 1u);
    if (!samples) return 1;
    if (fread(samples, 1, data, in) != data) { free(samples); return 1; }
    uint32_t n = data/2u;
    for (unsigned offset = 0; offset < BELL_SAMPLES; ++offset) {
        uint32_t leader_end = offset + BELL_LEADER*BELL_SAMPLES;
        if (n < leader_end + 40u*BELL_SAMPLES) continue;
        unsigned good = 1;
        for (unsigned j = 0; j < BELL_LEADER; ++j) {
            if (decode_tone(samples + 2u*(offset+j*BELL_SAMPLES), BELL_SAMPLES, 1) != 1) {
                good = 0; break;
            }
        }
        if (!good || decode_tone(samples + 2u*leader_end, BELL_SAMPLES, 1) != 0)
            continue;
        uint32_t frames = (n-leader_end)/(10u*BELL_SAMPLES);
        if (frames < 4u || frames > MAX_BITS+4u) continue;
        uint32_t payload_count = frames-4u;
        unsigned char *payload = malloc(payload_count ? payload_count : 1u);
        if (!payload) { free(samples); return 1; }
        uint32_t crc = UINT32_MAX, received_crc = 0;
        for (uint32_t i = 0; i < frames && good; ++i) {
            uint32_t base = leader_end + i*10u*BELL_SAMPLES;
            if (decode_tone(samples + 2u*base, BELL_SAMPLES, 1) != 0) {
                good = 0; break;
            }
            unsigned byte = 0;
            for (unsigned j = 0; j < 8u; ++j) {
                int bit = decode_tone(samples + 2u*(base+(j+1u)*BELL_SAMPLES),
                                      BELL_SAMPLES, 1);
                if (bit < 0) { good = 0; break; }
                byte |= (unsigned)bit << j;
            }
            if (!good || decode_tone(samples + 2u*(base+9u*BELL_SAMPLES),
                                     BELL_SAMPLES, 1) != 1) { good = 0; break; }
            if (i < payload_count) {
                if (byte > 1u) { good = 0; break; }
                payload[i] = (unsigned char)byte;
                crc = crc_update(crc, byte);
            } else received_crc |= (uint32_t)byte << (8u*(i-payload_count));
        }
        if (good && received_crc == ~crc) {
            good = fwrite(payload, 1, payload_count, out) == payload_count;
            free(payload);
            free(samples);
            return good && !ferror(out) ? 0 : 1;
        }
        free(payload);
    }
    free(samples);
    return 1;
}

static int decode(FILE *in, FILE *out, int mode) {
    unsigned char header[WAV_HEADER];
    unsigned char samples[SAMPLES_PER_BIT * 2];
    long size;
    if (fseek(in, 0, SEEK_END) || (size = ftell(in)) < WAV_HEADER ||
        fseek(in, 0, SEEK_SET) || fread(header, 1, sizeof header, in) != sizeof header)
        return 1;
    uint32_t data = u32(header + 40);
    unsigned count = SAMPLES_PER_BIT;
    if (memcmp(header, "RIFF", 4) || memcmp(header + 8, "WAVEfmt ", 8) ||
        memcmp(header + 36, "data", 4) || u32(header + 4) != 36u + data ||
        u32(header + 16) != 16 || u16(header + 20) != 1 ||
        u16(header + 22) != 1 || u32(header + 24) != (mode == 2 ? 48000u : 8000u) ||
        u32(header + 28) != (mode == 2 ? 96000u : 16000u) || u16(header + 32) != 2 ||
        u16(header + 34) != 16 || (long)data != size - WAV_HEADER ||
        data % 2u) return 1;
    if (mode == 2) {
        if (data > ((MAX_BITS+4u)*10u+BELL_LEADER)*BELL_SAMPLES*2u+78u)
            return 1;
        return decode_bell(in, out, data);
    }
    if (data % (count*2u)) return 1;
    uint32_t symbols = data/(count*2u);
    if (symbols > MAX_BITS) return 1;
    for (uint32_t i = 0; i < symbols; ++i) {
        int64_t sum = 0;
        unsigned strong = 0;
        if (fread(samples, 1, count*2u, in) != count*2u) return 1;
        if (mode == 1) {
            int bit = decode_tone(samples, count, 0);
            if (bit < 0) return 1;
            if (fputc(bit, out) == EOF) return 1;
            continue;
        }
        for (unsigned j = 0; j < count; ++j) {
            int16_t s = (int16_t)u16(samples + 2*j);
            sum += s;
            if (s >= 3000 || s <= -3000) ++strong;
        }
        if (strong < 48 || (sum > -192000 && sum < 192000)) return 1;
        if (fputc(sum > 0 ? 1 : 0, out) == EOF) return 1;
    }
    return ferror(in) || ferror(out);
}

int main(int argc, char **argv) {
    int rc;
    FILE *in, *out;
    if (argc != 4 || (strcmp(argv[1], "encode") && strcmp(argv[1], "decode") &&
                      strcmp(argv[1], "encode-fsk") && strcmp(argv[1], "decode-fsk") &&
                      strcmp(argv[1], "encode-bell202") && strcmp(argv[1], "decode-bell202"))) {
        fprintf(stderr, "usage: pulse-pcm encode|decode|encode-fsk|decode-fsk|encode-bell202|decode-bell202 input output\n");
        return 2;
    }
    in = fopen(argv[2], "rb");
    if (!in) { perror(argv[2]); return 1; }
    out = fopen(argv[3], "wb");
    if (!out) { perror(argv[3]); fclose(in); return 1; }
    int is_encode = !strcmp(argv[1], "encode") || !strcmp(argv[1], "encode-fsk") ||
                    !strcmp(argv[1], "encode-bell202");
    int mode = (!strcmp(argv[1], "encode-bell202") ||
                !strcmp(argv[1], "decode-bell202")) ? 2 :
               (!strcmp(argv[1], "encode-fsk") || !strcmp(argv[1], "decode-fsk"));
    rc = is_encode ? encode(in, out, mode) : decode(in, out, mode);
    if (fclose(in)) rc = 1;
    if (fclose(out)) rc = 1;
    if (rc) fprintf(stderr, "pulse-pcm: invalid signal or I/O failure\n");
    return rc;
}
