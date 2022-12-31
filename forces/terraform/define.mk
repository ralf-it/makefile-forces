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

# ! Does not work with `make %<tab>` to show targets
#███████████████████████████████████████████████████████████████████████████████████████████████████

#===================================================================================================
#███ TF define
#===================================================================================================

%+tf-show: ## (forces/define/TF) Show terraform infos for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-show__

%+tf-providers-mirror: ## (forces/define/TF) Init terraform for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-providers-mirror__

%+tf-taint: ## (forces/define/TF) Taint terraform ADDR for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

ifneq ($(ARGVN),)
	$(FORCES_TF_MAKE) __tf-taint__ `echo '$(ARGVN)'`
else
	$(FORCES_TF_MAKE) __tf-taint__
endif

%+tf-init: ## (forces/define/TF) Init terraform for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-init__

%+tf-plan: ## (forces/define/TF) Plan terraform for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-plan__

%+tf-apply: ## (forces/define/TF) Apply terraform for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-apply__

%+tf-apply-plan: ## (forces/define/TF) Apply terraform for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-apply-plan__

%+tf-destroy: ## (forces/define/TF) Apply terraform for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-destroy__

%+tf-destroy-plan: ## (forces/define/TF) Apply terraform for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-destroy-plan__


%+tf-validate: ## (forces/define/TF) Validate terraform for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-validate__

%+tf-destroy: ## (forces/define/TF) Destroy terraform for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-destroy__

%+tf-output: ## (forces/define/TF) Output terraform for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-output__

%+tf-all: ## (forces/define/TF) All terraform for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-all__

%+tf-import: ## (forces/define/TF) Imports terraform for ENV & PLAYBOOK. NOTE: call with  ... 'type[\"key\"].item'    "/subscriptions/..."
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-import__ '$(ARGVN)'

%+tf-state-rm:  ## (forces/define/TF) Remove tfstate for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

ifneq ($(ARGVN),)
	$(FORCES_TF_MAKE) __tf-state-rm__ `echo '$(ARGVN)'`
else
	$(FORCES_TF_MAKE) __tf-state-rm__
endif

%+tf-state-mv:  ## (forces/define/TF) Move item in the tfstate for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

ifneq ($(ARGVN),)
	$(FORCES_TF_MAKE) __tf-state-mv__ `echo '$(ARGVN)'`
else
	$(FORCES_TF_MAKE) __tf-state-mv__
endif


%+tf-state-list:  ## (forces/define/TF) List tfstate for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

ifneq ($(ARGVN),)
	$(FORCES_TF_MAKE) __tf-state-list__ `echo '$(ARGVN)'`
else
	$(FORCES_TF_MAKE) __tf-state-list__
endif

%+get-tfstate-sa-name: ## (forces/define/AZ) Get tfstate sa name for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __get-tfstate-sa-name__

#===================================================================================================
#███ TF Graph(viz) define
#===================================================================================================

%+tf-graph: ## (forces/define/TF) Plan graph for terraform for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-graph__


%+tf-graph-plan: ## (forces/define/TF) Plan graph for terraform for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-graph-plan__

%+tf-graph-apply: ## (forces/define/TF) Apply graph for terraform for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-graph-apply__

#===================================================================================================
#███ TF Visualize define
#===================================================================================================

%+tf-visualise: ## (forces/define/TF) Apply graph for terraform for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-visualise__

#===================================================================================================
#███ TF Checks
#===================================================================================================

%+tf-lint: ## (forces/define/TF) Lint terraform for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-lint__

#===================================================================================================
#███ TF docs define
#===================================================================================================

%+tf-docs: ## (forces/define/TF) Generate terraform docs for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	echo ENV=$$ENV
	echo PLAYBOOK=$$PLAYBOOK

	$(FORCES_TF_MAKE) __tf-docs__

	echo $*, $@, $(MAKECMDGOALS), $(ARGV0), $(ARGVN), $(ARGV)

#===================================================================================================
#███ TF State
#===================================================================================================

%+tf-state-az-whitelist: ## (forces/define/TF) Lint terraform for ENV & PLAYBOOK
	export ENVPLAYBOOK=$*
	export ENV=`echo $$ENVPLAYBOOK | cut -d'+' -f2`
	export PLAYBOOK=`echo $$ENVPLAYBOOK | cut -d'+' -f1`

	$(FORCES_TF_MAKE) __tf-state-az-whitelist__


#███████████████████████████████████████████████████████████████████████████████████████████████████
