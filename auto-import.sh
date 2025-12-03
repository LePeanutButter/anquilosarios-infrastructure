#!/usr/bin/env bash
#===============================================================================
# Script Name   : auto-import.sh
# Description   : Automatically imports existing Azure resources into the local
#               : Terraform state. If a resource already exists in the state,
#               : it is skipped. If the Azure resource exists but is not yet in
#               : Terraform state, it is imported. If the Azure resource does
#               : not exist, Terraform will create it during apply.
# Author        : LePeanutButter, Lanapequin, shiro
# Created       : 2025-12-02
# License       : MIT License
#===============================================================================

set -e

echo "Starting automatic Terraform import process..."

SUBSCRIPTION="${ARM_SUBSCRIPTION_ID}"

#-------------------------------------------------------------------------------
# IMPORT LIST
# Each entry defines a Terraform address and its matching Azure resource ID.
# Format:
#     TF_ADDRESS|AZURE_ID
#
# These resources will be checked one by one:
#   - If already in Terraform state → skipped
#   - If found in Azure → imported to state
#   - If not found in Azure → left for Terraform to create
#-------------------------------------------------------------------------------
IMPORTS=(
  "module.resource_group.azurerm_resource_group.rg|/subscriptions/$SUBSCRIPTION/resourceGroups/anquilosaurios-rg"
  "module.network.azurerm_virtual_network.vnet|/subscriptions/$SUBSCRIPTION/resourceGroups/anquilosaurios-rg/providers/Microsoft.Network/virtualNetworks/anquilo-vnet"
  "module.network.azurerm_subnet.subnet|/subscriptions/$SUBSCRIPTION/resourceGroups/anquilosaurios-rg/providers/Microsoft.Network/virtualNetworks/anquilo-vnet/subnets/default"
  "module.compute.azurerm_public_ip.pubip[0]|/subscriptions/$SUBSCRIPTION/resourceGroups/anquilosaurios-rg/providers/Microsoft.Network/publicIPAddresses/anquilo-vm-pip-0"
  "module.compute.azurerm_public_ip.pubip[1]|/subscriptions/$SUBSCRIPTION/resourceGroups/anquilosaurios-rg/providers/Microsoft.Network/publicIPAddresses/anquilo-vm-pip-1"
  "module.loadbalancer.azurerm_public_ip.lb_pip|/subscriptions/$SUBSCRIPTION/resourceGroups/anquilosaurios-rg/providers/Microsoft.Network/publicIPAddresses/anquilo-lb-pip"
  "module.network.azurerm_network_security_group.nsg|/subscriptions/$SUBSCRIPTION/resourceGroups/anquilosaurios-rg/providers/Microsoft.Network/networkSecurityGroups/anquilo-nsg"
)

#===============================================================================
# IMPORT LOOP
# Iterates through all defined resources, checking state, checking Azure, and
# performing imports when necessary. This section is fully idempotent.
#===============================================================================
for ITEM in "${IMPORTS[@]}"; do
    TF_ADDR="${ITEM%%|*}"
    AZURE_ID="${ITEM##*|}"

    echo "Checking $TF_ADDR"

    if terraform state show "$TF_ADDR" >/dev/null 2>&1; then
        echo "Already in state — skipping"
        continue
    fi

    if az resource show --ids "$AZURE_ID" >/dev/null 2>&1; then
        echo "Importing existing Azure resource..."
        terraform import "$TF_ADDR" "$AZURE_ID"
    else
        echo "Azure resource not found — will be created by Terraform"
    fi
done

echo "Auto-import complete"
