provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region"
  type        = string
}

variable "acr_name" {
  description = "The name of the Azure Container Registry"
  type        = string
}

variable "aca_env_name" {
  description = "The name of the Azure Container Apps Environment"
  type        = string
}

variable "gitlab_runner_principal_id" {
  description = "The Principal ID of the GitLab Runner's Managed Identity"
  type        = string
}

# Example Resource Group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Call the Container Apps Module
module "container_apps" {
  source = "./modules/container-apps"

  resource_group_name = azurerm_resource_group.example.name
  resource_group_id   = azurerm_resource_group.example.id
  location            = azurerm_resource_group.example.location

  acr_name     = var.acr_name
  aca_env_name = var.aca_env_name

  gitlab_runner_principal_id = var.gitlab_runner_principal_id
}

output "automation_jobs_identity_id" {
  value = module.container_apps.jobs_identity_id
}
