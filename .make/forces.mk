####################################################################################################
#### Copyright 2020-2024 (c) RALF-IT LLC
####################################################################################################
#### Licensed under the Apache License, Version 2.0 (the "License");
#### you may not use this file except in compliance with the License.
#### You may obtain a copy of the License at
####
####     https://raw.githubusercontent.com/ralf-it/makefile-forces/main/LICENSE.md
####
#### Unless required by applicable law or agreed to in writing, software
#### distributed under the License is distributed on an "AS IS" BASIS,
#### WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#### See the License for the specific language governing permissions and
#### limitations under the License.
####################################################################################################

####################################################################################################
####                                                                                            ####
####             ███╗   ███╗  █████╗  ██╗  ██╗ ███████╗ ███████╗ ██╗ ██╗      ███████╗          ####
####             ████╗ ████║ ██╔══██╗ ██║ ██╔╝ ██╔════╝ ██╔════╝ ██║ ██║      ██╔════╝          ####
####             ██╔████╔██║ ███████║ █████╔╝  █████╗   █████╗   ██║ ██║      █████╗            ####
####             ██║╚██╔╝██║ ██╔══██║ ██╔═██╗  ██╔══╝   ██╔══╝   ██║ ██║      ██╔══╝            ####
####             ██║ ╚═╝ ██║ ██║  ██║ ██║  ██╗ ███████╗ ██║      ██║ ███████╗ ███████╗          ####
####             ╚═╝     ╚═╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚══════╝ ╚═╝      ╚═╝ ╚══════╝ ╚══════╝          ####
####                                                                                            ####
####                   ███████╗  ██████╗  ██████╗   ██████╗ ███████╗ ███████╗                   ####
####                   ██╔════╝ ██╔═══██╗ ██╔══██╗ ██╔════╝ ██╔════╝ ██╔════╝                   ####
####                   █████╗   ██║   ██║ ██████╔╝ ██║      █████╗   ███████╗                   ####
####                   ██╔══╝   ██║   ██║ ██╔══██╗ ██║      ██╔══╝   ╚════██║                   ####
####                   ██║      ╚██████╔╝ ██║  ██║ ╚██████╗ ███████╗ ███████║                   ####
####                   ╚═╝       ╚═════╝  ╚═╝  ╚═╝  ╚═════╝ ╚══════╝ ╚══════╝                   ####
####                                                                                            ####
####                                                                                            ####
#### [ASCII TEXT](https://patorjk.com/software/taag/#p=display&h=0&f=ANSI%20Shadow&t=output%3A) ####
####################################################################################################
#### Makefile forces (fith force of nature for lazy people)
####################################################################################################
#### Updates (ifany): https://github.com/ralf-it/makefile-forces.git
####
#### FAQ:
####	+= append to variable
####	 = is regular assignment, dynamically evaluated when used
####	:= is immediate assignment (evaluated at declaration)
####	?= If the variable is not defined, set it to this value similar to :=
####
#### ! NOTE: non-internal targets must be commented with "## ...description..." else they are doomed

-include .env.forces

####################################################################################################
#### Configs
####################################################################################################

# ! TODO do we want to EXPORT all variables?
# ! else do
# VAR := 1
# export VAR
.EXPORT_ALL_VARIABLES:

#===================================================================================================
#=== Debugging and logging
#===================================================================================================
TRACE         ?= false
DEBUG         ?= false
VERBOSE       ?= false

ifeq ($(TRACE),true)
  TF_LOG    := TRACE
else ifeq ($(DEBUG),true)
  TF_LOG    := DEBUG
else ifeq ($(VERBOSE),true)
  TF_LOG    := INFO
endif

ifeq  ($(filter true, $(TRACE) $(DEBUG) $(VERBOSE)),)
  .SILENT:
  SILENT := true
else
  SILENT := false
endif

#===================================================================================================
#=== Makefile Flags
#===================================================================================================
M             ?= gmake

# force to run without caching targets
# disable built-in rules (e.g. %.o: %.c)
# warn if an undefined variable is referenced
MAKEFLAGS     += --always-make
MAKEFLAGS     += --no-builtin-rules
MAKEFLAGS     += --warn-undefined-variables

ifeq ($(TRACE),true)
MAKEFLAGS	  += --trace
endif

ifeq ($(DEBUG),true)
MAKEFLAGS	  += --debug
endif

ifeq ($(SILENT),false)
MAKEFLAGS	  += --print-directory
MAKEFLAGS     += --no-silent
else
MAKEFLAGS     += --no-print-directory
endif

# ! NOTE: disable parallelism, so thst we cam use make like `make TGT ARGS -- KWARGS`
# 0: disabled, -1: all-cores, n: number of jobs
PARALLEL      := 0

#===================================================================================================
#=== Shell
#===================================================================================================

.ONESHELL:    # multiline targets
.SHELL        := $(shell which bash) -euo pipefail
SHELL         := $(shell which bash)
SHELL_NAME    := $(notdir ${SHELL})
SHELL_VERSION := $(shell echo $${BASH_VERSION%%[^0-9.]*})



