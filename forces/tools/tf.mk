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


TF := $(shell which terraform)


FORCES_TF_DECLARE     := $(FORCES_PATH)/terraform/declare.mk
FORCES_TF_DEFINE      := $(FORCES_PATH)/terraform/define.mk
FORCES_TF_OPERATIONS  := $(FORCES_PATH)/terraform/operations.mk
FORCES_TF_MAKE        := time $(M) -f $(FORCES_TF_OPERATIONS)

####################################################################################################
#████ TARGETS
####################################################################################################

/tf-fmt: ## {forces/terraform} format terraform files
	$(M) $@+INFO
	set -x
	cd terraform || true
	terraform fmt -recursive

/tf-copy-sample-render: ## {forces/terraform} copy terraform sample render to .make/terraform
	$(M) $@+INFO
	set -x
	mkdir -p .make/terraform
	echo cp -r $(FORCES_PATH)/terraform/.samples/render.mk .make/terraform/render.mk
	$(M) .WARN -- "Define var 'FORCES_TF_RENDER := .make/terraform/render.mk' in your Makefile"

/tf-setup: ## {forces/terraform} setup terraform directories
	$(M) $@+INFO
	set -x
	mkdir -p terraform/{modules,configs,playbooks}
	mkdir -p terraform/playbooks/{stateless,stateful,pre.tf-remote-backend,pre.firewall-whitelister}
	mkdir -p configs/{dev,qa,stag,prod}

	cp -n $(FORCES_PATH)/terraform/.configs/.terraform-docs.yml ./
	cp -n $(FORCES_PATH)/terraform/.configs/.terraform-version  ./
	cp -n $(FORCES_PATH)/terraform/.configs/.tflint.tf          ./


#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ Install tools
#███████████████████████████████████████████████████████████████████████████████████████████████████

ifdef FORCES_TOOLS_ENABLE_INSTALL

#---------------------------------------------------------------------------------------------------
#-- Terraform
#---------------------------------------------------------------------------------------------------


/install-tfenv-opt: ## {forces/terraform} install tfenv in /opt/tfenv
	$(M) $@+INFO
	set -x
	git clone --depth=1 https://github.com/tfutils/tfenv.git --single-branch --branch v3.0.0 /opt/tfenv

/install-tfenv: ## {forces/terraform} install tfenv	in ~/.tfenv
	$(M) $@+INFO
	set -x
	git clone --depth=1 https://github.com/tfutils/tfenv.git --single-branch --branch v3.0.0 ~/.tfenv
	mkdir -p ~/.local/bin/
	ln -s ~/.tfenv/bin/* ~/.local/bin
	which tfenv

/install-tfenv-terraform-opt: ## {forces/terraform} init tfenv in /opt/tfenv
	$(M) $@+INFO
	set -x
	sudo /opt/tfenv/bin/tfenv install latest
	sudo /opt/tfenv/bin/tfenv use latest
	sudo /opt/tfenv/bin/tfenv version-name | tee -a .terraform-version.latest
	mv .terraform-version.latest .terraform-version
	echo "[$(DATE)] INFO - Copy .terraform-version to your TF playbook directory so that tfenv will automatically use it."

/install-tfenv-terraform: ## {forces/terraform} init tfenv in ~/.tfenv
	$(M) $@+INFO
	set -x
	tfenv install latest
	tfenv use latest
	sudo /opt/tfenv/bin/tfenv version-name | tee -a .terraform-version.latest
	mv .terraform-version.latest .terraform-version
	echo "[$(DATE)] INFO - Copy .terraform-version to your TF playbook directory so that tfenv will automatically use it."

/install-tfsec:
	$(M) $@+INFO
	set -x
	curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

/install-tflint:
	$(M) $@+INFO
	set -x
	curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

/install-checkov:
	$(M) $@+INFO
	set -x
	pip3 install checkov

/install-terraform-docs:
	$(M) $@+INFO
	set -x
	curl -Lo ./terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.17.0/terraform-docs-v0.17.0-$(shell uname)-amd64.tar.gz
	tar -xzf terraform-docs.tar.gz
	chmod +x terraform-docs
	sudo mv terraform-docs /usr/local/bin/terraform-docs

# install-rover:
# 	$(M) $@+INFO
# 	set -x
# 	wget     https://github.com/im2nguyen/rover/releases/download/v0.3.3/rover_0.3.3_linux_amd64.zip


endif