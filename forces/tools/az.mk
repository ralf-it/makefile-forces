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
#███ AZURE
#███████████████████████████████████████████████████████████████████████████████████████████████████

AZ_ACR ?= mcr.microsoft.com
AZ_ACR_NAME ?= $(shell echo $(AZ_ACR) | cut -d . -f1)

AZ_WEBAPP_SSH_PORT ?= 33623


/az: ## {forces/az} wrapper around AZ CLI with env set by makefile-forces
	$(M) $@+INFO
	set -xeuo pipefail
	az $(ARGVN)

## ! NOTE: workaround for avaiability error ...
## ... "Unable to get endpoints from the cloud. Server returned status code 503 for ...
## ... https://westeurope.management.azure.com/metadata/endpoints?api-version=2015-01-01"
/az-set-resource-manager-endpoint: ## {forces/azure} Make sure we can connect to azure resource manager endpoint will fallback to other regions
	$(M) $@+INFO
	set -xeuo pipefail
	if ! az cloud update --endpoint-resource-manager https://westeurope.management.azure.com;
		then
		if ! az cloud update --endpoint-resource-manager https://francecentral.management.azure.com;
		then
			az cloud update --endpoint-resource-manager https://switzerlandnorth.management.azure.com;
		fi
	fi

# /az-login-auto: ## {forces/azure} login to azure in order: SP -> User
# 	$(M) $@+INFO
# 	set -x
# ifdef ARM_TENANT_ID
#     ifdef ARM_CLIENT_ID
#         ifdef ARM_CLIENT_SECRET
# 	        $(M) /az-login-sp-tf
#         endif
#     endif
# else ifdef AZURE_TENANT_ID
#     ifdef AZURE_CLIENT_ID
#         ifdef AZURE_CLIENT_SECRET
# 	        $(M) /az-login-sp
#         endif
# 	else ifdef AZURE_USER_IDENTITY
# 	    $(M) /az-login-umi
#     else
# 	    $(M) /az-login-tid
#     endif
# else
# 	$(M) /az-login
# endif

/az-login: ## {forces/azure} login to azure
	$(M) $@+INFO
ifdef ARM_TENANT_ID
	az login  --tenant $(ARM_TENANT_ID) --allow-no-subscriptions
else
	az login --allow-no-subscriptions
endif

/az-login-devicecode: ## {forces/azure} login to azure with device code
	$(M) $@+INFO
ifdef ARM_TENANT_ID
	az login  --tenant $(ARM_TENANT_ID)  --use-device-code --allow-no-subscriptions
else
	az login --use-device-code --allow-no-subscriptions
endif

/az-login-tid:  ## {forces/azure} login to azure with tenant id
	$(M) $@+INFO
	az login --tenant $(AZURE_TENANT_ID) --allow-no-subscriptions

/az-login-sp: ## {forces/azure} login to azure with service principal
	$(M) $@+INFO
	set -x
	az login --service-principal --username $(AZURE_CLIENT_ID) --password $(AZURE_CLIENT_SECRET) --tenant $(AZURE_TENANT_ID) --allow-no-subscriptions

/az-login-sp-tf: ## {forces/azure} login to azure with service principal with TF creds
	$(M) $@+INFO
	set -x
	az login --service-principal --allow-no-subscriptions --password $(ARM_CLIENT_SECRET) --username $(ARM_CLIENT_ID) --tenant $(ARM_TENANT_ID)

/az-login-smi: ## {forces/azure} login to azure with system managed identity
	$(M) $@+INFO
	set -x
ifdef ARM_TENANT_ID
	az login --tenant $(ARM_TENANT_ID) --identity --allow-no-subscriptions
else
	az login --identity  --allow-no-subscriptions
endif

/az-login-umi: ## {forces/azure} login to azure with user managed identity
	$(M) $@+INFO
	set -x
ifdef ARM_TENANT_ID
	az login --tenant $(ARM_TENANT_ID) --identity --username $(AZURE_USER_IDENTITY) --allow-no-subscriptions
else
	az login --identity --username $(AZURE_USER_IDENTITY)  --allow-no-subscriptions
endif

/az-login-ms-graph: ## {forces/azure} login to azure with ms graph
	$(M) $@+INFO
	set -x
	az login --scope https://graph.microsoft.com --allow-no-subscriptions

/az-login-ms-graph-ownedby: ## {forces/azure} login to azure with ms graph app owned by
	$(M) $@+INFO
	set -x
	az login --scope https://graph.microsoft.com/Application.ReadWrite.OwnedBy --allow-no-subscriptions

/az-ms-graph-account-show: ## {forces/azure} ms graph help
	$(M) $@+INFO
	az rest --method get --uri https://graph.microsoft.com/v1.0/me

/az-ms-graph-help: ## {forces/azure} ms graph help
	$(M) $@+INFO
	open https://learn.microsoft.com/en-us/graph/permissions-reference

/az-acr-login: ## {forces/azure} login to azure container registry and whitelist current IP
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

/az-set-sub: ## {forces/azure} set subscription to AZ_SUBSCRIPTION_ID
	$(M) $@+INFO
	set -x
	az account set --subscription $(AZ_SUBSCRIPTION_ID)

/az-set-sub-dev: ## {forces/azure} set subscription to AZ_SUBSCRIPTION_ID_DEV
	$(M) $@+INFO
	set -x
	az account set --subscription $(AZ_SUBSCRIPTION_ID_DEV)

/az-set-sub-qa: ## {forces/azure} set subscription to AZ_SUBSCRIPTION_ID_QA
	$(M) $@+INFO
	set -x
	az account set --subscription $(AZ_SUBSCRIPTION_ID_QA)

