# Resource Group
resource_group_name = "aks-terraform-rg-codebyte"
location            = "eastus2"

# AKS Cluster
cluster_name       = "aksterraformclusterusercase5"
dns_prefix         = "aks-terraform"
kubernetes_version = "1.29.0"

# Default Node Pool
default_node_count     = 2
default_node_vm_size   = "Standard_D2s_v3"
default_node_min_count = 1
default_node_max_count = 5
os_disk_size_gb        = 100

# App Node Pool
app_node_count     = 1
app_node_vm_size   = "Standard_D4s_v3"
app_node_min_count = 1
app_node_max_count = 10

# Networking
vnet_name             = "aks-vnet"
vnet_address_space    = ["10.0.0.0/16"]
subnet_name           = "aks-subnet"
subnet_address_prefix = "10.0.1.0/24"
dns_service_ip        = "10.0.0.10"
service_cidr          = "10.0.0.0/24"
docker_bridge_cidr    = "172.17.0.1/16"

# Monitoring
log_analytics_workspace_name = "aks-workspace"
log_analytics_retention_days = 30

# AAD Integration
# Replace with your AAD group object ID for AKS administrators
aks_admin_group_object_id = "44373425-0ec6-4934-ba87-9087aa15747a"

# Environment
environment = "production"

# Tags
tags = {
  Environment = "Production"
  ManagedBy   = "Terraform"
  Project     = "AKS-Automation"
}















