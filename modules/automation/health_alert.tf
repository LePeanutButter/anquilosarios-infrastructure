/*
    Metric Alert for Load Balancer Probe Health
    -------------------------------------------
    - resource: azurerm_monitor_metric_alert.lb_health_alert
    - name: "lb-probe-unhealthy-alert"
    - scopes: Targets the Load Balancer resource ID (module.loadbalancer.lb_id)
    - description: Triggers a VM restart if the Load Balancer health probe reports failure
    - severity: 3 (Medium severity alert)
    - frequency: "PT1M" (Evaluates the metric every minute)
    - window_size: "PT5M" (Observes a 5-minute window to determine alert state)
    - Purpose: Monitors the "HealthProbeStatus" metric of the Load Balancer to detect
      unhealthy backend endpoints. If the probe fails, an alert action is triggered
      via an Action Group.
*/
resource "azurerm_monitor_metric_alert" "lb_health_alert" {
  name                = "lb-probe-unhealthy-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.lb_id]
  description         = "Triggers a VM restart if the Load Balancer probe fails."
  severity            = 3
  frequency           = "PT1M"
  window_size         = "PT5M"

  # Defines the logic for when the alert should be fired.
  criteria {
    metric_namespace = "Microsoft.Network/loadBalancers"
    metric_name      = "HealthProbeStatus"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1

    dimension {
      name     = "BackendPool"
      operator = "Include"
      values   = [var.backend_pool_name]
    }

    dimension {
      name     = "HealthProbe"
      operator = "Include"
      values   = [var.probe_name]
    }
  }

  # Sends notifications or triggers automated actions such as VM restart.
  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.force_recreate_sentinel
    ]
  }
}
