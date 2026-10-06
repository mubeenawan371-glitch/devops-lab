SRC_DIR := src
OUT_DIR := out
SOURCES := $(wildcard $(SRC_DIR)/*.txt)
OUTPUTS := $(patsubst $(SRC_DIR)/%.txt, $(OUT_DIR)/%.txt, $(SOURCES))

.PHONY: all check build test clean ci

# First target builds and tests everything via dependency chaining
all: test

# Order-only prerequisite for output directory creation
$(OUT_DIR):
	mkdir -p $(OUT_DIR)

# Pattern rule for uppercase conversion using automatic variables
$(OUT_DIR)/%.txt: $(SRC_DIR)/%.txt | $(OUT_DIR)
	@echo "BUILD $< -> $@"
	@tr '[:lower:]' '[:upper:]' < $< > $@

# Validates source directory and file presence
check:
	@if [ ! -d "$(SRC_DIR)" ] || [ -z "$(wildcard $(SRC_DIR)/*.txt)" ]; then \
		echo "ERROR: no .txt files found in $(SRC_DIR)"; \
		exit 1; \
	fi
	@echo "CHECK: Found $(words $(wildcard $(SRC_DIR)/*.txt)) source file(s) in $(SRC_DIR)"

# Build stage depends on all mapped output files
build: $(OUTPUTS)

# Test stage asserts that no lowercase letters remain in any output
test: build
	@if grep -l '[a-z]' $(OUTPUTS) >/dev/null 2>&1; then \
		echo "TEST FAILED: lowercase characters remain"; \
		exit 1; \
	fi
	@echo "TEST PASSED"

# Cleans up generated artifacts completely
clean:
	rm -rf $(OUT_DIR)

# CI pipeline runner sequence: clean -> check -> test
ci: clean check test



count: build ## report how many words were built
	@wc -w $(OUTPUTS) | tail -1
