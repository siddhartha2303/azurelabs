terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.14.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.28.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azsubscription-id
  client_id       = var.spn-client-id
  client_secret   = var.spn-client-secret
  tenant_id       = var.spn-tenant-id
}

provider "azuread" {
  tenant_id       = var.spn-tenant-id
  client_id       = var.spn-client-id
  client_secret   = var.spn-client-secret
}