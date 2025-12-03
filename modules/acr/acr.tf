/*
    Azure Container Registry Resource
    ---------------------------------
    - resource: `azurerm_container_registry.acr`
    - purpose: Creates an Azure Container Registry used for storing and
      managing container images for deployment across Azure services.

    Configuration:
        - name: The name of the Azure Container Registry instance, supplied
          via the `acr_name` variable. Must be globally unique.
        - resource_group_name: The Azure Resource Group in which the registry
          will be provisioned.
        - location: Azure region where the ACR will be created.
        - sku: Defines the ACR service tier. Using "Basic" provides a cost-effective
          registry suitable for development and small-scale workloads.
        - admin_enabled: Enables the admin account, allowing username/password
          authentication. Useful for testing or CI/CD pipelines, but should be
          disabled in production environments for stronger security.

    Usage:
        - Supports storing Docker images for Azure Container Instances,
          App Services, and VM-based deployments.
        - Integrates with build pipelines to push and pull container images.
*/
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}
