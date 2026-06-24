variable "name" {
  type        = string
  description = "Application Insights resource name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID to link Application Insights to"
}

variable "application_type" {
  type        = string
  description = "Application type (web, other, etc.)"
  default     = "web"
}

variable "retention_in_days" {
  type        = number
  description = "Data retention in days"
  default     = 90
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
