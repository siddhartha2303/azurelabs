terraform {
  backend "azurerm" {
    storage_account_name = "tfstorageactdemo9"
    container_name       = "tfstoragecontainer"
    key                  = "tf-demo.tfstate"
  }
}