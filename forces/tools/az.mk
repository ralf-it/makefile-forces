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

/az-login: ## {forces/azure} login to azure
	$(M) $@+INFO
	az login

/az-login-devicecode: ## {forces/azure} login to azure with device code
	$(M) $@+INFO
	az login --use-device-code

/az-login-sp: ## {forces/azure} login to azure with service principal
	$(M) $@+INFO
	set -x
	az login --service-principal --username $(AZURE_CLIENT_ID) --password $(AZURE_CLIENT_SECRET) --tenant $(AZURE_TENANT_ID)

/az-login-smi: ## {forces/azure} login to azure with system managed identity
	$(M) $@+INFO
	set -x
	az login --identity

/az-login-umi: ## {forces/azure} login to azure with user managed identity
	$(M) $@+INFO
	set -x
	az login --identity --username $(AZURE_USER_IDENTITY)

/az-login-ms-graph: ## {forces/azure} login to azure with ms graph
	$(M) $@+INFO
	set -x
	az login --scope https://graph.microsoft.com

/az-login-ms-graph-ownedby: ## {forces/azure} login to azure with ms graph app owned by
	$(M) $@+INFO
	set -x
	az login --scope https://graph.microsoft.com/Application.ReadWrite.OwnedBy

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

/az-set-sub-dev: ## {forces/azure} set subscription to AZ_SUBSCRIPTION_DEV_ID
	$(M) $@+INFO
	set -x
	az account set --subscription $(AZ_SUBSCRIPTION_DEV_ID)

/az-set-sub-qa: ## {forces/azure} set subscription to AZ_SUBSCRIPTION_QA_ID
	$(M) $@+INFO
	set -x
	az account set --subscription $(AZ_SUBSCRIPTION_QA_ID)

/az-set-sub-stag: ## {forces/azure} set subscription to AZ_SUBSCRIPTION_STAG_ID
	$(M) $@+INFO
	set -x
	az account set --subscription $(AZ_SUBSCRIPTION_STAG_ID)

/az-set-sub-prod: ## {forces/azure} set subscription to AZ_SUBSCRIPTION_PROD_ID
	$(M) $@+INFO
	set -x
	az account set --subscription $(AZ_SUBSCRIPTION_PROD_ID)

#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ Install tools
#███████████████████████████████████████████████████████████████████████████████████████████████████
ifdef FORCES_TOOLS_ENABLE_INSTALL

#---------------------------------------------------------------------------------------------------
#-- AZURE
#---------------------------------------------------------------------------------------------------

/install-az-cli: ## {forces/azure} install az cli
	$(M) $@+INFO
	set -x
	pip install azure-cli

/install-az-cli-interactive: ## {forces/azure} install az cli interactive
	$(M) $@+INFO
	set -x
	curl -L https://aka.ms/InstallAzureCli | bash



endif
