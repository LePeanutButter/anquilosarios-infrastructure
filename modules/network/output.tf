/*
    Virtual Network Name Output
    ----------------------------
    - description: Exposes the name of the Virtual Network (VNet) created.
    - value: Retrieves the `name` attribute of the `azurerm_virtual_network.vnet` resource.
    - usage: Useful for referencing this VNet from other modules such as subnets,
      network security groups, or load balancers.
*/
output "vnet_name" {
    description = "The name of the Virtual Network (VNet)."
    value       = azurerm_virtual_network.vnet.name
}

/*
    Subnet ID Output
    -----------------
    - description: Exposes the resource ID of the subnet created within the Virtual Network.
    - value: Retrieves the `id` attribute of the `azurerm_subnet.subnet` resource.
    - usage: Commonly used when attaching Network Interfaces (NICs), route tables,
      or configuring other networking components that depend on the subnet.
*/
output "subnet_id" {
    description = "The ID of the subnet created inside the VNet."
    value       = azurerm_subnet.subnet.id
}