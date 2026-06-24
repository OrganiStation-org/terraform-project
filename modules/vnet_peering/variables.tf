variable "primary_resource_group" {
  type        = string
  description = "Resource group of the primary virtual network"
}

variable "secondary_resource_group" {
  type        = string
  description = "Resource group of the secondary (DR) virtual network"
}

variable "primary_vnet_name" {
  type        = string
  description = "Name of the primary virtual network"
}

variable "secondary_vnet_name" {
  type        = string
  description = "Name of the secondary (DR) virtual network"
}

variable "primary_vnet_id" {
  type        = string
  description = "Resource ID of the primary virtual network"
}

variable "secondary_vnet_id" {
  type        = string
  description = "Resource ID of the secondary (DR) virtual network"
}
