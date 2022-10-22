data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azurerm_key_vault" "kv1" {
  name                = var.keyvault_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault_secret" "DbConnectionString" {
  name         = "DbConnectionString"
  key_vault_id = data.azurerm_key_vault.kv1.id
}

resource "azurerm_app_service_plan" "app_plan" {
  name                = var.app_service_plan_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  kind                = "Windows"
  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "webapp" {
  name                = var.app_service_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_plan.id

  site_config {
    dotnet_framework_version = "v4.0"
    use_32_bit_worker_process = true
    always_on = false
  }

  connection_string {
    name  = "Database"
    type  = "SQLAzure"
    value = data.azurerm_key_vault_secret.DbConnectionString.value
  }
}