version: '3.8'

services:
  traefik:
    image: traefik:v3.6.1
    command:
      - "--ping=true"
      - "--providers.swarm=true"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.ping.address=:8082"
      - "--ping.entrypoint=ping"
    ports:
      - "80:80"
      - "8082:8082"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
    networks:
      - default
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:8082/ping"]
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
    networks:
      - default
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://0.0.0.0:3000/app/api/health"]
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
        - "traefik.http.routers.svelte.entrypoints=web"
        - "traefik.http.routers.svelte.rule=PathPrefix(`/app`)"
        - "traefik.http.services.svelte.loadbalancer.server.port=3000"
        - "traefik.http.routers.root.entrypoints=web"
        - "traefik.http.routers.root.rule=Path(`/`)"
        - "traefik.http.routers.root.middlewares=redirect-to-app"
        - "traefik.http.middlewares.redirect-to-app.redirectregex.regex=^/$$"
        - "traefik.http.middlewares.redirect-to-app.redirectregex.replacement=/app"
        - "traefik.http.middlewares.redirect-to-app.redirectregex.permanent=true"

  dotnet_backend:
    image: ${acr_name}.azurecr.io/dotnet-backend:latest
    networks:
      - default
    environment:
      - ASPNETCORE_URLS=http://+:5000
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
        - "traefik.http.routers.backend.entrypoints=web"
        - "traefik.http.routers.backend.rule=PathPrefix(`/api`)"
        - "traefik.http.services.backend.loadbalancer.server.port=5000"
        - "traefik.http.services.backend.loadbalancer.server.scheme=http"


  unity_webgl:
    image: ${acr_name}.azurecr.io/unity-webgl:latest
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
        - "traefik.http.routers.unity.entrypoints=web"
        - "traefik.http.routers.unity.rule=PathPrefix(`/play`)"
        - "traefik.http.services.unity.loadbalancer.server.port=8080"

networks:
  default:
    driver: overlay
    attachable: true