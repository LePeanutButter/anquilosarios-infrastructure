#cloud-config

write_files:
  - path: /opt/app/stack.yml
    permissions: '0644'
    owner: root:root
    content: |
      ${stack_yaml}

  - path: /usr/local/bin/setup.sh
    permissions: '0755'
    owner: root:root
    content: |
      ${setup_script}

runcmd:
  - |
    export ACR_NAME="${acr_name}"
    export ADMIN_USERNAME="${admin_username}"
    export ARM_CLIENT_ID="${ARM_CLIENT_ID}"
    export ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET}"
    export ARM_TENANT_ID="${ARM_TENANT_ID}"
    export ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}"
    /usr/local/bin/setup.sh
