#!/bin/bash

# EKS Terraform Deployment Script
# Usage: ./deploy.sh <environment> <action>
# Example: ./deploy.sh dev plan
# Example: ./deploy.sh prod apply

set -e

ENVIRONMENT=$1
ACTION=$2

if [ -z "$ENVIRONMENT" ] || [ -z "$ACTION" ]; then
    echo "Usage: $0 <environment> <action>"
    echo "Environments: dev, staging, prod"
    echo "Actions: init, plan, apply, destroy"
    exit 1
fi

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    echo "Error: Environment must be one of: dev, staging, prod"
    exit 1
fi

# Validate action
if [[ ! "$ACTION" =~ ^(init|plan|apply|destroy)$ ]]; then
    echo "Error: Action must be one of: init, plan, apply, destroy"
    exit 1
fi

echo "🚀 Running Terraform $ACTION for $ENVIRONMENT environment..."

# Set variables
TFVARS_FILE="${ENVIRONMENT}.tfvars"
BACKEND_CONFIG="backend-${ENVIRONMENT}.hcl"

# Check if required files exist
if [ ! -f "$TFVARS_FILE" ]; then
    echo "Error: $TFVARS_FILE not found"
    exit 1
fi

if [ "$ACTION" = "init" ] && [ ! -f "$BACKEND_CONFIG" ]; then
    echo "Warning: $BACKEND_CONFIG not found. Using local backend."
    BACKEND_CONFIG=""
fi

# Execute Terraform commands
case $ACTION in
    init)
        if [ -n "$BACKEND_CONFIG" ]; then
            terraform init -backend-config="$BACKEND_CONFIG"
        else
            terraform init
        fi
        ;;
    plan)
        terraform plan -var-file="$TFVARS_FILE" -out="${ENVIRONMENT}.tfplan"
        ;;
    apply)
        if [ -f "${ENVIRONMENT}.tfplan" ]; then
            terraform apply "${ENVIRONMENT}.tfplan"
        else
            terraform apply -var-file="$TFVARS_FILE" -auto-approve
        fi
        ;;
    destroy)
        terraform destroy -var-file="$TFVARS_FILE" -auto-approve
        ;;
esac

echo "✅ Terraform $ACTION completed for $ENVIRONMENT environment"