# ============================================================
# OrganiStation - Production Environment Variables
# Usage: terraform plan -var-file="prod.tfvars"
#        terraform apply -var-file="prod.tfvars"
# ============================================================

project_name         = "mahesh"
location             = "centralindia"
dr_location          = "southindia"
service_bus_location = "centralindia"

environment_configs = {
  # dev key must exist to satisfy the variable type definition
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
    # High-availability, optimized for regional vCPU quota (10 vCPU limit)
    # Using D2s_v3 (2 vCPU) x 2 nodes = 4 vCPUs initially
    node_count = 2
    vm_size    = "Standard_D2s_v3"

    # Premium Key Vault SKU (HSM-backed secrets)
    kv_sku = "premium"

    # Higher CosmosDB throughput for production load
    cosmos_throughput = 1000

    # Autoscaling enabled: scales from 2 to 5 nodes
    enable_autoscaling = true
    max_count          = 5
    min_count          = 2

    # 90-day log retention for compliance
    log_retention_days = 90

    # Kubernetes namespace
    namespace = "prod-ns"
  }
}
