variable "resource_group_name" {
  type = string
}

variable "resource_group_id" {
  type = string
}

variable "location" {
  type = string
}

variable "acr_name" {
  type = string
}

variable "aca_env_name" {
  type = string
}

variable "gitlab_runner_principal_id" {
  type = string
  description = "The Principal ID of the GitLab Runner's System Assigned Identity"
}

