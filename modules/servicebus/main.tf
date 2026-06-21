resource "azurerm_servicebus_namespace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  tags                = var.tags
}

resource "azurerm_servicebus_topic" "notifications" {
  name         = "notifications"
  namespace_id = azurerm_servicebus_namespace.this.id
}

locals {
  subs = ["leave-notifications", "hr-announcements", "manager-notifications"]
}

resource "azurerm_servicebus_subscription" "subs" {
  for_each            = toset(local.subs)
  name                = each.key
  topic_id            = azurerm_servicebus_topic.notifications.id
  max_delivery_count  = 10
}

output "namespace_id" { value = azurerm_servicebus_namespace.this.id }
output "connection_string" {
  value     = azurerm_servicebus_namespace.this.default_primary_connection_string
  sensitive = true
}
