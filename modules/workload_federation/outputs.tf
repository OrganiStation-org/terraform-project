output "federated_credential_ids" {
  value       = { for k, v in azurerm_federated_identity_credential.ms : k => v.id }
  description = "Map of service name to federated identity credential ID"
}

output "federated_credential_names" {
  value       = { for k, v in azurerm_federated_identity_credential.ms : k => v.name }
  description = "Map of service name to federated identity credential name"
}
