# ===========================================
# Docker Compose Template: Multi-Service Deployment
# Environment: Configurable via ACR name
# Description:
#   - Defines three services: Svelte frontend, .NET backend, Unity WebGL
#   - Uses images hosted in Azure Container Registry
#   - Maps container ports to host ports for local access
#   - Configured to automatically restart unless explicitly stopped
# ===========================================

version: '3.8' # Docker Compose file format version

# -------------------------------------------
# Services Definition
# -------------------------------------------
services:
  # =========================================
  # Service: Svelte Frontend
  # Purpose: Serve the frontend UI built with Svelte
  # Image: Pulls from Azure Container Registry
  # Ports: Host 80 > Container 80
  # Restart Policy: unless-stopped
  # =========================================
  svelte_frontend:
    image: ${acr_name}.azurecr.io/svelte-frontend:latest
    ports:
      - "80:80"
    restart: unless-stopped

  # =========================================
  # Service: .NET Backend
  # Purpose: Serve API endpoints for the application
  # Image: Pulls from Azure Container Registry
  # Ports: Host 5000 > Container 5000
  # Restart Policy: unless-stopped
  # =========================================
  dotnet_backend:
    image: ${acr_name}.azurecr.io/dotnet-backend:latest
    ports:
      - "5000:5000"
    restart: unless-stopped

  # =========================================
  # Service: Unity WebGL
  # Purpose: Serve Unity WebGL builds for interactive content
  # Image: Pulls from Azure Container Registry
  # Ports: Host 8080 > Container 8080
  # Restart Policy: unless-stopped
  # =========================================
  unity_webgl:
    image: ${acr_name}.azurecr.io/unity-webgl:latest
    ports:
      - "8080:8080"
    restart: unless-stopped
