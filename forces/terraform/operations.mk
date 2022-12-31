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

#███████████████████████████████████████████████████████████████████████████████████████████████████
ifdef PLAYBOOK
ifdef ENV


#===================================================================================================
#███ Common VARS
#===================================================================================================

PLAYBOOKS_DIR           ?= terraform/playbooks
PATH_MODULES            ?= terraform/modules
DIR_MODULES             ?= ../../modules


PATH_PLAYBOOK           := $(PLAYBOOKS_DIR)/$(PLAYBOOK)
PATH_ROOT_FROM_PLAYBOOK := $(shell echo $(PATH_PLAYBOOK) | sed 's:/*$$::' | awk -F '/' '{for(i=2; i<NF; i++) printf "../"; print ".."}')
PATH_TF_WORK            := ../../.terraform/$(PLAYBOOK)_$(ENV)
PATH_TF_USER_LOGS       := ../../.terraform/$(PLAYBOOK)_$(ENV)/logs
DIR_TF_STATES           := ../../.tfstates
DIR_CONFIGS             := ../../configs/$(ENV)
PATH_VARS               := $(DIR_CONFIGS)/vars.tfvars
PATH_SECRETS            := $(DIR_CONFIGS)/secrets.tfvars
PATH_VARS_TEAM          := $(DIR_CONFIGS)/vars_team.tfvars
PATH_VARS_PLAYBOOK      := $(DIR_CONFIGS)/vars_$(PLAYBOOK).tfvars
PATH_SECRETS_PLAYBOOK   := $(DIR_CONFIGS)/secrets_$(PLAYBOOK).tfvars
PATH_BACKEND_TFVAR      := $(DIR_CONFIGS)/backend_$(PLAYBOOK).tfvars

ifeq ($(TF_USE_LOCAL_SECRET_FILES),true)
    VAR_FILES           := -var-file=$(PATH_VARS) \
                           -var-file=$(PATH_VARS_PLAYBOOK) \
                           -var-file=$(PATH_VARS_TEAM) \
                           -var-file=$(PATH_SECRETS) \
                           -var-file=$(PATH_SECRETS_PLAYBOOK)
else
    VAR_FILES           := -var-file=$(PATH_VARS) \
                           -var-file=$(PATH_VARS_PLAYBOOK) \
                           -var-file=$(PATH_VARS_TEAM)
endif

EXTRA_ARGS              ?=

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

TF_PLUGIN_CACHE_DIR      ?= $(HOME)/.terraform.d/plugin-cache/$(PLAYBOOK)/$(ENV)
TF_CLI_CONFIG_FILE       ?= $(PWD)/.terraform.tfrc
TERRAFORM_CONFIG          = $(TF_CLI_CONFIG_FILE)

TF_LOG                   ?= TRACE
TF_LOG_PATH              := $(PWD)/terraform/.terraform/$(PLAYBOOK)_$(ENV)/logs/$(shell date +"%s").log
ifeq ($(wildcard $(TF_LOG_PATH)),)
$(info Create $(TF_LOG_PATH))
$(shell mkdir -p $(PWD)/terraform/.terraform/$(PLAYBOOK)_$(ENV)/logs)
$(shell touch $(TF_LOG_PATH))
endif

ifeq ($(wildcard $(TF_PLUGIN_CACHE_DIR)),)
$(shell mkdir -p $(TF_PLUGIN_CACHE_DIR))
endif

ifeq ($(wildcard $(TF_CLI_CONFIG_FILE)),)
$(shell touch $(TF_CLI_CONFIG_FILE))
endif

## TODO static or file based path?
## TODO ...
# ifneq ($(wildcard $(TF_CLI_CONFIG_FILE)),)
#     # TF_MIRROR_LOCAL_PATH__   ?= $(shell cat $(TF_CLI_CONFIG_FILE) | yj -cj | jq .provider_installation[0].filesystem_mirror[0].path -r 2>null || echo "")
#     ifneq ($(TF_MIRROR_LOCAL_PATH__),)
#         TF_MIRROR_LOCAL_PATH       ?= $(TF_MIRROR_LOCAL_PATH__)
#     else
#         TF_MIRROR_LOCAL_PATH       ?= /usr/local/share/terraform/providers
#     endif
# endif

