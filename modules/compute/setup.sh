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

#-----------------------------------------------------------------------------
# Configuration
#-----------------------------------------------------------------------------
ADMIN_USER="${ADMIN_USERNAME:-azureuser}"
APP_DIR="/opt/app"

#-----------------------------------------------------------------------------
# System update and prerequisites
#-----------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

#-----------------------------------------------------------------------------
# Docker installation (if not already present)
#-----------------------------------------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmour -o /usr/share/keyrings/docker-archive-keyring.gpg || true
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io
fi

#-----------------------------------------------------------------------------
# Docker Compose plugin installation
#-----------------------------------------------------------------------------
if [ ! -x /usr/libexec/docker/cli-plugins/docker-compose ]; then
    mkdir -p /usr/libexec/docker/cli-plugins
    curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" -o /usr/libexec/docker/cli-plugins/docker-compose
    chmod +x /usr/libexec/docker/cli-plugins/docker-compose
    ln -sf /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose || true
fi

#-----------------------------------------------------------------------------
# Application directory and docker-compose file setup
#-----------------------------------------------------------------------------
mkdir -p "${APP_DIR}"
if docker compose version >/dev/null 2>&1; then
    docker compose up -d || true
else
    docker-compose up -d || true
fi

#-----------------------------------------------------------------------------
# Ensure Docker service is running
#-----------------------------------------------------------------------------
systemctl enable docker
systemctl start docker

#-----------------------------------------------------------------------------
# Grant Docker access to admin user
#-----------------------------------------------------------------------------
if id -u "${ADMIN_USER}" >/dev/null 2>&1; then
    usermod -aG docker "${ADMIN_USER}" || true
fi

#-----------------------------------------------------------------------------
# Start containers using Docker Compose
#-----------------------------------------------------------------------------
cd "${APP_DIR}"
# Prefer new 'docker compose' plugin; fallback to docker-compose if necessary
if docker compose version >/dev/null 2>&1; then
    docker compose up -d || true
else
    docker-compose up -d || true
fi
