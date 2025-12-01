# ===========================================
# Docker Swarm Template: Multi-Service Deployment
#
# Environment:
# - Uses ${acr_name} to pull images from Azure Container Registry (ACR)
#
# Description:
# - Deploys three application services:
#     • Svelte Frontend
#     • .NET Backend API
#     • Unity WebGL
# - Traefik provides reverse proxying and routing
# - All services are routed internally without host-port exposure
# - Load balancing handled by Docker Swarm + Traefik
# - Restart behavior managed through Swarm restart policies
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
  # - Routes incoming traffic to application services
  # - Operates in Docker Swarm mode
  # - Must run on a Swarm manager node
  #
  # Note:
  # - Only port 80 is exposed because HTTPS/ACME features
  #   are not configured in this minimal template
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
  # - Accessible via Traefik at: /app
  #
  # Notes:
  # - No host ports are mapped; all traffic comes through Traefik
  # =========================================
  svelte_frontend:
    image: ${acr_name}.azurecr.io/svelte-frontend:latest
    ports: []
    networks:
      - default
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
  # - Provides API endpoints used by frontend and WebGL content
  #
  # Routing:
  # - Accessible via /api
  #
  # Notes:
  # - Routed entirely through Traefik
  # =========================================
  dotnet_backend:
    image: ${acr_name}.azurecr.io/dotnet-backend:latest
    ports: []
    networks:
      - default
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
  # - Hosts Unity WebGL builds for interactive content
  #
  # Routing:
  # - Accessible via /play
  #
  # Notes:
  # - Traefik handles routing and load balancing
  # =========================================
  unity_webgl:
    image: ${acr_name}.azurecr.io/unity-webgl:latest
    ports: []
    networks:
      - default
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