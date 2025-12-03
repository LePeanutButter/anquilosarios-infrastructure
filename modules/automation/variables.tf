variable "resource_group_name" {}
variable "location" {}
variable "lb_id" {}
variable "probe_name" {}
variable "backend_pool_name" {}
variable "force_recreate" {
  type    = bool
  default = false
}
