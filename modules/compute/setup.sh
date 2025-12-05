#!/bin/bash
#===============================================================================
# Script Name   : setup.sh
# Description   : Provision an Ubuntu server with Docker and Docker Compose,
#               : configure an application directory, and launch containers
#               : for a Svelte frontend, .NET backend, and Unity WebGL service.
# Author        : LePeanutButter, Lanapequin, shiro
# Created       : 2025-11-20
# License       : MIT License
#===============================================================================

set -euo pipefail

APP_DIR="/opt/app"
ACR_NAME="${ACR_NAME:-anquiloacr}"
ADMIN_USER="${ADMIN_USERNAME:-azureuser}"
ARM_CLIENT_ID="${ARM_CLIENT_ID:-}"
ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET:-}"
ARM_TENANT_ID="${ARM_TENANT_ID:-}"
ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID:-}"

export DEBIAN_FRONTEND=noninteractive

# Basic packages
apt-get update -y
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# Add Docker official GPG key and repository (idempotent)
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
fi

ARCH="$(dpkg --print-architecture)"
CODENAME="$(lsb_release -cs)"
DOCKER_REPO="deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable"

if ! grep -Fxq "$DOCKER_REPO" /etc/apt/sources.list.d/docker.list 2>/dev/null; then
    echo "$DOCKER_REPO" | tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

apt-get update -y

# Install the exact Docker CE and CLI versions requested, plus supporting packages
apt-get install -y \
  docker-ce=5:28.5.2-1~ubuntu.22.04~jammy \
  docker-ce-cli=5:28.5.2-1~ubuntu.22.04~jammy \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# Hold packages to avoid automatic upgrades that could change API behavior
apt-mark hold docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || true

# Ensure Docker CLI plugin directory exists (some distros use /usr/libexec or /usr/local/lib)
DOCKER_CLI_PLUGINS_DIR="/usr/libexec/docker/cli-plugins"
if [ ! -d "$DOCKER_CLI_PLUGINS_DIR" ]; then
    DOCKER_CLI_PLUGINS_DIR="/usr/local/lib/docker/cli-plugins"
    mkdir -p "$DOCKER_CLI_PLUGINS_DIR"
fi

# Install docker-compose v2 plugin binary if missing (idempotent)
COMPOSE_BIN="$DOCKER_CLI_PLUGINS_DIR/docker-compose"
if [ ! -x "$COMPOSE_BIN" ]; then
    curl -fsSL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(dpkg --print-architecture)" \
        -o "$COMPOSE_BIN"
    chmod +x "$COMPOSE_BIN"
fi

# Azure CLI Repository
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmour > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list

# Install Azure CLI
sudo apt-get update -y
sudo apt-get install -y azure-cli

# Ensure Docker is running
systemctl enable docker
systemctl start docker

# Give admin user Docker permissions
if id -u "${ADMIN_USER}" >/dev/null 2>&1; then
    usermod -aG docker "${ADMIN_USER}" || true
fi

# Prepare app directory
mkdir -p "${APP_DIR}"
cd "${APP_DIR}"

# Initialize Swarm (idempotent)
if ! docker node ls >/dev/null 2>&1; then
    docker swarm init --advertise-addr "$(hostname -I | awk '{print $1}')"
fi

# Login to Azure using Service Principal
az login --service-principal --username "$ARM_CLIENT_ID" --password "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID" >/dev/null

# Set the subscription
az account set --subscription "$ARM_SUBSCRIPTION_ID"

# Login to Azure Container Registry
az acr login --name "$ACR_NAME"

# Pull images
if az acr repository show-tags --name "$ACR_NAME" --repository dotnet-backend --query "[?@=='latest']" -o tsv | grep -q latest; then
    docker pull $ACR_NAME.azurecr.io/dotnet-backend:latest
fi

if az acr repository show-tags --name "$ACR_NAME" --repository svelte-frontend --query "[?@=='latest']" -o tsv | grep -q latest; then
    docker pull $ACR_NAME.azurecr.io/svelte-frontend:latest
fi

if az acr repository show-tags --name "$ACR_NAME" --repository unity-webgl --query "[?@=='latest']" -o tsv | grep -q latest; then
    docker pull $ACR_NAME.azurecr.io/unity-webgl:latest
fi

CERT_DIR="./certs"
KEY_FILE="${CERT_DIR}/dummy.key"
CERT_FILE="${CERT_DIR}/dummy.pem"

mkdir -p "$CERT_DIR"

if [ ! -f "$KEY_FILE" ] || [ ! -f "$CERT_FILE" ]; then
    if ! command -v openssl &> /dev/null
    then
        if ! sudo apt-get install -y openssl; then
            exit 1
        fi
    fi
    
    openssl genrsa -out "$KEY_FILE" 2048
    
    openssl req -new -x509 -key "$KEY_FILE" -out "$CERT_FILE" -days 365 -subj "/CN=localhost"
fi

TLS_FILE="./traefik/tls.yml"

mkdir -p "$(dirname "$TLS_FILE")"

cat > "$TLS_FILE" <<EOF
tls:
  stores:
    default:
      defaultCertificate:
        certFile: /certs/dummy.pem
        keyFile: /certs/dummy.key
EOF

# Deploy stack
docker stack rm appstack || true
sleep 5
docker stack deploy -c stack.yml appstack

cat <<EOF >/opt/app/env.sh
export ACR_NAME="${ACR_NAME:-anquiloacr}"
export ARM_CLIENT_ID="${ARM_CLIENT_ID:-}"
export ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET:-}"
export ARM_TENANT_ID="${ARM_TENANT_ID:-}"
export ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID:-}"
EOF

# Restrict access: only root can read/write
chmod 600 /opt/app/env.sh
chown root:root /opt/app/env.sh

# Refresh script with the same environment variables
cat <<'EOF' >/opt/app/refresh.sh
#!/bin/bash
set -euo pipefail
source /opt/app/env.sh

# Login to Azure using Service Principal
az login --service-principal --username "$ARM_CLIENT_ID" --password "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID" >/dev/null

# Set the subscription
az account set --subscription "$ARM_SUBSCRIPTION_ID"

# Login to Azure Container Registry
az acr login --name "$ACR_NAME"

# Pull latest images
if az acr repository show-tags --name "$ACR_NAME" --repository dotnet-backend --query "[?@=='latest']" -o tsv | grep -q latest; then
    docker pull $ACR_NAME.azurecr.io/dotnet-backend:latest
    docker service update --force appstack_dotnet-backend
fi

if az acr repository show-tags --name "$ACR_NAME" --repository svelte-frontend --query "[?@=='latest']" -o tsv | grep -q latest; then
    docker pull $ACR_NAME.azurecr.io/svelte-frontend:latest
    docker service update --force appstack_svelte-frontend
fi

if az acr repository show-tags --name "$ACR_NAME" --repository unity-webgl --query "[?@=='latest']" -o tsv | grep -q latest; then
    docker pull $ACR_NAME.azurecr.io/unity-webgl:latest
    docker service update --force appstack_unity-webgl
fi
EOF

chmod +x /opt/app/refresh.sh

# Add cron job
CRON_LINE="*/2 * * * * /opt/app/refresh.sh >> /var/log/app_refresh.log 2>&1"

# Only add if not already present
sudo crontab -u azureuser -l 2>/dev/null | grep -F "$CRON_LINE" >/dev/null || \
    ( sudo crontab -u azureuser -l 2>/dev/null; echo "$CRON_LINE" ) | sudo crontab -u azureuser -