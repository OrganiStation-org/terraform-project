resource "azurerm_log_analytics_workspace" "this" {
  name                = "mahesh-law-${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
  tags                = var.tags
}

output "log_analytics_id" { value = azurerm_log_analytics_workspace.this.id }
output "log_analytics_workspace_id" { value = azurerm_log_analytics_workspace.this.workspace_id }
