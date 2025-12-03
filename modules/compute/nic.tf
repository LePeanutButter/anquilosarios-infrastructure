/*
    Network Interfaces (NICs)
    -------------------------
    Each VM receives a NIC connected to the subnet and assigned a public IP.
*/
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "anquilo-nic-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pubip[count.index].id
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.force_recreate_sentinel
    ]
  }
}
