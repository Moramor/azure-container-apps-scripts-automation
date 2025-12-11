# Use a lightweight Python base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# [OPTIONAL] Install system dependencies if needed
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     gcc \
#     && rm -rf /var/lib/apt/lists/*

# Copy requirements file first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# [OPTIONAL] Set default command (can be overridden in job.config.yaml)
CMD ["python", "main.py"]