ifneq ($(DEBUG),true)
   # -e: exit on error
   # -u: error on undefined variable
   # -o pipefail: catch pipe errors
   # -c: run in non-interactive mode
  .SHELLFLAGS	:= -eu -o pipefail -c
else
   # -x: print command before execution
  .SHELLFLAGS	:= -xeu -o pipefail  -c
endif


####################################################################################################
#### System Checks
####################################################################################################

#===================================================================================================
#=== Os Check
#===================================================================================================
ifndef OS
  OS := $(shell uname -s)
else ifneq ($(OS),Windows_NT)
  OS := $(shell uname -s)
else ifeq ($(OS),Windows_NT)
  $(error Windows is not supported. Scram!)
endif

OS_LOWER := $(shell echo $(OS) | tr '[:upper:]' '[:lower:]')

#===================================================================================================
#=== Make Check
#===================================================================================================
ifeq ($(shell expr $(MAKE_VERSION) \< 4.3), 1)
    $(error Using not supported Make $(MAKE_VERSION))
else ifeq ($(SILENT),false)
    $(info Using Make $(MAKE_VERSION))
endif

#===================================================================================================
#=== Bash Check
#===================================================================================================
ifeq ($(shell expr $(SHELL_VERSION) \< 5.1), 1)
    $(error Using not supported Bash $(SHELL_VERSION))
else ifeq ($(SILENT),false)
    $(info Using Bash $(SHELL_VERSION))
endif

####################################################################################################
#### ENV VARS
####################################################################################################

DATE          ?= $(shell date)
DATETIME      ?= $(shell date +%Y%m%dT%H%M%S)
TERM          ?= xterm-256color
COWSAY        := $(shell which cowsay || echo /usr/games/cowsay)

WHOAMI        := $(shell whoami)
CPUS          := $(shell nproc)
MY_IP         := $(shell curl -ss "http://ipv4.icanhazip.com" | tr -d [:space:])
MY_IP_CIDR    := $(MY_IP)/32



####################################################################################################
#### HACKS
####################################################################################################

MAKEFILE_LIST_UNIQ = `echo $(MAKEFILE_LIST)  | tr ' ' '\n' |  sort | uniq`

ifndef DATETIME0
DATETIME0 := $(DATETIME)
endif
# If command line input is defined (i.e. `$(M) INFO aladef -- --ala --ma --kota`)
ifdef MAKECMDGOALS
    # Get first item from MAKECMDGOALS
    ifndef ARGV0
    ARGV0 := $(firstword $(MAKECMDGOALS))
    endif

    # Get second and next items from MAKECMDGOALS
    ifndef ARGVN
    ARGVN := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    endif

    ifndef ARGV
    ARGV = $(filter-out $@,$(filter-out --,$(MAKECMDGOALS)))
    endif

## ! Catch undefined targets when doing `$(M) INFO ala ma kota`
## ! Note: use `$(M) INFO -- --ala --ma --kota` to pass arguments to target
## ! when `--warn-undefined-variables` and `ARGV` are used
## !
%:
	# echo "Undefined target: $@"
	# echo "MAKECMDGOALS: $(MAKECMDGOALS)"
	# echo "ARGV: $(ARGV)"
	# echo "%=$*"
	if [ "$(ARGV0)" != "$(MAKECMDGOALS)" ]; then # ! NOTE: disable parallelism, change behaviour of make TGT1 TG2 to make TGT1 ARGS...
		if [ "$(SILENT)" == "false" ]; then
			echo "ARGVs & MAKECMDGOALS: $(ARGV0); $(ARGVN); $(ARGV); $(MAKECMDGOALS)"
		fi
		exit 0
	fi
	@:

## ! .......................................................................
else
    ARGV ?=
    ARGV0 ?=
    ARGVN ?=
endif


####################################################################################################
#### TARGETS
####################################################################################################

null :=
space := ${null} ${null}
${space} := ${space}

define \n


endef

#===================================================================================================
#=== UTILS
#===================================================================================================

clear: ## {terminal} clear the screen
	clear

show-env: ## {terminal} show environment variables
	$(M) $@+INFO
	env | sort

rm-temps: ## {utils} remove temporary files
	$(M) $@+INFO
	cd /tmp
	find . -delete

generate-secret-alfanum: ## {utils} generate secret
	$(M) $@+INFO
	openssl rand -hex 22

generate-secret-base64: ## {utils} generate secret
	$(M) $@+INFO
	openssl rand -base64 32


#===================================================================================================
#=== SELF UPDATE
#===================================================================================================

MAKEFILE_LIST_UNIQ   = `echo $(MAKEFILE_LIST)  | tr ' ' '\n' |  sort | uniq`

MAKEFILE_FORCES         ?= .make/forces.mk
MAKEFILE_FORCES_URL     ?= https://raw.githubusercontent.com/ralf-it/makefile-forces/main/.make/forces.mk
MAKEFILE_FORCES_GIT     ?= https://github.com/ralf-it/makefile-forces
MAKEFILE_FORCES_GIT_API ?= https://api.github.com/repos/ralf-it/makefile-forces/tags

