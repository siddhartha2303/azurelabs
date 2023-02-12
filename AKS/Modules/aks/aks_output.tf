output "clientID" {
  value = data.azurerm_user_assigned_identity.k8s-userIdentity.client_id
}

output "objectID" {
  value = data.azurerm_user_assigned_identity.k8s-userIdentity.principal_id
}

output "ID" {
  value = data.azurerm_user_assigned_identity.k8s-userIdentity.id
}

output "aks_operator_guid" {
  value = data.azuread_group.aks_operator.id
}