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

ADMIN_USER="${ADMIN_USERNAME:-azureuser}"
APP_DIR="/opt/app"

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

# Deploy stack
docker stack rm appstack || true
sleep 5
docker stack deploy -c stack.yml appstack