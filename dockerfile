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
