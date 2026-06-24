# ============================================================
# OrganiStation - Development Environment Variables
# Usage: terraform plan -var-file="dev.tfvars"
#        terraform apply -var-file="dev.tfvars"
# ============================================================

project_name = "mahesh"
location     = "centralindia"
dr_location          = "southindia"
service_bus_location = "centralindia"

environment_configs = {
  dev = {
    # Low-cost, single-node cluster for development
    node_count         = 1
    vm_size            = "Standard_D2s_v3"

    # Standard Key Vault SKU (no HSM needed in dev)
    kv_sku             = "standard"

    # Minimum CosmosDB throughput
    cosmos_throughput  = 400

    # No autoscaling for dev (cost savings)
    enable_autoscaling = false
    max_count          = 1
    min_count          = 1

    # Short log retention (cost savings)
    log_retention_days = 30

    # Kubernetes namespace
    namespace          = "dev-ns"
  }

  # prod key must exist to satisfy the variable type definition
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
