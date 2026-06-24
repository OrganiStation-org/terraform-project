output "namespace_id" {
  value       = azurerm_servicebus_namespace.this.id
  description = "Service Bus namespace resource ID"
}

output "connection_string" {
  value       = azurerm_servicebus_namespace.this.default_primary_connection_string
  sensitive   = true
  description = "Service Bus namespace primary connection string"
}
