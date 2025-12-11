terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = true # Consider disabling if using pure managed identity
}

resource "azurerm_container_app_environment" "aca_env" {
  name                = var.aca_env_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

# User Assigned Identity for Automation Jobs
resource "azurerm_user_assigned_identity" "jobs_identity" {
  location            = var.location
  name                = "id-automation-jobs"
  resource_group_name = var.resource_group_name
}

# Grant the Jobs Identity permission to pull from ACR
resource "azurerm_role_assignment" "jobs_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.jobs_identity.principal_id
}

# Role Assignment: Allow GitLab Runner (System Assigned Identity) to push to ACR
# Principal ID of the GitLab Runner VM/VMSS is required here
resource "azurerm_role_assignment" "acr_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = var.gitlab_runner_principal_id
}

# Role Assignment: Allow GitLab Runner to manage Container Apps in the Resource Group
resource "azurerm_role_assignment" "aca_contributor" {
  scope                = var.resource_group_id
  role_definition_name = "Contributor"
  principal_id         = var.gitlab_runner_principal_id
}

# Role Assignment: Allow GitLab Runner to assign the User Identity to the Jobs
# This is required so the runner can attach 'id-automation-jobs' to the container apps it creates
resource "azurerm_role_assignment" "identity_operator" {
  scope                = azurerm_user_assigned_identity.jobs_identity.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.gitlab_runner_principal_id
}