TF_MIRROR_LOCAL_PATH     ?= /usr/local/share/terraform/providers

# ! ERR Not expanding automatically if used implicitly in target, and replacing with $() give bad results
# TF_VAR_playbooks		 := `echo $(PLAYBOOKS) | jq -R 'split(" ") | map(select(length > 0))' -rc`
TF_VAR_playbooks         := $(PLAYBOOKS)

# ! TODO nmap is meesing with the screen in vscode hiding the cursor
# TF_VAR_nmap_path         := $(shell which nmap)

ROVER_CLI_ARGS_COMMON    := -showSensitive -name $(PLAYBOOK) -tfPath $(TF) -planPath $(PATH_TF_PLAN) -tfVarsFile $(PATH_VARS) -tfVarsFile $(PATH_VARS_PLAYBOOK)

#---------------------------------------------------------------------------------------------------
#███ TF VARS - remote/local state
#---------------------------------------------------------------------------------------------------

TF_VAR_custom_logs_dir   := $(PATH_TF_USER_LOGS)

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

#---------------------------------------------------------------------------------------------------
#███ TF VARS - az
#---------------------------------------------------------------------------------------------------

ARM_TENANT_ID            ?= $(AZ_TENANT_ID_$(shell echo $(ENV) | tr a-z A-Z))
ARM_SUBSCRIPTION_ID      := $(AZ_SUBSCRIPTION_ID_$(shell echo $(ENV) | tr a-z A-Z))

ARM_CLIENT_ID            ?= $(AZ_CLIENT_ID_$(shell echo $(ENV) | tr a-z A-Z))
ARM_CLIENT_SECRET        ?= $(AZ_CLIENT_SECRET_$(shell echo $(ENV) | tr a-z A-Z))

#===================================================================================================
#███ TF
#===================================================================================================
# $(M) $@+INFO -- "NOTE: Using TF_PLUGIN_CACHE_DIR($(TF_PLUGIN_CACHE_DIR)) for terraform providers caching."

__tf-all__:  .clear /tf-fmt /az-set-sub-$(ENV) ## (forces/wrapper/tf) All terraform
	$(M) $@+INFO

	$(M) $@+INFO -- "NOTE: Using TF_CLI_CONFIG_FILE($(TF_CLI_CONFIG_FILE)) for terraform tuning."

	$(FORCES_TF_MAKE) __tf-init__
	$(FORCES_TF_MAKE) __tf-validate__
	$(FORCES_TF_MAKE) __tf-plan__
	$(FORCES_TF_MAKE) __tf-apply-plan__

	if [ "$(TF_OUTPUT_ENABLED)" == "true" ]
	then
		$(FORCES_TF_MAKE) __tf-output__
	fi


	if [ "$(TF_DOCS_ENABLED)" == "true" ]
	then
		$(FORCES_TF_MAKE) __tf-docs__
	fi

__tf-taint__:  /tf-fmt /az-set-sub-$(ENV) ## (forces/wrapper/tf) Import resource from cloud to tfstate. NOTE: call with  ... 'type[\"key\"].item'    "/subscriptions/..."
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
	$(TF) taint --  $(ARGVN)

__tf-import__:  /tf-fmt /az-set-sub-$(ENV) ## (forces/wrapper/tf) Import resource from cloud to tfstate. NOTE: call with  ... 'type[\"key\"].item'    "/subscriptions/..."
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
	$(TF) import --  $(ARGVN)

