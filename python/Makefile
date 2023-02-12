# NOTE: For targets, run `make help`. <skr>

ifeq ($(TRACE),yes)
XTRACE = -x
endif

SHELL = /usr/bin/env bash $(XTRACE)

C = ,

BD := $(shell tput bold)
BL := $(shell tput setaf 4)
CY := $(shell tput setaf 6)
RS := $(shell tput sgr0)

COMMITISH ?= @{u}
REVISION  ?= $(shell git rev-parse --abbrev-ref $(COMMITISH))
REMOTE    ?= $(shell cut -d/ -f1 <<<$(REVISION))
CONTAINER ?= $(shell basename $$(git remote get-url $(REMOTE)) .git)
MACHINE   ?= $(CONTAINER)

define cmd_vm
podman machine $(1) $(MACHINE);
endef

define vm_exists
podman machine inspect $(MACHINE) >/dev/null 2>&1; echo $$?
endef

define vm_running
state=$$(podman machine inspect $(MACHINE) 2>/dev/null | jq -r .[0].State); 
[[ $$state == running ]];
echo $$?
endef

define ovm_running
length=$$(podman machine list --format json |jq -r '[.[]|select(.Running==true)]|length');\
[[ $$length == 1 ]];\
echo $$?
endef

define stop_ovm
ovm=$$(podman machine list --format json |jq -r '.[]|select(.Running==true).Name');\
podman machine stop "$$ovm";
endef

define head_ctr
podman -c $(MACHINE) container $(1)
endef

define cmd_ctr
$(call head_ctr,$(1)) $(CONTAINER)
endef

define ctr_exists
$(call cmd_ctr,exists) 2>/dev/null; echo $$?
endef

.PHONY: help
help:
	@printf '\n\
$(BD)launch targets:$(RS)\n\
\n\
$(CY)vm$(RS)               - $(BL)machine init$(RS)\n\
$(CY)vm-on$(RS)            - $(BL)machine start$(RS)\n\
$(CY)vm-off$(RS)           - $(BL)machine stop$(RS)\n\
$(CY)vm-rs$(RS)            - $(BL)machine stop and start$(RS)\n\
$(CY)vm-rm$(RS)            - $(BL)machine rm$(RS)\n\
\n\
$(CY)ctr$(RS)              - $(BL)container create$(RS)\n\
$(CY)ctr-on$(RS)           - $(BL)container start$(RS)\n\
$(CY)ctr-rm$(RS)           - $(BL)container rm$(RS)\n\
\n'

.PHONY: vm
vm:
ifeq ($(shell $(call vm_exists)),125)
	$(call cmd_vm,init)
endif

.PHONY: vm-on
vm-on: vm
	$(if $(filter $(shell $(call vm_running)),1),\
	$(if $(filter $(shell $(call ovm_running)),0),\
	$(call stop_ovm))\
	$(call cmd_vm,start))

.PHONY: vm-off
vm-off:
	$(if $(filter $(shell $(call vm_running)),0),\
  $(call cmd_vm,stop))

.PHONY: vm-rm
vm-rm: vm-off
	$(if $(filter $(shell $(call vm_exists)),0),\
	$(call cmd_vm,rm --force))

.PHONY: vm-rs
ifeq ($(shell $(call vm_exists)),125)	
vm-rs: vm-off vm-on
	$(error machine $(MACHINE) does not exist.)
else
vm-rs: vm-off vm-on
endif

.PHONY: ctr
ctr: IMAGE = debian:bookworm-slim
ctr: vm-on
	$(if $(filter $(shell $(call ctr_exists)),1),\
	$(call head_ctr,create) \
	--tty \
  --interactive \
  --mount type=bind$(C)source=$(PWD)/src$(C)destination=/src \
  --name $(CONTAINER) \
  -- $(IMAGE))

.PHONY: ctr-on
ctr-on: ctr
	$(call cmd_ctr,start --attach)

.PHONY: ctr-rm
ctr-rm:
ifeq ($(shell $(call ctr_exists)),0)	
	$(call cmd_ctr,rm)
endif

FORCE:

