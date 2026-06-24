variable "resource_group_name" {
  type        = string
  description = "Resource group containing the workload identity"
}

variable "oidc_issuer_url" {
  type        = string
  description = "AKS OIDC issuer URL for federated credentials"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace for service accounts"
}

variable "env" {
  type        = string
  description = "Environment name"
}

variable "parent_id" {
  type        = string
  description = "Resource ID of the parent user-assigned managed identity"
}
