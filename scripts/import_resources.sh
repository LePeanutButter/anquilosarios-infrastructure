#!/usr/bin/env bash

set -e

SUBS="${ARM_SUBSCRIPTION_ID}"
RG="anquilosaurios-rg"

echo "Importing Azure resources into Terraform state..."

terraform import module.acr.azurerm_container_registry.acr /subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.ContainerRegistry/registries/anquiloacr || true

terraform import module.automation.azurerm_automation_account.auto_account /subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Automation/automationAccounts/auto-anquilosaurios-rg || true

terraform import module.compute.azurerm_public_ip.pubip[0] /subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Network/publicIPAddresses/anquilo-vm-pip-0 || true

terraform import module.compute.azurerm_public_ip.pubip[1] /subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Network/publicIPAddresses/anquilo-vm-pip-1 || true

terraform import module.loadbalancer.azurerm_public_ip.lb_pip /subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Network/publicIPAddresses/anquilo-lb-pip || true

terraform import module.network.azurerm_network_security_group.nsg /subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Network/networkSecurityGroups/anquilo-nsg || true

terraform import module.network.azurerm_virtual_network.vnet /subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Network/virtualNetworks/anquilo-vnet || true

terraform import module.automation.azurerm_automation_runbook.reboot_vm_runbook "/subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Automation/automationAccounts/auto-anquilosaurios-rg/runbooks/Reboot-Failed-VM"

terraform import module.network.azurerm_subnet.subnet "/subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Network/virtualNetworks/anquilo-vnet/subnets/default"

terraform import module.automation.azurerm_monitor_action_group.action_group "/subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Insights/actionGroups/ag-reboot-vm"

terraform import module.loadbalancer.azurerm_lb.lb "/subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Network/loadBalancers/anquilo-lb"

terraform import module.loadbalancer.azurerm_lb_backend_address_pool.bpool /subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Network/loadBalancers/anquilo-lb/backendAddressPools/anquilo-bpool

terraform import module.loadbalancer.azurerm_lb_probe.tcp_probe /subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Network/loadBalancers/anquilo-lb/probes/tcp-probe

terraform import module.compute.azurerm_network_interface.nic[0] /subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Network/networkInterfaces/anquilo-nic-0

terraform import module.compute.azurerm_network_interface.nic[1] /subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Network/networkInterfaces/anquilo-nic-1

terraform import module.compute.azurerm_linux_virtual_machine.vm[0] "/subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Compute/virtualMachines/anquilo-vm-0"

terraform import module.compute.azurerm_linux_virtual_machine.vm[1] "/subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Compute/virtualMachines/anquilo-vm-1"

terraform import module.loadbalancer.azurerm_lb_rule.http_rule "/subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Network/loadBalancers/anquilo-lb/loadBalancingRules/http-rule"

terraform import module.network.azurerm_subnet_network_security_group_association.subnet_nsg "/subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Network/virtualNetworks/anquilo-vnet/subnets/default"

terraform import module.loadbalancer.azurerm_network_interface_backend_address_pool_association.nic_assoc[0] "/subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Network/networkInterfaces/anquilo-nic-0/ipConfigurations/internal|/subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Network/loadBalancers/anquilo-lb/backendAddressPools/anquilo-bpool" || true

terraform import module.loadbalancer.azurerm_network_interface_backend_address_pool_association.nic_assoc[1] "/subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Network/networkInterfaces/anquilo-nic-1/ipConfigurations/internal|/subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Network/loadBalancers/anquilo-lb/backendAddressPools/anquilo-bpool" || true

terraform import module.automation.azurerm_monitor_metric_alert.lb_health_alert "/subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.Insights/metricAlerts/lb-probe-unhealthy-alert"

echo "Imports completed (errors ignored if already imported)."