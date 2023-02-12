output "strgKey1" {
  value     = module.create_storage.storage_primary_access_key
  sensitive = true
}

output "strgKey2" {
  value     = module.create_storage.storage_secondary_access_key
  sensitive = true
}