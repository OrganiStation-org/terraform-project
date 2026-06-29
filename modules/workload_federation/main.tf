locals {
  services   = ["auth", "ai", "hr", "finance", "projects", "gateway", "frontend", "notification"]
  namespaces = distinct(["dev-ns", var.namespace])

  # Generate mapping of services to namespaces
  service_namespaces = {
    for pair in setproduct(local.services, local.namespaces) :
    "${pair[0]}-${pair[1]}" => {
      service   = pair[0]
      namespace = pair[1]
    }
  }
}

resource "azurerm_federated_identity_credential" "ms" {
  for_each            = local.service_namespaces
  name                = "${each.value.service}-${each.value.namespace}-fed-cred-${var.env}"
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  parent_id           = var.parent_id
  subject             = "system:serviceaccount:${each.value.namespace}:${each.value.service}-sa"
}
