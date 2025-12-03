# ===========================================
# Docker Swarm Template: Multi-Service Deployment
# Environment: Uses ${acr_name} to pull images from Azure Container Registry (ACR)
# Description:
# - Deploys three application services:
#     - Svelte Frontend
#     - .NET Backend API
#     - Unity WebGL
# - Traefik provides reverse proxying, routing, and load balancing
# - All services are routed internally without exposing host ports
# - Each service has a Docker Swarm healthcheck to monitor availability
# - Restart behavior is managed through Swarm restart policies
# ===========================================

version: '3.8'

# -------------------------------------------
# Services Definition
# -------------------------------------------
services:
  # =========================================
  # Traefik Reverse Proxy & Load Balancer
  #
  # Responsibilities:
  # - Routes incoming traffic to all application services
  # - Operates in Docker Swarm mode
  # - Must run on a Swarm manager node
  #
  # Notes:
  # - Exposes port 80 for minimal HTTP access
  # - Healthcheck ensures Traefik responds to /ping requests
  # =========================================
  traefik:
    image: traefik:v3.1
    command:
      - "--providers.docker.swarmMode=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
    ports:
      - "80:80"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
    networks:
      - default
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:80/ping"] 
      interval: 10s
      timeout: 3s
      retries: 3
      start_period: 10s
    deploy:
      placement:
        constraints:
          - node.role == manager
      restart_policy:
        condition: on-failure

  # =========================================
  # Svelte Frontend
  #
  # Purpose:
  # - Serves the main application UI
  #
  # Routing:
  # - Accessible through Traefik at /app
  #
  # Notes:
  # - All traffic is routed via Traefik; no direct host ports
  # - Healthcheck ensures service availability on port 80
  # =========================================
  svelte_frontend:
    image: ${acr_name}.azurecr.io/svelte-frontend:latest
    ports: []
    networks:
      - default
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:80"]
      interval: 10s
      timeout: 3s
      retries: 3
      start_period: 5s
    deploy:
      replicas: 2
      restart_policy:
        condition: on-failure
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.svelte.rule=PathPrefix(`/app`)"
      - "traefik.http.services.svelte.loadbalancer.server.port=80"
  
  # =========================================
  # .NET Backend API
  #
  # Purpose:
  # - Provides API endpoints for frontend and Unity WebGL
  #
  # Routing:
  # - Accessible through Traefik at /api
  #
  # Notes:
  # - Healthcheck ensures API responds on port 5000 at /health
  # =========================================
  dotnet_backend:
    image: ${acr_name}.azurecr.io/dotnet-backend:latest
    ports: []
    networks:
      - default
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__MongoDB=${CONNECTIONSTRINGS__MONGODB}
      - MongoDB__DatabaseName=${MONGODB__DATABASENAME}
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:5000/health"]
      interval: 10s
      timeout: 3s
      retries: 3
      start_period: 5s
    deploy:
      replicas: 2
      restart_policy:
        condition: on-failure
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.backend.rule=PathPrefix(`/api`)"
      - "traefik.http.services.backend.loadbalancer.server.port=5000"

  # =========================================
  # Unity WebGL Service
  #
  # Purpose:
  # - Hosts interactive Unity WebGL builds
  #
  # Routing:
  # - Accessible through Traefik at /play
  #
  # Notes:
  # - Healthcheck ensures content is available on port 8080
  # =========================================
  unity_webgl:
    image: ${acr_name}.azurecr.io/unity-webgl:latest
    ports: []
    networks:
      - default
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:8080"]
      interval: 10s
      timeout: 3s
      retries: 3
      start_period: 10s
    deploy:
      replicas: 2
      restart_policy:
        condition: on-failure
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.unity.rule=PathPrefix(`/play`)"
      - "traefik.http.services.unity.loadbalancer.server.port=8080"

# -------------------------------------------
# Networks
# -------------------------------------------
networks:
  default:
    driver: overlay