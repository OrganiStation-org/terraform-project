variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Azure region for the Service Bus namespace (co-locate with primary workload region)"
}

variable "name" {
  type        = string
  description = "Service Bus namespace name"
}

variable "sku" {
  type        = string
  description = "Service Bus SKU (Basic, Standard, or Premium)"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
