variable "spn-client-id" {}
variable "spn-client-secret" {}
variable "spn-tenant-id" {}
variable "azsubscription-id" {}
variable "rg_name" {
  type        = string
  description = "This is resource group name"
}

variable "location" {
  type        = string
  description = "This is location of resource group"
}

variable "environment" {
  type = string
}

variable "kv_name" {
  type = string
}

variable "strg_name" {
  type = string
}