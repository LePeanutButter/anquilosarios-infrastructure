/*
  Terraform Configuration Block
  -----------------------------
  - Defines required providers and Terraform version constraints.
  - Ensures consistent behavior across environments and prevents
    incompatible Terraform or provider versions from being used.
*/
terraform {
  required_providers {
    /*
      AzureRM Provider
      ----------------
      - source: Specifies the official HashiCorp AzureRM provider.
      - version: Uses a version constraint (~> 3.0) to allow newer
      compatible minor versions while preventing breaking changes.
    */
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Require Terraform CLI version 1.14.0 or newer.
  required_version = ">= 1.14.0"
}

/*
  Azure Resource Manager (AzureRM) Provider Configuration
  -------------------------------------------------------
  The 'features' block is required, even if empty. It enables
  provider-specific features and ensures compatibility with the AzureRM provider.
*/
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

/*
  Terraform Modules
  -----------------
  - Modules encapsulate reusable infrastructure components.
  - Promote modularity, maintainability, and consistency across environments.
  - Inputs (variables) and outputs allow parameterization and inter-module communication.
*/

/*
  Network Module
  ----------------
  - source: Path to the local network module.
  - Inputs:
      - resource_group_name: The resource group in which network resources are created.
      - location: Azure region where network resources will be deployed.
  - Purpose: Creates networking resources such as virtual networks and subnets
      required for the virtual machines and other resources.
*/
module "network" {
  source = "./modules/network"

  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = module.network.vnet_name
  force_recreate      = var.force_recreate
}

/*
  Compute Module
  ----------------
  - source: Path to the local compute module.
  - Inputs:
      - vm_count: Number of virtual machines to create.
      - vm_size: Azure VM size/type (e.g., Standard_B2s).
      - admin_username: Username for the VM administrator account.
      - admin_public_key: SSH public key for VM authentication.
      - resource_group_name: Resource group where VMs will be created.
      - location: Azure region for VM deployment.
  - Purpose: Provisions Linux virtual machines with the specified configuration.
*/
module "compute" {
  source                     = "./modules/compute"
  vm_count                   = var.vm_count
  vm_size                    = var.vm_size
  admin_username             = var.admin_username
  admin_public_key           = var.admin_public_key
  resource_group_name        = var.resource_group_name
  location                   = var.location
  acr_name                   = var.acr_name
  subnet_id                  = module.network.subnet_id
  nsg_id                     = module.network.nsg_id
  force_recreate             = var.force_recreate
  CONNECTIONSTRINGS__MONGODB = var.CONNECTIONSTRINGS__MONGODB
  MONGODB__DATABASENAME      = var.MONGODB__DATABASENAME
  ARM_CLIENT_ID              = var.ARM_CLIENT_ID
  ARM_CLIENT_SECRET          = var.ARM_CLIENT_SECRET
  ARM_TENANT_ID              = var.ARM_TENANT_ID
  ARM_SUBSCRIPTION_ID        = var.ARM_SUBSCRIPTION_ID
}

/*
  Load Balancer Module
  --------------------
  - source: Path to the local load balancer module.
  - Inputs:
      - resource_group_name: The resource group where the LB and related resources will be created.
      - location: Azure region for the load balancer.
      - frontend_port: Port exposed on the load balancer.
      - backend_port: Port used by backend VMs.
      - vm_count: Number of backend VMs/NICs to associate with the LB.
  - Purpose: Creates an Azure Load Balancer with a public IP, backend pool,
      probe, and load balancer rule. Associates NICs from the compute module
      with the backend pool.
*/
module "loadbalancer" {
  source = "./modules/loadbalancer"

  resource_group_name = var.resource_group_name
  location            = var.location
  frontend_port       = var.frontend_port
  backend_port        = var.backend_port
  vm_count            = var.vm_count
  nic_ids             = module.compute.nic_ids
  nic_ip_names        = module.compute.nic_ip_names
  force_recreate      = var.force_recreate
}

/*
  Azure Container Registry (ACR) Module
  -------------------------------------
  - source: Path to the local Azure Container Registry module.

  Inputs:
      - acr_name: Name of the Azure Container Registry instance to create.
      - resource_group_name: The resource group in which the ACR will be deployed.
      - location: Azure region where the ACR will reside.

  Purpose:
      - Deploys an Azure Container Registry for storing and managing Docker
          container images used by applications or CI/CD pipelines.
      - Supports seamless integration with Azure Container Instances (ACI), and VM-based deployments.
      - Provides secure and centralized image storage, enabling consistent
          container delivery across environments.
*/
module "acr" {
  source              = "./modules/acr"
  acr_name            = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  force_recreate      = var.force_recreate
}

/*
  Automation Module
  -----------------
  - source: Path to the local automation module.
  
  Inputs:
      - resource_group_name: The Azure Resource Group where automation
          resources will be created.
      - location: Azure region for the automation account deployment.

  Purpose:
      - Deploys an Azure Automation Account configured to manage VM
          operations, specifically automated VM reboots.
      - Sets up runbooks, schedules, or scripts to perform periodic or
          on-demand reboots of virtual machines provisioned via the
          compute module.
      - Ensures VMs are maintained in a desired operational state
          without manual intervention, improving reliability and
          uptime.
*/
module "automation" {
  source              = "./modules/automation"
  resource_group_name = var.resource_group_name
  location            = var.location
  lb_id               = module.loadbalancer.lb_id
  probe_name          = module.loadbalancer.probe_name
  backend_pool_name   = module.loadbalancer.backend_pool_name
  force_recreate      = var.force_recreate
}
