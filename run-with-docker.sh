#!/bin/bash
set -e

# Kubernetes Node Security Hardening - Docker Ansible Runner
# This script runs the Ansible playbook in a Docker container

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output formatting
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
DOCKER_IMAGE="willhallonline/ansible:latest"
DOCKER_WORKING_DIR="/ansible"
ANSIBLE_ARGS=""

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -h|--help)
      echo "Usage: $0 [ansible-playbook options]"
      echo ""
      echo "This script runs the Ansible playbook in a Docker container."
      echo "All arguments are passed directly to ansible-playbook."
      echo ""
      echo "Example:"
      echo "  $0 --private-key ~/.ssh/id_ed25519 --tags ssh,firewall"
      exit 0
      ;;
    *)
      ANSIBLE_ARGS="$ANSIBLE_ARGS $1"
      shift
      ;;
  esac
done

echo -e "${BLUE}Kubernetes Node Security Hardening via Docker${NC}"
echo -e "${BLUE}==========================================${NC}"
echo -e "${YELLOW}Working directory:${NC} $SCRIPT_DIR"
echo -e "${YELLOW}Docker image:${NC} $DOCKER_IMAGE"
echo -e "${YELLOW}Ansible args:${NC} $ANSIBLE_ARGS"
echo ""

# Create a temporary directory for SSH control paths
SSH_CONTROL_DIR=$(mktemp -d)
echo -e "${YELLOW}Creating SSH control directory:${NC} $SSH_CONTROL_DIR"
chmod 777 $SSH_CONTROL_DIR

# Construct the Docker run command
DOCKER_CMD="docker run --rm -v $SCRIPT_DIR:/ansible -v $SSH_CONTROL_DIR:/tmp"

# Mount SSH keys if needed
if [[ "$ANSIBLE_ARGS" == *"--private-key"* ]] || [[ "$ANSIBLE_ARGS" == *"-k"* ]]; then
  # Mount SSH keys as read-only
  DOCKER_CMD="$DOCKER_CMD -v $HOME/.ssh:/root/.ssh:ro"
  echo -e "${YELLOW}Mounting SSH keys from:${NC} $HOME/.ssh"
fi

# Add working directory and image
DOCKER_CMD="$DOCKER_CMD -w $DOCKER_WORKING_DIR $DOCKER_IMAGE"

# Add the ansible-playbook command with playbook and args
DOCKER_CMD="$DOCKER_CMD ansible-playbook k8s-security.yml -e 'ansible_ssh_control_path_dir=/tmp' $ANSIBLE_ARGS"

# Display the full command
echo -e "${YELLOW}Running command:${NC}"
echo "$DOCKER_CMD"
echo ""

# Execute the command
eval $DOCKER_CMD
EXIT_CODE=$?

# Cleanup the temporary directory
rm -rf $SSH_CONTROL_DIR

# Check execution result
if [ $EXIT_CODE -eq 0 ]; then
  echo ""
  echo -e "${GREEN}Security hardening playbook execution completed successfully!${NC}"
else
  echo ""
  echo -e "${YELLOW}Security hardening playbook execution had issues. Please check the output above.${NC}"
  exit 1
fi 