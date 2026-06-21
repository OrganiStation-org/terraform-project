variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "name" { type = string }
variable "sku" {
  type    = string
  default = "Standard"
}

resource "azurerm_servicebus_namespace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
}

resource "azurerm_servicebus_topic" "notifications" {
  name         = "notifications"
  namespace_id = azurerm_servicebus_namespace.this.id
}

locals {
  subs = ["leave-notifications", "hr-announcements", "manager-notifications"]
}

resource "azurerm_servicebus_subscription" "subs" {
  for_each = toset(local.subs)
  name     = each.key
  topic_id = azurerm_servicebus_topic.notifications.id
}

output "namespace_id" { value = azurerm_servicebus_namespace.this.id }
output "connection_string" {
  value     = azurerm_servicebus_namespace.this.default_primary_connection_string
  sensitive = true
}
