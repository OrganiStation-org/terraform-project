variable "project_name" {
  type        = string
  description = "Project name prefix"
  default     = "mahesh"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "centralindia"
}

variable "dr_location" {
  type        = string
  description = "Disaster Recovery region"
  default     = "southindia"
}

variable "service_bus_location" {
  type        = string
  description = "Azure region for Service Bus (co-located with primary workload for low latency)"
  default     = "centralindia"
}

variable "environment_configs" {
  type = map(object({
    node_count         = number
    vm_size            = string
    kv_sku             = string
    cosmos_throughput  = number
    enable_autoscaling = bool
    max_count          = number
    min_count          = number
    log_retention_days = number
    namespace          = string
  }))
  description = "Configuration mapping for different environments"
}

locals {
  # Default to 'prod' if the workspace is 'default'
  env = terraform.workspace == "default" ? "prod" : terraform.workspace

  # Configuration selected from the provided tfvars
  config = var.environment_configs[local.env]
}
