output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "kube_config" {
  value     = module.aks.kube_config
  sensitive = true
}

output "cosmos_db_endpoint" {
  value = module.cosmosdb.endpoint
}

output "key_vault_uri" {
  value = module.keyvault.vault_uri
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "resource_group_name" {
  value = module.resource_group.name
}
