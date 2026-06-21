resource "azurerm_cosmosdb_account" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "MongoDB"
  tags                = var.tags
  capabilities { name = "EnableMongo" }
  public_network_access_enabled = false

  geo_location {
    location          = var.location
    failover_priority = 0
  }
  geo_location {
    location          = var.secondary_location
    failover_priority = 1
  }
  consistency_policy { consistency_level = "Session" }
}

resource "azurerm_cosmosdb_mongo_database" "main" {
  name                = "organistation-db"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  throughput          = var.throughput
}

resource "azurerm_private_endpoint" "cosmos" {
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "cosmos-connection"
    private_connection_resource_id = azurerm_cosmosdb_account.this.id
    is_manual_connection           = false
    subresource_names              = ["MongoDB"]
  }

  private_dns_zone_group {
    name                 = "cosmos-dns-group"
    private_dns_zone_ids = [var.dns_zone_id]
  }
}
