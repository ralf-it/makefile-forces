#!/usr/bin/env bash
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

# ! TODO WIKI
# WIKI="https://github.com/acmesh-official/acme.sh/wiki/forces/acme.sh/dnsapi/README.md"

########  Public functions #####################

# Usage: add  _acme-challenge.www.domain.com   "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs"
# Used to add txt record
#
# Ref: https://docs.microsoft.com/en-us/rest/api/dns/recordsets/createorupdate
#

dns_azure_cli_add() {
    fulldomain=$1
    txtvalue=$2
    prefix0=_acme-challenge

    # Variables
    # AZUREDNS_SUBSCRIPTION_ID="$AZ_SUBSCRIPTION_ID_DEV"
    # AZUREDNS_RESOURCE_GROUP="dns-test"
    # _domain='localtest.pl'
    # fulldomain="_acme-challenge.$DNS_ZONE" # Adjust based on your needs, typically the subdomain part
    # txtvalue="2v5lAcUCXbEbAn9YkPvhhYDAphfKuX_1SxhnBQVjELg"

    if [ "${txtvalue}" == "" ]; then
        _err "You didn't specify the Azure DNS TXT value (txtvalue)"
        return 1
    fi

    if [ -z "${AZUREDNS_ZONE}" ]; then
        AZUREDNS_ZONE=""
        _err "You didn't specify the Azure Subscription ID (AZUREDNS_ZONE)"
        return 1
    fi

    if [ -z "${AZUREDNS_SUBSCRIPTION_ID}" ]; then
        AZUREDNS_SUBSCRIPTION_ID=""
        _err "You didn't specify the Azure Subscription ID (AZUREDNS_SUBSCRIPTION_ID)"
        return 1
    fi

    if [ -z "${AZUREDNS_RESOURCE_GROUP}" ]; then
        AZUREDNS_RESOURCE_GROUP=""
        _err "You didn't specify the Azure Resource Group (AZUREDNS_RESOURCE_GROUP)"
        return 1
    fi

    prefix=$(echo ${fulldomain} | sed "s:.${AZUREDNS_ZONE}::")

    if ! echo "${prefix}" | grep -qE "^${prefix0}"; then
        _err "The fulldomain (${fulldomain}) computed prefix (${prefix}) does not match pattern (${prefix0})."
        return 1
    fi

    if [ "${prefix}.${AZUREDNS_ZONE}" != "${fulldomain}" ]; then
        _err "The fulldomain(${fulldomain}) does not match to pattern prefix.AZUREDNS_ZONE(${prefix}.${AZUREDNS_ZONE})."
        return 1
    fi

    _info "Adding TXT record (name=${prefix}; value=${txtvalue}) to Azure DNS Zone: ${AZUREDNS_ZONE} (RG: ${AZUREDNS_RESOURCE_GROUP}; SUB: ${AZUREDNS_SUBSCRIPTION_ID}; FULLDOMAIN: ${fulldomain}) "

    set -x
    az network dns record-set txt add-record \
    --subscription "${AZUREDNS_SUBSCRIPTION_ID}" \
    --resource-group "${AZUREDNS_RESOURCE_GROUP}" \
    --zone-name "${AZUREDNS_ZONE}" \
    --record-set-name "${prefix}" \
    --value="${txtvalue}" # <<<  ! NOTE: it solves issue with values starting with '-'
    set +x

    _info "Record added successfully."

    return 0
}

dns_azure_cli_rm() {
    fulldomain=$1
    txtvalue=$2
    prefix0=_acme-challenge

    if [ -z "$AZUREDNS_SUBSCRIPTION_ID" ]; then
        AZUREDNS_SUBSCRIPTION_ID=""
        _err "You didn't specify the Azure Subscription ID (AZUREDNS_SUBSCRIPTION_ID)"
        return 1
    fi

    if [ -z "$AZUREDNS_RESOURCE_GROUP" ]; then
        AZUREDNS_RESOURCE_GROUP=""
        _err "You didn't specify the Azure Resource Group (AZUREDNS_RESOURCE_GROUP)"
        return 1
    fi

    if [ -z "${AZUREDNS_ZONE}" ]; then
        AZUREDNS_ZONE=""
        _err "You didn't specify the Azure Subscription ID (AZUREDNS_ZONE)"
        return 1
    fi

    prefix=$(echo ${fulldomain} | sed "s:.${AZUREDNS_ZONE}::")

    if ! echo "${prefix}" | grep -qE "^${prefix0}"; then
        _err "The fulldomain(${fulldomain}) computed prefix(${prefix}) does not match pattern prefix0.AZUREDNS_ZONE(${prefix0}.${AZUREDNS_ZONE})."
        return 1
    fi

    if [ "${prefix}.${AZUREDNS_ZONE}" != "${fulldomain}" ]; then
        _err "The fulldomain(${fulldomain}) does not match to pattern prefix.AZUREDNS_ZONE(${prefix}.${AZUREDNS_ZONE})."
        return 1
    fi

    _info "Deleting TXT record (name=${prefix}; value=${txtvalue}) to Azure DNS Zone: ${AZUREDNS_ZONE} (RG: ${AZUREDNS_RESOURCE_GROUP}; SUB: ${AZUREDNS_SUBSCRIPTION_ID}; FULLDOMAIN: ${fulldomain}) "

    az network dns record-set txt remove-record \
    --subscription "${AZUREDNS_SUBSCRIPTION_ID}" \
    --resource-group "${AZUREDNS_RESOURCE_GROUP}" \
    --zone-name "${AZUREDNS_ZONE}" \
    --record-set-name "${prefix}" \
    --value "${txtvalue}" \
    --keep-empty-record-set

    _info "Record deleted successfully."
    return 0

}