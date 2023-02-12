data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azuread_group" "aks_administrators" {
  display_name = "${data.azurerm_resource_group.rg.name}-cluster-administrators"   
}
data "azuread_group" "aks_operator" {
  display_name = "${data.azurerm_resource_group.rg.name}-cluster-operator"   
}

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = var.cluster_name
    location            = data.azurerm_resource_group.rg.location
    resource_group_name = data.azurerm_resource_group.rg.name
    node_resource_group = "${data.azurerm_resource_group.rg.name}-nrg"
    dns_prefix          = var.dns_prefix
    sku_tier            = "Free"
    role_based_access_control_enabled = true

    identity {
      type = "SystemAssigned"
    }

    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
            key_data = "ssh key here"
        }
    }

    default_node_pool {
        name                  = "agentpool"
        node_count            = var.agent_count
        vm_size               = "Standard_B2s"
        enable_auto_scaling   = true
        min_count             = 1
        max_count             = 2
    }

    network_profile {
        load_balancer_sku   = "standard"
        network_plugin      = "azure"
        network_policy      = "calico"
        service_cidr        = "10.0.0.0/16"
        dns_service_ip      = "10.0.0.10"
        docker_bridge_cidr  = "172.17.0.1/16"
        outbound_type       = "loadBalancer"
    }


    azure_active_directory_role_based_access_control {
        managed = true
        admin_group_object_ids = [data.azuread_group.aks_administrators.id]
        azure_rbac_enabled     = true
    }
}

data "azurerm_resource_group" "node-rg" {
  name = "${data.azurerm_resource_group.rg.name}-nrg"
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}

data "azurerm_kubernetes_cluster" "k8s-aks" {
  name = var.cluster_name
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}

/*data "azurerm_user_assigned_identity" "aksManagedIdentity" {
  name                = "managedidentity-aks"
  resource_group_name = data.azurerm_resource_group.node-rg.name
}*/

data "azurerm_user_assigned_identity" "k8s-userIdentity" {
  name                = "${azurerm_kubernetes_cluster.k8s.name}-agentpool"
  resource_group_name = data.azurerm_resource_group.node-rg.name
}

resource "azurerm_role_assignment" "agentpool_msi" {   
    scope                            = data.azurerm_resource_group.node-rg.id
    role_definition_name             = "Managed Identity Operator"
    #principal_id                     = data.azurerm_kubernetes_cluster.k8s-aks.identity[0].principal_id
    principal_id                     = data.azurerm_user_assigned_identity.k8s-userIdentity.principal_id
    skip_service_principal_aad_check = true
    depends_on = [
      azurerm_kubernetes_cluster.k8s
    ]
}

resource "azurerm_role_assignment" "agentpool_vm" {
    scope                            = data.azurerm_resource_group.node-rg.id
    role_definition_name             = "Virtual Machine Contributor"
    #principal_id                     = data.azurerm_kubernetes_cluster.k8s-aks.identity[0].principal_id
    principal_id                     = data.azurerm_user_assigned_identity.k8s-userIdentity.principal_id
    skip_service_principal_aad_check = true
    depends_on = [
      azurerm_kubernetes_cluster.k8s
    ]
}

resource "azurerm_user_assigned_identity" "userIdentity" {
  resource_group_name = "${var.rg_name}-nrg"
  location            = data.azurerm_resource_group.rg.location
  name                = "managedidentity-aks"
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}