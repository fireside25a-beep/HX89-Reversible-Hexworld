CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -Wl,-z,relro,-z,now,-z,noexecstack
AS ?= as
LD ?= ld
CLANG ?= clang

all: bin/hx89 bin/pulse-pcm bin/hx89-gas bin/byte-polyform bin/hx89-chiral-proof

build/hx0-x86_64.o: boot/x86_64/hx0.S
	mkdir -p build
	$(AS) -o $@ $<

bin/hx0-x86_64: build/hx0-x86_64.o
	mkdir -p bin
	$(LD) -o $@ $<

build/hx0_bitstream.hx0: boot/hx0_bitstream.S seeds/hx0_bitstream.hx0
	mkdir -p build
	$(AS) -o build/hx0_bitstream.o boot/hx0_bitstream.S
	objcopy -O binary -j .rodata build/hx0_bitstream.o $@
	cmp $@ seeds/hx0_bitstream.hx0

# HX0 reconstructs the semantic image from one-bit symbols. The original
# ETCH route independently verifies the same canonical image.
build/bootstrap.stamp: bin/hx0-x86_64 bin/pulse-pcm build/hx0_bitstream.hx0 seeds/hx0_etch.hx0 seeds/hx89_seed.bits seeds/hx89_semantics.bits seeds/hx87_seed.etch seeds/hx87_seed.hx seeds/hx87_semantics.etch seeds/hx87_semantics.seed
	mkdir -p build
	./bin/hx0-x86_64 build/hx0_bitstream.hx0 < seeds/hx89_seed.bits > build/hx87_seed.stageA
	cmp build/hx87_seed.stageA seeds/hx87_seed.hx
	./bin/hx0-x86_64 build/hx0_bitstream.hx0 < seeds/hx89_semantics.bits > build/hx87_semantics.seed
	cmp build/hx87_semantics.seed seeds/hx87_semantics.seed
	./bin/hx0-x86_64 seeds/hx0_etch.hx0 < seeds/hx87_seed.etch > build/hx87_seed.etchdecoded
	cmp build/hx87_seed.etchdecoded build/hx87_seed.stageA
	./bin/hx0-x86_64 seeds/hx0_etch.hx0 < seeds/hx87_semantics.etch > build/hx87_semantics.etchdecoded
	cmp build/hx87_semantics.etchdecoded build/hx87_semantics.seed
	./bin/pulse-pcm encode-fsk seeds/hx89_seed.bits build/hx89_seed.fsk.wav
	./bin/pulse-pcm decode-fsk build/hx89_seed.fsk.wav build/hx89_seed.fsk.bits
	./bin/hx0-x86_64 build/hx0_bitstream.hx0 < build/hx89_seed.fsk.bits > build/hx87_seed.fskdecoded
	cmp build/hx87_seed.fskdecoded build/hx87_seed.stageA
	./bin/pulse-pcm encode-fsk seeds/hx89_semantics.bits build/hx89_semantics.fsk.wav
	./bin/pulse-pcm decode-fsk build/hx89_semantics.fsk.wav build/hx89_semantics.fsk.bits
	./bin/hx0-x86_64 build/hx0_bitstream.hx0 < build/hx89_semantics.fsk.bits > build/hx87_semantics.fskdecoded
	cmp build/hx87_semantics.fskdecoded build/hx87_semantics.seed
	./bin/pulse-pcm encode-bell202 seeds/hx89_seed.bits build/hx89_seed.bell.wav
	./bin/pulse-pcm decode-bell202 build/hx89_seed.bell.wav build/hx89_seed.bell.bits
	./bin/hx0-x86_64 build/hx0_bitstream.hx0 < build/hx89_seed.bell.bits > build/hx87_seed.belldecoded
	cmp build/hx87_seed.belldecoded build/hx87_seed.stageA
	./bin/pulse-pcm encode-bell202 seeds/hx89_semantics.bits build/hx89_semantics.bell.wav
	./bin/pulse-pcm decode-bell202 build/hx89_semantics.bell.wav build/hx89_semantics.bell.bits
	./bin/hx0-x86_64 build/hx0_bitstream.hx0 < build/hx89_semantics.bell.bits > build/hx87_semantics.belldecoded
	cmp build/hx87_semantics.belldecoded build/hx87_semantics.seed
	printf 'HX89_BOOTSTRAP_VERIFIED\n' > $@

bootstrap: build/bootstrap.stamp

build/hx89_x86_64.o: src/hx89_x86_64.S build/bootstrap.stamp
	mkdir -p build
	$(CC) -c -o $@ src/hx89_x86_64.S

bin/hx89: build/hx89_x86_64.o
	mkdir -p bin
	$(CC) $(CFLAGS) -no-pie -o $@ build/hx89_x86_64.o

bin/pulse-pcm: src/pulse_pcm.c
	mkdir -p bin
	$(CC) -std=c11 -O2 -Wall -Wextra -Werror -o $@ $<

bin/hx89-gas: src/hex_gas.c
	mkdir -p bin
	$(CC) -std=c11 -O2 -Wall -Wextra -Werror -o $@ $<

bin/byte-polyform: src/byte_polyform.c
	mkdir -p bin
	$(CC) -std=c11 -O2 -Wall -Wextra -Werror -o $@ $<

bin/hx89-chiral-proof: src/chiral_law.c
	mkdir -p bin
	$(CC) -std=c11 -O3 -Wall -Wextra -Werror -o $@ $<

cross-objects:
	mkdir -p build
	$(CLANG) --target=aarch64-linux-gnu -c boot/aarch64/hx0.S -o build/hx0-aarch64.o
	$(CLANG) --target=riscv64-linux-gnu -c boot/riscv64/hx0.S -o build/hx0-riscv64.o

check: all
	sh tests/test.sh

release-evidence: all
	sh tests/release_evidence.sh

audit: release-evidence
	sh tests/audit.sh

sanitize:
	sh tests/sanitize.sh

clean:
	rm -rf build thesis/build
	rm -f bin/hx89 bin/hx0-x86_64 bin/pulse-pcm bin/hx89-gas bin/byte-polyform bin/hx89-chiral-proof frame.ppm hx89.state hx89.regen
	rm -f evidence/*.actual evidence/*.sha256 evidence/*.txt evidence/*.o evidence/*.ppm evidence/*.state evidence/*.regen
	rm -f research/crtc/paper/*.aux research/crtc/paper/*.log research/crtc/paper/*.out research/crtc/paper/*.toc
	rm -f dist/*.pdf

.PHONY: all bootstrap check cross-objects release-evidence audit sanitize clean documents thesis thesis-check scientific-registry consistency-audit verify-all

documents:
	sh tools/build_documents.sh

thesis: documents

scientific-registry:
	python3 tools/generate_scientific_registry.py

thesis-check: documents
	python3 thesis/tools/generate_fragments.py --check
	python3 thesis/tools/independent_math_audit.py
	python3 thesis/tools/prose_lint.py
	python3 tools/style_lint.py
	python3 thesis/tools/verify_consistency.py

consistency-audit: scientific-registry documents
	python3 tools/consistency_audit.py

verify-all:
	$(MAKE) clean all
	$(MAKE) sanitize
	$(MAKE) audit
	$(MAKE) -C research/crtc clean verification
	$(MAKE) scientific-registry
	$(MAKE) thesis-check
	python3 tools/consistency_audit.py
