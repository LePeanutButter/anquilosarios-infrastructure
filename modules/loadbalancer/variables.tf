variable "resource_group_name" {}
variable "location" {}
variable "frontend_port" {}
variable "backend_port" {}
variable "vm_count" {}
variable "nic_ids" {}
variable "nic_ip_names" {}
variable "force_recreate" {
  type = string
}
