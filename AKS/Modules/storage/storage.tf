data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

resource "azurerm_storage_account" "azstorage" {
  name                     = var.strg_name
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
  access_tier = "Cool"
}

resource "azurerm_storage_container" "azstorageContainer" {
  name = var.strgContainer_name 
  storage_account_name = var.strg_name
  depends_on = [
    azurerm_storage_account.azstorage
  ]
}
