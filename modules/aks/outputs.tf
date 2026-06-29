output "cluster_name" { value = azurerm_kubernetes_cluster.this.name }
output "kube_config" { value = azurerm_kubernetes_cluster.this.kube_config_raw }
output "oidc_issuer_url" { value = azurerm_kubernetes_cluster.this.oidc_issuer_url }
