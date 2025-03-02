output "resource_group_name" {
  value = azurerm_resource_group.aks_rg.name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.host
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.aks.id
}

output "virtual_network_name" {
  value = azurerm_virtual_network.aks_vnet.name
}

output "subnet_name" {
  value = azurerm_subnet.aks_subnet.name
}

output "admin_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.aks_rg.name} --name ${azurerm_kubernetes_cluster.aks.name} --admin"
}

output "user_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.aks_rg.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}
