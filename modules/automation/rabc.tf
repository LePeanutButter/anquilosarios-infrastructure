/*
  Data Source: Azure Resource Group
  ---------------------------------
  Inputs:
      - name: The name of the existing Azure Resource Group to look up (from variable `var.resource_group_name`).

  Purpose:
      - Retrieves information about an existing Azure Resource Group by name.
      - Provides access to properties of the resource group such as its `id`, `location`, and `tags`.
      - Enables other resources or role assignments to reference the RG dynamically without hardcoding the ID.
*/
data "azurerm_resource_group" "rg" {
    name = var.resource_group_name
}

/*
    Role Assignment for Automation Runbook (RBAC)
    ---------------------------------------------
    - resource: azurerm_role_assignment.auto_account_rbac
    - scope: Assigns permissions at the Resource Group level
    - role_definition_name: "Contributor"
    - principal_id: Identity of the Automation Account

    Purpose:
    Grants the Automation Account's managed identity the "Contributor" role
    so the runbook can perform operations such as starting, stopping,
    or restarting virtual machines inside the target Resource Group.
*/
resource "azurerm_role_assignment" "auto_account_rbac" {
    scope                = data.azurerm_resource_group.rg.id
    role_definition_name = "Contributor"
    principal_id         = azurerm_automation_account.auto_account.identity[0].principal_id
}