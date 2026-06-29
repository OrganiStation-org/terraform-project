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
  project_name        = local.project_id
  tags                = local.common_tags
}

module "application_insights" {
  source                     = "./modules/application_insights"
  name                       = "${local.project_id}-appinsights-${local.env}"
  location                   = module.resource_group.location
  resource_group_name        = module.resource_group.name
  log_analytics_workspace_id = module.monitoring.log_analytics_id
  retention_in_days          = local.config.log_retention_days
  tags                       = local.common_tags
}

module "private_dns" {
  source              = "./modules/private_dns"
  resource_group_name = module.resource_group.name
  vnet_ids = {
    primary = module.networking.vnet_id
    dr      = module.dr_networking.vnet_id
  }
  tags = local.common_tags
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
  location            = var.service_bus_location
  name                = "${local.project_id}-sb-${local.env}"
  sku                 = "Standard"
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
  source                 = "./modules/cosmosdb"
  resource_group_name    = module.resource_group.name
  location               = module.resource_group.location
  name                   = "${local.project_id}-cosmos-${local.env}"
  throughput             = local.config.cosmos_throughput
  subnet_id              = module.networking.private_endpoints_subnet_id
  dns_zone_id            = module.private_dns.cosmos_dns_zone_id
  secondary_location     = var.dr_location
  dr_subnet_id           = module.dr_networking.private_endpoints_subnet_id
  dr_resource_group_name = module.dr_resource_group.name
  tags                   = local.common_tags
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
  prometheus_id       = module.monitoring.prometheus_id
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

resource "azurerm_public_ip" "vm_pip" {
  name                = "${local.project_id}-vm-pip-${local.env}"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_network_security_group" "vm_nsg" {
  name                = "${local.project_id}-vm-nsg-${local.env}"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${local.project_id}-vm-nic-${local.env}"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.networking.vm_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip.id
  }
  tags = local.common_tags
}

resource "azurerm_network_interface_security_group_association" "vm_nic_nsg" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

resource "azurerm_linux_virtual_machine" "management_vm" {
  name                            = "${local.project_id}-vm-${local.env}"
  location                        = module.resource_group.location
  resource_group_name             = module.resource_group.name
  size                            = "Standard_B2s"
  admin_username                  = "Mahesh"
  admin_password                  = "Mahesh@050903"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = local.common_tags
}

resource "azurerm_key_vault_secret" "vm_password" {
  name         = "aks-vm-password"
  value        = "Mahesh@050903"
  key_vault_id = module.keyvault.id
}
