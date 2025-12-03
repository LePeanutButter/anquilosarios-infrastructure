/*
    Public IPs
    ----------
    Creates a public IP per VM for external SSH/L2 access.
*/
resource "azurerm_public_ip" "pubip" {
  count               = var.vm_count
  name                = "anquilo-vm-pip-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  lifecycle {
    replace_triggered_by = [
      null_resource.force_recreate_sentinel
    ]
  }
}