makefile-forces-update: ## {<<FORCES>>} update and install makefile-forces from github via pip
	$(M) $@+INFO-B
	set +x
	MAKEFILE_FORCES_VERSION=`curl $(MAKEFILE_FORCES_GIT_API) | jq '.[].name' -r | sort -r --version-sort | head -n1`
	pip install git+$(MAKEFILE_FORCES_GIT).git@$${MAKEFILE_FORCES_VERSION} --verbose --force

makefile-forces-version: ## {<<FORCES>>} show makefile-forces version
	$(M) $@+INFO
	MAKEFILE_FORCES_VERSION=`curl $(MAKEFILE_FORCES_GIT_API) | jq '.[].name' -r | sort -r --version-sort | head -n1`
	echo $${MAKEFILE_FORCES_VERSION}

#===================================================================================================
#=== LINT
#===================================================================================================

pre-commit-run: ## {lint} run pre-commit
	$(M) $@+INFO
	set -x
	pre-commit run --all-files --show-diff-on-failure --verbose --color always

#===================================================================================================
#== DOCKER
#===================================================================================================
D                    ?= docker
D_PRUNE_IMG           = $(D) image prune --force
D_PRUNE_NET           = $(D) network prune --force
D_PRUNE_VOL           = $(D) volume prune --force
D_PRUNE               =	$(D) system prune --volumes --force
D_PURGE               = $(D) system prune --all --volumes --force

docker-purge: ## {docker} purge all docker resources
	$(M) $@+INFO
	$(D_PURGE)

docker-prune: ## {docker} Prune dandling resources
	$(M) $@+INFO
	set -x
	$(D_PRUNE)

docker-prune-net: ## {docker} Prune networks
	$(M) $@+INFO
	set -x
	$(D_PRUNE_NET)

docker-prune-vol: ## {docker} Prune volumes
	$(M) $@+INFO
	set -x
	$(D_PRUNE_VOL)

docker-prune-vol-ci-pipeline: ## {docker} Prune volumes with label ci=${CI} and ci_pipeline_id=${CI_PIPELINE_ID}
	$(M) $@+INFO
	set -x
	$(D_PRUNE_VOL) --filter "label=ci=${CI}" --filter "label=ci_pipeline_id=${CI_PIPELINE_ID}"

docker-prune-img-ci-pipeline: ## {docker} Prune images with label ci=${CI} and ci_pipeline_id=${CI_PIPELINE_ID}
	$(M) $@+INFO
	set -x
	$(D_PRUNE_IMG) --filter "label=ci=${CI}" --filter "label=ci_pipeline_id=${CI_PIPELINE_ID}"

docker-prune-net-ci-pipeline: ## {docker} Prune network with label ci=${CI} and ci_pipeline_id=${CI_PIPELINE_ID}
	$(M) $@+INFO
	set -x
	$(D_PRUNE_NET) --filter "label=ci=${CI}" --filter "label=ci_pipeline_id=${CI_PIPELINE_ID}"



#===================================================================================================
#== NET
#===================================================================================================

show-used-ports: ## {net} show used ports
	$(M) $@+INFO
	sudo lsof -i -P -n | grep LISTEN

#===================================================================================================
#== Terraform
#===================================================================================================

TF := $(shell which terraform)

tf-fmt: ## {terraform} format terraform files
	$(M) $@+INFO
	cd terraform || true
	terraform fmt -recursive

#===================================================================================================
#== AZURE
#===================================================================================================

AZ_ACR ?= mcr.microsoft.com
AZ_ACR_NAME ?= $(shell echo $(AZ_ACR) | cut -d . -f1)


## ! NOTE: workaround for avaiability error ...
## ... "Unable to get endpoints from the cloud. Server returned status code 503 for ...
## ... https://westeurope.management.azure.com/metadata/endpoints?api-version=2015-01-01"
az-set-resource-manager-endpoint: ## {azure} set resource manager endpoint
	$(M) $@+INFO
	set -xeuo pipefail
	if ! az cloud update --endpoint-resource-manager https://westeurope.management.azure.com;
		then
		if ! az cloud update --endpoint-resource-manager https://francecentral.management.azure.com;
		then
			az cloud update --endpoint-resource-manager https://switzerlandnorth.management.azure.com;
		fi
	fi

az-login: ## {azure} login to azure
	$(M) $@+INFO
	az login

az-login-devicecode: ## {azure} login to azure with device code
	$(M) $@+INFO
	az login --use-device-code

az-login-sp: ## {azure} login to azure with service principal
	$(M) $@+INFO
	set -x
	az login --service-principal --username $(AZURE_CLIENT_ID) --password $(AZURE_CLIENT_SECRET) --tenant $(AZURE_TENANT_ID)

az-login-smi: ## {azure} login to azure with system managed identity
	$(M) $@+INFO
	set -x
	az login --identity

az-login-umi: ## {azure} login to azure with user managed identity
	$(M) $@+INFO
	set -x
	az login --identity --username $(AZURE_USER_IDENTITY)

az-login-ms-graph: ## {azure} login to azure with ms graph
	$(M) $@+INFO
	set -x
	az login --scope https://graph.microsoft.com

