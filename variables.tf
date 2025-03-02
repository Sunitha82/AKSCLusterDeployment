variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "aks-terraform-rg"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus2"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aksterraformclusterusercase5"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "aks-terraform"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29.0"
}

variable "default_node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "default_node_vm_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "default_node_min_count" {
  description = "Minimum number of nodes for auto-scaling the default node pool"
  type        = number
  default     = 1
}

variable "default_node_max_count" {
  description = "Maximum number of nodes for auto-scaling the default node pool"
  type        = number
  default     = 5
}

variable "app_node_count" {
  description = "Number of nodes in the application node pool"
  type        = number
  default     = 3
}

variable "app_node_vm_size" {
  description = "VM size for the application node pool"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "app_node_min_count" {
  description = "Minimum number of nodes for auto-scaling the application node pool"
  type        = number
  default     = 1
}

variable "app_node_max_count" {
  description = "Maximum number of nodes for auto-scaling the application node pool"
  type        = number
  default     = 10
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB for AKS cluster nodes"
  type        = number
  default     = 100
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
  default     = "aks-vnet"
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Name of the Subnet"
  type        = string
  default     = "aks-subnet"
}

variable "subnet_address_prefix" {
  description = "Address prefix for the Subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "dns_service_ip" {
  description = "DNS service IP address"
  type        = string
  default     = "10.0.0.10"
}

variable "service_cidr" {
  description = "CIDR notation IP range from which to assign service cluster IPs"
  type        = string
  default     = "10.0.0.0/24"
}

variable "docker_bridge_cidr" {
  description = "CIDR notation IP range for Docker bridge network"
  type        = string
  default     = "172.17.0.1/16"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
  default     = "aks-workspace"
}

variable "log_analytics_retention_days" {
  description = "Retention days for Log Analytics Workspace"
  type        = number
  default     = 30
}

variable "aks_admin_group_object_id" {
  description = "Object ID of the Azure AD group for AKS administrators"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment for the AKS cluster"
  type        = string
  default     = "production"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
