data "azurerm_storage_account" "azstorage" {
  name                = var.strg_name
  resource_group_name = var.rg_name
  depends_on = [
    azurerm_storage_container.azstorageContainer
  ]
}

output "storage_primary_access_key" {
  value = data.azurerm_storage_account.azstorage.primary_access_key
}

output "storage_secondary_access_key" {
  value = data.azurerm_storage_account.azstorage.secondary_access_key
}