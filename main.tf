resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

locals {
  project_id = "${var.project_name}${random_string.suffix.result}"
  common_tags = {
    Environment = local.env
    Owner       = "OrganiStation-DevOps"
    Project     = "OrganiStation"
    ManagedBy   = "Terraform"
  }
}

module "resource_group" {
  source   = "./modules/resource_group"
  name     = "${local.project_id}-rg-${local.env}"
  location = var.location
  tags     = local.common_tags
}

module "dr_resource_group" {
  source   = "./modules/resource_group"
  name     = "${local.project_id}-dr-rg-${local.env}"
  location = var.dr_location
  tags     = local.common_tags
}

module "networking" {
  source              = "./modules/networking"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vnet_name           = "${local.project_id}-vnet-${local.env}"
  env                 = local.env
  tags                = local.common_tags
}

module "dr_networking" {
  source              = "./modules/networking"
  resource_group_name = module.dr_resource_group.name
  location            = module.dr_resource_group.location
  vnet_name           = "${local.project_id}-dr-vnet-${local.env}"
  env                 = local.env
  address_space       = ["10.1.0.0/16"]
  tags                = local.common_tags
}

module "vnet_peering" {
  source                   = "./modules/vnet_peering"
  primary_resource_group   = module.resource_group.name
  secondary_resource_group = module.dr_resource_group.name
  primary_vnet_name        = module.networking.vnet_name
  secondary_vnet_name      = module.dr_networking.vnet_name
  primary_vnet_id          = module.networking.vnet_id
  secondary_vnet_id        = module.dr_networking.vnet_id
}

module "identity" {
  source              = "./modules/identity"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  env                 = local.env
  project_name        = local.project_id
  tags                = local.common_tags
}

module "acr" {
  source              = "./modules/acr"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "${replace(local.project_id, "-", "")}acr${local.env}"
  aks_principal_id    = module.identity.aks_kubelet_identity_id
  tags                = local.common_tags
}

module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  env                 = local.env
  retention_days      = local.config.log_retention_days
  tags                = local.common_tags
}

module "private_dns" {
  source              = "./modules/private_dns"
  resource_group_name = module.resource_group.name
  vnet_id             = module.networking.vnet_id
  tags                = local.common_tags
}

module "storage" {
  source              = "./modules/storage"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "${local.project_id}store${local.env}"
  subnet_id           = module.networking.private_endpoints_subnet_id
  dns_zone_blob_id    = module.private_dns.blob_dns_zone_id
  dns_zone_file_id    = module.private_dns.file_dns_zone_id
  tags                = local.common_tags
}

module "servicebus" {
  source              = "./modules/servicebus"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "${local.project_id}-sb-${local.env}"
  sku                 = local.env == "prod" ? "Premium" : "Standard"
  tags                = local.common_tags
}

module "signalr" {
  source              = "./modules/signalr"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "${local.project_id}-signalr-${local.env}"
  tags                = local.common_tags
}

module "communication_services" {
  source              = "./modules/communication_services"
  resource_group_name = module.resource_group.name
  name                = "${local.project_id}-acs-${local.env}"
  tags                = local.common_tags
}

module "keyvault" {
  source              = "./modules/keyvault"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "${local.project_id}-kv-${local.env}"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = local.config.kv_sku
  subnet_id           = module.networking.private_endpoints_subnet_id
  dns_zone_id         = module.private_dns.kv_dns_zone_id
  aks_identity_id     = module.identity.aks_workload_identity_principal_id
  tags                = local.common_tags
}

module "cosmosdb" {
  source              = "./modules/cosmosdb"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "${local.project_id}-cosmos-${local.env}"
  throughput          = local.config.cosmos_throughput
  subnet_id           = module.networking.private_endpoints_subnet_id
  dns_zone_id         = module.private_dns.cosmos_dns_zone_id
  secondary_location  = var.dr_location
  tags                = local.common_tags
}

module "aks" {
  source              = "./modules/aks"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "${local.project_id}-aks-${local.env}"
  vnet_subnet_id      = module.networking.aks_subnet_id
  identity_id         = module.identity.aks_identity_id
  node_count          = local.config.node_count
  vm_size             = local.config.vm_size
  enable_autoscaling  = local.config.enable_autoscaling
  max_count           = local.config.max_count
  min_count           = local.config.min_count
  log_analytics_id    = module.monitoring.log_analytics_id
  tags                = local.common_tags
}

module "app_gateway" {
  source              = "./modules/app_gateway"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "${local.project_id}-appgw-${local.env}"
  subnet_id           = module.networking.appgw_subnet_id
  tags                = local.common_tags
}

module "bastion" {
  source              = "./modules/bastion"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  subnet_id           = module.networking.bastion_subnet_id
  tags                = local.common_tags
}

module "workload_federation" {
  source              = "./modules/workload_federation"
  resource_group_name = module.resource_group.name
  oidc_issuer_url     = module.aks.oidc_issuer_url
  namespace           = local.config.namespace
  env                 = local.env
  parent_id           = module.identity.aks_workload_identity_id
}
