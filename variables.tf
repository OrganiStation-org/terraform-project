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
  default     = "westus2"
}

variable "environment_configs" {
  type = map(object({
    node_count          = number
    vm_size             = string
    kv_sku              = string
    cosmos_throughput   = number
    enable_autoscaling  = bool
    max_count           = number
    min_count           = number
    log_retention_days  = number
    namespace           = string
  }))
  description = "Configuration mapping for different environments"
  default = {
    dev = {
      node_count         = 1
      vm_size            = "Standard_D2s_v3"
      kv_sku             = "standard"
      cosmos_throughput  = 400
      enable_autoscaling = false
      max_count          = 1
      min_count          = 1
      log_retention_days = 30
      namespace          = "dev-ns"
    }
    prod = {
      node_count         = 3
      vm_size            = "Standard_D4s_v3"
      kv_sku             = "premium"
      cosmos_throughput  = 1000
      enable_autoscaling = true
      max_count          = 5
      min_count          = 2
      log_retention_days = 90
      namespace          = "prod-ns"
    }
  }
}

locals {
  env = terraform.workspace
  # Select config based on workspace, fallback to dev if workspace is default
  config = lookup(var.environment_configs, local.env, var.environment_configs["dev"])
}
