variable "acr_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "force_recreate" {
  type    = bool
  default = false
}
