variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "name" { type = string }
variable "subnet_id" { type = string }
variable "dns_zone_blob_id" { type = string }
variable "dns_zone_file_id" { type = string }

resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  public_network_access_enabled = true
  tags                          = var.tags
}

resource "azurerm_storage_container" "docs" {
  name                  = "documents"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_storage_share" "chroma" {
  name                 = "chromadb-share"
  storage_account_name = azurerm_storage_account.this.name
  quota                = 5
}

# Private Endpoints for Blob and File
resource "azurerm_private_endpoint" "blob" {
  name                = "${var.name}-blob-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "blob-connection"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

resource "azurerm_private_endpoint" "file" {
  name                = "${var.name}-file-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "file-connection"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }
}

output "name" { value = azurerm_storage_account.this.name }
output "primary_connection_string" {
  value     = azurerm_storage_account.this.primary_connection_string
  sensitive = true
}
