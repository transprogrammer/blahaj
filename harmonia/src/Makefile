# NOTE: For targets, run `make help`. <skr>

ifeq ($(TRACE),yes)
XTRACE = -x
endif

SHELL = /usr/bin/env bash $(XTRACE)

BD := $(shell tput bold)
BL := $(shell tput setaf 4)
CY := $(shell tput setaf 6)
RS := $(shell tput sgr0)

HELP = '\n\
$(BD)project targets:$(RS)\n\
\n\
$(CY)run$(RS)   - $(BL)runs harmony.$(RS)\n\
$(CY)clean$(RS) - $(BL)removes the venv.$(RS)\n\
\n\
$(CY)venv$(RS)  - $(BL)creates the python venv.$(RS)\n\
$(CY)pip$(RS)   - $(BL)installs pip packages.$(RS)\n\
\n'

.PHONY: help
help:
	@printf $(HELP)

VENV ?= .venv

define activate
source $(VENV)/bin/activate;
endef

.PHONY: run
run: $(VENV)
	$(call activate) \
	./main.py

.PHONY: venv
venv: $(VENV)

$(VENV):
	python3 -m venv .venv

.PHONY: pip
pip: $(VENV)
	$(call activate) \
	python3 -m pip install -r requirements.txt

.PHONY: clean
clean:
	rm -fr$(V) $(VENV)

FORCE:
