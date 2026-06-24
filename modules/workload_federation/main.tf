locals {
  services = ["auth", "ai", "hr", "finance", "projects", "gateway", "frontend", "notification"]
}

resource "azurerm_federated_identity_credential" "ms" {
  for_each            = toset(local.services)
  name                = "${each.key}-fed-cred-${var.env}"
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  parent_id           = var.parent_id
  subject             = "system:serviceaccount:${var.namespace}:${each.key}-sa"
}
