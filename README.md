# EKS Terraform Modular Infrastructure

This repository contains a modularized Terraform configuration for deploying Amazon EKS Auto Mode clusters across multiple environments (dev, staging, prod).

## Architecture

The infrastructure is organized into reusable modules:

- **VPC Module**: Creates VPC, subnets, NAT gateways (with single/multi-AZ options), and routing
- **EKS Module**: Deploys EKS Auto Mode cluster with automatic compute and storage management, plus ECR repositories
- **Database Module**: Sets up RDS PostgreSQL with proper security groups
- **Bastion Module**: Creates a bastion host for secure cluster access

## What is EKS Auto Mode?

EKS Auto Mode is a fully managed compute option that automatically provisions and manages:
- **Compute**: Nodes scale automatically based on pod requirements
- **Storage**: EBS volumes are automatically provisioned and managed
- **Networking**: Load balancers and networking are configured automatically

Benefits:
- No manual node group management
- Automatic scaling and right-sizing
- Reduced operational overhead
- Pay only for resources used by pods

## Directory Structure

```
eks-terraform-modular/
├── main.tf                    # Root module configuration
├── variables.tf               # Root module variables
├── outputs.tf                 # Root module outputs
├── providers.tf               # Provider configuration
├── locals.tf                  # Local values and data sources
├── dev.tfvars                 # Development environment variables
├── staging.tfvars             # Staging environment variables
├── prod.tfvars                # Production environment variables
├── backend.hcl.template       # Backend configuration template
├── deploy.sh                  # Deployment script
├── README.md                  # This file
├── MIGRATION_GUIDE.md         # EKS Auto Mode migration guide
└── modules/
    ├── vpc/                   # VPC module
    ├── eks/                   # EKS Auto Mode module
    ├── database/              # Database module
    └── bastion/               # Bastion module
```

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **kubectl** for cluster management
4. **AWS IAM permissions** for EKS, VPC, RDS, and EC2 resources

## Required AWS Resources

Before deploying, ensure you have:

1. **EC2 Key Pairs** created for each environment
2. **AWS Secrets Manager** secrets for database credentials:
   ```bash
   aws secretsmanager create-secret \
     --name "webapp-dev-db-creds" \
     --description "Database credentials for dev environment" \
     --secret-string '{"db_user":"admin","db_pass":"your-secure-password"}'
   ```

3. **S3 bucket** for Terraform state (optional but recommended)
4. **DynamoDB table** for state locking (optional but recommended)

## Environment Configuration

### Development (dev.tfvars)
- Public subnets for cost optimization
- No NAT gateways
- Minimal resources
- Database and bastion disabled

### Staging (staging.tfvars)
- Private subnets
- Single NAT gateway option for cost optimization
- Production-like configuration
- Optional database and bastion

### Production (prod.tfvars)
- Private subnets
- Multi-AZ NAT gateways (configurable)
- High-performance configuration
- Multi-AZ RDS with backups
- Additional monitoring and security

## NAT Gateway Configuration

The VPC module supports flexible NAT gateway configuration:

### Multi-AZ NAT Gateways (High Availability)
```hcl
enable_nat_gateway = true
single_nat_gateway = false
```
- Creates 2 NAT gateways (one per AZ)
- Higher availability, higher cost (~$65/month)

### Single NAT Gateway (Cost Optimization)
```hcl
enable_nat_gateway = true
single_nat_gateway = true
```
- Creates 1 NAT gateway
- Lower cost (~$32.50/month), single point of failure

### No NAT Gateway
```hcl
enable_nat_gateway = false
```
- Use with public subnets only
- Lowest cost

## Deployment

### Option 1: Using the deployment script (Recommended)

```bash
# Initialize Terraform
./deploy.sh dev init

# Plan deployment
./deploy.sh dev plan

# Apply changes
./deploy.sh dev apply

# Destroy infrastructure (when needed)
./deploy.sh dev destroy
```

### Option 2: Manual Terraform commands

```bash
# Initialize
terraform init

# Plan for specific environment
terraform plan -var-file="dev.tfvars" -out="dev.tfplan"

# Apply
terraform apply "dev.tfplan"

# Or apply directly
terraform apply -var-file="dev.tfvars"
```

## Backend Configuration

For production use, configure remote state storage:

