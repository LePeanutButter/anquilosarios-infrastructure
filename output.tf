/*
  Terraform Output Values
  ------------------------
  - Expose useful information about created Azure resources after deployment.
  - These outputs can be referenced by other modules, automation scripts,
    or displayed to the user upon completion of `terraform apply`.
*/

# List of public IPs created for compute resources
output "public_ips" {
  value = module.compute.public_ips
}

# Names of the deployed virtual machines
output "vm_names" {
  value = module.compute.vm_names
}

# Network Interface resource IDs for the compute VMs
output "nic_ids" {
  value = module.compute.nic_ids
}

# Names of the IP configurations associated with each NIC
output "nic_ip_names" {
  value = module.compute.nic_ip_names
}

# Public IP address assigned to the Load Balancer
output "load_balancer_public_ip" {
  value = module.loadbalancer.load_balancer_public_ip
}

# Azure Container Registry login server URL
output "login_server" {
  value = module.acr.login_server
}

# Admin username for Azure Container Registry
output "admin_username" {
  value = module.acr.admin_username
}

# Admin password for Azure Container Registry
output "admin_password" {
  value     = module.acr.admin_password
  sensitive = true
}

# Name of the Virtual Network
output "vnet_name" {
  value = module.network.vnet_name
}

# Subnet ID within the Virtual Network
output "subnet_id" {
  value = module.network.subnet_id
}

# Resource ID of the Azure Load Balancer
output "lb_id" {
  value = module.loadbalancer.lb_id
}
