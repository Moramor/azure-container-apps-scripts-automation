# Automated Jobs Framework - Infrastructure

This folder contains the core logic and templates used by the automated jobs framework. It should **not** be modified unless you are updating the deployment logic itself.

## Files

*   **`deploy_job.py`**: 
    A Python script executed during the CD pipeline. 
    1.  Reads the `job.config.yaml` of the target script.
    2.  Checks if the Azure Container App Job exists.
    3.  Creates or Updates the Job in Azure with the correct schedule, image, and environment variables.

*   **`ci_templates.yml`**:
    A shared GitLab CI template file.
    It defines `.deploy_aca_job_template`, which encapsulates the steps to:
    1.  Login to Azure & ACR.
    2.  Build the Docker image.
    3.  Push the image to the registry.
    4.  Run `deploy_job.py`.

## Usage

These files are referenced by the generator pipeline in `../.gitlab-ci.yml`. The generator dynamically creates a child pipeline that `includes` these templates.


