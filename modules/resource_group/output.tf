output "rg_name" {
  description = "The name of the Azure Resource Group."
  value       = azurerm_resource_group.rg.name
}

output "rg_location" {
  description = "The location of the Azure Resource Group."
  value       = azurerm_resource_group.rg.location
}