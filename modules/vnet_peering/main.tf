resource "azurerm_virtual_network_peering" "primary_to_secondary" {
  name                         = "peak-to-dr"
  resource_group_name          = var.primary_resource_group
  virtual_network_name         = var.primary_vnet_name
  remote_virtual_network_id    = var.secondary_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "secondary_to_primary" {
  name                         = "dr-to-peak"
  resource_group_name          = var.secondary_resource_group
  virtual_network_name         = var.secondary_vnet_name
  remote_virtual_network_id    = var.primary_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
