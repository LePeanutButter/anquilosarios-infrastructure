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
  - [/usr/local/bin/setup.sh]
