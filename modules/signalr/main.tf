variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "name" { type = string }

resource "azurerm_signalr_service" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "Free_F1" # Upgrade to Standard_S1 in Prod if needed
    capacity = 1
  }

  cors {
    allowed_origins = ["*"] # Restrict this to your frontend URL in Prod
  }

  connectivity_logs_enabled = true
  messaging_logs_enabled    = true
  service_mode              = "Default"
}

output "hostname" { value = azurerm_signalr_service.this.hostname }
output "primary_connection_string" { value = azurerm_signalr_service.this.primary_connection_string, sensitive = true }
