# Create Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "aks" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days
  tags                = var.tags
}

# Create Azure Monitor Action Group
resource "azurerm_monitor_action_group" "aks" {
  name                = "aks-critical-alerts"
  resource_group_name = azurerm_resource_group.aks_rg.name
  short_name          = "aksalerts"

  email_receiver {
    name                    = "admin"
    email_address           = "admin@example.com"
    use_common_alert_schema = true
  }
}

# Create Alert for Node CPU Usage
resource "azurerm_monitor_metric_alert" "node_cpu" {
  name                = "aks-high-cpu-usage"
  resource_group_name = azurerm_resource_group.aks_rg.name
  scopes              = [azurerm_kubernetes_cluster.aks.id]
  description         = "Alert when node CPU usage exceeds 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.aks.id
  }
}

# Create Alert for Node Memory Usage
resource "azurerm_monitor_metric_alert" "node_memory" {
  name                = "aks-high-memory-usage"
  resource_group_name = azurerm_resource_group.aks_rg.name
  scopes              = [azurerm_kubernetes_cluster.aks.id]
  description         = "Alert when node memory usage exceeds 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_memory_working_set_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.aks.id
  }
}

# Create Alert for Pod Status
resource "azurerm_monitor_metric_alert" "pod_failed" {
  name                = "aks-pod-failures"
  resource_group_name = azurerm_resource_group.aks_rg.name
  scopes              = [azurerm_kubernetes_cluster.aks.id]
  description         = "Alert when pods fail"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.aks.id
  }
}

# Setup diagnostic settings for AKS
resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "aks-diagnostics"
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id

  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_log {
    category = "kube-audit"
  }

  enabled_log {
    category = "cluster-autoscaler"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
