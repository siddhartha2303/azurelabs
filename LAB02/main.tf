resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location

  tags = {
    environment = var.environment
  }
}

data "azuredevops_project" "AKS-DEMO" {
  name = "AKS-DEMO"
}
data "azuread_service_principal" "tfServicepPrincipal" {
  display_name = "tfServicepPrincipal"
}

data "azurerm_subscription" "subscriptionID" {
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv1" {
  depends_on                 = [azurerm_resource_group.rg, module.create_storage]
  name                       = var.kv_name
  location                   = var.location
  resource_group_name        = var.rg_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  sku_name                   = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    //application_id = data.azuread_service_principal.tfServicepPrincipal.application_id
    key_permissions = [
      "Get",
    ]
    secret_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set",
    ]
    storage_permissions = [
      "Get",
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azuread_service_principal.tfServicepPrincipal.object_id
    key_permissions = [
      "Get", "List"
    ]
    secret_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set",
    ]
    storage_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_key_vault_secret" "client-id" {
  name         = "client-id"
  value        = data.azuread_service_principal.tfServicepPrincipal.application_id
  key_vault_id = azurerm_key_vault.kv1.id
  depends_on = [
    module.create_storage
  ]
}

resource "azurerm_key_vault_secret" "client-secret" {
  name         = "client-secret"
  value        = "6LI8Q~XFvDdNFpDa4ycJLDhPul2.f~D3VbEPwbd8"
  key_vault_id = azurerm_key_vault.kv1.id
  depends_on = [
    module.create_storage
  ]
}

resource "azurerm_key_vault_secret" "TenantID" {
  name         = "TenantID"
  value        = data.azurerm_subscription.subscriptionID.tenant_id
  key_vault_id = azurerm_key_vault.kv1.id
  depends_on = [
    module.create_storage
  ]
}

resource "azurerm_key_vault_secret" "SubscriptionID" {
  name         = "SubscriptionID"
  value        = data.azurerm_subscription.subscriptionID.subscription_id
  key_vault_id = azurerm_key_vault.kv1.id
  depends_on = [
    module.create_storage
  ]
}

resource "azurerm_key_vault_secret" "strgKey1" {
  name         = "strgKey1"
  value        = module.create_storage.storage_primary_access_key
  key_vault_id = azurerm_key_vault.kv1.id
  depends_on = [
    module.create_storage
  ]
}

resource "azurerm_key_vault_secret" "strgKey2" {
  name         = "strgKey2"
  value        = module.create_storage.storage_secondary_access_key
  key_vault_id = azurerm_key_vault.kv1.id
  depends_on = [
    module.create_storage
  ]
}

module "create_storage" {
  source             = "../Modules/storage"
  rg_name            = var.rg_name
  strg_name          = var.strg_name
  strgContainer_name = var.strgContainer_name
  depends_on         = [azurerm_resource_group.rg]
}

module "create_db" {
  source             = "../Modules/db"
  rg_name            = var.rg_name
  keyvault_name      = var.kv_name
  sql_server_name    = var.dbsrv_name
  sql_database_name  = var.db_name
  sql_admin_login    = var.dbsrv_name
  sql_admin_password = "India@123"
  depends_on         = [azurerm_resource_group.rg, azurerm_key_vault.kv1]
}

resource "azuredevops_variable_group" "azdevops-variable-group" {
  depends_on = [
    azurerm_key_vault_secret.client-id,
    azurerm_key_vault_secret.client-secret,
    azurerm_key_vault_secret.TenantID,
    azurerm_key_vault_secret.SubscriptionID,
    azurerm_key_vault_secret.strgKey1,
    azurerm_key_vault_secret.strgKey2,
  ]
  project_id   = data.azuredevops_project.AKS-DEMO.project_id
  name         = "azkeys"
  description  = "key vault keys"
  allow_access = true

  key_vault {
    name                = var.kv_name
    service_endpoint_id = "f05d21b0-f0c0-4744-b940-1bd526199f63"
  }

  variable {
    name = "client-secret"
  }

  variable {
    name = "client-id"
  }

  variable {
    name = "TenantID"
  }

  variable {
    name = "SubscriptionID"
  }

  variable {
    name = "strgKey1"
  }

  variable {
    name = "strgKey2"
  }
}
