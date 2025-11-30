/*
    Subnet
    ------
    Defines a subnet inside the Virtual Network.
*/
resource "azurerm_subnet" "subnet" {
    name                 = "default"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}