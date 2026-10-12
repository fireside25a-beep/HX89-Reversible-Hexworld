#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define HX89_ARENA_CELLS 4096u
#define MAX_PAYLOAD (HX89_ARENA_CELLS - 1u)

static int read_all(const char *path, uint8_t **data, size_t *len) {
    FILE *f = fopen(path, "rb");
    if (!f) return 1;
    if (fseek(f, 0, SEEK_END) != 0) { fclose(f); return 1; }
    long end = ftell(f);
    if (end < 0 || (unsigned long)end > MAX_PAYLOAD) { fclose(f); errno = EFBIG; return 1; }
    if (fseek(f, 0, SEEK_SET) != 0) { fclose(f); return 1; }
    *len = (size_t)end;
    *data = *len ? malloc(*len) : NULL;
    if (*len && !*data) { fclose(f); return 1; }
    if (*len && fread(*data, 1, *len, f) != *len) {
        free(*data); *data = NULL; fclose(f); return 1;
    }
    if (fclose(f) != 0) { free(*data); *data = NULL; return 1; }
    return 0;
}

static int write_polyform(const char *path, const uint8_t *data, size_t len) {
    FILE *f = fopen(path, "wb");
    if (!f) return 1;
    int bad = fputs("HX87P1\n# canonical byte compiler: one EMIT cell per payload byte\n", f) == EOF;
    for (size_t i = 0; i < len && !bad; ++i) {
        bad = fprintf(f, "CELL %zu 0 0 0 0 1 %u 0 0\n", i, (unsigned)data[i]) < 0;
    }
    if (!bad) bad = fprintf(f, "CELL %zu 0 0 0 0 0 0 0 0\n", len) < 0;
    if (fclose(f) != 0) bad = 1;
    return bad;
}

int main(int argc, char **argv) {
    if (argc != 3 || !strcmp(argv[1], argv[2])) {
        fputs("usage: byte-polyform INPUT.bin OUTPUT.hx\n", stderr);
        return 2;
    }
    uint8_t *data = NULL;
    size_t len = 0;
    if (read_all(argv[1], &data, &len)) {
        if (errno == EFBIG) fprintf(stderr, "byte-polyform: payload exceeds %u bytes\n", MAX_PAYLOAD);
        else perror("byte-polyform: input");
        free(data);
        return 1;
    }
    int bad = write_polyform(argv[2], data, len);
    free(data);
    if (bad) {
        perror("byte-polyform: output");
        return 1;
    }
    printf("BYTE_POLYFORM payload=%zu cells=%zu status=PASS\n", len, len + 1u);
    return 0;
}
