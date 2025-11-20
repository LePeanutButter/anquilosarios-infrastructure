# Azure region where resources will be deployed.
variable "location" {
    type    = string
    default = "eastus"
}

# Name of the Resource Group to be created.
variable "resource_group_name" {
    type    = string
    default = "anquilosaurios-rg"
}

# Number of virtual machines to deploy.
variable "vm_count" {
    type    = number
    default = 2
}

# Azure VM size for each virtual machine.
variable "vm_size" {
    type    = string
    default = "Standard_B1s"
}

# Username for SSH authentication into the Linux VMs.
variable "admin_username" {
    type    = string
    default = "azureuser"
}

# SSH public key for admin access. Must be in standard "ssh-rsa AAAA..." format.
variable "admin_public_key" {
    type    = string
    description = "Your SSH public key (ssh-rsa AAAA...)"
    default = ""
}

# Port on which the load balancer will listen for incoming traffic.
variable "frontend_port" {
    type    = number
    default = 80
}

# Port on the backend virtual machines to which the load balancer will forward traffic.
variable "backend_port" {
    type    = number
    default = 80
}

# Name of the Azure Container Registry to be created.
variable "acr_name" {
    type    = string
    default = "anquiloacr001"
}