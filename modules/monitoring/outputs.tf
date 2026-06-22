output "log_analytics_id" { value = azurerm_log_analytics_workspace.this.id }
output "log_analytics_workspace_id" { value = azurerm_log_analytics_workspace.this.workspace_id }
output "prometheus_id" { value = azurerm_monitor_workspace.this.id }
output "grafana_url" { value = azurerm_dashboard_grafana.this.endpoint }
