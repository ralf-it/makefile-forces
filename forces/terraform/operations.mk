#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ Copyright 2020-2024 (c) RALF-IT LLC
#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ Licensed under the Apache License, Version 2.0 (the "License");
#███ you may not use this file except in compliance with the License.
#███ You may obtain a copy of the License at
#███
#███     https://raw.githubusercontent.com/ralf-it/makefile-forces/main/LICENSE.md
#███
#███ Unless required by applicable law or agreed to in writing, software
#███ distributed under the License is distributed on an "AS IS" BASIS,
#███ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#███ See the License for the specific language governing permissions and
#███ limitations under the License.
#███████████████████████████████████████████████████████████████████████████████████████████████████

-include .env.forces
FORCES_PATH ?= $(file < .make/FORCES)
ifeq ($(FORCES_PATH),)
  FORCES_PATH := $(file < ~/.make/FORCES)
endif

include $(FORCES_PATH)/main.mk

#███████████████████████████████████████████████████████████████████████████████████████████████████
ifdef PLAYBOOK
ifdef ENV

#===================================================================================================
#███ Common VARS
#===================================================================================================

PLAYBOOKS_DIR           := terraform/playbooks
PATH_PLAYBOOK           := $(PLAYBOOKS_DIR)/$(PLAYBOOK)
PATH_MODULES            := terraform/modules
PATH_ROOT_FROM_PLAYBOOK := $(shell echo $(PATH_PLAYBOOK) | sed 's:/*$$::' | awk -F '/' '{for(i=2; i<NF; i++) printf "../"; print ".."}')
PATH_TF_WORK            := ../../.terraform/$(PLAYBOOK)_$(ENV)
DIR_TF_STATES           := ../../.tfstates
DIR_CONFIGS             := ../../configs/$(ENV)
DIR_MODULES             := ../../modules
PATH_VARS               := $(DIR_CONFIGS)/vars.tfvars
PATH_SECRETS            := $(DIR_CONFIGS)/secrets.tfvars
PATH_VARS_TEAM          := $(DIR_CONFIGS)/vars_team.tfvars
PATH_VARS_PLAYBOOK      := $(DIR_CONFIGS)/vars_$(PLAYBOOK).tfvars
PATH_SECRETS_PLAYBOOK   := $(DIR_CONFIGS)/secrets_$(PLAYBOOK).tfvars
PATH_BACKEND_TFVAR      := $(DIR_CONFIGS)/backend_$(PLAYBOOK).tfvars

VAR_FILES               := -var-file=$(PATH_VARS) \
                           -var-file=$(PATH_VARS_PLAYBOOK) \
                           -var-file=$(PATH_VARS_TEAM) \
                           -var-file=$(PATH_SECRETS) \
                           -var-file=$(PATH_SECRETS_PLAYBOOK)

EXTRA_ARGS ?=

export PATH_TF_WORK

ifeq ($(wildcard $(PATH_PLAYBOOK)),)
$(error DIR $(PATH_PLAYBOOK) does not exist.)
endif

ifeq ($(wildcard $(PATH_PLAYBOOK)/$(PATH_VARS)),)
$(error FILE $(PATH_VARS) does not exist.)
endif

ifeq ($(wildcard $(PATH_PLAYBOOK)/$(PATH_VARS_PLAYBOOK)),)
$(error FILE $(PATH_VARS_PLAYBOOK) does not exist.)
endif

ifeq ($(wildcard $(PATH_PLAYBOOK)/$(DIR_TF_STATES)),)
$(shell mkdir -p $(PATH_PLAYBOOK)/$(DIR_TF_STATES))
endif

#===================================================================================================
#███ TF VARS
#===================================================================================================

# ! TFENV wont work without .terraform-version file in playbook

TFENV_AUTO_INSTALL       ?= true
TFENV_CURL_OUTPUT        ?= 0
TFENV_ARCH               ?= $(shell uname -m)

