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
apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

# Install Docker
if ! command -v docker >/dev/null 2>&1; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | gpg --dearmour -o /usr/share/keyrings/docker-archive-keyring.gpg || true

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
      > /etc/apt/sources.list.d/docker.list

    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io
fi

# Install Docker Compose v2 plugin
if [ ! -x /usr/libexec/docker/cli-plugins/docker-compose ]; then
    mkdir -p /usr/libexec/docker/cli-plugins
    curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" \
        -o /usr/libexec/docker/cli-plugins/docker-compose
    chmod +x /usr/libexec/docker/cli-plugins/docker-compose
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

# Deploy stack
docker stack rm appstack || true
sleep 5
docker stack deploy -c stack.yml appstack