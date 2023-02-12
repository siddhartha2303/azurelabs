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
variable "strgContainer_name" {
  type = string
}

variable "db_name" {
  type = string
}

variable "dbsrv_name" {
  type = string
}

variable "client_secret" {
  type = string
}

variable "service_endpoint_id" {
  type = string
}