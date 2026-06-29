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

# Azure Managed Grafana
resource "azurerm_dashboard_grafana" "this" {
  name                          = "${var.project_name}-grafana-${var.env}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = "Standard"
  public_network_access_enabled = true
  grafana_major_version         = 12

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.this.id
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "grafana_monitoring" {
  scope                = azurerm_monitor_workspace.this.id
  role_definition_name = "Monitoring Data Reader"
  principal_id         = azurerm_dashboard_grafana.this.identity[0].principal_id
}