TF_DATA_DIR              := $(PATH_TF_WORK)/.init
PATH_TF_PLAN             := $(PATH_TF_WORK)/playbook.tfplan
PATH_TF_PLAN_JSON        := $(PATH_TF_WORK)/playbook.json
TF_CLI_ARGS_COMMON       := -input=false $(VAR_FILES)
TF_CLI_ARGS_validate     :=
PATH_TF_GRAPH_SVG        := .images/graph.svg
PATH_TF_GRAPH_DOT        := .images/graph.dot
PATH_TF_GRAPHS           := .images
DIR_TF_PLAN_VISUAL 	     := $(PATH_TF_WORK)/terraform-visual

# ! ERR Not expanding automatically if used implicitly in target, and replacing with $() give bad results
# TF_VAR_playbooks		 := `echo $(PLAYBOOKS) | jq -R 'split(" ") | map(select(length > 0))' -rc`
TF_VAR_playbooks         := $(PLAYBOOKS)

# ! TODO nmap is meesing with the screen in vscode hiding the cursor
# TF_VAR_nmap_path         := $(shell which nmap)

ROVER_CLI_ARGS_COMMON    := -showSensitive -name $(PLAYBOOK) -tfPath $(TF) -planPath $(PATH_TF_PLAN) -tfVarsFile $(PATH_VARS) -tfVarsFile $(PATH_VARS_PLAYBOOK)

ifeq ($(PLAYBOOK), $(PLAYBOOK_REMOTE_BACKEND))
PATH_TF_STATE            := $(DIR_TF_STATES)/$(PLAYBOOK)-$(ENV).tfstate
TF_CLI_ARGS_state        := -state $(PATH_TF_STATE)
TF_CLI_ARGS_init         := -backend=false
TF_CLI_ARGS_apply        := -input=false          -state $(PATH_TF_STATE) -auto-approve $(EXTRA_ARGS)
TF_CLI_ARGS_plan         := $(TF_CLI_ARGS_COMMON) -state $(PATH_TF_STATE) -out $(PATH_TF_PLAN) $(EXTRA_ARGS)
TF_CLI_ARGS_destroy      := $(TF_CLI_ARGS_COMMON) -state $(PATH_TF_STATE) $(EXTRA_ARGS)
TF_CLI_ARGS_import       := $(TF_CLI_ARGS_COMMON) -state $(PATH_TF_STATE)
TF_CLI_ARGS_refresh      := $(TF_CLI_ARGS_COMMON) -state $(PATH_TF_STATE)
TF_CLI_ARGS_force-unlock := $(TF_CLI_ARGS_COMMON) -state $(PATH_TF_STATE)
TF_CLI_ARGS_taint        := -state $(PATH_TF_STATE)
TF_CLI_ARGS_untaint      := -state $(PATH_TF_STATE)
TF_CLI_ARGS_output       := -state $(PATH_TF_STATE)
TF_CLI_ARGS_graph        := -module-depth=0
ROVER_CLI_ARGS           := $(ROVER_CLI_ARGS_COMMON)
else
PATH_TF_STATE            :=
TF_CLI_ARGS_state        :=
TF_CLI_ARGS_init         := -backend-config=$(PATH_BACKEND_TFVAR)
TF_CLI_ARGS_apply        := -input=false -auto-approve $(EXTRA_ARGS)
TF_CLI_ARGS_plan         := $(TF_CLI_ARGS_COMMON) -out $(PATH_TF_PLAN) $(EXTRA_ARGS)
TF_CLI_ARGS_destroy      := $(TF_CLI_ARGS_COMMON) $(EXTRA_ARGS)
TF_CLI_ARGS_import       := $(TF_CLI_ARGS_COMMON)
TF_CLI_ARGS_refresh      := $(TF_CLI_ARGS_COMMON)
TF_CLI_ARGS_force-unlock := $(TF_CLI_ARGS_COMMON)
TF_CLI_ARGS_taint        :=
TF_CLI_ARGS_untaint      :=
TF_CLI_ARGS_output       :=
TF_CLI_ARGS_graph        := -module-depth=0
ROVER_CLI_ARGS           := $(ROVER_CLI_ARGS_COMMON) -tfBackendConfig $(PATH_BACKEND_TFVAR)
endif

