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
#███ ACME.SH
#███████████████████████████████████████████████████████████████████████████████████████████████████

# REQUIRED BY: forces/acme.sh/dnsapi/dns_azure_cli.sh
AZUREDNS_ZONE            ?=
AZUREDNS_SUBSCRIPTION_ID ?=
AZUREDNS_RESOURCE_GROUP  ?=

ACME_SH_DIR              ?= $(HOME)/.acme.sh

ACME_MODE_PROD           := prod
ACME_MODE_STAG           := staging

ACME_MODE                ?= $(ACME_MODE_PROD)
ACME_HOME_DIR             = $(ACME_SH_DIR)/$(AZUREDNS_ZONE)/$(ACME_MODE)
ACME_CONF_DIR             = $(ACME_SH_DIR)/$(AZUREDNS_ZONE)/$(ACME_MODE)/configs

ACME_SH_CLI              := $(ACME_SH_DIR)/acme.sh
ACME_SH_DEBUG            ?= 0

ACME_CERT_PASSWORD       ?=
ACME_DOMAIN              ?=
ACME_EMAIL               ?=

# Used durig installs to PROJECTs DIR
ACME_CERTS_DIR           ?= $(PWD)/.certs/$(ACME_DOMAIN)
ACME_CA_FILE             ?= $(ACME_CERTS_DIR)/ca.pem
ACME_KEY_FILE            ?= $(ACME_CERTS_DIR)/key.pem
ACME_PFX_FILE            ?= $(ACME_CERTS_DIR)/cert.pfx
ACME_CERT_FILE           ?= $(ACME_CERTS_DIR)/cert.pem
ACME_FULLCHAIN_FILE      ?= $(ACME_CERTS_DIR)/fullchain.pem

ACME_SERVER              ?=
ACME_SERVER_LETSENCRYPT  := letsencrypt

ifeq ($(ACME_SERVER),$(ACME_SERVER_LETSENCRYPT))
ACME_SERVER_KWARG        := --server letsencrypt
else ifneq ($(ACME_SERVER), )
ACME_SERVER_KWARG        := --server $(ACME_SERVER)
else
ACME_SERVER_KWARG        :=
endif

ifeq ($(ACME_MODE),$(ACME_MODE_STAG))
ACME_MODE_STAG_ENABLED   := --staging
else
ACME_MODE_STAG_ENABLED   :=
endif


## [Validity](https://github.com/acmesh-official/acme.sh/wiki/Validity)
##
ACME_VALID_TO_DAYS         ?= 90
ifeq ($(ACME_SERVER),$(ACME_SERVER_LETSENCRYPT))
ACME_VALID_TO_DAYS_ENABLED :=
else
ACME_VALID_TO_DAYS_ENABLED := --valid-to   '+$(ACME_VALID_TO_DAYS)d'
endif

## [GitHub - acmesh-official/acme.sh: A pure Unix shell script implementing ACME client protocol](https://github.com/acmesh-official/acme.sh#10-issue-ecc-certificates)
##
## ACME_CERT_KEY_SIZE valid values are:
## * ec-256 (prime256v1, "ECDSA P-256", which is the default key type)
## * ec-384 (secp384r1, "ECDSA P-384")
## * ec-521 (secp521r1, "ECDSA P-521", which is not supported by Let's Encrypt yet.)
## * 2048 (RSA2048)
## * 3072 (RSA3072)
## * 4096 (RSA4096)
##
ACME_CERT_KEY_TYPE       ?= EC
ACME_CERT_KEY_SIZE       ?= 256

ifeq ($(ACME_CERT_KEY_TYPE),EC)
ACME_CERT_KEY_SIZE__     ?= ec-$(ACME_CERT_KEY_SIZE)
else ifeq ($(ACME_CERT_KEY_SIZE),256)
ACME_CERT_KEY_SIZE__     ?= ec-256
else ifeq ($(ACME_CERT_KEY_SIZE),384)
ACME_CERT_KEY_SIZE__     ?= ec-384
else ifeq ($(ACME_CERT_KEY_SIZE),521)
ACME_CERT_KEY_SIZE__     ?= ec-521
else
ACME_CERT_KEY_SIZE__     ?= $(ACME_CERT_KEY_SIZE)
endif

