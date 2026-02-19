# Makefile for EKS Terraform Infrastructure

.PHONY: help init-dev init-staging init-prod plan-dev plan-staging plan-prod apply-dev apply-staging apply-prod destroy-dev destroy-staging destroy-prod fmt validate clean

# Default environment
ENV ?= dev

help: ## Show this help message
	@echo 'Usage: make [target] [ENV=environment]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ''
	@echo 'Environments: dev, staging, prod'
	@echo 'Example: make plan ENV=staging'

# Initialization targets
init-dev: ## Initialize Terraform for dev environment
	./deploy.sh dev init

init-staging: ## Initialize Terraform for staging environment
	./deploy.sh staging init

init-prod: ## Initialize Terraform for prod environment
	./deploy.sh prod init

init: ## Initialize Terraform for specified environment (ENV=dev|staging|prod)
	./deploy.sh $(ENV) init

# Planning targets
plan-dev: ## Plan Terraform changes for dev environment
	./deploy.sh dev plan

plan-staging: ## Plan Terraform changes for staging environment
	./deploy.sh staging plan

plan-prod: ## Plan Terraform changes for prod environment
	./deploy.sh prod plan

plan: ## Plan Terraform changes for specified environment (ENV=dev|staging|prod)
	./deploy.sh $(ENV) plan

# Apply targets
apply-dev: ## Apply Terraform changes for dev environment
	./deploy.sh dev apply

apply-staging: ## Apply Terraform changes for staging environment
	./deploy.sh staging apply

apply-prod: ## Apply Terraform changes for prod environment
	./deploy.sh prod apply

apply: ## Apply Terraform changes for specified environment (ENV=dev|staging|prod)
	./deploy.sh $(ENV) apply

# Destroy targets
destroy-dev: ## Destroy dev environment infrastructure
	./deploy.sh dev destroy

destroy-staging: ## Destroy staging environment infrastructure
	./deploy.sh staging destroy

destroy-prod: ## Destroy prod environment infrastructure
	./deploy.sh prod destroy

destroy: ## Destroy infrastructure for specified environment (ENV=dev|staging|prod)
	./deploy.sh $(ENV) destroy

# Utility targets
fmt: ## Format Terraform files
	terraform fmt -recursive

validate: ## Validate Terraform configuration
	terraform validate

clean: ## Clean Terraform files
	rm -rf .terraform/
	rm -f *.tfplan
	rm -f *.tfstate*
	rm -f .terraform.lock.hcl

# Kubernetes targets
kubeconfig-dev: ## Update kubeconfig for dev cluster
	aws eks update-kubeconfig --region us-west-2 --name webapp-dev

kubeconfig-staging: ## Update kubeconfig for staging cluster
	aws eks update-kubeconfig --region us-west-2 --name webapp-staging

kubeconfig-prod: ## Update kubeconfig for prod cluster
	aws eks update-kubeconfig --region us-west-2 --name webapp-prod

# Output targets
outputs: ## Show Terraform outputs for specified environment
	terraform output

# Security targets
security-scan: ## Run security scan on Terraform files
	@command -v tfsec >/dev/null 2>&1 || { echo "tfsec not installed. Install with: brew install tfsec"; exit 1; }
	tfsec .

# Documentation targets
docs: ## Generate documentation
	@command -v terraform-docs >/dev/null 2>&1 || { echo "terraform-docs not installed. Install with: brew install terraform-docs"; exit 1; }
	terraform-docs markdown table --output-file README-modules.md modules/

# Cost estimation (requires infracost)
cost-dev: ## Estimate costs for dev environment
	@command -v infracost >/dev/null 2>&1 || { echo "infracost not installed. Visit: https://www.infracost.io/docs/"; exit 1; }
	infracost breakdown --path . --terraform-var-file dev.tfvars

cost-staging: ## Estimate costs for staging environment
	@command -v infracost >/dev/null 2>&1 || { echo "infracost not installed. Visit: https://www.infracost.io/docs/"; exit 1; }
	infracost breakdown --path . --terraform-var-file staging.tfvars

cost-prod: ## Estimate costs for prod environment
	@command -v infracost >/dev/null 2>&1 || { echo "infracost not installed. Visit: https://www.infracost.io/docs/"; exit 1; }
	infracost breakdown --path . --terraform-var-file prod.tfvars