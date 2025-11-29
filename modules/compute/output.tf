/*
  Public IP Addresses Output
  ---------------------------
  - value: Retrieves the list of public IP addresses from all
    `azurerm_public_ip.pubip` resources.
  - usage: Commonly used to connect to virtual machines or expose services
    after the infrastructure is provisioned.
*/
output "public_ips" {
    value = azurerm_public_ip.pubip[*].ip_address
}

/*
    Virtual Machine Names Output
    -----------------------------
    - value: Returns the names of all Azure Linux Virtual Machines created via
      the `azurerm_linux_virtual_machine.vm` resource.
    - usage: Helpful for logging, automation, referencing VM resources, or
      integrating with external systems that require VM identification.
*/
output "vm_names" {
    description = "List of VM names."
    value = azurerm_linux_virtual_machine.vm[*].name
}

/*
    Network Interface IDs Output
    ----------------------------
    - description: Provides the IDs of all network interfaces (NICs) created
      for the virtual machines.
    - value: Retrieves the `id` attribute from each `azurerm_network_interface.nic`
      resource.
    - usage: Useful for attaching NICs to other resources, referencing in
      automation scripts, or troubleshooting network configurations.
*/
output "nic_ids" {
    value = azurerm_network_interface.nic[*].id
}

output "nic_ip_names" {
    value = [for nic in azurerm_network_interface.nic : nic.ip_configuration[0].name]
}
