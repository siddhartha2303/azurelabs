#change 4
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location

  tags = {
    environment = var.environment
  }
}

resource "azuread_group" "aks_administrators" {
  display_name     = "${azurerm_resource_group.rg.name}-cluster-administrators"
  security_enabled = true
}
resource "azuread_group" "aks_operator" {
  display_name = "${azurerm_resource_group.rg.name}-cluster-operator"
  security_enabled = true
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv1" {
  depends_on                 = [azurerm_resource_group.rg]
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
}

resource "azurerm_key_vault_secret" "client-id" {
  name         = "client-id"
  value        = module.create_aks_cluster.clientID
  key_vault_id = azurerm_key_vault.kv1.id
  depends_on = [
    module.create_aks_cluster
  ]
}

resource "azurerm_key_vault_secret" "id" {
  name         = "id"
  value        = module.create_aks_cluster.ID
  key_vault_id = azurerm_key_vault.kv1.id
  depends_on = [
    module.create_aks_cluster
  ]
}

resource "azurerm_key_vault_secret" "storageconnectionstring" {
  name         = "storageconnectionstring"
  value        = data.azurerm_storage_account.aks-strg.primary_connection_string
  key_vault_id = azurerm_key_vault.kv1.id
  depends_on = [
    module.create_aks_cluster
  ]
}

module "create_aks_cluster" {
  source         = "git::ssh://git@ssh.dev.azure.com/v3/siddhartha2303/AKS-DEMO/AKS-DEMO//Modules/aks"
  rg_name        = var.rg_name
  cluster_name   = "aksdemo-cluster"
  dns_prefix     = "aksdemo-dns"
  ssh_public_key = "your ADO key"
  agent_count    = 2
  depends_on     = [azurerm_resource_group.rg,azuread_group.aks_administrators]
}

data "azurerm_user_assigned_identity" "k8s-userIdentity" {
  name                = "aksdemo-cluster-agentpool"
  resource_group_name = "${var.rg_name}-nrg"
  depends_on = [
    module.create_aks_cluster
  ]
}

resource "azurerm_role_assignment" "akv_sp" {
  scope                = azurerm_key_vault.kv1.id
  role_definition_name = "Reader"
  #principal_id         = module.create_aks_cluster.objectID
  principal_id  = data.azurerm_user_assigned_identity.k8s-userIdentity.principal_id
  depends_on = [
    module.create_aks_cluster
  ]
}
resource "azurerm_key_vault_access_policy" "aks-sp-kv" {
  key_vault_id = azurerm_key_vault.kv1.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  #object_id    = module.create_aks_cluster.objectID
  object_id  = data.azurerm_user_assigned_identity.k8s-userIdentity.principal_id

  secret_permissions = [
    "Get",
  ]
  depends_on = [
    module.create_aks_cluster, azurerm_role_assignment.akv_sp
  ]
}

data "azurerm_storage_account" "aks-strg" {
  name                = var.strg_name
  resource_group_name = "TfDemo01"
}

resource "azurerm_role_assignment" "aks-strg-role" {
  scope                = data.azurerm_storage_account.aks-strg.id
  role_definition_name = "Storage Blob Data Reader"
  #principal_id         = module.create_aks_cluster.objectID
  principal_id  = data.azurerm_user_assigned_identity.k8s-userIdentity.principal_id
  depends_on = [
    module.create_aks_cluster
  ]
}

/*
module "create_appservice" {
  source                = "../Modules/appservice"
  rg_name               = var.rg_name
  keyvault_name         = var.kv_name
  app_service_plan_name = "my-appserviceplan"
  app_service_name      = "demowebapp006"
  depends_on            = [azurerm_resource_group.rg,module.create_db]
}*/