az-login-ms-graph-ownedby: ## {azure} login to azure with ms graph app owned by
	$(M) $@+INFO
	set -x
	az login --scope https://graph.microsoft.com/Application.ReadWrite.OwnedBy

az-acr-login: ## {azure} login to azure container registry and whitelist current IP
	$(M) $@+INFO
	set -x

	if [ "$(AZ_ACR)" == "mcr.microsoft.com" ];
	then
		$(M) $@+ERROR -- AZ_ACR is set to $(AZ_ACR), which is not allowed
	fi

	if [ "$(AZ_ACR_NAME)" == "" ];
	then
		$(M) $@+ERROR -- AZ_ACR_NAME is set to '$(AZ_ACR_NAME)', which is not allowed
	fi

	az acr network-rule add --name $(AZ_ACR_NAME) --ip-address $(MY_IP) || true

	az acr login --name $(AZ_ACR_NAME) # equivalent to docker login

az-set-sub: ## {azure} set subscription to AZ_SUBSCRIPTION_ID
	$(M) $@+INFO
	set -x
	az account set --subscription $(AZ_SUBSCRIPTION_ID)

az-set-sub-dev: ## {azure} set subscription to AZ_SUBSCRIPTION_DEV_ID
	$(M) $@+INFO
	set -x
	az account set --subscription $(AZ_SUBSCRIPTION_DEV_ID)

az-set-sub-qa: ## {azure} set subscription to AZ_SUBSCRIPTION_QA_ID
	$(M) $@+INFO
	set -x
	az account set --subscription $(AZ_SUBSCRIPTION_QA_ID)

az-set-sub-stag: ## {azure} set subscription to AZ_SUBSCRIPTION_STAG_ID
	$(M) $@+INFO
	set -x
	az account set --subscription $(AZ_SUBSCRIPTION_STAG_ID)

az-set-sub-prod: ## {azure} set subscription to AZ_SUBSCRIPTION_PROD_ID
	$(M) $@+INFO
	set -x
	az account set --subscription $(AZ_SUBSCRIPTION_PROD_ID)

#===================================================================================================
#=== GIT
#===================================================================================================

GIT_DATE           ?= $(shell date)

gaa: ## {git} git add all
	$(M) $@+INFO
	set -x
	git add --all

gcam: ## {git} git commit ammend with message
	$(M) $@+INFO
	set -x
  ifdef GIT_AUTHOR
	git commit --amend --author="$(GIT_AUTHOR)" --date="$(GIT_DATE)" -m "$(GIT_MSG)"
  else
	git commit --amend --date="$(GIT_DATE)" -m "$(GIT_MSG)"
  endif

gcae: ## {git} git commit ammend --no-edit
	$(M) $@+INFO
	set -x
  ifdef GIT_AUTHOR
	git commit --amend --no-edit --author="$(GIT_AUTHOR)" --date="$(GIT_DATE)"
  else
	git commit --amend --no-edit --date="$(GIT_DATE)"
  endif

gca: ## {git} git commit ammend
	$(M) $@+INFO
	set -x
  ifdef GIT_AUTHOR
	git commit --amend --author="$(GIT_AUTHOR)" --date="$(GIT_DATE)"
  else
	git commit --amend --date="$(GIT_DATE)"
  endif

gcm: ## {git} git commit with message
	$(M) $@+INFO
	set -x
  ifdef GIT_AUTHOR
	git commit --author="$(GIT_AUTHOR)" --date="$(GIT_DATE)" -m "$(GIT_MSG)"
  else
	git commit --date="$(GIT_DATE)" -m "$(GIT_MSG)"
  endif

gacp: ## {git} git add all, commit, and push
	$(M) $@+INFO
	$(M) gaa
	$(M) gcm
	$(M) gpf

gp: ## {git} git push
	$(M) $@+INFO
	set -x
	git push

gpf: ## {git} git push force with lease
	$(M) $@+INFO
	set -x
	git push --force --force-with-lease

gf: ## {git} git fetch
	$(M) $@+INFO
	set -x
	git fetch

gtagf: ## {git} git tag
	$(M) $@+INFO
	set -x
	git tag $(file < VERSION) --force
	git push origin --tags --force

GACF: ## {git} git add all, commit ammend, and push force with lease
	$(M) $@+INFO
	$(M) gaa
	$(M) gcae
	$(M) gpf

GACMFT: ## {git} git add all, commit ammend, push force with lease, tag force
	$(M) $@+INFO
	$(M) gaa
	$(M) gcam
	$(M) gpf
	$(M) gtagf

git-super-config: ## {git} set super(lazy) git config (submodule.recurse, rebase.autoStash, pull.rebase)
	$(M) $@+INFO
	set -x
	git config submodule.recurse true
	git config rebase.autoStash true
	git config pull.rebase true

