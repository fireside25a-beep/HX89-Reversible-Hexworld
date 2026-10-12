/* HX89 hexagonal Boolean lattice gas. Each byte contains six velocity bits.
 * The local collision is a permutation; streaming is a permutation on a torus.
 * This is a microscopic particle model, not a calibrated continuum solver.
 */
#include <errno.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const int dx[6] = {1, 0, -1, -1, 0, 1};
static const int dy[6] = {0, 1, 1, 0, -1, -1};

static unsigned collide(unsigned s, int reverse) {
    if (s == 9) return reverse ? 36 : 18;
    if (s == 18) return reverse ? 9 : 36;
    if (s == 36) return reverse ? 18 : 9;
    if (s == 21) return 42;
    if (s == 42) return 21;
    return s;
}

static unsigned count(unsigned s) {
    unsigned n = 0;
    for (int i = 0; i < 6; ++i) n += (s >> i) & 1u;
    return n;
}

static void measure(const uint8_t *a, size_t n, uint64_t *mass,
                    int64_t *px, int64_t *py) {
    *mass = 0; *px = 0; *py = 0;
    for (size_t k = 0; k < n; ++k)
        for (int i = 0; i < 6; ++i)
            if (a[k] & (1u << i)) {
                ++*mass; *px += dx[i]; *py += dy[i];
            }
}

static uint64_t hash(const uint8_t *a, size_t n) {
    uint64_t h = UINT64_C(14695981039346656037);
    for (size_t i = 0; i < n; ++i) { h ^= a[i]; h *= UINT64_C(1099511628211); }
    return h;
}

static uint64_t random_word(uint64_t *s) {
    *s ^= *s >> 12; *s ^= *s << 25; *s ^= *s >> 27;
    return *s * UINT64_C(2685821657736338717);
}

static int wrap(int n, int size) {
    return n < 0 ? n + size : n >= size ? n - size : n;
}

static void step(const uint8_t *from, uint8_t *to, int w, int h, int reverse,
                 uint64_t *collisions) {
    memset(to, 0, (size_t)w * (size_t)h);
    for (int y = 0; y < h; ++y)
        for (int x = 0; x < w; ++x) {
            size_t at = (size_t)y*(size_t)w + (size_t)x;
            if (!reverse) {
                unsigned s = collide(from[at], 0);
                if (s != from[at] && collisions) ++*collisions;
                for (int i = 0; i < 6; ++i)
                    if (s & (1u << i)) {
                        size_t dst = (size_t)wrap(y+dy[i],h)*(size_t)w +
                                     (size_t)wrap(x+dx[i],w);
                        to[dst] |= (uint8_t)(1u << i);
                    }
            } else {
                unsigned s = 0;
                for (int i = 0; i < 6; ++i) {
                    size_t src = (size_t)wrap(y+dy[i],h)*(size_t)w +
                                 (size_t)wrap(x+dx[i],w);
                    s |= from[src] & (1u << i);
                }
                to[at] = (uint8_t)collide(s, 1);
            }
        }
}

static int local_proof(void) {
    for (unsigned s = 0; s < 64; ++s) {
        uint8_t a = (uint8_t)s, b = (uint8_t)collide(s, 0);
        uint64_t m0, m1; int64_t x0, x1, y0, y1;
        measure(&a, 1, &m0, &x0, &y0);
        measure(&b, 1, &m1, &x1, &y1);
        unsigned rotated = ((s << 1) & 63u) | (s >> 5);
        unsigned mapped_rotated = ((unsigned)b << 1 & 63u) | (b >> 5);
        if (collide(b, 1) != s || m0 != m1 || x0 != x1 || y0 != y1 ||
            collide(rotated, 0) != mapped_rotated)
            return 1;
    }
    puts("LOCAL 64/64 bijective mass/momentum conserved, C6 rotationally covariant");
    return 0;
}

static int number(const char *s, uint64_t min, uint64_t max, uint64_t *v) {
    char *end;
    if (!*s) return 1;
    for (const char *p = s; *p; ++p) if (*p < '0' || *p > '9') return 1;
    errno = 0;
    *v = strtoull(s, &end, 10);
    return errno || *end || *v < min || *v > max;
}

static int write_image(const char *path, const uint8_t *a, int w, int h) {
    FILE *f = fopen(path, "wb");
    if (!f) return 1;
    int bad = fprintf(f, "P5\n%d %d\n255\n", w, h) < 0;
    for (int i = 0; i < w*h && !bad; ++i)
        if (fputc((int)count(a[i])*42, f) == EOF) bad = 1;
    if (fclose(f)) bad = 1;
    return bad;
}

/* Measured column densities or complete PGM bytes become actual EMIT cells.
 * Running the generated Polyform in bin/hx89 emits them from its own cells.
 */
