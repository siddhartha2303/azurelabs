variable "rg_name" {
  type = string
  description = "provide the resource group name"
}

variable "agent_count" {
    default = 2
}

variable "ssh_public_key" {
    default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyneWLm+dTE1cVROWQyTGbGT2NZlhVkzB46r3a1sFgZStg1FneWUszB4/PIaPVru+2uuMIFGuFij46Qq0Hd4OYpgyVvUAmrda5mPMmw+moJ2K3iMf6p4sGtYaz7BN76qx4QJG1c6f2+ZoVxLtz2jTRQrE3zo0do6ASdYSz+wE838rCCIkXJGgonYyK1qGaQnC5B8hBwwQJTe3aqAXyva3bM4fsXWWTTxTaIXmwaZAar4loVJ8TMYdyr2SU8XwoTbWRS1ninrk5wyUDIfgIOkaF7far54wFlIGPET8yurqQ/8Y85g4KhsmNDttM/VWrtGvFe/u/CMlQSPnDP7kuMk4z"
}

variable "dns_prefix" {
    default = "k8stest"
}

variable "cluster_name" {
    default = "k8stest"
}
