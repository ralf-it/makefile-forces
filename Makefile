include forces/.samples/forces.mk
# ? OR
# include $(PWD)/.make/forces.mk

#███████████████████████████████████████████████████████████████████████████████████████████████████
#████ Development
#███████████████████████████████████████████████████████████████████████████████████████████████████

release-tag: /GACMTP ## [git/tag] push as new tag

release-tag-force: /GACMTPF ## [git/tag] force push as a tag

install-tag: ## [install/tag] Install forces
	$(M) $@+INFO
	set -x
	pip install git+https://github.com/ralf-it/makefile-forces.git@v3.0.6 --verbose --force
	$(M) make /install-acme-sh-contrib

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
PLAYBOOK_REMOTE_BACKEND := remote-backend
AZ_SUBSCRIPTION_LOCAL_ID := dummy1
AZ_TENANT_ID := dummy2

PLAYBOOKS := $(PLAYBOOK_SAMPLE) \
             $(PLAYBOOK_REMOTE_BACKEND)

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
