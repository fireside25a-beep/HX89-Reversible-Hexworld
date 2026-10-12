/* Exhaustive finite-state checker for the HX89 deterministic chiral hex gas.
 *
 * The program is deliberately independent of src/hex_gas.c.  It checks the
 * local identities on all 64 collision states and the complete 2^24 state
 * space of a 2x2 torus.  The all-size theorem follows from the documented
 * local operator identities; exhaustive enumeration is a finite machine
 * certificate, not a numerical inference of the general result.
 */
#include <stdint.h>
#include <stdio.h>

#ifndef HX89_CHIRAL_STATE_BITS
#define HX89_CHIRAL_STATE_BITS 24
#endif

#if HX89_CHIRAL_STATE_BITS < 1 || HX89_CHIRAL_STATE_BITS > 24
#error "HX89_CHIRAL_STATE_BITS must be in 1..24"
#endif

static const int dx[6] = {1, 0, -1, -1, 0, 1};
static const int dy[6] = {0, 1, 1, 0, -1, -1};

static inline uint8_t collide(uint8_t s, int chirality) {
    if (s == 9)  return chirality > 0 ? 18 : 36;
    if (s == 18) return chirality > 0 ? 36 : 9;
    if (s == 36) return chirality > 0 ? 9 : 18;
    if (s == 21) return 42;
    if (s == 42) return 21;
    return s;
}

static inline uint8_t reflect_local(uint8_t s) {
    static const uint8_t map[6] = {0, 5, 4, 3, 2, 1};
    uint8_t t = 0;
    for (int i = 0; i < 6; ++i) if (s & (1u << i)) t |= (uint8_t)(1u << map[i]);
    return t;
}

static inline uint8_t reverse_velocity_local(uint8_t s) {
    uint8_t t = 0;
    for (int i = 0; i < 6; ++i) if (s & (1u << i)) t |= (uint8_t)(1u << ((i + 3) % 6));
    return t;
}

static inline int mass_local(uint8_t s) {
    int n = 0;
    for (int i = 0; i < 6; ++i) n += (s >> i) & 1u;
    return n;
}

static inline int momentum_x_local(uint8_t s) {
    int p = 0;
    for (int i = 0; i < 6; ++i) if (s & (1u << i)) p += dx[i];
    return p;
}

static inline int momentum_y_local(uint8_t s) {
    int p = 0;
    for (int i = 0; i < 6; ++i) if (s & (1u << i)) p += dy[i];
    return p;
}

static inline uint32_t get_cell(uint32_t z, int at) {
    return (z >> (6 * at)) & 63u;
}

static inline uint32_t set_cell(uint32_t z, int at, uint8_t s) {
    uint32_t mask = 63u << (6 * at);
    return (z & ~mask) | ((uint32_t)s << (6 * at));
}

static inline int wrap2(int x) { return x & 1; }

static uint32_t step2(uint32_t z, int chirality) {
    uint32_t out = 0;
    for (int y = 0; y < 2; ++y) for (int x = 0; x < 2; ++x) {
        uint8_t s = collide((uint8_t)get_cell(z, 2*y + x), chirality);
        for (int i = 0; i < 6; ++i) if (s & (1u << i)) {
            int nx = wrap2(x + dx[i]), ny = wrap2(y + dy[i]);
            int at = 2*ny + nx;
            uint8_t d = (uint8_t)get_cell(out, at);
            out = set_cell(out, at, (uint8_t)(d | (uint8_t)(1u << i)));
        }
    }
    return out;
}

static uint32_t inverse_step2(uint32_t z, int chirality) {
    uint32_t out = 0;
    for (int y = 0; y < 2; ++y) for (int x = 0; x < 2; ++x) {
        uint8_t incoming = 0;
        for (int i = 0; i < 6; ++i) {
            int sx = wrap2(x + dx[i]), sy = wrap2(y + dy[i]);
            incoming |= (uint8_t)get_cell(z, 2*sy + sx) & (uint8_t)(1u << i);
        }
        out = set_cell(out, 2*y + x, collide(incoming, -chirality));
    }
    return out;
}

static uint32_t reflect2(uint32_t z) {
    uint32_t out = 0;
    for (int y = 0; y < 2; ++y) for (int x = 0; x < 2; ++x) {
        int nx = wrap2(x + y), ny = wrap2(-y);
        out = set_cell(out, 2*ny + nx, reflect_local((uint8_t)get_cell(z, 2*y + x)));
    }
    return out;
}

static uint32_t reverse_velocity2(uint32_t z) {
    uint32_t out = 0;
    for (int at = 0; at < 4; ++at)
        out = set_cell(out, at, reverse_velocity_local((uint8_t)get_cell(z, at)));
    return out;
}

static uint32_t collide_all2(uint32_t z, int chirality) {
    uint32_t out = 0;
    for (int at = 0; at < 4; ++at)
        out = set_cell(out, at, collide((uint8_t)get_cell(z, at), chirality));
    return out;
}

/* Theta_chi = C_{-chi} P V.  For this collision-then-stream convention it is
 * the collision-dressed PT reversor: Theta^2=I and Theta F Theta=F^-1.
 */
static uint32_t theta2(uint32_t z, int chirality) {
    return collide_all2(reflect2(reverse_velocity2(z)), -chirality);
}