git-org-config: ## {git} set org git config
	$(M) $@+INFO

	if [ -z "$(ORG)" ]; then
		$(M) $@+ERROR -- ORG is not set
	fi

	if [ -z "$(ORG_REPOS_DIR)" ]; then
		$(M) $@+ERROR -- ORG_REPOS_DIR is not set
	fi

	if [ -z "$(GIT_AUTHOR)" ]; then
		$(M) $@+ERROR -- GIT_AUTHOR is not set
	fi

	if [ -z "$(GIT_AUTHOR_EMAIL)" ]; then
		$(M) $@+ERROR -- GIT_AUTHOR_EMAIL is not set
	fi

	if [ -z "$(ORG_SSH_KEY)" ]; then
		$(M) $@+ERROR -- ORG_SSH_KEY is not set
	fi

	set -x

	cat <<-EOF >> .gitconfig
	[includeIf "gitdir:$(ORG)/"]
		path = $(ORG_REPOS_DIR)/.gitconfig
	EOF

	mkdir -p $(ORG_REPOS_DIR)

	cat <<-EOF >> $(ORG_REPOS_DIR)/.gitconfig
		[user]
		name = $(GIT_AUTHOR)
		email = $(GIT_AUTHOR_EMAIL)

		[core]
		sshCommand = ssh -i $(ORG_SSH_KEY)
	EOF

git-sizer: ## {git} run git-sizer
	$(M) $@+INFO
	git-sizer  --threshold=1 -v

#===================================================================================================
#=== PSQL
#===================================================================================================

psql-exec-cmd: ## {psql/cmd} Execute psql command
	$(M) $@+INFO
	set -xueo pipefail
	if psql --echo-queries --no-password -h $(DB_HOST) -p $(DB_PORT) -U $(POSTGRES_USER) -d $(POSTGRES_DB)  -c "$(PSQL_CMD)"; then
		echo "Success."
	else
		echo "Failed."
	fi

psql-exec-cmd-migrator: ## {psql/cmd} Execute psql command as migrator user
	$(M) $@+INFO
	set -xueo pipefail

	if psql --echo-queries --no-password -h $(DB_HOST) -p $(DB_PORT) -U $(POSTGRES_USER_MIGRATOR) -d $(POSTGRES_DB)  -c "$(PSQL_CMD)"; then
		set +x
		$(M) $@+INFO -- Success.
	else
		set +x
		$(M) $@+ERROR -- Failed.
	fi

####################################################################################################
### Install tools
####################################################################################################

install-tools: install-archivemount install-nmap install-tfenv ## {tools} Install tools

#---------------------------------------------------------------------------------------------------
#-- File System
#---------------------------------------------------------------------------------------------------

install-archivemount:
	sudo apt install archivemount

#---------------------------------------------------------------------------------------------------
#-- Net
#---------------------------------------------------------------------------------------------------

install-nmap: ## {net} install nmap
	$(M) $@+INFO
	sudo apt-get install -y nmap

install-lsof: ## {net} install lsof
	$(M) $@+INFO
	sudo apt install lsof -yy

install-netcat: ## {net} install netcat
	$(M) $@+INFO
	sudo apt install netcat-openbsd -yy

#---------------------------------------------------------------------------------------------------
#-- Git
#---------------------------------------------------------------------------------------------------

install-git-sizer: ## {git} install git-sizer
	$(M) $@+INFO
	wget https://github.com/github/git-sizer/releases/download/v1.5.0/git-sizer-1.5.0-linux-amd64.zip -nc
	mkdir -p git-sizer
	sudo unzip  -o git-sizer-1.5.0-linux-amd64.zip -d git-sizer
	sudo mv git-sizer/git-sizer /usr/local/bin/git-sizer
	sudo chmod +x /usr/local/bin/git-sizer
	rm -rf git-sizer-1.5.0-linux-amd64.zip
	rm -rf git-sizer

#---------------------------------------------------------------------------------------------------
#-- Docker & Docker Compose
#---------------------------------------------------------------------------------------------------

install-docker: ## {docker} install docker
	$(M) $@+INFO
	set -x
	sudo apt-get install -y dbus-user-session
	# [Install Docker Engine on Debian](https://docs.docker.com/engine/install/debian/#install-using-the-convenience-script)
	mkdir -p .install
	curl -fsSL https://get.docker.com -o .install/get-docker.sh
	sudo bash .install/get-docker.sh
	rm -rf .install/get-docker.sh
	$(M) post-install-docker

post-install-docker: ## {docker} post install docker
	$(M) $@+INFO
	set -x
	sudo journalctl -n 20 --no-pager --unit docker.service
	sudo  docker run hello-world

uninstall-docker: ## {docker} uninstall docker
	$(M) $@+INFO
	set -x
	dockerd-rootless-setuptool.sh uninstall --force || true
	/usr/bin/dockerd-rootless-setuptool.sh uninstall -f || true
	systemctl --user daemon-reload
	sudo systemctl daemon-reload
	/usr/bin/rootlesskit rm -rf $(HOME)/.local/share/docker || true

	sudo apt-get purge docker* docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras -yy

	sudo rm -rf /var/lib/docker
	sudo rm -rf /var/lib/containerd
	sudo rm -rf /home/docker || true
	sudo rm -rf $(HOME)/.config/systemd/user/docker.service

#---------------------------------------------------------------------------------------------------
#-- Terraform
#---------------------------------------------------------------------------------------------------

