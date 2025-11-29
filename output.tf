/*
  Terraform Output Values
  ------------------------
  - Expose useful information about created Azure resources after deployment.
  - These outputs can be referenced by other modules, automation scripts,
    or displayed to the user upon completion of `terraform apply`.
*/

output "public_ips" {
  value = module.compute.public_ips
}

output "vm_names" {
  value = module.compute.vm_names
}

output "nic_ids" {
  value = module.compute.nic_ids
}

output "nic_ip_names" {
  value = module.compute.nic_ip_names
}

output "load_balancer_public_ip" {
  value = module.loadbalancer.load_balancer_public_ip
}

output "login_server" {
  value = module.acr.login_server
}

output "admin_username" {
  value = module.acr.admin_username
}

output "admin_password" {
  value = module.acr.admin_password
}

output "rg_name" {
  value = module.resource_group.rg_name
}

output "rg_location" {
  value = module.resource_group.rg_location
}

output "vnet_name" {
  value = module.network.vnet_name
}

output "subnet_id" {
  value = module.network.subnet_id
}