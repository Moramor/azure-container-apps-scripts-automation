import yaml
import os
import argparse
import subprocess
import sys
import time

def load_config(config_path):
    with open(config_path, 'r') as file:
        return yaml.safe_load(file)

def deploy_job(config_file, image_tag, resource_group, environment_name):
    config = load_config(config_file)
    
    job_name = config.get('name')
    schedule = config.get('schedule')
    cpu = config.get('cpu', '0.5')
    memory = config.get('memory', '1.0Gi')
    env_keys = config.get('env_keys', [])
    command = config.get('command', [])
    
    # Get registry server from environment variable
    registry_server = os.environ.get('ACR_LOGIN_SERVER')
    
    # Get User Assigned Identity ID (Required)
    identity_id = os.environ.get('AZURE_JOB_IDENTITY_ID')
    
    if not identity_id:
        print("Error: AZURE_JOB_IDENTITY_ID environment variable is required")
        sys.exit(1)
    
    if not job_name or not schedule:
        print("Error: 'name' and 'schedule' are required in job.config.yaml")
        sys.exit(1)

    print(f"Deploying Job: {job_name}")
    
    # 1. Check if job exists and DELETE it to ensure clean state
    # This avoids complexity with 'update' command arguments differing from 'create'
    check_cmd = f"az containerapp job show --name {job_name} --resource-group {resource_group}"
    job_exists = subprocess.call(check_cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) == 0
    
    if job_exists:
        print(f"Job {job_name} exists. Deleting to ensure clean update...")
        delete_cmd = f"az containerapp job delete --name {job_name} --resource-group {resource_group} --yes"
        subprocess.run(delete_cmd, shell=True, check=True)
        # Give Azure a moment to process the deletion
        time.sleep(5)

    # 2. Create the Job
    az_cmd = [
        "az", "containerapp", "job", "create",
        "--name", job_name,
        "--resource-group", resource_group,
        "--environment", environment_name,
        "--image", image_tag,
        "--cpu", str(cpu),
        "--memory", str(memory),
        "--cron-expression", schedule,
        "--replica-timeout", "1800",
        "--trigger-type", "Schedule",
        "--parallelism", "1",
        "--replica-completion-count", "1",
        "--replica-retry-limit", "0",
        "--mi-user-assigned", identity_id
    ]
    
    # Add registry configuration
    if registry_server:
        az_cmd.extend(["--registry-server", registry_server])
        az_cmd.extend(["--registry-identity", identity_id])

    # Command override
    if command:
        az_cmd.extend(["--command", command[0]])
        if len(command) > 1:
            az_cmd.append("--args")
            az_cmd.extend(command[1:])

    # Environment variables
    if env_keys:
        env_vars = []
        for key in env_keys:
            val = os.environ.get(key)
            if val:
                env_vars.append(f"{key}={val}")
            else:
                print(f"Warning: {key} not found in environment")
        
        if env_vars:
            az_cmd.append("--env-vars")
            az_cmd.extend(env_vars)
            
    # Remove --registry-identity system from the update command if it's already set to avoid potential conflicts
    # or keep it to ensure it's enforced. We will keep it.
    
    print(f"Executing deployment for {job_name}...")
    # print(f"DEBUG: {' '.join(az_cmd)}") # Uncomment for debug
    
    result = subprocess.run(az_cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        print("Deployment Failed!")
        print(result.stderr)
        sys.exit(1)
    
    print("Deployment Successful!")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", required=True, help="Path to job.config.yaml")
    parser.add_argument("--image", required=True, help="Full image tag")
    parser.add_argument("--resource-group", required=True)
    parser.add_argument("--environment", required=True, help="Container App Environment Name")
    
    args = parser.parse_args()
    
    deploy_job(args.config, args.image, args.resource_group, args.environment)
