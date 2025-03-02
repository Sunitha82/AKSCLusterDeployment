provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true  # Keep this if you still need it
}

# Create Resource Group
resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Create AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  # Default node pool configuration
  default_node_pool {
    name       = "default"
    #node_count = var.default_node_count
    vm_size    = var.default_node_vm_size
    os_disk_size_gb = var.os_disk_size_gb
    vnet_subnet_id  = azurerm_subnet.aks_subnet.id
    tags            = var.tags

    # Auto-scaling settings
    enable_auto_scaling = true
    min_count           = var.default_node_min_count
    max_count           = var.default_node_max_count
  }

  # Use Managed Identity for the AKS cluster
  identity {
    type = "SystemAssigned"
  }

  # Basic RBAC without AAD integration
  role_based_access_control_enabled = true

  # Network Configuration
  network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    dns_service_ip     = var.dns_service_ip
    service_cidr       = var.service_cidr
    docker_bridge_cidr = var.docker_bridge_cidr
    load_balancer_sku  = "standard"
  }

  # Simplified configuration without add-ons to ensure compatibility

  tags = var.tags

  depends_on = [
    azurerm_virtual_network.aks_vnet,
    azurerm_subnet.aks_subnet,
    azurerm_log_analytics_workspace.aks
  ]
}

# Create a user-assigned node pool for applications
resource "azurerm_kubernetes_cluster_node_pool" "app_node_pool" {
  name                  = "appnodepool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.app_node_vm_size
  node_count            = var.app_node_count
  os_disk_size_gb       = var.os_disk_size_gb
  vnet_subnet_id        = azurerm_subnet.aks_subnet.id

  # Auto-scaling settings
  enable_auto_scaling   = true
  min_count             = var.app_node_min_count
  max_count             = var.app_node_max_count

  node_labels           = {
    "nodepool-type" = "app"
    "environment"   = var.environment
  }
  tags = var.tags
}
