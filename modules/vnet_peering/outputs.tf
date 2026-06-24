output "primary_to_secondary_peering_id" {
  value       = azurerm_virtual_network_peering.primary_to_secondary.id
  description = "Resource ID of the primary-to-secondary VNet peering"
}

output "secondary_to_primary_peering_id" {
  value       = azurerm_virtual_network_peering.secondary_to_primary.id
  description = "Resource ID of the secondary-to-primary VNet peering"
}
