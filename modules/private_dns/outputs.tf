output "kv_dns_zone_id" { value = azurerm_private_dns_zone.kv.id }
output "cosmos_dns_zone_id" { value = azurerm_private_dns_zone.cosmos.id }
output "blob_dns_zone_id" { value = azurerm_private_dns_zone.blob.id }
output "file_dns_zone_id" { value = azurerm_private_dns_zone.file.id }
output "sb_dns_zone_id" { value = azurerm_private_dns_zone.sb.id }
