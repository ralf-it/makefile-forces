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

# ! Does not work with `make $<tab>` to show targets

# ! Hack needed to have `make <tab>` work with targets ...
# ! ... Due that PLAYBOOK/ENV will not persist inside target ...
# ! ... (will be overwritten by latest set PLAYBOOK/ENV from Makefile)
#███████████████████████████████████████████████████████████████████████████████████████████████████
ifdef PLAYBOOK
ifdef ENV

#===================================================================================================
#███ Check ENV and PLAYBOOK
#===================================================================================================

ifneq ($(findstring +,$(PLAYBOOK)),)
	$(error PLAYBOOK $(PLAYBOOK) name cannot contain '+')
endif

ifneq ($(findstring +,$(ENV)),)
	$(error ENV $(ENV) name cannot contain '+')
endif

#===================================================================================================
#███ TF link
#===================================================================================================

@$(PLAYBOOK)-$(ENV)-tf-show:               $(PLAYBOOK)+$(ENV)+tf-show                ## (forces/declare/TF) Show tfstate
@$(PLAYBOOK)-$(ENV)-tf-init:               $(PLAYBOOK)+$(ENV)+tf-init                ## (forces/declare/TF) Init terraform
@$(PLAYBOOK)-$(ENV)-tf-plan:               $(PLAYBOOK)+$(ENV)+tf-plan                ## (forces/declare/TF) Plan terraform
@$(PLAYBOOK)-$(ENV)-tf-taint:              $(PLAYBOOK)+$(ENV)+tf-taint               ## (forces/declare/TF) Taint terraform
@$(PLAYBOOK)-$(ENV)-tf-apply:              $(PLAYBOOK)+$(ENV)+tf-apply               ## (forces/declare/TF) Apply terraform
@$(PLAYBOOK)-$(ENV)-tf-apply-plan:         $(PLAYBOOK)+$(ENV)+tf-apply-plan          ## (forces/declare/TF) Apply terraform
@$(PLAYBOOK)-$(ENV)-tf-destroy:            $(PLAYBOOK)+$(ENV)+tf-destroy             ## (forces/declare/TF) Apply destroy terraform
@$(PLAYBOOK)-$(ENV)-tf-destroy-plan:       $(PLAYBOOK)+$(ENV)+tf-destroy-plan        ## (forces/declare/TF) Apply destroy terraform
@$(PLAYBOOK)-$(ENV)-tf-output:             $(PLAYBOOK)+$(ENV)+tf-output              ## (forces/declare/TF) Output terraform
@$(PLAYBOOK)-$(ENV)-tf-validate:           $(PLAYBOOK)+$(ENV)+tf-validate            ## (forces/declare/TF) Validate terraform
@$(PLAYBOOK)-$(ENV)-tf-destroy:            $(PLAYBOOK)+$(ENV)+tf-destroy             ## (forces/declare/TF) Destroy terraform
@$(PLAYBOOK)-$(ENV)-tf-all:                $(PLAYBOOK)+$(ENV)+tf-all                 ## (forces/declare/TF) All terraform
@$(PLAYBOOK)-$(ENV)-tf-import:             $(PLAYBOOK)+$(ENV)+tf-import              ## (forces/declare/TF) Import resources to tfstate
@$(PLAYBOOK)-$(ENV)-tf-state-mv:           $(PLAYBOOK)+$(ENV)+tf-state-mv            ## (forces/declare/TF) Move item in the tfstate
@$(PLAYBOOK)-$(ENV)-tf-state-rm:           $(PLAYBOOK)+$(ENV)+tf-state-rm            ## (forces/declare/TF) Remove tfstate
@$(PLAYBOOK)-$(ENV)-tf-state-list:         $(PLAYBOOK)+$(ENV)+tf-state-list          ## (forces/declare/TF) List tfstate
@$(PLAYBOOK)-$(ENV)-tf-providers-mirror:   $(PLAYBOOK)+$(ENV)+tf-providers-mirror    ## (forces/declare/TF) Providers mirror

#===================================================================================================
#███ TF checks
#===================================================================================================

@$(PLAYBOOK)-$(ENV)-tf-lint: $(PLAYBOOK)+$(ENV)+tf-lint ## (forces/declare/TF) Lint terraform

#===================================================================================================
#███ TF docs link
#===================================================================================================

@$(PLAYBOOK)-$(ENV)-tf-docs: $(PLAYBOOK)+$(ENV)+tf-docs ## (forces/declare/TF) Generate terraform docs

#===================================================================================================
#███ TF Graph(viz) link
#===================================================================================================


@$(PLAYBOOK)-$(ENV)-tf-graph:       $(PLAYBOOK)+$(ENV)+tf-graph ## (forces/declare/TF) Graph plan
@$(PLAYBOOK)-$(ENV)-tf-graph-plan:  $(PLAYBOOK)+$(ENV)+tf-graph-plan ## (forces/declare/TF) Graph plan
@$(PLAYBOOK)-$(ENV)-tf-graph-apply: $(PLAYBOOK)+$(ENV)+tf-graph-apply ## (forces/declare/TF) Graph apply from plan file

#===================================================================================================
#███ TF visualise link
#===================================================================================================

@$(PLAYBOOK)-$(ENV)-tf-visualise:   $(PLAYBOOK)+$(ENV)+tf-visualise ## (forces/declare/TF) Visualize plan

#===================================================================================================
#███ TF State
#===================================================================================================

@$(PLAYBOOK)-$(ENV)-tf-state-az-whitelist:   $(PLAYBOOK)+$(ENV)+tf-state-az-whitelist ## (forces/declare/TF) Whitelist TF State in AZ Account

endif # ENV
endif # PLAYBOOK
#███████████████████████████████████████████████████████████████████████████████████████████████████
