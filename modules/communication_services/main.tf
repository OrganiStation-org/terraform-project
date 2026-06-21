variable "resource_group_name" { type = string }
variable "name" { type = string }

resource "azurerm_communication_service" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  data_location       = "United States" # ACS has specific data locations
}

output "id" { value = azurerm_communication_service.this.id }
output "primary_connection_string" { value = azurerm_communication_service.this.primary_connection_string, sensitive = true }
