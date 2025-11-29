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