/az-set-sub-stag: ## {forces/azure} set subscription to AZ_SUBSCRIPTION_ID_STAG
	$(M) $@+INFO
	set -x
	az account set --subscription $(AZ_SUBSCRIPTION_ID_STAG)

/az-set-sub-prod: ## {forces/azure} set subscription to AZ_SUBSCRIPTION_ID_PROD
	$(M) $@+INFO
	set -x
	az account set --subscription $(AZ_SUBSCRIPTION_ID_PROD)

/az-storage-whitelist-ip: ## {forces/azure} whitelist IP for $(item)
	$(M) $@+INFO
	set -x

	if [ "$(AZ_RG_NAME)" == "" ]
	then
		$(M) $@+ERROR -- AZ_RG_NAME is not set
		exit 1
	fi

	if [ "$(AZ_SA_NAME)" == "" ]
	then
		$(M) $@+ERROR -- AZ_SA_NAME is not set
		exit 1
	fi

	if [ "$(MY_IP)" == "" ]
	then
		$(M) $@+ERROR -- MY_IP is not set
		exit 1
	fi

	az storage account network-rule add \
	-g $(AZ_RG_NAME) \
	-n $(AZ_SA_NAME) \
	--ip-address $(MY_IP)


/az-webapp-ssh-tunnel: ## [az] create a ssh tunnel to a webapp
	$(M) $@+INFO

	if [ "$(AZ_RG)" == "" ]
	then
		$(M) $@+ERROR -- AZ_RG is not set
		exit 1
	fi

	if [ "$(AZ_APPSVC)" == "" ]
	then
		$(M) $@+ERROR -- AZ_APPSVC is not set
		exit 1
	fi

	az webapp create-remote-connection  -g $(AZ_RG) -n $(AZ_APPSVC) --port $(AZ_WEBAPP_SSH_PORT) $(ARGVN)

/az-webapp-ssh: ## [az] ssh to a webapp
	$(M) $@+INFO
	set -x

	if ! sshpass -V
	then
		$(M) $@+ERROR -- sshpass is not installed
	fi

	export SSHPASS="Docker!"
	sshpass -e ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no root@127.0.0.1 -p $(AZ_WEBAPP_SSH_PORT) $(ARGVN)

/az-psqlf-unwhitelist-myip: ## {forces/azure} un-whitelist my ip for postgres flexible server
	$(M) $@+INFO
	set -x

	if [ "$(AZ_RG_NAME)" == "" ]
	then
		$(M) $@+ERROR -- AZ_RG_NAME is not set
		exit 1
	fi

	if [ "$(AZ_PSQLF_NAME)" == "" ]
	then
		$(M) $@+ERROR -- AZ_PSQLF_NAME is not set
		exit 1
	fi

	if [ "$(RULE_NAME)" == "" ]
	then
		$(M) $@+ERROR -- RULE_NAME is not set
		exit 1
	fi

	az postgres flexible-server firewall-rule delete \
		--resource-group ${AZ_RG_NAME} \
		--name ${AZ_PSQLF_NAME} \
		--rule-name "${RULE_NAME}" \
		--yes

/az-psqlf-whitelist-myip: ## {forces/azure} whitelist my ip for postgres flexible server
	$(M) $@+INFO
	set -x

	if ! SUBCOMMAND=update $(M) /az-psqlf-whitelist-myip__;
	then
		SUBCOMMAND=create $(M) /az-psqlf-whitelist-myip__
	fi

/az-psqlf-whitelist-myip__: ## {forces/azure/internal} whitelist my ip for postgres flexible server
	$(M) $@+INFO
	set -x

	if [ "$(AZ_RG_NAME)" == "" ]
	then
		$(M) $@+ERROR -- AZ_RG_NAME is not set
		exit 1
	fi

	if [ "$(AZ_PSQLF_NAME)" == "" ]
	then
		$(M) $@+ERROR -- AZ_PSQLF_NAME is not set
		exit 1
	fi

	if [ "$(MY_IP)" == "" ]
	then
		$(M) $@+ERROR -- MY_IP is not set
		exit 1
	fi

	if [ "$(RULE_NAME)" == "" ]
	then
		$(M) $@+ERROR -- RULE_NAME is not set
		exit 1
	fi

	if [ "$(SUBCOMMAND)" == "" ]
	then
		$(M) $@+ERROR -- SUBCOMMAND is not set
		exit 1
	fi

	az postgres flexible-server firewall-rule $(SUBCOMMAND) \
		--resource-group ${AZ_RG_NAME} \
		--name ${AZ_PSQLF_NAME} \
		--rule-name "${RULE_NAME}" \
		--start-ip-address ${MY_IP} \
		--end-ip-address  ${MY_IP};

/az-webapp-logs-tail: ## {forces/azure} tail logs from webapp
	$(M) $@+INFO
	set -x

	if [ "$(AZ_RG)" == "" ]
	then
		$(M) $@+ERROR -- AZ_RG is not set
		exit 1
	fi

	if [ "$(AZ_APPSVC)" == "" ]
	then
		$(M) $@+ERROR -- AZ_APPSVC is not set
		exit 1
	fi

	az webapp log tail -g $(AZ_RG) -n $(AZ_APPSVC) --verbose

#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ Install tools
#███████████████████████████████████████████████████████████████████████████████████████████████████
ifdef FORCES_TOOLS_ENABLE_INSTALL

#---------------------------------------------------------------------------------------------------
#-- AZURE
#---------------------------------------------------------------------------------------------------

/install-az-cli: ## {forces/azure} installs az cli
	$(M) $@+INFO
	set -x
	pip install azure-cli

/install-az-cli-interactive: ## {forces/azure} installs az cli interactive
	$(M) $@+INFO
	set -x
	curl -L https://aka.ms/InstallAzureCli | bash



endif
