provider "azurerm" {
  features {}
}

# Example Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-automation-framework"
  location = "West Europe"
}

# Call the Container Apps Module
module "container_apps" {
  source = "./modules/container-apps"

  resource_group_name = azurerm_resource_group.example.name
  resource_group_id   = azurerm_resource_group.example.id
  location            = azurerm_resource_group.example.location

  acr_name     = "myautomationacr" # Must be globally unique and alphanumeric
  aca_env_name = "aca-env-automation"

  # REPLACE THIS with your GitLab Runner's Managed Identity Principal ID
  gitlab_runner_principal_id = "00000000-0000-0000-0000-000000000000"
}

output "automation_jobs_identity_id" {
  value = module.container_apps.jobs_identity_id
}

