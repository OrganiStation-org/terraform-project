output "id" {
  value       = azurerm_application_insights.this.id
  description = "Application Insights resource ID"
}

output "app_id" {
  value       = azurerm_application_insights.this.app_id
  description = "Application Insights application ID"
}

output "instrumentation_key" {
  value       = azurerm_application_insights.this.instrumentation_key
  sensitive   = true
  description = "Application Insights instrumentation key"
}

output "connection_string" {
  value       = azurerm_application_insights.this.connection_string
  sensitive   = true
  description = "Application Insights connection string"
}
