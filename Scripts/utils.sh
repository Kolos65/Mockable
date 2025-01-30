#!/bin/bash

# Function to determine the container runtime
get_container_runtime() {
    if command -v podman &> /dev/null; then
        echo "podman"
    elif command -v docker &> /dev/null; then
        echo "docker"
    else
        echo "Neither podman nor docker is installed. Please install one of them to proceed." >&2
        exit 1
    fi
}
