#!/bin/bash
set -e

# Kubernetes Node Security Hardening - Ansible Runner
# This script runs the Ansible playbook to apply security hardening to Kubernetes nodes

# Colors for output formatting
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
INVENTORY_PATH="inventory/hosts.ini"
PRIVATE_KEY=""
SSH_USER="root"
LIMIT=""
TAGS="all"
DEBUG=false
CHECK_MODE=false

# Display help message
usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -i, --inventory PATH      Path to inventory file (default: inventory/hosts.ini)"
  echo "  -k, --private-key PATH    Path to SSH private key"
  echo "  -u, --user USERNAME       SSH username (default: root)"
  echo "  -l, --limit PATTERN       Limit to specified hosts or group"
  echo "  -t, --tags TAGS           Only run tasks with these tags (default: all)"
  echo "  -c, --check               Run in check mode (dry run)"
  echo "  -d, --debug               Enable debug output"
  echo "  -h, --help                Display this help message"
  echo ""
  echo "Example:"
  echo "  $0 --private-key ~/.ssh/id_ed25519 --tags ssh,firewall"
  exit 1
}

# Parse command line arguments
parse_args() {
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -i|--inventory)
        INVENTORY_PATH="$2"
        shift 2
        ;;
      -k|--private-key)
        PRIVATE_KEY="$2"
        shift 2
        ;;
      -u|--user)
        SSH_USER="$2"
        shift 2
        ;;
      -l|--limit)
        LIMIT="$2"
        shift 2
        ;;
      -t|--tags)
        TAGS="$2"
        shift 2
        ;;
      -c|--check)
        CHECK_MODE=true
        shift
        ;;
      -d|--debug)
        DEBUG=true
        shift
        ;;
      -h|--help)
        usage
        ;;
      *)
        echo "Unknown parameter: $1"
        usage
        ;;
    esac
  done
}

# Main execution script
main() {
  parse_args "$@"
  
  echo -e "${BLUE}Kubernetes Node Security Hardening${NC}"
  echo -e "${BLUE}====================================${NC}"
  echo -e "${YELLOW}Inventory:${NC} $INVENTORY_PATH"
  echo -e "${YELLOW}SSH User:${NC} $SSH_USER"
  
  if [ -n "$PRIVATE_KEY" ]; then
    echo -e "${YELLOW}SSH Key:${NC} $PRIVATE_KEY"
  fi
  
  if [ -n "$LIMIT" ]; then
    echo -e "${YELLOW}Limiting to:${NC} $LIMIT"
  fi
  
  echo -e "${YELLOW}Running tags:${NC} $TAGS"
  
  if [ "$CHECK_MODE" = true ]; then
    echo -e "${YELLOW}Mode:${NC} Check (Dry Run)"
  else
    echo -e "${YELLOW}Mode:${NC} Apply"
  fi
  
  echo ""
  echo -e "${GREEN}Starting Ansible playbook execution...${NC}"
  echo ""
  
  # Build the ansible-playbook command
  ANSIBLE_CMD="ansible-playbook k8s-security.yml"
  
  # Add inventory
  ANSIBLE_CMD="$ANSIBLE_CMD -i $INVENTORY_PATH"
  
  # Add SSH user
  ANSIBLE_CMD="$ANSIBLE_CMD -u $SSH_USER"
  
  # Add private key if specified
  if [ -n "$PRIVATE_KEY" ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD --private-key=$PRIVATE_KEY"
  fi
  
  # Add limit if specified
  if [ -n "$LIMIT" ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD --limit=$LIMIT"
  fi
  
  # Add tags if specified
  if [ -n "$TAGS" ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD --tags=$TAGS"
  fi
  
  # Add check mode if enabled
  if [ "$CHECK_MODE" = true ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD --check"
  fi
  
  # Add debug mode if enabled
  if [ "$DEBUG" = true ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD -vvv"
  fi
  
  # Display the command
  echo -e "${YELLOW}Running command:${NC} $ANSIBLE_CMD"
  echo ""
  
  # Execute the command
  eval $ANSIBLE_CMD
  
  # Check execution result
  if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}Security hardening playbook execution completed successfully!${NC}"
  else
    echo ""
    echo -e "${YELLOW}Security hardening playbook execution had issues. Please check the output above.${NC}"
    exit 1
  fi
}

# Execute main with all arguments
main "$@" 