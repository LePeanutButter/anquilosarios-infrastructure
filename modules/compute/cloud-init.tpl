# ===========================================
# Cloud-Init Configuration Template: cloud-config.tpl
# Environment: Cloud VM / Instance Initialization
# Description:
#   - Creates and writes files required for Docker deployment
#   - Sets permissions and ownership for configuration and setup scripts
#   - Executes setup script on first boot to deploy services
# ===========================================

# -------------------------------------------
# File Creation Section
# -------------------------------------------
write_files:
  # =========================================
  # File: Docker Compose YAML
  # Path: /opt/app/docker-compose.yml
  # Purpose: Store the docker-compose configuration
  # Permissions: 0644 (read/write owner, read others)
  # Owner: root:root
  # Content: Populated from template variable ${compose_yaml}
  # =========================================
  - path: /opt/app/docker-compose.yml
    permissions: '0644'
    owner: root:root
    content: |
      ${compose_yaml}

  # =========================================
  # File: Setup Script
  # Path: /usr/local/bin/setup.sh
  # Purpose: Script to set up and start services
  # Permissions: 0755 (executable)
  # Owner: root:root
  # Content: Populated from template variable ${setup_script}
  # =========================================
  - path: /usr/local/bin/setup.sh
    permissions: '0755'
    owner: root:root
    content: |
      ${setup_script}

# -------------------------------------------
# Commands to Run on First Boot
# -------------------------------------------
runcmd:
  # =========================================
  # Command: Execute Setup Script
  # Purpose: Run the setup script to deploy Docker services
  # Notes: Runs automatically during instance initialization
  # =========================================
  - /usr/local/bin/setup.sh
