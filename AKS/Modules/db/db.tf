data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azurerm_key_vault" "kv1" {
  name                = var.keyvault_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_sql_server" "sqldb" {
  name                         = var.sql_server_name
  resource_group_name          = data.azurerm_resource_group.rg.name
  location                     = data.azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_sql_database" "db" {
  name                = "terraform-sqldatabase20"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sqldb.name
  zone_redundant      = false
  edition             = "Basic"
}

resource "azurerm_sql_firewall_rule" "rule" {
  name                = "AlllowAzureServices"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_sql_server.sqldb.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_key_vault_secret" "DbConnectionString" {
  name         = "DbConnectionString"
  value       = "Server=tcp:${azurerm_sql_server.sqldb.fully_qualified_domain_name},1433,Initial Catalog=${azurerm_sql_database.db.name};Persist Security Info=False;User ID=${azurerm_sql_server.sqldb.administrator_login};Password=${azurerm_sql_server.sqldb.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = data.azurerm_key_vault.kv1.id
}
