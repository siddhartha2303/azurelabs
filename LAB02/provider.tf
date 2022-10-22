terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "0.1.3"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.14.0"
    }
  }
}

provider "azuredevops" {
  org_service_url       = "https://dev.azure.com/siddhartha2303"
  personal_access_token = "pydcqysg354lq5uakwbaxyzmyu5hgeuzajwxrevfld3jz2bbplmq"
}

provider "azurerm" {
  features {}
}