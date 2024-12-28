# Base image for a development container
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Quarto
RUN curl -fsSL https://github.com/quarto-dev/quarto-cli/releases/download/v1.2.313/quarto-1.2.313-linux-amd64.tar.gz | tar -xz -C /opt \
    && ln -s /opt/quarto-1.2.313/bin/quarto /usr/local/bin/quarto

# Set up the working environment
WORKDIR /workspace

# Copy the entire repository
COPY . .

# Create and activate a virtual environment, then install Python dependencies
RUN python -m venv venv \
    && . venv/bin/activate \
    && pip install --no-cache-dir -r requirements.txt

# Set default shell
SHELL ["/bin/bash", "-c"]

# Default entrypoint
CMD ["bash"]
