/*
    Action Group for Automated VM Reboot
    ------------------------------------
    - resource: azurerm_monitor_action_group.action_group
    - name: "ag-reboot-vm"
    - short_name: "reboot"
    - Purpose: Defines an Action Group that triggers an Azure Automation Runbook
      whenever an alert (such as a Load Balancer probe failure) is fired.
      This Action Group sends a webhook call to the Automation Account runbook
      that performs the virtual machine reboot.
*/
resource "azurerm_monitor_action_group" "action_group" {
    name                = "ag-reboot-vm"
    resource_group_name = var.resource_group_name
    short_name          = "reboot"

    #Connects the Action Group with an Automation Runbook so the alert system. Can automatically trigger a VM reboot through a webhook call.
    automation_runbook_receiver {
        name                    = "reboot-vm-webhook"
        automation_account_id   = azurerm_automation_account.auto_account.id
        runbook_name            = azurerm_automation_runbook.reboot_vm_runbook.name
        webhook_resource_id     = azurerm_automation_runbook.reboot_vm_runbook.id
        is_global_runbook       = true
        service_uri             = "https://s1events.azure-automation.net/webhooks"
        use_common_alert_schema = true 
    }
}