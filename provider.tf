provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }

  default_tags {
    tags = {
      Environment = terraform.workspace
      Owner       = "OrganiStation-DevOps"
      Project     = "OrganiStation"
      ManagedBy   = "Terraform"
    }
  }
}

provider "azuread" {}

# Data source for current subscription
data "azurerm_client_config" "current" {}
