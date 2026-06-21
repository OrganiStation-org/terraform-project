module "resource_group" {
  source   = "./modules/resource_group"
  name     = "${var.project_name}-rg-${local.env}"
  location = var.location
}

module "networking" {
  source              = "./modules/networking"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vnet_name           = "${var.project_name}-vnet-${local.env}"
  env                 = local.env
}

module "identity" {
  source              = "./modules/identity"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  env                 = local.env
  project_name        = var.project_name
}

module "acr" {
  source              = "./modules/acr"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "${replace(var.project_name, "-", "")}acr${local.env}"
  aks_principal_id    = module.identity.aks_kubelet_identity_id
}

module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  env                 = local.env
  retention_days      = local.config.log_retention_days
}

module "private_dns" {
  source              = "./modules/private_dns"
  resource_group_name = module.resource_group.name
  vnet_id             = module.networking.vnet_id
}

module "storage" {
  source              = "./modules/storage"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "${var.project_name}store${local.env}"
  subnet_id           = module.networking.private_endpoints_subnet_id
  dns_zone_blob_id    = module.private_dns.blob_dns_zone_id
  dns_zone_file_id    = module.private_dns.file_dns_zone_id
}

module "servicebus" {
  source              = "./modules/servicebus"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "${var.project_name}-sb-${local.env}"
  sku                 = local.env == "prod" ? "Premium" : "Standard"
}

module "signalr" {
  source              = "./modules/signalr"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "${var.project_name}-signalr-${local.env}"
}

module "communication_services" {
  source              = "./modules/communication_services"
  resource_group_name = module.resource_group.name
  name                = "${var.project_name}-acs-${local.env}"
}

module "keyvault" {
  source              = "./modules/keyvault"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "${var.project_name}-kv-${local.env}"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = local.config.kv_sku
  subnet_id           = module.networking.private_endpoints_subnet_id
  dns_zone_id         = module.private_dns.kv_dns_zone_id
  aks_identity_id     = module.identity.aks_workload_identity_id
}

module "cosmosdb" {
  source              = "./modules/cosmosdb"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "${var.project_name}-cosmos-${local.env}"
  throughput          = local.config.cosmos_throughput
  subnet_id           = module.networking.private_endpoints_subnet_id
  dns_zone_id         = module.private_dns.cosmos_dns_zone_id
}

module "aks" {
  source              = "./modules/aks"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "${var.project_name}-aks-${local.env}"
  vnet_subnet_id      = module.networking.aks_subnet_id
  identity_id         = module.identity.aks_identity_id
  node_count          = local.config.node_count
  vm_size             = local.config.vm_size
  enable_autoscaling  = local.config.enable_autoscaling
  max_count           = local.config.max_count
  min_count           = local.config.min_count
  log_analytics_id    = module.monitoring.log_analytics_id
}

module "app_gateway" {
  source              = "./modules/app_gateway"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "${var.project_name}-appgw-${local.env}"
  subnet_id           = module.networking.appgw_subnet_id
}

module "bastion" {
  source              = "./modules/bastion"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  subnet_id           = module.networking.bastion_subnet_id
}

module "workload_federation" {
  source              = "./modules/workload_federation"
  resource_group_name = module.resource_group.name
  oidc_issuer_url     = module.aks.oidc_issuer_url
  namespace           = local.config.namespace
  env                 = local.env
  parent_id           = module.identity.aks_workload_identity_id
}
