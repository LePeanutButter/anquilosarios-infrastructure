/*
    Azure Load Balancer Configuration
    ---------------------------------
    - Provision a public IP, load balancer, backend pool, health probe, and load balancing rule.
    - Associate virtual machine NICs with the backend pool for proper traffic distribution.
    - Tags are applied for project and environment identification.
*/

/*
    Public IP for Load Balancer
    ----------------------------
    - resource: azurerm_public_ip.lb_pip
    - name: "anquilo-lb-pip"
    - location: Azure region where the public IP is provisioned (from var.location)
    - allocation_method: Static
    - sku: Standard
    - tags: Identifies project and environment
    - Purpose: Provides a public IP address that the load balancer frontend can use.
*/
resource "azurerm_public_ip" "lb_pip" {
  name                = "anquilo-lb-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    project = "anquilosaurios"
    env     = "production"
  }
}

/*
    Azure Load Balancer
    -------------------
    - resource: azurerm_lb.lb
    - name: "anquilo-lb"
    - location: var.location
    - sku: Basic
    - frontend_ip_configuration: References the public IP created above
    - tags: Identifies project and environment
    - Purpose: Distributes inbound traffic across backend VMs and monitors health.
*/
resource "azurerm_lb" "lb" {
  name                = "anquilo-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Basic"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }

  tags = {
    project = "anquilosaurios"
    env     = "production"
  }
}

/*
    Load Balancer Backend Address Pool
    ----------------------------------
    - resource: azurerm_lb_backend_address_pool.bpool
    - name: "anquilo-bpool"
    - loadbalancer_id: Associates with the Azure Load Balancer created above
    - depends_on: Ensures the load balancer is created first
    - Purpose: Holds the backend VMs that receive traffic from the load balancer.
*/
resource "azurerm_lb_backend_address_pool" "bpool" {
  name            = "anquilo-bpool"
  loadbalancer_id = azurerm_lb.lb.id

  depends_on = [azurerm_lb.lb]
}

/*
    Load Balancer Health Probe
    ---------------------------
    - resource: azurerm_lb_probe.tcp_probe
    - name: "tcp-probe"
    - protocol: Tcp
    - port: var.backend_port
    - interval_in_seconds: 5
    - number_of_probes: 2
    - depends_on: Ensures the load balancer exists before creating the probe
    - Purpose: Monitors the health of backend VMs to determine availability.
*/
resource "azurerm_lb_probe" "tcp_probe" {
  name                = "tcp-probe"
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Tcp"
  port                = var.backend_port
  interval_in_seconds = 5
  number_of_probes    = 2

  depends_on = [azurerm_lb.lb]
}

/*
    Load Balancer Rule
    -------------------
    - resource: azurerm_lb_rule.http_rule
    - name: "http-rule"
    - protocol: Tcp
    - frontend_port: var.frontend_port
    - backend_port: var.backend_port
    - frontend_ip_configuration_name: "LoadBalancerFrontEnd"
    - backend_address_pool_ids: References the backend pool
    - probe_id: Uses the health probe for monitoring VM availability
    - idle_timeout_in_minutes: 4
    - Purpose: Routes incoming traffic from the frontend IP to backend VMs.
*/
resource "azurerm_lb_rule" "http_rule" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = var.frontend_port
  backend_port                   = var.backend_port
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpool.id]
  probe_id                       = azurerm_lb_probe.tcp_probe.id
  idle_timeout_in_minutes        = 4
}

/*
    Network Interface Backend Pool Association
    -------------------------------------------
    - resource: azurerm_network_interface_backend_address_pool_association.nic_assoc
    - count: var.vm_count (associates multiple NICs)
    - network_interface_id: NICs to associate, from var.nic_ids
    - ip_configuration_name: "ipconfig1" (default NIC IP configuration)
    - backend_address_pool_id: References the LB backend pool
    - Purpose: Connects each VM’s NIC to the load balancer backend pool
        so they receive traffic according to the LB rule.
*/
resource "azurerm_network_interface_backend_address_pool_association" "nic_assoc" {
  count                   = var.vm_count
  network_interface_id    = var.nic_ids[count.index]
  ip_configuration_name   = var.nic_ip_names[count.index]
  backend_address_pool_id = azurerm_lb_backend_address_pool.bpool.id
}
