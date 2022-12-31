#███████████████████████████████████████████████████████████████████████████████████████████████████
#████ Makefile Forces - BASELINE
#███████████████████████████████████████████████████████████████████████████████████████████████████
FORCES_TOOLS_ENABLE_AZ := true
FORCES_TOOLS_ENABLE_TF := true
FORCES_TOOLS_ENABLE_GIT := true
FORCES_TOOLS_ENABLE_PSQL := true
FORCES_TOOLS_ENABLE_DOCKER := true
FORCES_TOOLS_ENABLE_INSTALL := true

-include .env.forces
FORCES_PATH ?= $(file < .make/FORCES)
ifeq ($(FORCES_PATH),)
  FORCES_PATH := $(file < ~/.make/FORCES)
endif

include $(FORCES_PATH)/main.mk


#███████████████████████████████████████████████████████████████████████████████████████████████████
#████ Development
#███████████████████████████████████████████████████████████████████████████████████████████████████

release-tag: /GACMTP ## [git/tag] push as new tag

release-tag-force: /GACMTPF ## [git/tag] force push as a tag

dev-home: ## [dev/home] Install forces in HOME
	$(M) $@+INFO
	set -x
	rm ~/.local/include/make -Rf
	python setup.py install --verbose --force
	find ~/.local/include/make

dev-local: ## [dev/local] Install forces in local dir
	$(M) $@+INFO
	set -x

	rm $(PWD)/.make -Rf
	PWD=$(PWD) python setup.py install --verbose --force
	rm -rf *.egg-info
	find $(PWD)/.make

####################################################################################################
#████ Tests
####################################################################################################


#===================================================================================================
#████ Static targets for a project
#===================================================================================================


api-render: ## [api/render]
	$(M) $@+INFO
	set -x
api-run: ## [api/run]
	$(M) $@+INFO
	set -x
api-test: ## [api/test]
	$(M) $@+INFO
	set -x
api-all: ## [api/all]
	$(M) $@+INFO
	set -x
api-destroy: ## [api/destroy]
api-init: ## [api/init]
api-plan: ## [api/plan]

web-render: ## [web/render]
web-run: ## [web/run]
web-test: ## [web/test]
web-all: ## [web/all]
web-destroy: ## [web/destroy]
web-init: ## [web/init]
web-plan: ## [web/plan]


#===================================================================================================
#████ Dynamic targets for terraform playbooks
#===================================================================================================

#=============================================================
#=== TF DECLARE
#=============================================================

DEV := local

PLAYBOOK_SAMPLE := sample

#-------------------------------------------------------------
#--- PLAYBOOK_REMOTE_BACKEND
#-------------------------------------------------------------

ENV := $(DEV)
PLAYBOOK := $(PLAYBOOK_SAMPLE)
include $(FORCES_TF_DECLARE) # call with `make @<TAB>` to expand

#=============================================================
#=== TF DEFINE
#=============================================================
include $(FORCES_TF_DEFINE)

FORCES_TF_RENDER := $(FORCES_PATH)/terraform/.samples/render.mk
# ? OR
# FORCES_TF_RENDER := $(PWD)/.make/terraform/render.mk

ifdef FORCES_TF_RENDER
include $(FORCES_TF_RENDER)
endif