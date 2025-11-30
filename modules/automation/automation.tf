/*
    Automation Account
    ------------------------------------
    - resource: azurerm_automation_account.auto_account
    - name: Prefixed with "auto-" followed by the Resource Group name
    - sku_name: Basic tier for Azure Automation
    - identity: SystemAssigned Managed Identity required for authenticating
                inside runbooks without credentials

    Purpose:
    Hosts the Azure Automation Runbook responsible for VM recovery operations
    such as restarting a failed virtual machine.
*/
resource "azurerm_automation_account" "auto_account" {
    name                = "auto-${var.resource_group_name}"
    location            = var.location
    resource_group_name = var.resource_group_name
    sku_name            = "Basic"

    identity {
        type = "SystemAssigned"
    }
}

/*
    Automation Runbook (VM Restart Script)
    -----------------------------------------
    - resource: azurerm_automation_runbook.reboot_vm_runbook
    - name: "Reboot-Failed-VM"
    - runbook_type: PowerShell
    - content: Embedded PowerShell script used to restart a VM
    - automation_account_name: Uses the Automation Account defined above

    Script Purpose:
    - Authenticates using the Automation Account's managed identity
    - Logs which VM is being restarted
    - Calls Restart-AzVM to restart the affected virtual machine

    Note:
    Azure Automation typically ships with the Az.Compute module preinstalled,
    which is required for Restart-AzVM.
*/
resource "azurerm_automation_runbook" "reboot_vm_runbook" {
    name                    = "Reboot-Failed-VM"
    location                = var.location
    resource_group_name     = var.resource_group_name
    automation_account_name = azurerm_automation_account.auto_account.name
    runbook_type            = "PowerShell"
    log_progress            = true
    log_verbose             = true
    content                 = file("${path.module}/reboot.ps1")
}