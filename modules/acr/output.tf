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