SHELL := /bin/bash
PYTHON ?= python3
export PYTHONPATH := src
export PYTHONUNBUFFERED := 1

.PHONY: all verification test exact monitor paper clean

all: verification

verification:
	@mkdir -p results
	@set -o pipefail; { \
		echo '=== UNIT TESTS ==='; \
		$(PYTHON) -m unittest discover -s tests -v; \
		echo; echo '=== EXACT SYMBOLIC REPORT ==='; \
		$(PYTHON) -m crtc.exact_report; \
		echo; echo '=== SELF-MONITOR ==='; \
		$(PYTHON) -m crtc.monitor --all; \
	} 2>&1 | tee results/VERIFICATION.txt

test:
	$(PYTHON) -m unittest discover -s tests -v

exact:
	$(PYTHON) -m crtc.exact_report

monitor:
	$(PYTHON) -m crtc.monitor --all

paper:
	cd paper && pdflatex -interaction=nonstopmode -halt-on-error main.tex && pdflatex -interaction=nonstopmode -halt-on-error main.tex

clean:
	rm -rf .pytest_cache __pycache__ src/crtc/__pycache__ tests/__pycache__ build dist *.egg-info src/*.egg-info
	find . -name '*.pyc' -delete
	rm -f paper/*.aux paper/*.log paper/*.out paper/*.toc