install-tfenv-opt: ## {terraform} install tfenv in /opt/tfenv
	$(M) $@+INFO
	set -x
	git clone --depth=1 https://github.com/tfutils/tfenv.git --single-branch --branch v3.0.0 /opt/tfenv

install-tfenv: ## {terraform} install tfenv	in ~/.tfenv
	$(M) $@+INFO
	set -x
	git clone --depth=1 https://github.com/tfutils/tfenv.git --single-branch --branch v3.0.0 ~/.tfenv

init-tfenv-opt: ## {terraform} init tfenv in /opt/tfenv
	$(M) $@+INFO
	set -x
	sudo /opt/tfenv/bin/tfenv install latest
	sudo /opt/tfenv/bin/tfenv use latest
	sudo /opt/tfenv/bin/tfenv version-name | tee -a .terraform-version.latest
	mv .terraform-version.latest .terraform-version
	echo "[$(DATE)] INFO - Copy .terraform-version to your TF playbook directory so that tfenv will automatically use it."

init-tfenv: ## {terraform} init tfenv in ~/.tfenv
	$(M) $@+INFO
	set -x
	tfenv install latest
	tfenv use latest
	sudo /opt/tfenv/bin/tfenv version-name | tee -a .terraform-version.latest
	mv .terraform-version.latest .terraform-version
	echo "[$(DATE)] INFO - Copy .terraform-version to your TF playbook directory so that tfenv will automatically use it."

install-tfsec:
	$(M) $@+INFO
	set -x
	curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

install-tflint:
	$(M) $@+INFO
	set -x
	curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

install-checkov:
	$(M) $@+INFO
	set -x
	pip3 install checkov

#---------------------------------------------------------------------------------------------------
#-- Terminal
#---------------------------------------------------------------------------------------------------

install-tmux-opt: ## {terminal} install tmux in /opt/.config
	$(M) $@+INFO
	set -x
	sudo apt install tmux -yy
	sudo mkdir -p /opt/.config
	sudo cp .tmux.conf /opt/.config/.tmux.conf
	sudo ln -s /opt/.config/.tmux.conf ~/.tmux.conf

install-tmux: ## {terminal} install tmux in ~/.tmux.conf
	$(M) $@+INFO
	set -x
	sudo apt install tmux -yy
	cp .tmux.conf ~/.tmux.conf

#---------------------------------------------------------------------------------------------------
#-- Python Distribution
#---------------------------------------------------------------------------------------------------


install-miniconda3-opt: ## {tools} install miniconda3 in /opt/miniconda3
	$(M) $@+INFO
	set -x
	sudo mkdir -p /opt/miniconda3
	sudo chown root:sudo -Rf /opt/miniconda3
	sudo chmod 775 -Rf /opt/miniconda3
	wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /opt/miniconda3/miniconda.sh
	bash /opt/miniconda3/miniconda.sh -b -u -p /opt/miniconda3

#---------------------------------------------------------------------------------------------------
#-- IDEs
#---------------------------------------------------------------------------------------------------

install-jetbrains-toolbox: ## {tools} install jetbrains-toolbox
	$(M) $@+INFO-B

	set -x
	TMP_DIR="/tmp"
	INSTALL_DIR="$$HOME/.local/share/JetBrains/Toolbox/bin"
	INSTALL_DIR_CHECKSUM="$$HOME/.local/share/JetBrains/Toolbox/checksum"
	OS_LOWER=$(shell echo $(OS) | tr '[:upper:]' '[:lower:]')

	$(M) $@+INFO -- Fetching the URL of the latest version...

	export TOOLBOOX_URL='https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release'
	curl -s $$TOOLBOOX_URL > $$TMP_DIR/jetbrains-toolbox-releases.json

	ARCHIVE_URL=`jq -r .TBA[0].downloads.$${OS_LOWER}.link -r $$TMP_DIR/jetbrains-toolbox-releases.json`
	ARCHIVE_URL_CHECKSUM=`jq -r .TBA[0].downloads.$${OS_LOWER}.checksumLink -r $$TMP_DIR/jetbrains-toolbox-releases.json`

	ARCHIVE_FILENAME=`basename "$$ARCHIVE_URL"`
	ARCHIVE_CHECKSUM_FILENAME=`basename "$$ARCHIVE_URL_CHECKSUM"`

	$(M) $@+INFO -- Downloading $$ARCHIVE_CHECKSUM_FILENAME...

	wget -nc --show-progress -cO "$$TMP_DIR/$$ARCHIVE_CHECKSUM_FILENAME" "$$ARCHIVE_URL_CHECKSUM" || true

	$(M) $@+INFO -- Downloading $$ARCHIVE_FILENAME...

	wget -nc --show-progress -cO "$$TMP_DIR/$$ARCHIVE_FILENAME" "$$ARCHIVE_URL" || true

	$(M) $@+INFO -- Verifying the checksum...

	ARCHIVE_CHECKSUM0=`cat "$$TMP_DIR/$$ARCHIVE_CHECKSUM_FILENAME" | awk '{print $$1}'`
	ARCHIVE_CHECKSUM=`sha256sum "$$TMP_DIR/$$ARCHIVE_FILENAME" | awk '{print $$1}'`

	diff <(echo "$$ARCHIVE_CHECKSUM0") <(echo "$$ARCHIVE_CHECKSUM")

	$(M) $@+INFO -- Extracting to $$INSTALL_DIR...

	mkdir -p "$$INSTALL_DIR"
	rm "$$INSTALL_DIR/jetbrains-toolbox" 2>/dev/null || true
	tar -xzf "$$TMP_DIR/$$ARCHIVE_FILENAME" -C "$$INSTALL_DIR" --strip-components=1
	rm "$$TMP_DIR/$$ARCHIVE_FILENAME"
	chmod +x "$$INSTALL_DIR/jetbrains-toolbox"

	SYMLINK_DIR="$$HOME/.local/bin"

	$(M) $@+INFO -- Symlinking to $$SYMLINK_DIR/jetbrains-toolbox...

	mkdir -p $$SYMLINK_DIR
	rm "$$SYMLINK_DIR/jetbrains-toolbox" 2>/dev/null || true
	ln -s "$$INSTALL_DIR/jetbrains-toolbox" "$$SYMLINK_DIR/jetbrains-toolbox"

