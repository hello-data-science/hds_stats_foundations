# Base image for a development container
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \ 
    gdebi-core \ 
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set architecture-specific Quarto URL
# This runs at build time to determine the architecture and download the correct Quarto package.
RUN ARCH=$(uname -m) && \
    if [ "$(uname -m)" = "x86_64" ]; then \
        ARCH="amd64"; \
        elif [ "$(uname -m)" = "arm64" ] || [ "$(uname -m)" = "aarch64" ]; then \
        ARCH="arm64"; \
    else \
        echo "Unsupported architecture"; exit 1; \
    fi && \
    curl -fsSL https://github.com/quarto-dev/quarto-cli/releases/download/v1.7.6/quarto-1.7.6-linux-${ARCH}.tar.gz | tar -xz -C /opt \
    && ln -s /opt/quarto-1.7.6/bin/quarto /usr/local/bin/quarto

# Verify Quarto installation
RUN quarto --version

# Define an argument for the working directory
ARG WORKDIR=/workspaces/hds_stats_foundations

# Set up the working environment
WORKDIR $WORKDIR

# Copy the entire repository
COPY . .

# Remove any existing virtual environment and create a new one, then install Python dependencies
RUN rm -rf venv \
    && python -m venv venv \
    && . venv/bin/activate \
    && pip install --no-cache-dir -r requirements.txt

# Set environment variables for venv
ENV VIRTUAL_ENV=$WORKDIR/venv
ENV PATH="$WORKDIR/venv/bin:$PATH"

# Add venv activation to .bashrc for interactive shells
RUN echo ". $WORKDIR/venv/bin/activate" >> /root/.bashrc

# Set default shell
SHELL ["/bin/bash", "-c"]

# Default entrypoint
CMD ["bash", "--login"]