#===================================================================================================
#███ TF
#===================================================================================================

__tf-all__: .clear tf-fmt az-set-sub-$(ENV) ## (forces/wrapper/tf) All terraform
	$(M) $@+INFO
	set -x
	$(FORCES_TF_MAKE) __tf-init__
	$(FORCES_TF_MAKE) __tf-validate__
	$(FORCES_TF_MAKE) __tf-plan__
	$(FORCES_TF_MAKE) __tf-apply-plan__
	$(FORCES_TF_MAKE) __tf-output__
	$(FORCES_TF_MAKE) __tf-docs__
	$(FORCES_TF_MAKE) __tf-graph__


__tf-import__:  ## (forces/wrapper/tf) Import resource from cloud to tfstate
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
	$(TF) import --  $(ARGVN)

__tf-show__:  ## (forces/wrapper/tf) Show tfstate
	$(M) $@+INFO
	set -x
	echo ENV=$(ENV)
	echo PLAYBOOK=$(PLAYBOOK)

	echo PATH_VARS=$(PATH_VARS)
	echo PATH_TF_WORK=$(PATH_TF_WORK)
	echo PATH_TF_STATE=$(PATH_TF_STATE)
	echo PATH_PLAYBOOK=$(PATH_PLAYBOOK)

	echo TF_VAR_playbooks=${TF_VAR_playbooks}

	$(TF) -version

__tf-init__:  ## (forces/wrapper/tf) Init terraform
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
	$(TF)  init -reconfigure -upgrade

__tf-plan__:  ## (forces/wrapper/tf) Plan terraform
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
ifdef TARGET
	$(TF) plan -target $(TARGET)
else
	$(TF) plan
endif

__tf-apply-plan__:  ## (forces/wrapper/tf) Apply terraform
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
ifdef TARGET
	$(TF)  apply -target $(TARGET) $(PATH_TF_PLAN)
else
	$(TF)  apply $(PATH_TF_PLAN)
endif

__tf-apply__:  ## (forces/wrapper/tf) Apply terraform
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
ifdef TARGET
	$(TF)  apply -target $(TARGET) $(TF_CLI_ARGS_COMMON)
else
	$(TF)  apply $(TF_CLI_ARGS_COMMON)
endif

__tf-output__:  ## (forces/wrapper/tf) Output terraform
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
	$(TF)  output -json | tee $(PATH_TF_WORK)/output.json

__tf-validate__:  ## (forces/wrapper/tf) Validate terraform
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
	$(TF)  validate

__tf-destroy__:  ## (forces/wrapper/tf) Destroy terraform
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
	$(TF) destroy

__tf-state-list__:  ## (forces/wrapper/tf) List tfstate
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
	$(TF) state list

__tf-state-rm__:   ## (forces/wrapper/tf) Remove tfstate
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)

	ADDRESSES=`echo '$(ARGVN)' | tr '\n' ' '`

	$(TF) state rm $$ADDRESSES

#---------------------------------------------------------------------------------------------------
#███ TF CHECKS
#---------------------------------------------------------------------------------------------------

__tf-lint-modules__:  tf-fmt ## (forces/wrapper/tf) Lint terraform modules
	$(M) $@+INFO
	set -x
	cd $(PATH_MODULES)
	tflint --init --config $(PWD)/.tflint.tf
	tflint \
		--config $(PWD)/.tflint.tf \
		--recursive \
		--color \
		# --fix # ! FIX with caution

