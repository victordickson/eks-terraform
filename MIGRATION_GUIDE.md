# EKS Auto Mode Migration Guide

## Overview

This guide documents the migration from standard EKS with managed node groups to **EKS Auto Mode** and the addition of flexible NAT gateway configuration.

## Changes Made

### 1. EKS Auto Mode Conversion

EKS Auto Mode automatically manages compute, storage, and networking for your Kubernetes clusters. The following changes were implemented:

#### Removed Components
- Manual node groups (aws_eks_node_group)
- Launch templates
- Node security groups
- AMI data sources
- Node-specific variables (k8s_desired_size, k8s_min_size, k8s_max_size, k8s_node_instance_types, node_volume_size, node_volume_type)

#### Added Components
- **compute_config** block in EKS cluster with:
  - `enabled = true` - Enables Auto Mode
  - `node_pools = ["general-purpose", "system"]` - Auto-managed node pools
  - `node_role_arn` - IAM role for Auto Mode nodes

- **storage_config** block with:
  - Block storage enabled for automatic EBS management

#### Updated IAM Policies
Added required Auto Mode policies to node IAM role:
- AmazonEKSVPCResourceController
- AmazonEKSBlockStoragePolicy
- AmazonEKSComputePolicy
- AmazonEKSLoadBalancingPolicy
- AmazonEKSNetworkingPolicy

Updated assume role policy to include both `ec2.amazonaws.com` and `eks.amazonaws.com` services.

### 2. NAT Gateway Configuration

Added flexible NAT gateway configuration for cost optimization:

#### New Variable: `single_nat_gateway`
- **Type**: boolean
- **Default**: false
- **Purpose**: Control whether to use a single NAT gateway (cost optimization) or multi-AZ NAT gateways (high availability)

#### Configuration Options

**Multi-AZ NAT Gateways (Production - High Availability)**
```hcl
enable_nat_gateway = true
single_nat_gateway = false
```
- Creates 2 NAT gateways (one per AZ)
- Each private subnet routes through its own NAT gateway
- Higher cost but better availability

**Single NAT Gateway (Cost Optimization)**
```hcl
enable_nat_gateway = true
single_nat_gateway = true
```
- Creates 1 NAT gateway in first AZ
- Both private subnets route through the same NAT gateway
- Lower cost but single point of failure

**No NAT Gateway (Public Subnets)**
```hcl
enable_nat_gateway = false
single_nat_gateway = true  # Value doesn't matter
```
- No NAT gateways created
- Use with public subnets only

## Benefits of EKS Auto Mode

1. **Simplified Management**: No need to manage node groups, scaling, or AMI updates
2. **Automatic Scaling**: Nodes scale automatically based on pod requirements
3. **Cost Optimization**: Only pay for resources actually used by pods
4. **Integrated Storage**: Automatic EBS volume management
5. **Built-in Networking**: Automatic load balancer and networking configuration
6. **Reduced Operational Overhead**: AWS manages node lifecycle, patching, and updates

## Environment Configurations

### Development (dev.tfvars)
- NAT Gateway: Disabled (using public subnets)
- Cost: Minimal

### Staging (staging.tfvars)
- NAT Gateway: Disabled (can be enabled with single_nat_gateway = true)
- Cost: Low

### Production (prod.tfvars)
- NAT Gateway: Enabled with multi-AZ option
- `single_nat_gateway = false` for high availability
- Can be set to `true` for cost savings if single point of failure is acceptable

## Migration Steps

1. **Backup Current State**
   ```bash
   terraform state pull > terraform.tfstate.backup
   ```

2. **Review Changes**
   ```bash
   terraform plan -var-file="prod.tfvars"
   ```

3. **Apply Changes**
   ```bash
   terraform apply -var-file="prod.tfvars"
   ```

   **Note**: This will destroy existing node groups and create a new Auto Mode cluster. Plan for downtime or use blue-green deployment.

4. **Verify Cluster**
   ```bash
   aws eks update-kubeconfig --region us-west-2 --name webapp-prod
   kubectl get nodes
   ```

## Cost Comparison

### NAT Gateway Costs (us-west-2)
- **Multi-AZ (2 NAT Gateways)**:
  - Fixed: ~$65/month ($0.045/hour × 2 × 730 hours)
  - Data processing: $0.045/GB × 2
  
- **Single NAT Gateway**:
  - Fixed: ~$32.50/month ($0.045/hour × 730 hours)
  - Data processing: $0.045/GB
  
- **Savings**: ~50% on NAT gateway fixed costs with single NAT gateway

### EKS Auto Mode
- No additional cost for Auto Mode itself
- Pay only for EC2 instances, EBS volumes, and data transfer
- Potential savings from better resource utilization

## Important Notes

1. **Breaking Change**: Migrating to Auto Mode will recreate the EKS cluster
2. **Workload Migration**: Plan to migrate workloads during maintenance window
3. **State Management**: Ensure Terraform state is backed up before migration
4. **Testing**: Test in dev/staging environments first
5. **Monitoring**: Monitor costs and performance after migration

## Rollback Plan

If you need to rollback to managed node groups:
1. Restore Terraform state from backup
2. Revert code changes using git
3. Apply previous configuration

## Support

For issues or questions:
- Review AWS EKS Auto Mode documentation: https://docs.aws.amazon.com/eks/latest/userguide/automode.html
- Check Terraform AWS provider documentation
- Contact AWS Support for Auto Mode specific issues
