/*
  Resource Group Name Output
  ---------------------------
  - description: Exposes the name of the Azure Resource Group created in the
    deployment.
  - value: Retrieves the `name` attribute from the `azurerm_resource_group.rg`
    resource.
  - usage: Useful for referencing the Resource Group across modules, automation
    scripts, policies, or when querying Azure for deployed assets.
*/
output "rg_name" {
  description = "The name of the Azure Resource Group."
  value       = azurerm_resource_group.rg.name
}

/*
  Resource Group Location Output
  -------------------------------
  - description: Provides the Azure region where the Resource Group resides.
  - value: Extracts the `location` attribute from the
    `azurerm_resource_group.rg` resource.
  - usage: Helps maintain regional consistency when deploying dependent
    resources, validating compliance, or generating region-specific automation.
*/
output "rg_location" {
  description = "The location of the Azure Resource Group."
  value       = azurerm_resource_group.rg.location
}