ifeq ($(ACME_CERT_KEY_SIZE__),ec-521)
$(error EC-521 is not supported by Let's Encrypt yet.)
endif


ifeq ($(wildcard $(ACME_HOME_DIR)),)
$(shell mkdir -p $(ACME_HOME_DIR))
endif

ifeq ($(wildcard $(ACME_CONF_DIR)),)
$(shell mkdir -p $(ACME_CONF_DIR))
endif

ifeq ($(wildcard $(ACME_CERTS_DIR)),)
$(shell mkdir -p $(ACME_CERTS_DIR))
endif

/acme-sh-cli-check: ## {forces/acmesh} check if acme.sh is installed
	if ! $(ACME_SH_CLI) --version
	then
		$(M) $@+ERROR -- acme.sh is not installed
	fi

/acme-sh-azuredns-vars-check: ## {forces/acmesh} acme.sh dns using az cli
	$(M) $@+INFO
	set -x

	if [ "$(AZUREDNS_ZONE)" == "" ]
	then
		$(M) $@+ERROR -- AZUREDNS_ZONE is not set
	fi

	if [ "$(AZUREDNS_SUBSCRIPTION_ID)" == "" ]
	then
		$(M) $@+ERROR -- AZUREDNS_SUBSCRIPTION_ID is not set
	fi

	if [ "$(AZUREDNS_RESOURCE_GROUP)" == "" ]
	then
		$(M) $@+ERROR -- AZUREDNS_RESOURCE_GROUP is not set
	fi

	if [ "$(ACME_CERT_KEY_TYPE)" == "" ]
	then
		$(M) $@+ERROR -- ACME_CERT_KEY_TYPE is not set
	fi

	if [ "$(ACME_CERT_KEY_SIZE)" == "" ]
	then
		$(M) $@+ERROR -- ACME_CERT_KEY_SIZE is not set
	fi


/acme-sh-cert-files-check:  ##  {forces/acmesh} check if acme.sh cert files are set

	if [ "$(ACME_CERTS_DIR)" == "" ]
	then
		$(M) $@+ERROR -- ACME_CERTS_DIR is not set
	fi

	if [ "$(ACME_CA_FILE)" == "" ]
	then
		$(M) $@+ERROR -- ACME_CA_FILE is not set
	fi

	if [ "$(ACME_KEY_FILE)" == "" ]
	then
		$(M) $@+ERROR -- ACME_KEY_FILE is not set
	fi

	if [ "$(ACME_CERT_FILE)" == "" ]
	then
		$(M) $@+ERROR -- ACME_CERT_FILE is not set
	fi

	if [ "$(ACME_FULLCHAIN_FILE)" == "" ]
	then
		$(M) $@+ERROR -- ACME_FULLCHAIN_FILE is not set
	fi

/acme-sh-show-cert-info:  /acme-sh-cli-check  /acme-sh-azuredns-vars-check ## {forces/acmesh} show cert info
	$(M) $@+INFO
	set -xeuo pipefail

	if [ "$(ACME_DOMAIN)" == "" ]
	then
		$(M) $@+ERROR -- ACME_DOMAIN is not set
	fi

	if [ "$(ACME_HOME_DIR)" == "" ]
	then
		$(M) $@+ERROR -- ACME_HOME_DIR is not set
	fi

	if [ "$(ACME_CONF_DIR)" == "" ]
	then
		$(M) $@+ERROR -- ACME_CONF_DIR is not set
	fi

	if $(ACME_SH_CLI)                      \
		--info                             \
		--domain      '$(ACME_DOMAIN)'     \
		--home        '$(ACME_HOME_DIR)'   \
		--config-home '$(ACME_CONF_DIR)'   \
		$(ARGVN)                           \
	2>&1 | grep "No such file or directory";
	then
		$(M) $@+ERROR -- "Certificate files are not existing."
	fi

/acme-sh-copy-certs:  /acme-sh-cli-check  /acme-sh-azuredns-vars-check /acme-sh-cert-files-check  /acme-sh-show-cert-info ## {forces/acmesh} copy certs to destination
	$(M) $@+INFO
	set -xeuo pipefail

	if [ "$(ACME_DOMAIN)" == "" ]
	then
		$(M) $@+ERROR -- ACME_DOMAIN is not set
	fi

	if [ "$(ACME_HOME_DIR)" == "" ]
	then
		$(M) $@+ERROR -- ACME_HOME_DIR is not set
	fi

	if [ "$(ACME_CONF_DIR)" == "" ]
	then
		$(M) $@+ERROR -- ACME_CONF_DIR is not set
	fi

	$(M) $@+INFO -- "Installing certificate files in DIR $(ACME_CERTS_DIR)."

	mkdir -p $(ACME_CERTS_DIR)

	$(ACME_SH_CLI)                                   \
		--install-cert                               \
		--ca-file           $(ACME_CA_FILE)          \
		--key-file          $(ACME_KEY_FILE)         \
		--cert-file         $(ACME_CERT_FILE)        \
		--fullchain-file    $(ACME_FULLCHAIN_FILE)   \
		--home             '$(ACME_HOME_DIR)'        \
		--config-home      '$(ACME_CONF_DIR)'        \
		--domain           '$(ACME_DOMAIN)'          \
		$(ARGVN)

/acme-sh-convert-pkcs12:  /acme-sh-cli-check  /acme-sh-azuredns-vars-check /acme-sh-cert-files-check /acme-sh-show-cert-info ## {forces/acmesh} convert pem certs to pkcs12
	$(M) $@+INFO
	set -x

	if [ "$(ACME_DOMAIN)" == "" ]
	then
		$(M) $@+ERROR -- ACME_DOMAIN is not set
	fi

	if [ "$(ACME_CERT_PASSWORD)" == "" ]
	then
		$(M) $@+ERROR -- ACME_CERT_PASSWORD is not set
	fi

	if [ "$(ACME_PFX_FILE)" == "" ]
	then
		$(M) $@+ERROR -- ACME_PFX_FILE is not set
	fi

	$(M) $@+INFO -- "Covertting certificate files in DIR $(ACME_CERTS_DIR) to pfx with password."
	openssl pkcs12 -export                              \
			-password pass:$(ACME_CERT_PASSWORD)        \
			-in            $(ACME_FULLCHAIN_FILE)       \
			-inkey         $(ACME_KEY_FILE)             \
			-out           $(ACME_PFX_FILE)

/acme-sh-register-email: ## {forces/acmesh} register email
	$(M) $@+INFO
	set -x


	if [ "$(ACME_EMAIL)" == "" ]
	then
		$(M) $@+ERROR -- ACME_EMAIL is not set
	fi

	if [ "$(ACME_HOME_DIR)" == "" ]
	then
		$(M) $@+ERROR -- ACME_HOME_DIR is not set
	fi

	if [ "$(ACME_CONF_DIR)" == "" ]
	then
		$(M) $@+ERROR -- ACME_CONF_DIR is not set
	fi

	if [ ! -f "$(ACME_HOME_DIR)/$(ACME_EMAIL).lock" ];
	then
		$(M) $@+INFO -- "Register email $(ACME_EMAIL) with acme.sh..."

		$(ACME_SH_CLI)                        \
			--register-account                \
			--email       '$(ACME_EMAIL)'     \
			--debug       '$(ACME_SH_DEBUG)'  \
			--home        '$(ACME_HOME_DIR)'  \
			--config-home '$(ACME_CONF_DIR)'

		$(M) $@+INFO -- "Create lock file for email $(ACME_EMAIL) in $(ACME_HOME_DIR)..."
		touch $(ACME_HOME_DIR)/$(ACME_EMAIL).lock
	else
		$(M) $@+INFO -- "Email $(ACME_EMAIL) is already registered."
	fi

/acme-sh-issue-azuredns:  /acme-sh-cli-check  /acme-sh-azuredns-vars-check ## {forces/acmesh} acme.sh dns using az cli
	$(M) $@+INFO
	set -x

	if [ "$(ACME_DOMAIN)" == "" ]
	then
		$(M) $@+ERROR -- ACME_DOMAIN is not set
	fi

	if [ "$(ACME_HOME_DIR)" == "" ]
	then
		$(M) $@+ERROR -- ACME_HOME_DIR is not set
	fi

	if [ "$(ACME_CONF_DIR)" == "" ]
	then
		$(M) $@+ERROR -- ACME_CONF_DIR is not set
	fi

	$(M) $@+INFO -- "Get current timestamp"
	current_timestamp=`date -d "now" +%s`

	$(M) $@+INFO -- "Get expiry timestamp"
	expiry_timestamp=`                         \
		$(ACME_SH_CLI)                         \
			--info                             \
			--home        '$(ACME_HOME_DIR)'   \
			--config-home '$(ACME_CONF_DIR)'   \
			--debug       '$(ACME_SH_DEBUG)'   \
			--domain      '$(ACME_DOMAIN)'     \
			$(ARGVN)                           \
		| grep "Le_NextRenewTime="             \
		| cut -d'=' -f2                        \
		| tr -d "'"                            \
		|| echo ""                             `

	if [ "$$expiry_timestamp" == "" ]; then
		$(M) $@+INFO -- "Certificate does not exist. Set expiry_timestamp to 0."
		expiry_timestamp=0
	fi

	$(M) $@+INFO -- "Compare expiry and current timestamps."
	if [ $$expiry_timestamp -le $$current_timestamp ];
	then
		$(M) $@+INFO -- "Enter the flock to ACME issue sequentially..."
		(
			$(M) $@+INFO -- "Try to acquire lock ..."
			if flock --exclusive --no-fork --verbose 200;
			then
				$(M) $@+INFO -- "Command executing under lock ..."

				$(M) /acme-sh-register-email

				$(M) $@+INFO -- "Generate new certificate for domain $(ACME_DOMAIN) using $(AZUREDNS_ZONE) for ACME CHALLENGE."
				$(ACME_SH_CLI)                                \
					--issue                                   \
					--dns          dns_azure_cli              \
					--home        '$(ACME_HOME_DIR)'          \
					--config-home '$(ACME_CONF_DIR)'          \
					--debug       '$(ACME_SH_DEBUG)'          \
					--keylength   '$(ACME_CERT_KEY_SIZE__)'   \
					--domain      '$(ACME_DOMAIN)'            \
					$(ACME_VALID_TO_DAYS_ENABLED)             \
					$(ACME_SERVER_KWARG)        \
					$(ACME_MODE_STAG_ENABLED)                 \
					$(ARGVN)
				sleep 3
				$(M) $@+WARN -- "Completed. Release the lock."
			else
				$(M) $@+INFO -- "Wait for the lock release ..."
				flock -x 200;
			fi
		) 200>$(ACME_HOME_DIR)/$(AZUREDNS_ZONE).lock
	else
		DAYS_LEFT=$$(( ($$expiry_timestamp - $$current_timestamp) / 86400))
		$(M) $@+INFO -- Certificate is still valid. Expires in $${DAYS_LEFT}d. Abort.
	fi


/acme-sh-issue-azuredns-wildcard:  ## {forces/acmesh} acme.sh dns using az cli
	$(M) $@+INFO
	set -x

	if [ "$(ACME_DOMAIN)" == "" ]
	then
		$(M) $@+ERROR -- ACME_DOMAIN is not set
	fi

	$(M) /acme-sh-issue-azuredns --  "--domain  '*.$(ACME_DOMAIN)'  $(ARGVN)"

/acme-sh-issue-azuredns-staging:  ## {forces/acmesh} acme.sh dns using az cli
	$(M) $@+INFO
	set -x

	ACME_MODE=$(ACME_MODE_STAG) \
	$(M) /acme-sh-issue-azuredns


/acme-sh-issue-azuredns-staging-wildcard:  ## {forces/acmesh} acme.sh dns using az cli
	$(M) $@+INFO
	set -x

	ACME_MODE=$(ACME_MODE_STAG) \
	$(M) /acme-sh-issue-azuredns-wildcard

/acme-sh-copy-certs-wildcard: ## {forces/acmesh} copy certs to destination
	$(M) $@+INFO
	set -x

	if [ "$(ACME_DOMAIN)" == "" ]
	then
		$(M) $@+ERROR -- ACME_DOMAIN is not set
	fi

	$(M) /acme-sh-copy-certs  --  "--domain   '*.$(ACME_DOMAIN)' $(ARGVN)"

/acme-sh-copy-certs-staging-wildcard:  ## {forces/acmesh} copy staging certs to destination
	$(M) $@+INFO
	set -x

	ACME_MODE=$(ACME_MODE_STAG) \
	$(M) /acme-sh-copy-certs-wildcard

/acme-sh-convert-pkcs12-wildcard: ## {forces/acmesh} convert pem certs to pkcs12
	$(M) $@+INFO
	set -x

	if [ "$(ACME_DOMAIN)" == "" ]
	then
		$(M) $@+ERROR -- ACME_DOMAIN is not set
	fi

	$(M) /acme-sh-convert-pkcs12 --  "--domain  '*.$(ACME_DOMAIN)' $(ARGVN)"

/acme-sh-convert-pkcs12-staging-wildcard: ## {forces/acmesh} convert staging pem certs to pkcs12
	$(M) $@+INFO
	set -x

	ACME_MODE=$(ACME_MODE_STAG) \
	$(M) /acme-sh-convert-pkcs12-wildcard

/acme-sh-all-azuredns: ## {forces/acmesh} acme.sh dns using az cli
	$(M) $@+INFO

	$(M) /acme-sh-issue-azuredns
	$(M) /acme-sh-copy-certs-azuredns
	$(M) /acme-sh-convert-pkcs12

/acme-sh-all-azuredns-wildcard: ## {forces/acmesh} acme.sh dns using az cli
	$(M) $@+INFO

	$(M) /acme-sh-issue-azuredns-wildcard
	$(M) /acme-sh-convert-pkcs12-wildcard
	$(M) /acme-sh-copy-certs-wildcard

#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ Install tools
#███████████████████████████████████████████████████████████████████████████████████████████████████
ifdef FORCES_TOOLS_ENABLE_INSTALL

#---------------------------------------------------------------------------------------------------
#-- ACME.SH
#---------------------------------------------------------------------------------------------------


/install-acme-sh: ## {forces/acmesh} installs acme.sh
	$(M) $@+INFO
	set -x

	if [ "$(ACME_EMAIL)" == "" ];
	then
		$(M) $@+ERROR -- ACME_EMAIL is not set
		exit 1
	fi

	if [ "$(ACME_SH_DIR)" == "" ];
	then
		$(M) $@+ERROR -- ACME_SH_DIR is not set
		exit 1
	fi

	curl https://get.acme.sh | sh -s email=$(ACME_EMAIL) --no-cron 2>/dev/null

	set -x

	$(M) /install-acme-sh-contrib

/install-acme-sh-contrib: ## {forces/acmesh} installs acme.sh contrib scripts
	$(M) $@+INFO
	set -x
	cp -rf $(FORCES_PATH)/acme.sh/dnsapi/*.sh $(ACME_SH_DIR)/dnsapi

endif
