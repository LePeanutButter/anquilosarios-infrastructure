# -------------------------------------------
# Template Rendering: Docker Compose YAML
# -------------------------------------------
locals {
  stack_yaml = templatefile("${path.module}/stack.tpl", {
    acr_name = var.acr_name
  })

  cloud_init = templatefile("${path.module}/cloud-init.tpl", {
    stack_yaml   = indent(6, local.stack_yaml)
    setup_script = indent(6, file("${path.module}/setup.sh"))
  })
}

/*
    Linux Virtual Machines
    ----------------------
    Deploys a set of Ubuntu Linux VMs using provided variables.
*/
resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "anquilo-vm-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  # NIC assigned to this VM
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id
  ]

  # OS disk configuration
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
    name                 = "osdisk-anquilo-${count.index}"
  }

  # Ubuntu 22.04 LTS Image
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Disable password authentication to enforce SSH key usage
  disable_password_authentication = true

  # SSH Key Authentication
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_public_key
  }

  # read the plain shell script and base64-encode it for Azure custom_data
  custom_data = base64encode(local.cloud_init)


  # Metadata tags for lifecycle management
  tags = {
    environment = "production"
    project     = "anquilosaurios"
  }
}
