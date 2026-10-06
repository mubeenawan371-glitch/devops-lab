# Makefile — fallback copy of the Lab 02 model answer.
# Use ONLY if you no longer have your own Lab 02 work, and say so in your report.
# Verified against GNU Make 3.81 and 4.3.

SRC_DIR := src
OUT_DIR := out
SOURCES := $(wildcard $(SRC_DIR)/*.txt)
OUTPUTS := $(patsubst $(SRC_DIR)/%.txt,$(OUT_DIR)/%.txt,$(SOURCES))

.PHONY: all check build test clean ci help

all: test  ## build and test everything (default)

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

$(OUT_DIR)/%.txt: $(SRC_DIR)/%.txt | $(OUT_DIR)
	@echo "  BUILD $< -> $@"
	@tr '[:lower:]' '[:upper:]' < $< > $@

check:  ## fail early if there is nothing to build
	@test -d $(SRC_DIR) || { echo "ERROR: source directory $(SRC_DIR) not found"; exit 1; }
	@test -n "$(SOURCES)" || { echo "ERROR: no .txt files found in $(SRC_DIR)"; exit 1; }
	@echo "check: $(words $(SOURCES)) source file(s) in $(SRC_DIR)"

build: $(OUTPUTS)  ## build every out-of-date output

test: build  ## verify every output
	@if grep -l '[a-z]' $(OUTPUTS) >/dev/null 2>&1; then \
	   echo "TEST FAILED: lowercase characters remain"; exit 1; \
	 fi
	@echo "TEST PASSED"

clean:  ## remove all generated files
	rm -rf $(OUT_DIR)

ci: clean check test  ## the build server entry point

# Extension answer: self-documenting targets.
help:  ## show this help
	@grep -E '^[a-z][a-zA-Z_-]*:.*?## ' $(MAKEFILE_LIST) \
	 | sed 's/:.*## /\t/' | column -t -s "$$(printf '\t')"
