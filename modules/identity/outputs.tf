output "aks_identity_id" { value = azurerm_user_assigned_identity.aks.id }
output "aks_kubelet_identity_id" { value = azurerm_user_assigned_identity.aks.principal_id }
output "aks_workload_identity_client_id" { value = azurerm_user_assigned_identity.workload.client_id }
output "aks_workload_identity_id" { value = azurerm_user_assigned_identity.workload.id }
output "aks_workload_identity_principal_id" { value = azurerm_user_assigned_identity.workload.principal_id }
