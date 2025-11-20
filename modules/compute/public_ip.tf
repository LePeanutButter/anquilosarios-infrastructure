/*
    Public IPs
    ----------
    Creates a public IP per VM for external SSH/L2 access.
*/
resource "azurerm_public_ip" "pubip" {
    count               = var.vm_count
    name                = "anquilo-vm-pip-${count.index}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Dynamic"
    sku                 = "Basic"
}