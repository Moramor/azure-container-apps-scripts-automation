# How to Remove an Automation Job

The automation framework **does not** automatically delete Azure resources when a folder is deleted from this repository. A manual cleanup step is required.

## Steps to Remove an Automation

### 1. Delete the Azure Container App Job
The job resource must be deleted from Azure to stop execution.

**Option A: Using Azure Portal**
1.  Go to the [Azure Portal](https://portal.azure.com). Or directly to container app jobs : https://portal.azure.com/#browse/Microsoft.App%2Fjobs
2.  Navigate to the Resource Group.
3.  Find the **Container App Job** resource.
4.  Click **Delete**.

**Option B: Using Azure CLI**
Run the following command (replace `<job-name>` with the name defined in `job.config.yaml`):

```bash
az login
az containerapp job delete \
  --name <job-name> \
  --resource-group <resource-group-name> \
  --yes
```

### 2. Remove the Code
Once the Azure resource is deleted, the project folder can be safely removed from this repository.

1.  Delete the folder (e.g., `automated_jobs_framework/my-automation`).
2.  Commit and push changes.

```bash
git rm -r automated_jobs_framework/my-automation
git commit -m "Remove my-automation"
git push
```

---

**Note:** If the code is deleted without deleting the Azure resource, the job will continue to run on its existing schedule indefinitely.
