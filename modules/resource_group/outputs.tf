output "name" {
  value       = azurerm_resource_group.this.name
  description = "The name of the resource group"
}

output "location" {
  value       = azurerm_resource_group.this.location
  description = "The Azure region"
}