__tf-show__: /tf-fmt  ## (forces/wrapper/tf) Show tfstate
	$(M) $@+INFO
	set -x
	echo ENV=$(ENV)
	echo PLAYBOOK=$(PLAYBOOK)

	echo PATH_VARS=$(PATH_VARS)
	echo PATH_TF_WORK=$(PATH_TF_WORK)
	echo PATH_TF_STATE=$(PATH_TF_STATE)
	echo PATH_PLAYBOOK=$(PATH_PLAYBOOK)

	echo TF_VAR_playbooks=${TF_VAR_playbooks}

	echo TF_PLUGIN_CACHE_DIR=$(TF_PLUGIN_CACHE_DIR)
	echo TF_CLI_CONFIG_FILE=$(TF_CLI_CONFIG_FILE)

	$(TF) -version

__tf-providers-mirror__: /tf-fmt ## (forces/wrapper/tf) Download providers as a zip to local DIR
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
ifeq ($(TF_MIRROR_LOCAL_PATH),)
	$(M) $@+ERROR -- "TF_MIRROR_LOCAL_PATH value can not be empty."
else
	$(TF) providers mirror $(TF_MIRROR_LOCAL_PATH)
endif

__tf-init__: /tf-fmt /az-set-sub-$(ENV)  ## (forces/wrapper/tf) Init terraform
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
	$(TF)  init -reconfigure -upgrade

__tf-plan__: /tf-fmt /az-set-sub-$(ENV) ## (forces/wrapper/tf) Plan terraform
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
ifdef TARGET
	$(TF) plan -target $(TARGET)
else
	$(TF) plan
endif

__tf-apply-plan__: /tf-fmt /az-set-sub-$(ENV) ## (forces/wrapper/tf) Apply terraform
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
ifdef TARGET
	$(TF)  apply -target $(TARGET) $(PATH_TF_PLAN)
else
	$(TF)  apply $(PATH_TF_PLAN)
endif

__tf-apply__:  /tf-fmt /az-set-sub-$(ENV) ## (forces/wrapper/tf) Apply terraform
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
ifdef TARGET
	$(TF)  apply -target $(TARGET) $(TF_CLI_ARGS_COMMON)
else
	$(TF)  apply $(TF_CLI_ARGS_COMMON)
endif

__tf-destory-plan__: /tf-fmt /az-set-sub-$(ENV) ## (forces/wrapper/tf) Apply terraform
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
ifdef TARGET
	$(TF)  apply -destroy -target $(TARGET) $(PATH_TF_PLAN)
else
	$(TF)  apply -destroy $(PATH_TF_PLAN)
endif

__tf-destroy__: /tf-fmt /az-set-sub-$(ENV) ## (forces/wrapper/tf) Destroy terraform
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
	$(TF) destroy
ifdef TARGET
	$(TF)  apply -destroy -target $(TARGET) $(TF_CLI_ARGS_COMMON)
else
	$(TF)  apply -destroy $(TF_CLI_ARGS_COMMON)
endif

__tf-output__: /tf-fmt /az-set-sub-$(ENV) ## (forces/wrapper/tf) Output terraform
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
	$(TF)  output -json | tee $(PATH_TF_WORK)/output.json

__tf-validate__: /tf-fmt /az-set-sub-$(ENV) ## (forces/wrapper/tf) Validate terraform
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
	$(TF)  validate

__tf-state-list__: /tf-fmt /az-set-sub-$(ENV) ## (forces/wrapper/tf) List tfstate
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)
	$(TF) state list

__tf-state-rm__: /tf-fmt /az-set-sub-$(ENV) ## (forces/wrapper/tf) Remove tfstate
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)

	ADDRESSES=`echo '$(ARGVN)' | tr '\n' ' '`

	$(TF) state rm $$ADDRESSES

__tf-state-mv__: /tf-fmt /az-set-sub-$(ENV) ## (forces/wrapper/tf) Move item in the tfstate
	$(M) $@+INFO
	set -x
	cd $(PATH_PLAYBOOK)

	ADDRESSES=`echo '$(ARGVN)' | tr '\n' ' '`

	$(TF) state mv $$ADDRESSES

#---------------------------------------------------------------------------------------------------
#███ TF CHECKS
#---------------------------------------------------------------------------------------------------

