variable "vm_count" {}
variable "vm_size" {}
variable "admin_username" {}
variable "admin_public_key" {}
variable "resource_group_name" {}
variable "location" {}
variable "acr_name" {}
variable "subnet_id" {}
variable "CONNECTIONSTRINGS__MONGODB" {}
variable "MONGODB__DATABASENAME" {}
variable "ARM_CLIENT_ID" {}
variable "ARM_CLIENT_SECRET" {}
variable "ARM_TENANT_ID" {}
variable "ARM_SUBSCRIPTION_ID" {}
variable "force_recreate" {
  type    = bool
  default = false
}