1. Copy `backend.hcl.template` to `backend-{env}.hcl`
2. Update the S3 bucket and DynamoDB table names
3. Initialize with backend config:
   ```bash
   terraform init -backend-config="backend-dev.hcl"
   ```

## Post-Deployment

### Configure kubectl

```bash
aws eks update-kubeconfig --region us-west-2 --name webapp-dev
```

### Verify Auto Mode Cluster

```bash
# Check cluster status
kubectl get nodes

# View Auto Mode configuration
aws eks describe-cluster --name webapp-dev --region us-west-2 --query 'cluster.computeConfig'
```

### Deploy Workloads

With EKS Auto Mode, simply deploy your pods - nodes will be automatically provisioned:

```bash
kubectl apply -f your-deployment.yaml
```

Auto Mode will:
- Automatically provision nodes based on pod requirements
- Scale nodes up/down as needed
- Manage storage volumes automatically

## EKS Auto Mode Features

1. **Automatic Compute Management**:
   - Nodes provisioned automatically based on pod requirements
   - No need to manage node groups or scaling policies
   - Automatic node upgrades and patching

2. **Integrated Storage**:
   - EBS volumes automatically provisioned for persistent volumes
   - No need to install CSI drivers
   - Automatic volume lifecycle management

3. **Built-in Networking**:
   - Load balancers automatically configured
   - No need to install AWS Load Balancer Controller
   - Automatic network policy enforcement

4. **Cost Optimization**:
   - Pay only for resources used by pods
   - Automatic right-sizing of nodes
   - No over-provisioning

## Security Best Practices

1. **Network Security**:
   - Private subnets for EKS nodes and RDS
   - Security groups with minimal required access
   - NAT gateways for outbound internet access

2. **Encryption**:
   - EBS volumes encrypted (Auto Mode default)
   - RDS storage encrypted
   - ECR repositories with encryption

3. **Access Control**:
   - IAM roles with least privilege
   - Bastion host for secure access
   - Private EKS endpoint option available

4. **Monitoring**:
   - CloudWatch logs enabled for EKS
   - RDS enhanced monitoring
   - ECR image scanning

## Customization

### Adding new environments

1. Create new `.tfvars` file (e.g., `test.tfvars`)
2. Update `deploy.sh` script to include new environment
3. Create corresponding backend configuration

### Modifying resources

- Update module variables in respective `variables.tf` files
- Modify resource configurations in module `main.tf` files
- Add new outputs in module `outputs.tf` files

## Troubleshooting

### Common Issues

1. **IAM Permissions**: Ensure your AWS credentials have sufficient permissions for Auto Mode
2. **Key Pairs**: Verify EC2 key pairs exist in the target region
3. **Secrets Manager**: Ensure database credential secrets are created
4. **Resource Limits**: Check AWS service limits for your account
5. **Auto Mode Availability**: Ensure Auto Mode is available in your region

### Useful Commands

```bash
# Check EKS cluster status
aws eks describe-cluster --name webapp-dev --region us-west-2

# View Auto Mode configuration
aws eks describe-cluster --name webapp-dev --region us-west-2 --query 'cluster.computeConfig'

# Get cluster endpoint
terraform output cluster_endpoint

# Get ECR login command
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $(terraform output -raw ecr_frontend_repository_url)

# View Auto Mode nodes
kubectl get nodes -o wide
```

## Cost Optimization

- Use single NAT gateway for non-production environments
- EKS Auto Mode automatically optimizes compute costs
- Set up resource quotas and limits
- Monitor costs with AWS Cost Explorer
- Consider using Fargate for certain workloads

## Migration from Managed Node Groups

If you're migrating from standard EKS with managed node groups to Auto Mode, see [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) for detailed instructions.

## Contributing

1. Follow Terraform best practices
2. Update documentation for any changes
3. Test changes in development environment first
4. Use consistent naming conventions
5. Add appropriate tags to all resources

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) for Auto Mode specifics
3. Review AWS EKS Auto Mode documentation: https://docs.aws.amazon.com/eks/latest/userguide/automode.html
4. Consult Terraform AWS provider documentation

## Additional Resources

- [AWS EKS Auto Mode Documentation](https://docs.aws.amazon.com/eks/latest/userguide/automode.html)
- [Terraform AWS Provider - EKS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster)
- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