ifndef CI
	$(M) $@+INFO -- Running for the first time to set-up...
	( "$$INSTALL_DIR/jetbrains-toolbox" & )

	$(M) $@+INFO -- Done! JetBrains Toolbox should now be running, in your application list, and you can run it in terminal as jetbrains-toolbox
	$(M) $@+INFO -- ensure that $$SYMLINK_DIR is on your PATH
else
	$(M) $@+INFO -- Done! Running in a CI -- skipped launching the AppImage.
endif

	$(M) $@+INFO-E
####################################################################################################
### HELP
####################################################################################################

# Set the default target
.DEFAULT_GOAL := help
.PHONY: help

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## {help} This help.
	echo -e "\n$(COLOUR_GREEN)>>> PROJECT HELP <<<$(END_COLOUR)\n"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_0-9-]+:.*?## / {printf "$(COLOUR_GREEN)%-50s$(END_COLOUR) %s\n", $$1":", $$2}' $(MAKEFILE_LIST_UNIQ) | grep -v '\{' | grep '\[' | sort -k 2 || echo "..."

help-extras: ## {help} This help.
	echo -e "\n$(COLOUR_BLUE)>>> EXTRAS HELP <<<$(END_COLOUR)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_0-9-]+:.*?## / {printf "$(COLOR_CYAN)%-50s$(END_COLOUR) %s\n", $$1":", $$2}' $(MAKEFILE_LIST_UNIQ) | grep '\{' | sort -k 2 || echo "..."

help-templates: ## {help} This help.
	echo -e "\n$(COLOUR_BLUE)>>> TEMPLATES HELP <<<$(END_COLOUR)"
	@awk 'BEGIN {FS = ":.*?## "} /^[$$_(-+a-zA-Z_0-9-]+:.*?## / {printf "$(COLOUR_ORANGE)%-50s$(END_COLOUR) %s\n", $$1":", $$2}' $(MAKEFILE_LIST_UNIQ)  | grep -v '\{' | grep '(' | sort -k 2 || echo "..."

help-all: ## {help} This help.
	$(M) help
	$(M) help-extras
	$(M) help-templates

# ! TODO
# help-draft: ##
# 	awk '/^# Not a target:/ { flag = 1; next }    flag && NF == 0 { flag = 0; next }    !flag'

# 	awk '!/^[#[:space:]]*Implicit rule search has not been done\.$$/ && !/^[#[:space:]]*Modification time never checked\.$$/ && !/^[#[:space:]]*File has not been updated\.$$/'

# 	awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}'

# 	awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {printf $$1 "/2:" $$2 "/3:" $$3 "\n"}}'

help-no-color: ## {help} This help (no color).
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_0-9-]+:.*?## / {printf "%-40s %s\n", $$1":", $$2}' $(MAKEFILE_LIST_UNIQ) | sort


makefile-list: ## {make} Show list of loaded Makefiles and .env's
	echo $(MAKEFILE_LIST_UNIQ)

#===================================================================================================
#== Logging
#===================================================================================================

