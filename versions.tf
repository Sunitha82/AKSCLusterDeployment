terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75.0"  # Use a specific version compatible with your environment
    }
  }
  required_version = ">= 1.00.0"  # Lowering the required Terraform version
}
