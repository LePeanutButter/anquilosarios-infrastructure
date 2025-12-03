/*
  Load Balancer Public IP Output
  ------------------------------
  - description: Exposes the public IP address assigned to the Azure Load
    Balancer.
  - value: Fetches the `ip_address` attribute from the `azurerm_public_ip.lb_pip`
    resource.
  - usage: Essential for routing external traffic to backend resources
    behind the Load Balancer, integration with DNS, or monitoring purposes.
*/
output "load_balancer_public_ip" {
  description = "Public IP address for the Load Balancer"
  value       = azurerm_public_ip.lb_pip.ip_address
}

/*
  Load Balancer Resource ID Output
  --------------------------------
  - description: Exposes the unique Azure Resource Manager (ARM) ID
    associated with the Azure Load Balancer.
  - value: Retrieves the `id` attribute from the `azurerm_lb.lb` resource.
  - usage: Useful for referencing the Load Balancer in other modules,
    attaching dependent resources (such as backend pools, probes, or rules),
    or integrating with automation, monitoring, and governance tooling that
    relies on ARM resource identifiers.
*/
output "lb_id" {
  description = "The ID of the Azure Load Balancer."
  value       = azurerm_lb.lb.id
}

output "probe_name" {
  value = azurerm_lb_probe.tcp_probe.name
}

output "backend_pool_name" {
  value = azurerm_lb_backend_address_pool.bpool.name
}