static int write_polyform(const char *path, const uint8_t *a, int w, int h,
                          int full_image) {
    FILE *f = fopen(path, "wb");
    if (!f) return 1;
    int bad = fputs("HX87P1\n", f) == EOF;
    int pos = 0;
    if (full_image) {
        char header[64];
        int len = snprintf(header, sizeof header, "P5\n%d %d\n255\n", w, h);
        if (len < 0 || len >= (int)sizeof header || len+w*h+1 > 4096) bad=1;
        for (int i = 0; i < len && !bad; ++i)
            bad = fprintf(f, "CELL %d 0 0 0 0 1 %u 0 0\n",
                          pos++, (unsigned char)header[i]) < 0;
        for (int i = 0; i < w*h && !bad; ++i)
            bad = fprintf(f, "CELL %d 0 0 0 0 1 %u 0 0\n",
                          pos++, 42u*count(a[i])) < 0;
    } else {
        if (fputs("# Hex-gas column mean occupancy: 0..6\n", f) == EOF) bad=1;
        for (int x = 0; x < w && !bad; ++x) {
            unsigned particles = 0;
            for (int y = 0; y < h; ++y) particles += count(a[y*w+x]);
            unsigned mean = (particles + (unsigned)h/2u)/(unsigned)h;
            bad = fprintf(f, "CELL %d 0 0 0 0 1 %u 0 0\n",
                          pos++, 48u+mean) < 0;
        }
        if (!bad) bad = fprintf(f, "CELL %d 0 0 0 0 1 10 0 0\n",pos++) < 0;
    }
    if (!bad) bad = fprintf(f, "CELL %d 0 0 0 0 0 0 0 0\n", pos) < 0;
    if (fclose(f)) bad = 1;
    return bad;
}

int main(int argc, char **argv) {
    if (argc == 2 && !strcmp(argv[1], "--verify-local")) return local_proof();
    uint64_t ww, hh, ss, seed;
    if ((argc != 7 && argc != 8) ||
        (argc == 8 && strcmp(argv[7], "--image-polyform")) ||
        number(argv[1], 8, 128, &ww) ||
        number(argv[2], 8, 128, &hh) || number(argv[3], 0, 10000, &ss) ||
        number(argv[4], 1, UINT64_MAX, &seed) || !strcmp(argv[5], argv[6])) {
        fputs("usage: hx89-gas WIDTH HEIGHT STEPS SEED image.pgm cells.hx [--image-polyform]\n"
              "       hx89-gas --verify-local\n", stderr);
        return 2;
    }
    if (local_proof()) return 1;
    int w = (int)ww, h = (int)hh;
    size_t n = (size_t)w*(size_t)h;
    uint8_t *a = malloc(n), *b = malloc(n), *original = malloc(n);
    if (!a || !b || !original) {
        fputs("hx89-gas: allocation failed\n", stderr);
        free(a); free(b); free(original); return 1;
    }
    uint64_t rng = seed, collisions = 0, m0, m1;
    int64_t px0, py0, px1, py1;
    for (int y = 0; y < h; ++y)
        for (int x = 0; x < w; ++x) {
            unsigned s = 0;
            int64_t cx = 2*x-w+1, cy = 2*y-h+1;
            int center = 16*cx*cx < (int64_t)w*w &&
                         16*cy*cy < (int64_t)h*h;
            for (int i = 0; i < 6; ++i)
                if ((random_word(&rng) & 3u) < (unsigned)(center ? 3 : 1))
                    s |= 1u << i;
            a[y*w+x] = (uint8_t)s;
        }
    memcpy(original, a, n);
    measure(a,n,&m0,&px0,&py0);
    for (uint64_t t = 0; t < ss; ++t) {
        step(a,b,w,h,0,&collisions);
        uint8_t *tmp=a; a=b; b=tmp;
        measure(a,n,&m1,&px1,&py1);
        if (m0!=m1 || px0!=px1 || py0!=py1) {
            fputs("hx89-gas: conservation failure\n",stderr);
            free(a); free(b); free(original); return 1;
        }
    }
    uint64_t final_hash = hash(a,n);
    int bad = write_image(argv[5],a,w,h) ||
              write_polyform(argv[6],a,w,h,argc==8);
    for (uint64_t t = 0; t < ss && !bad; ++t) {
        step(a,b,w,h,1,NULL);
        uint8_t *tmp=a; a=b; b=tmp;
    }
    if (!bad && memcmp(a,original,n)) bad=1;
    if (!bad) printf("GAS size=%dx%d steps=%" PRIu64 " mass=%" PRIu64
                     " px=%" PRId64 " py=%" PRId64
                     " collisions=%" PRIu64 " final=%016" PRIx64
                     " reverse=PASS\n",w,h,ss,m0,px0,py0,collisions,final_hash);
    else fputs("hx89-gas: output or reverse verification failed\n",stderr);
    free(a); free(b); free(original);
    return bad;
}
