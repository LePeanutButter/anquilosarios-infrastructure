# ===========================================
# Cloud-Init Configuration Template: cloud-config.tpl
#
# Environment:
# - Used for initializing a cloud VM/instance at first boot
#
# Description:
# - Writes required configuration files for Docker Swarm deployment
# - Ensures proper file permissions and ownership
# - Executes a setup script on first boot to deploy application services
# ===========================================

# -------------------------------------------
# File Creation Section
# -------------------------------------------
write_files:
  # =========================================
  # File: Docker Swarm Stack YAML
  # Path: /opt/app/stack.yml
  # Purpose: Store the docker swarm stack configuration
  # Permissions: 0644 (read/write owner, read others)
  # Owner: root:root
  # Content: Populated from template variable ${stack_yaml}
  # =========================================
  - path: /opt/app/stack.yml
    permissions: '0644'
    owner: root:root
    content: |
      ${stack_yaml}

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
  # Initial Setup Execution
  # Purpose: Executes the setup script that handles environment initialization
  # Notes: runcmd executes during the first boot phase of cloud-init
  # =========================================
  - /usr/local/bin/setup.sh
