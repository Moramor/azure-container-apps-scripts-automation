# Azure Automated Jobs Framework

This framework allows the deployment of scheduled scripts to **Azure Container Apps** by adding a folder with the code and a configuration file.

## 📂 Quick Start: Create a New Job

1.  **Create a Folder**: 
    Create a new directory inside `automated_jobs_framework/` (e.g., `automated_jobs_framework/my-job/`).

2.  **Add Files from Templates**:
    Commented templates are available in `_templates/`.
    *   **Python**: Copy files from `_templates/python/`

3.  **Define Dependencies**:
    Create a `requirements.txt` file listing all Python libraries required by the script.
    
    To generate this file cleanly, it is recommended to work in a virtual environment:
    ```bash
    # Create a virtual environment (this folder is ignored by git)
    python3 -m venv venv
    
    # Activate it
    source venv/bin/activate
    
    # Install your packages
    pip install requests pandas azure-identity
    
    # Freeze dependencies to file
    pip freeze > requirements.txt
    ```
    
    Example content:
    ```text
    requests==2.31.0
    pandas==2.2.0
    azure-identity==1.15.0
    ```

4.  **Customize `job.config.yaml`**:
    *   **name**: Unique name for the job (e.g., `my-report-job`).
    *   **schedule**: Cron expression (e.g., `"0 9 * * *"`).
    *   **env_keys**: List of secrets/variables required by the script (see below).

5.  **Push to GitLab**: 
    The CI/CD pipeline will automatically detect the new folder, build the Docker image, and deploy the scheduled job to Azure.

---

## 🔐 Required GitLab CI/CD Variables

### **Framework Variables** (Required for deployment)
These must be set in **Settings > CI/CD > Variables**:

| Variable | Description | Example |
| :--- | :--- | :--- |
| `AZURE_RESOURCE_GROUP` | Azure Resource Group for Container Apps | `rg-automation-framework` |
| `AZURE_CONTAINER_APP_ENV` | Container App Environment name | `aca-env-automation` |
| `ACR_NAME` | Azure Container Registry name (alphanumeric only, no dashes) | `myautomationacr` |
| `ACR_LOGIN_SERVER` | ACR login server URL (format: `<acr-name>.azurecr.io`) | `myautomationacr.azurecr.io` |
| `AZURE_JOB_IDENTITY_ID` | Resource ID of the User Assigned Identity for jobs | `/subscriptions/.../userAssignedIdentities/id-automation-jobs` |

**How to find ACR_LOGIN_SERVER:**
1. Go to Azure Portal > Container registries > Target registry
2. In the Overview page, copy the **Login server** value
3. It will be in the format: `<registry-name>.azurecr.io`

### **Script-Specific Variables**
Add any secrets required by scripts (e.g., `SLACK_WEBHOOK_URL`, `API_KEY`, etc.).

---

## 🔐 Handling Secrets in Scripts

Secrets must **NOT** be placed in code or `job.config.yaml`.

1.  **Define the Variable in GitLab**:
    Go to **Settings > CI/CD > Variables** and add the secret (e.g., `MY_API_KEY`).

2.  **Reference in `job.config.yaml`**:
    Add the key to the `env_keys` list:
    ```yaml
    env_keys:
      - MY_API_KEY
    ```

3.  **Usage in Code**:
    *   Python: `os.environ.get("MY_API_KEY")`

---

## 🛠️ Configuration Reference

### `job.config.yaml`

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | ✅ | Unique identifier for the job in Azure. |
| `schedule` | ✅ | Cron expression (e.g., `"*/5 * * * *"`). |
| `env_keys` | ❌ | List of GitLab CI variables to inject. |
| `cpu` | ❌ | CPU cores (default: 0.5). |
| `memory` | ❌ | Memory limit (default: 1.0Gi). |
| `command` | ❌ | Override the container's start command. |

---

## 🏗️ Architecture

*   **Generator Pipeline**: The main `.gitlab-ci.yml` scans this directory for any folder containing a `job.config.yaml`.
*   **Dynamic Child Pipeline**: A pipeline is generated on-the-fly to deploy each job independently.
*   **Infrastructure**: Uses Azure Container Apps Jobs (Serverless).
*   **Authentication**: The GitLab Runner uses its System Assigned Managed Identity to authenticate with Azure (no credentials needed in CI variables).

---

## 🚀 How the Pipeline Works

1.  **Detect Changes**: When code is pushed to a folder with `job.config.yaml`, the pipeline detects it.
2.  **Generate Child Pipeline**: A dynamic pipeline is created with a deployment job for each detected script.
3.  **Build & Push**: The Docker image is built and pushed to Azure Container Registry.
4.  **Deploy Job**: The `deploy_job.py` script creates or updates the Azure Container App Job with the new image and schedule.
5.  **Execution**: All jobs run on the configured GitLab Runner.
