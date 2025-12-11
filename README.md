# Azure Script Automation Framework

A serverless framework to deploy scheduled automation scripts to **Azure Container Apps Jobs** using **GitLab CI/CD**.

This project provides a "drop-in" folder structure where you can add scripts (Python, etc.), and they are automatically containerized and deployed to Azure with no additional infrastructure configuration.

## Features

*   **Serverless**: Runs on Azure Container Apps Jobs (pay per execution).
*   **Dynamic CI/CD**: A generator pipeline scans folders and creates deployment jobs on the fly.
*   **Secure**: Uses Azure Managed Identities for authentication (no API keys).
*   **Infrastructure as Code**: Includes Terraform modules to provision the required Azure resources.

## Architecture

1.  **GitLab CI**: Scans the `automated_jobs_framework/` directory.
2.  **Generator**: Creates a child pipeline for each detected script.
3.  **Docker**: Builds an image and pushes it to Azure Container Registry (ACR).
4.  **Azure CLI**: Deploys/Updates the Container App Job in Azure.

## Prerequisites

*   Azure Subscription
*   GitLab Runner with:
    *   **System Assigned Managed Identity** (if on Azure VM/VMSS)
    *   OR credentials to run `az login`
*   Terraform (to provision infrastructure)

## Getting Started

1.  **Provision Infrastructure**:
    Go to the `terraform/` folder and apply the configuration to create the ACR, Environment, and Identities.
    
    ```bash
    cd terraform
    terraform init
    terraform apply
    ```

2.  **Configure GitLab**:
    Set the required CI/CD variables in GitLab based on the Terraform outputs (ACR Name, Resource Group, Identity ID).

3.  **Add a Script**:
    Create a new folder in `automated_jobs_framework/` with your code and a `job.config.yaml`.
    
    See [Framework Documentation](automated_jobs_framework/README.md) for details.

## License

MIT License