__tf-lint-modules__:  /tf-fmt ## (forces/wrapper/tf) Lint terraform modules
	$(M) $@+INFO
	set -x

	$(M) /tf-lint-modules

__tf-lint-playbook__:  /tf-fmt ## (forces/wrapper/tf) Lint terraform playbook
	$(M) $@+INFO
	set -x

	$(M) /tf-lint-playbook

__tf-lint__: tf-fmt ## (forces/wrapper/tf) Lint terraform
# $(MW) __tf-lint-modules__
	$(M) $@+INFO
	set -x
	$(FORCES_TF_MAKE) __tf-lint-playbook__

#---------------------------------------------------------------------------------------------------
#███ TF DOCS
#---------------------------------------------------------------------------------------------------

__tf-docs__: /tf-fmt ## (forces/wrapper/tf) Generate terraform docs
	$(M) $@+INFO
	set -x

	$(M) /tf-docs

#---------------------------------------------------------------------------------------------------
#███ TF graph
#---------------------------------------------------------------------------------------------------

__tf-graph__: /tf-fmt ## (forces/wrapper/tf) Generate terraform graph with default summarization of resources
	$(M) $@+INFO
	set -x

	cd $(PATH_PLAYBOOK)
	mkdir -p $(PATH_TF_GRAPHS)
	$(TF) graph > $(PATH_TF_GRAPH_DOT) && dot -Tsvg $(PATH_TF_GRAPH_DOT) -o $(PATH_TF_GRAPH_SVG)


__tf-graph-apply__: /tf-fmt ## (forces/wrapper/tf) Generate terraform graph with extended view of resources given by apply operation
	$(M) $@+INFO
	set -x

	cd $(PATH_PLAYBOOK)
	mkdir -p $(PATH_TF_GRAPHS)
	$(TF) graph -type=apply > $(PATH_TF_GRAPH_DOT) && dot -Tsvg $(PATH_TF_GRAPH_DOT) -o $(PATH_TF_GRAPH_SVG)

__tf-graph-plan__: /tf-fmt ## (forces/wrapper/tf) Generate terraform graph with extended view of resources given by plan operation
	$(M) $@+INFO
	set -x

	cd $(PATH_PLAYBOOK)
	mkdir -p $(PATH_TF_GRAPHS)
	$(TF) graph -type=plan > $(PATH_TF_GRAPH_DOT) && dot -Tsvg $(PATH_TF_GRAPH_DOT) -o $(PATH_TF_GRAPH_SVG)

#---------------------------------------------------------------------------------------------------
#███ TF visualise
#---------------------------------------------------------------------------------------------------

__tf-visualise__: /tf-fmt ## (forces/wrapper/tf) Render and open terraform visualisation in browser based on tf plan
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

#---------------------------------------------------------------------------------------------------
#███ TF State
#---------------------------------------------------------------------------------------------------

__tf-state-az-whitelist__: /tf-fmt /az-set-sub-$(ENV) ## (forces/wrapper/tf) Whitelist IP for tfstate in azure storage account
	$(M) $@+INFO
	set -x

	if [ "$(TF_STATE_RESOURCE_GROUP_NAME)" == "" ]
	then
		$(M) $@+ERROR -- TF_STATE_RESOURCE_GROUP_NAME is not set
		exit 1
	fi

	if [ "$(TF_STATE_STORAGE_ACCOUNT_NAME)" == "" ]
	then
		$(M) $@+ERROR -- TF_STATE_STORAGE_ACCOUNT_NAME is not set
		exit 1
	fi

	AZ_RG_NAME=$(TF_STATE_RESOURCE_GROUP_NAME) \
	AZ_SA_NAME=$(TF_STATE_STORAGE_ACCOUNT_NAME) \
	$(M) /az-storage-whitelist-ip

endif # ENV
endif # PLAYBOOK_SELECTED
#███████████████████████████████████████████████████████████████████████████████████████████████████

