resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "cosmos" {
  name                = "privatelink.mongo.cosmos.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "sb" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv" {
  for_each              = toset(var.vnet_ids)
  name                  = "kv-link-${index(var.vnet_ids, each.value)}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  virtual_network_id    = each.value
}

resource "azurerm_private_dns_zone_virtual_network_link" "cosmos" {
  for_each              = toset(var.vnet_ids)
  name                  = "cosmos-link-${index(var.vnet_ids, each.value)}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.cosmos.name
  virtual_network_id    = each.value
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  for_each              = toset(var.vnet_ids)
  name                  = "blob-link-${index(var.vnet_ids, each.value)}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = each.value
}

resource "azurerm_private_dns_zone_virtual_network_link" "file" {
  for_each              = toset(var.vnet_ids)
  name                  = "file-link-${index(var.vnet_ids, each.value)}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.file.name
  virtual_network_id    = each.value
}

resource "azurerm_private_dns_zone_virtual_network_link" "sb" {
  for_each              = toset(var.vnet_ids)
  name                  = "sb-link-${index(var.vnet_ids, each.value)}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sb.name
  virtual_network_id    = each.value
}
