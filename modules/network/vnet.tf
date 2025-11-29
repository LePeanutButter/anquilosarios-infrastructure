/*
    Virtual Network (VNet)
    ----------------------
    Provides an isolated network environment within Azure.
*/
resource "azurerm_virtual_network" "vnet" {
  name                = "anquilo-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}