__tf-lint-playbook__:  tf-fmt ## (forces/wrapper/tf) Lint terraform playbook
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
	tflint --init --config $(PWD)/.tflint.tf
	tflint \
		--config $(PWD)/.tflint.tf \
		--var-file=$(PATH_VARS) \
		--var-file=$(PATH_VARS_PLAYBOOK) \
		--call-module-type=all \
		--recursive \
		--color \
		--fix # ! FIX with caution

__tf-lint__: tf-fmt ## (forces/wrapper/tf) Lint terraform
# $(MW) __tf-lint-modules__
	$(M) $@+INFO
	set -x
	$(FORCES_TF_MAKE) __tf-lint-playbook__

#---------------------------------------------------------------------------------------------------
#███ TF DOCS
#---------------------------------------------------------------------------------------------------

__tf-docs__: tf-fmt ## (forces/wrapper/tf) Generate terraform docs
	$(M) $@+INFO
	set -x

	find $(PATH_MODULES) -type d \
	-not -path '*/.*' \
	-not -path '*/assets*' \
	-not -path '*/*modules' \
		| xargs -I {} \
			terraform-docs {} -c .terraform-docs.yml

	ls $(PLAYBOOKS_DIR) \
		| xargs -I {} \
			terraform-docs $(PLAYBOOKS_DIR)/{} -c .terraform-docs.yml

#---------------------------------------------------------------------------------------------------
#███ TF graph
#---------------------------------------------------------------------------------------------------

__tf-graph__: tf-fmt ## (forces/wrapper/tf) Generate terraform graph with default summarization of resources
	$(M) $@+INFO
	set -x

	cd $(PATH_PLAYBOOK)
	mkdir -p $(PATH_TF_GRAPHS)
	$(TF) graph > $(PATH_TF_GRAPH_DOT) && dot -Tsvg $(PATH_TF_GRAPH_DOT) -o $(PATH_TF_GRAPH_SVG)


__tf-graph-apply__: tf-fmt ## (forces/wrapper/tf) Generate terraform graph with extended view of resources given by apply operation
	$(M) $@+INFO
	set -x

	cd $(PATH_PLAYBOOK)
	mkdir -p $(PATH_TF_GRAPHS)
	$(TF) graph -type=apply > $(PATH_TF_GRAPH_DOT) && dot -Tsvg $(PATH_TF_GRAPH_DOT) -o $(PATH_TF_GRAPH_SVG)

__tf-graph-plan__: tf-fmt ## (forces/wrapper/tf) Generate terraform graph with extended view of resources given by plan operation
	$(M) $@+INFO
	set -x

	cd $(PATH_PLAYBOOK)
	mkdir -p $(PATH_TF_GRAPHS)
	$(TF) graph -type=plan > $(PATH_TF_GRAPH_DOT) && dot -Tsvg $(PATH_TF_GRAPH_DOT) -o $(PATH_TF_GRAPH_SVG)

#---------------------------------------------------------------------------------------------------
#███ TF visualise
#---------------------------------------------------------------------------------------------------

__tf-visualise__: tf-fmt ## (forces/wrapper/tf) Render and open terraform visualisation in browser based on tf plan
	$(M) $@+INFO
	set -x

	set +x
	$(M) $@+WARN -- Not implemented yet, crashing on too big plan files.

	# cd $(PATH_PLAYBOOK)
	# terraform show -json $(PATH_TF_PLAN) > $(PATH_TF_PLAN_JSON)
	# cd $(PATH_TF_WORK)

	# (
	# 	sleep 3 && open http://0.0.0.0:9000
	# ) &

	# docker run --rm -it -p 9000:9000 -v ./:/src im2nguyen/rover:latest -planJSONPath=playbook.json

	# # docker run --rm -it -p 9000:9000 -v "$(PATH_PLAYBOOK):/src" im2nguyen/rover -tfBackendConfig test.tfbackend -tfVarsFile test.tfvars -tfVar max_length=4

endif # ENV
endif # PLAYBOOK_SELECTED
#███████████████████████████████████████████████████████████████████████████████████████████████████

