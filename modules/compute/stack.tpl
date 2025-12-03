version: '3.8'

services:
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

networks:
  default:
    driver: overlay