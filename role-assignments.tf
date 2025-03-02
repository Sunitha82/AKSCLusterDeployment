data "azurerm_container_registry" "acr" {
  name                = "codebyteusecase5acr"
  resource_group_name = "codebyteusecase5"  # Replace with actual resource group
}

resource "azurerm_role_assignment" "aks_acr" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = data.azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
