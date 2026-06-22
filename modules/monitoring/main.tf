resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.project_name}-law-${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
  tags                = var.tags
}

# Azure Managed Prometheus (Monitor Workspace)
resource "azurerm_monitor_workspace" "this" {
  name                = "${var.project_name}-prometheus-${var.env}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}
