variable "rg_name" {
  type = string
  description = "provide the resource group name"
}

variable "app_service_plan_name" {
  type        = string
  description = "App Service Plan name in Azure"
}

variable "app_service_name" {
  type        = string
  description = "App Service name in Azure"
}

variable "keyvault_name" {
    type        = string
}