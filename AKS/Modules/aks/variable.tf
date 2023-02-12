variable "rg_name" {
  type = string
  description = "provide the resource group name"
}

variable "agent_count" {
    default = 2
}

variable "ssh_public_key" {
    default = "ssh key here"
}

variable "dns_prefix" {
    default = "k8stest"
}

variable "cluster_name" {
    default = "k8stest"
}
