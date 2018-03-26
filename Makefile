PYTHON3 := $(shell which python3 2>/dev/null)
COVERAGE3 := $(shell which coverage3 2>/dev/null)

PYTHON := python3
COVERAGE := coverage3
COPTS := run --append
TESTRUNNER := -m unittest discover tests

.PHONY: help
help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  install            to install Strawberry Fields"
	@echo "  wheel              to build the Strawberry Fields wheel"
	@echo "  dist               to package the source distribution"
	@echo "  clean              to delete all temporary, cache, and build files"
	@echo "  clean-docs         to delete all built documentation"
	@echo "  test               to run the test suite for all backends"
	@echo "  test-[backend]     to run the test suite for backend fock, tf, or gaussian"
	@echo "  coverage           to generate a coverage report for all backends"
	@echo "  coverage-[backend] to generate a coverage report for backend fock, tf, or gaussian"

.PHONY: install
install:
ifndef PYTHON3
	@echo "To install Strawberry Fields you need to have Python 3 installed"
endif
	$(PYTHON) setup.py install

.PHONY: wheel
wheel:
	$(PYTHON) setup.py bdist_wheel

.PHONY: dist
dist:
	$(PYTHON) setup.py sdist

.PHONY : clean
clean:
	rm -rf strawberryfields/__pycache__
	rm -rf strawberryfields/backends/__pycache__
	rm -rf strawberryfields/backends/fockbackend/__pycache__
	rm -rf strawberryfields/backends/tfbackend/__pycache__
	rm -rf strawberryfields/backends/gaussianbackend/__pycache__
	rm -rf tests/__pycache__
	rm -rf dist
	rm -rf build

docs:
	make -C doc html

.PHONY : clean-docs
clean-docs:
	make -C doc clean

test: test-gaussian test-fock test-tf batch-test-tf

test-%:
	@echo "Testing $(subst test-,,$@) backend..."
	export BACKEND=$(subst test-,,$@) && $(PYTHON) $(TESTRUNNER)

batch-test-%:
	@echo "Testing $(subst batch-test-,,$@) backend in batch mode..."
	export BACKEND=$(subst batch-test-,,$@) && export BATCHED=1 && $(PYTHON) $(TESTRUNNER)

coverage: coverage-gaussian coverage-fock coverage-tf #batch-coverage-tf
	$(COVERAGE) report
	$(COVERAGE) html

coverage-%:
	@echo "Generating coverage report for $(subst coverage-,,$@) backend..."
	export BACKEND=$(subst coverage-,,$@) && $(COVERAGE) $(COPTS) $(TESTRUNNER)

batch-coverage-%:
	@echo "Generating coverage report for $(subst batch-coverage-,,$@) backend in batch mode..."
	export BACKEND=$(subst batch-coverage-,,$@) && export BATCHED=1 && $(COVERAGE) $(COPTS) $(TESTRUNNER)
