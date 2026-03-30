#!/bin/bash
# Script to run OverSIP tests in Docker

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="oversip-test"

echo "Building Docker image for OverSIP tests..."
docker build -f "$SCRIPT_DIR/Dockerfile.test" -t "$PROJECT_NAME" "$SCRIPT_DIR"

echo ""
echo "Running tests in Docker container..."
docker run --rm "$PROJECT_NAME" rake test

echo ""
echo "Tests completed successfully!"