/* Build observables of definite Theta parity from two independent raw bits.
 * A(theta q)=+A(q), B(theta q)=-B(q) by construction.  They are used only to
 * machine-check the finite-time correlation reciprocity on the full state
 * space; the theorem itself is proved algebraically in the documentation.
 */
static inline int raw_phi(uint32_t z) { return (int)((z >> 0) & 1u); }
static inline int raw_psi(uint32_t z) { return (int)((z >> 20) & 1u); }

static int even_observable(uint32_t z, int chirality) {
    return raw_phi(z) + raw_phi(theta2(z, chirality));
}

static int odd_observable(uint32_t z, int chirality) {
    return raw_psi(z) - raw_psi(theta2(z, chirality));
}

int main(void) {
    for (unsigned s = 0; s < 64; ++s) {
        uint8_t u = (uint8_t)s;
        for (int chirality = -1; chirality <= 1; chirality += 2) {
            uint8_t v = collide(u, chirality);
            if (collide(v, -chirality) != u) {
                fprintf(stderr, "CHIRAL_LAW_FAIL local_inverse state=%u chi=%d\n", s, chirality); return 1;
            }
            if (mass_local(v) != mass_local(u) ||
                momentum_x_local(v) != momentum_x_local(u) ||
                momentum_y_local(v) != momentum_y_local(u)) {
                fprintf(stderr, "CHIRAL_LAW_FAIL local_conservation state=%u chi=%d\n", s, chirality); return 1;
            }
            if (reflect_local(collide(reflect_local(u), chirality)) != collide(u, -chirality)) {
                fprintf(stderr, "CHIRAL_LAW_FAIL local_reflection state=%u chi=%d\n", s, chirality); return 1;
            }
            if (reverse_velocity_local(collide(reverse_velocity_local(u), chirality)) != v) {
                fprintf(stderr, "CHIRAL_LAW_FAIL local_velocity_reversal state=%u chi=%d\n", s, chirality); return 1;
            }
        }
    }

    const uint32_t limit = 1u << HX89_CHIRAL_STATE_BITS;
    int64_t corr_ab[2] = {0, 0};
    int64_t corr_ba[2] = {0, 0};

    for (uint32_t z = 0; z < limit; ++z) {
        if (reflect2(step2(z, +1)) != step2(reflect2(z), -1)) {
            fprintf(stderr, "CHIRAL_LAW_FAIL mirror_chirality state=%u\n", z); return 1;
        }

        for (int ci = 0; ci < 2; ++ci) {
            int chirality = ci == 0 ? -1 : +1;
            uint32_t th = theta2(z, chirality);
            if (theta2(th, chirality) != z) {
                fprintf(stderr, "CHIRAL_LAW_FAIL theta_involution state=%u chi=%d\n", z, chirality); return 1;
            }
            if (theta2(step2(theta2(z, chirality), chirality), chirality) != inverse_step2(z, chirality)) {
                fprintf(stderr, "CHIRAL_LAW_FAIL dressed_PT state=%u chi=%d\n", z, chirality); return 1;
            }

            /* Exact one-step echo: F -> Theta -> F -> Theta returns q. */
            uint32_t echo = theta2(step2(theta2(step2(z, chirality), chirality), chirality), chirality);
            if (echo != z) {
                fprintf(stderr, "CHIRAL_LAW_FAIL echo state=%u chi=%d\n", z, chirality); return 1;
            }

            uint32_t fz = step2(z, chirality);
            corr_ab[ci] += (int64_t)even_observable(fz, chirality) * (int64_t)odd_observable(z, chirality);
            corr_ba[ci] += (int64_t)odd_observable(fz, chirality) * (int64_t)even_observable(z, chirality);
        }
    }

#if HX89_CHIRAL_STATE_BITS == 24
    for (int ci = 0; ci < 2; ++ci) {
        if (corr_ab[ci] != -corr_ba[ci]) {
            int chirality = ci == 0 ? -1 : +1;
            fprintf(stderr, "CHIRAL_LAW_FAIL correlation_reciprocity chi=%d AB=%lld BA=%lld\n",
                    chirality, (long long)corr_ab[ci], (long long)corr_ba[ci]);
            return 1;
        }
    }

    printf("CHIRAL_LAW_PASS local_states=64 global_states=%u "
           "mirror_chirality=PASS theta_involution=PASS dressed_PT_reversor=PASS "
           "echo=PASS correlation_reciprocity=PASS both_chiralities=PASS "
           "corr_minus=%lld/%lld corr_plus=%lld/%lld\n",
           limit,
           (long long)corr_ab[0], (long long)corr_ba[0],
           (long long)corr_ab[1], (long long)corr_ba[1]);
#else
    /* A truncated numeric prefix is not an F/Theta-invariant ensemble, so the
     * correlation change-of-variables identity is intentionally not tested
     * in the sanitizer sample.  The full 2^24 release certificate above is
     * the correlation gate. */
    printf("CHIRAL_LAW_PASS local_states=64 global_states=%u "
           "mirror_chirality=PASS theta_involution=PASS dressed_PT_reversor=PASS "
           "echo=PASS correlation_reciprocity=NOT_CHECKED_NONINVARIANT_SAMPLE both_chiralities=PASS\n",
           limit);
#endif
    return 0;
}
