version: '3.8'

services:
  traefik:
    image: traefik:v3.6.1
    command:
      - "--ping=true"
      - "--providers.swarm=true"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--entrypoints.websecure.http.tls=true"
      - "--entrypoints.ping.address=:8082"
      - "--ping.entrypoint=ping"
      - "--providers.file.filename=/etc/traefik/tls.yml"
    ports:
      - "80:80"
      - "443:443"
      - "8082:8082"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - "/opt/app/certs:/certs"
      - "/opt/app/traefik/tls.yml:/etc/traefik/tls.yml:ro"
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
      labels:
        - "traefik.http.middlewares.https-redirect.redirectscheme.scheme=https"
        - "traefik.http.middlewares.https-redirect.redirectscheme.permanent=true"
        - "traefik.http.routers.http-catchall.entrypoints=web"
        - "traefik.http.routers.http-catchall.rule=HostRegexp(`{host:.+}`)"
        - "traefik.http.routers.http-catchall.middlewares=https-redirect"
        - "traefik.http.routers.http-catchall.priority=1"

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
        - "traefik.http.routers.svelte.entrypoints=websecure"
        - "traefik.http.routers.svelte.rule=PathPrefix(`/app`)"
        - "traefik.http.services.svelte.loadbalancer.server.port=3000"
        - "traefik.http.services.svelte.loadbalancer.server.scheme=http"
        - "traefik.http.routers.svelte.priority=2"
        - "traefik.http.routers.frontend-root.entrypoints=websecure"
        - "traefik.http.routers.frontend-root.rule=Path(`/`)"
        - "traefik.http.routers.frontend-root.middlewares=redirect-to-app"
        - "traefik.http.routers.frontend-root.priority=1"
        - "traefik.http.middlewares.redirect-to-app.redirectregex.regex=^/$"
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
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:5000/api/health"]
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
        - "traefik.http.routers.unity.priority=3"
        - "traefik.http.routers.backend.entrypoints=websecure" 
        - "traefik.http.routers.backend.rule=PathPrefix(`/api`)"
        - "traefik.http.services.backend.loadbalancer.server.port=5000"
        - "traefik.http.services.backend.loadbalancer.server.scheme=http"

  unity_webgl:
    image: ${acr_name}.azurecr.io/unity-webgl:latest
    networks:
      - default
    environment:
      - PORT=8080
      - NODE_ENV=production
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/play/health"]
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
        - "traefik.http.routers.unity.entrypoints=websecure" 
        - "traefik.http.routers.unity.rule=PathPrefix(`/play`)"
        - "traefik.http.routers.unity.priority=5"
        - "traefik.http.services.unity.loadbalancer.server.port=8080"
        - "traefik.http.services.unity.loadbalancer.server.scheme=http"

networks:
  default:
    driver: overlay
    attachable: true