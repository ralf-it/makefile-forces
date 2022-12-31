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
#███ TERRAFORM
#███████████████████████████████████████████████████████████████████████████████████████████████████

####################################################################################################
#████ VARS
####################################################################################################

TF                        ?= $(shell which terraform)
TFENV                     ?= $(shell which tfenv)

TF_USE_LOCAL_SECRET_FILES ?= true
TF_DOCS_ENABLED           ?= true
TF_OUTPUT_ENABLED         ?= true

FORCES_TF_DECLARE         := $(FORCES_PATH)/terraform/declare.mk
FORCES_TF_DEFINE          := $(FORCES_PATH)/terraform/define.mk
FORCES_TF_OPERATIONS      := $(FORCES_PATH)/terraform/operations.mk
FORCES_TF_MAKE            := time gmake -f $(FORCES_PATH)/main.mk -f $(FORCES_TF_OPERATIONS)

####################################################################################################
#████ RENDER
####################################################################################################

ifdef FORCES_TF_RENDER
    ifneq ($(wildcard $(FORCES_TF_RENDER)),)
        include $(FORCES_TF_RENDER)
    endif
endif

####################################################################################################
#████ TARGETS
####################################################################################################

/tf-fmt: ## {forces/terraform} format terraform files
	$(M) $@+INFO
	set -x
	cd terraform || true
	$(TF) fmt -recursive

/tf-copy-sample-render: ## {forces/terraform} copy terraform sample render to .make/terraform
	$(M) $@+INFO
	set -x
	mkdir -p .make/terraform
	echo cp -r $(FORCES_PATH)/terraform/.samples/render.mk .make/terraform/render.mk
	$(M) .WARN -- "Define var 'FORCES_TF_RENDER := .make/terraform/render.mk' in your Makefile"

/tf-setup: /tf-setup-tf-tools ## {forces/terraform} setup terraform directories and tools
	$(M) $@+INFO
	set -x
	mkdir -p terraform/{modules,configs,playbooks}
	mkdir -p terraform/playbooks/{stateless,stateful,pre.tf-remote-backend,pre.firewall-whitelister}
	mkdir -p configs/{dev,qa,stag,prod}

/tf-setup-tf-tools: ## {forces/terraform} setup terraform tools (tfenv, tflint, tfsec, terraform-docs)
	cp -n $(FORCES_PATH)/terraform/.configs/.terraform-docs.yml ./
	cp -n $(FORCES_PATH)/terraform/.configs/.terraform-version  ./
	cp -n $(FORCES_PATH)/terraform/.configs/.tflint.tf          ./
	cp -n $(FORCES_PATH)/terraform/.configs/.terraform.tfrc     ./

/tf-docs:  ## {forces/terraform} generate terraform documentation
	$(M) $@+INFO
	set -x

	if [ "$(PATH_MODULES)" != "" ]
	then
		find $(PATH_MODULES) -type d \
		-not -path '*/.*' \
		-not -path '*/assets*' \
		-not -path '*/*modules' \
			| xargs -I {} \
				terraform-docs {} -c .terraform-docs.yml
	else
		set +x
		$(M) $@+WARN -- "PATH_MODULES is not set. Skipping modules docs generation."
	fi

	if [ "$(PLAYBOOKS_DIR)" != "" ]
	then
		ls $(PLAYBOOKS_DIR) \
			| xargs -I {} \
				terraform-docs $(PLAYBOOKS_DIR)/{} -c .terraform-docs.yml
	else
		set +x
		$(M) $@+WARN -- "PLAYBOOKS_DIR is not set. Skipping playbook docs generation."
	fi


/tf-lint-modules:   ## (forces/wrapper/tf) Lint terraform modules
	$(M) $@+INFO
	set -x

	if [ "$(PATH_MODULES)" == "" ]
	then
		set +x
		$(M) $@+ERROR -- PATH_PLAYBOOK is not set
		exit 1
	fi

	cd $(PATH_MODULES)
	tflint --init --config $(PWD)/.tflint.tf
	tflint \
		--config $(PWD)/.tflint.tf \
		--recursive \
		--color \
		# --fix # ! FIX with caution

/tf-lint-playbook: ## (forces/wrapper/tf) Lint terraform playbook
	$(M) $@+INFO
	set -x

	if [ "$(PATH_PLAYBOOK)" == "" ]
	then
		set +x
		$(M) $@+ERROR -- PATH_PLAYBOOK is not set
		exit 1
	fi

	if [ "$(PATH_VARS)" == "" ]
	then
		set +x
		$(M) $@+ERROR -- PATH_VARS is not set
		exit 1
	fi

	if [ "$(PATH_VARS_PLAYBOOK)" == "" ]
	then
		set +x
		$(M) $@+ERROR -- PATH_VARS_PLAYBOOK is not set
		exit 1
	fi

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

#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ installs tools
#███████████████████████████████████████████████████████████████████████████████████████████████████

ifdef FORCES_TOOLS_ENABLE_INSTALL

#---------------------------------------------------------------------------------------------------
#-- Terraform
#---------------------------------------------------------------------------------------------------

/install-tf-dirs: ## {forces/terraform} setup terraform directories in HOST to be used by ../terraform/.configs/.terraform.tfrc
	$(M) $@+INFO
	set -x
	$(SUDO) mkdir -p /usr/local/share/terraform/{plugin-cache,plugins,providers}
	$(SUDO) chmod 775 /usr/local/share/terraform/{plugin-cache,plugins,providers}
	$(SUDO) chown root:$(SUDO) /usr/local/share/terraform/{plugin-cache,plugins,providers}

/install-tfenv-opt: ## {forces/terraform} installs tfenv in /opt/tfenv
	$(M) $@+INFO
	set -x
	$(SUDO) git clone --depth=1 https://github.com/tfutils/tfenv.git --single-branch --branch v3.0.0 /opt/tfenv

/install-tfenv-terraform: ## {forces/terraform} init tfenv in ~/.tfenv
	$(M) $@+INFO
	set -x
	mv .terraform-version .terraform-version.old || true
	$(SUDO) $(TFENV) install latest
	$(SUDO) $(TFENV) use latest
	$(SUDO) $(TFENV) version-name | tee -a .terraform-version.latest
	mv .terraform-version.latest .terraform-version
	echo "[$(DATE)] INFO - Copy .terraform-version to your TF playbook directory so that tfenv will automatically use it."

/install-tfsec: ## {forces/terraform} installs tfsec
	$(M) $@+INFO
	set -x
	curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

/install-tflint: ## {forces/terraform} installs tflint
	$(M) $@+INFO
	set -x
	curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

/install-checkov: ## {forces/terraform} installs checkov
	$(M) $@+INFO
	set -x
	pip3 install checkov

/install-terraform-docs: ## {forces/terraform} installs terraform-docs
	$(M) $@+INFO
	set -x
	curl -Lo ./terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.17.0/terraform-docs-v0.17.0-$(shell uname)-amd64.tar.gz
	tar -xzf terraform-docs.tar.gz
	chmod +x terraform-docs
	$(SUDO) mv terraform-docs /usr/local/bin/terraform-docs

# install-rover: ## {forces/terraform} installs rover
# 	$(M) $@+INFO
# 	set -x
# 	wget     https://github.com/im2nguyen/rover/releases/download/v0.3.3/rover_0.3.3_linux_amd64.zip


endif



