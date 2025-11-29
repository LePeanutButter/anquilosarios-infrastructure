/*
  Terraform Output Values
  ------------------------
  - Expose useful information about created Azure resources after deployment.
  - These outputs can be referenced by other modules, automation scripts,
    or displayed to the user upon completion of `terraform apply`.
*/

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
  description = "IDs of the NICs created for the VMs"
  value       = azurerm_network_interface.nic[*].id
}

output "nic_ip_names" {
  value = azurerm_network_interface.nic[*].ip_configuration[0].name
}

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
  ACR Login Server Output
  ------------------------
  - description: Provides the fully qualified login server URL of the Azure
    Container Registry instance.
  - value: Retrieves the `login_server` attribute from the
    `azurerm_container_registry.acr` resource.
  - usage: Required when pushing or pulling container images using Docker,
    CI/CD pipelines, or other container tooling.
*/
output "login_server" {
  value = azurerm_container_registry.acr.login_server
}

/*
  ACR Admin Username Output
  --------------------------
  - description: Returns the administrative username for the Azure Container
    Registry when admin access is enabled.
  - value: Extracts the `admin_username` attribute from the ACR resource.
  - usage: Used for authenticating to the registry from automation scripts,
    local Docker clients, or build pipelines that require ACR login.
*/
output "admin_username" {
  value = azurerm_container_registry.acr.admin_username
}


/*
  ACR Admin Password Output
  --------------------------
  - description: Exposes the admin password associated with the Azure
    Container Registry. Marked as **sensitive** to ensure it is not displayed
    in logs or CLI output.
  - value: Retrieves the `admin_password` secret value from the ACR resource.
  - usage: Required for authentication when using admin-based access to push
    or pull images. Should be stored securely in secret managers or CI/CD
    variable stores.
*/
output "admin_password" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}
