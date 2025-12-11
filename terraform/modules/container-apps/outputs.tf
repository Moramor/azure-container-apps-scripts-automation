output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "aca_env_id" {
  value = azurerm_container_app_environment.aca_env.id
}

output "jobs_identity_id" {
  value = azurerm_user_assigned_identity.jobs_identity.id
  description = "The Resource ID of the User Assigned Identity for automation jobs"
}

output "jobs_identity_client_id" {
  value = azurerm_user_assigned_identity.jobs_identity.client_id
  description = "The Client ID of the User Assigned Identity for automation jobs"
}

