/*
    Subnet + NSG Association
    ------------------------
    Applies the NSG rules to the defined subnet.
*/
resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id

  lifecycle {
    replace_triggered_by = [
      null_resource.force_recreate_sentinel
    ]
  }
}