COLOUR_GREEN     = \033[0;32m
COLOUR_BLUE      = \033[0;34m
COLOR_CYAN       = \033[0;36m
COLOUR_ORANGE    = \033[0;33m
COLOUR_RED       = \033[0;31m
END_COLOUR       = \033[0m
LINE_CHAR       ?= =
COLUMNS         ?= $(shell tput cols)
MSG              =

.line:
	printf -- '$(LINE_CHAR)%.0s' {1..$(COLUMNS)}; echo

INFO-B: ## {logging} log info begin
	$(M) $@+INFO-B

INFO-E: ## {logging} log info end
	$(M) $@+INFO-E

INFO: ## {logging} log info
	$(M) $@+INFO

WARN: ## {logging} log warning
	$(M) $@+WARN

ERROR: ## {logging} log error
	$(M) $@+ERROR

%+INFO-B: ## (logging) log info begin template
	export TARGET=$*
	set +x
	if [ "$(ARGVN)" != "" ];
	then
		MSG="$(MSG)$(ARGVN)"
	else
		MSG="$(MSG)$(ARGV0)"
	fi
	if [ "$$MSG" == "" ];
	then
		HELP=`$(M) help-no-color | grep "$$TARGET:" | cut -d ' ' -f 2- | awk '{$$1=$$1};1' || ( echo "No help comment available for $$TARGET. Abort" && exit 1 )`
		MSG="$$HELP"
	fi

	echo -en "" "$(COLOUR_GREEN)\r"
	$(M) .line
	if [ "$$TARGET" == "INFO" ];
	then
		echo -e "[$(DATE)] INFO BEGIN - $${MSG}..."
	else
		echo -e "[$(DATE)] INFO BEGIN - $${TARGET^^} - $${MSG}..."
	fi
	$(M) .line LINE_CHAR='-'
	echo -en "" "$(END_COLOUR)\r"
	echo

%+INFO-E: ## (logging) log info end template
	export TARGET=$*
	set +x
	if [ "$(ARGVN)" != "" ];
	then
		MSG="$(MSG)$(ARGVN)"
	else
		MSG="$(MSG)$(ARGV0)"
	fi
	if [ "$$MSG" == "" ];
	then
		HELP=`$(M) help-no-color | grep "$$TARGET:" | cut -d ' ' -f 2- | awk '{$$1=$$1};1' || ( echo "No help comment available for $$TARGET. Abort" && exit 1 )`
		MSG="$$HELP"
	fi

	echo
	echo -en "" "$(COLOUR_GREEN)\r"
	$(M) .line LINE_CHAR='-'
	if [ "$$TARGET" == "INFO" ];
	then
		echo -e "[$(DATE)] INFO END - $${MSG}..."
	else
		echo -e "[$(DATE)] INFO END - $${TARGET^^} - $${MSG}..."
	fi
	$(M) .line
	echo -e "$(END_COLOUR)"

%+INFO: ## (logging) log info template
	export TARGET=$*
	set +x
	if [ "$(ARGVN)" != "" ];
	then
		MSG="$(MSG)$(ARGVN)"
	else
		MSG="$(MSG)$(ARGV0)"
	fi
	if [ "$$MSG" == "" ];
	then
		HELP=`$(M) help-no-color | grep "$$TARGET:" | cut -d ' ' -f 2- | awk '{$$1=$$1};1' || ( echo "No help comment available for $$TARGET. Abort" && exit 1 )`
		MSG="$$HELP"
	fi

	if [ "$$TARGET" == "INFO" ];
	then
		echo -e "$(COLOUR_GREEN)[$(DATE)] INFO - $${MSG}...$(END_COLOUR)"
	else
		echo -e "$(COLOUR_GREEN)[$(DATE)] INFO - $${TARGET^^} - $${MSG}...$(END_COLOUR)"
	fi

%+WARN: ## (logging) log warning template
	export TARGET=$*
	set +x
	if [ "$(ARGVN)" != "" ];
	then
		MSG="$(MSG)$(ARGVN)"
	else
		MSG="$(MSG)$(ARGV0)"
	fi
	if [ "$$TARGET" == "WARN" ];
	then
		echo -e "$(COLOUR_ORANGE)[$(DATE)] WARN - $${MSG}...$(END_COLOUR)"
	else
		echo -e "$(COLOUR_ORANGE)[$(DATE)] WARN - $${TARGET^^} - $${MSG}...$(END_COLOUR)"
	fi

%+ERROR: ## (logging) log error template
	echo "ERROR"
	export TARGET=$*
	set +x
	if [ "$(ARGVN)" != "" ];
	then
		MSG="$(MSG)$(ARGVN)"
	else
		MSG="$(MSG)$(ARGV0)"
	fi
	if [ "$$TARGET" == "WARN" ];
	then
		echo -e "$(COLOUR_RED)[$(DATE)] ERROR - $${MSG}...$(END_COLOUR)"
	else
		echo -e "$(COLOUR_RED)[$(DATE)] ERROR -  $${TARGET^^} - $${MSG}...$(END_COLOUR)"
	fi
	exit 1

define OUTPUT_ASCI
$(COLOUR_GREEN)
.██████╗  ██╗   ██╗ ████████╗ ██████╗  ██╗   ██╗ ████████╗
██╔═══██╗ ██║   ██║ ╚══██╔══╝ ██╔══██╗ ██║   ██║ ╚══██╔══╝ ██╗
██║   ██║ ██║   ██║    ██║    ██████╔╝ ██║   ██║    ██║    ╚═╝
██║   ██║ ██║   ██║    ██║    ██╔═══╝  ██║   ██║    ██║    ██╗
╚██████╔╝ ╚██████╔╝    ██║    ██║      ╚██████╔╝    ██║    ╚═╝
.╚═════╝   ╚═════╝     ╚═╝    ╚═╝       ╚═════╝     ╚═╝
$(END_COLOUR)
endef

test-output-asci:
	@echo -e '$(OUTPUT_ASCI)'