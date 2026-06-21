resource "azurerm_user_assigned_identity" "aks" {
  name                = "${var.project_name}-aks-identity-${var.env}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "workload" {
  name                = "${var.project_name}-workload-identity-${var.env}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}
