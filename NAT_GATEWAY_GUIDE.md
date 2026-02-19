# NAT Gateway Configuration Quick Reference

## Overview

The VPC module now supports flexible NAT gateway configuration to balance cost and availability requirements across different environments.

## Configuration Variables

### `enable_nat_gateway`
- **Type**: boolean
- **Default**: true
- **Description**: Whether to create NAT gateways at all

### `single_nat_gateway`
- **Type**: boolean  
- **Default**: false
- **Description**: Use a single NAT gateway for all private subnets (cost optimization)

## Configuration Scenarios

### Scenario 1: Multi-AZ NAT Gateways (Production)

**Use Case**: High availability production environments

**Configuration**:
```hcl
enable_nat_gateway = true
single_nat_gateway = false
```

**Architecture**:
```
┌─────────────────────────────────────────────────────┐
│                      VPC                            │
│                                                     │
│  ┌──────────────┐              ┌──────────────┐   │
│  │   AZ-1       │              │   AZ-2       │   │
│  │              │              │              │   │
│  │  ┌────────┐  │              │  ┌────────┐  │   │
│  │  │ Public │  │              │  │ Public │  │   │
│  │  │Subnet 1│  │              │  │Subnet 2│  │   │
│  │  └───┬────┘  │              │  └───┬────┘  │   │
│  │      │       │              │      │       │   │
│  │  ┌───▼────┐  │              │  ┌───▼────┐  │   │
│  │  │  NAT   │  │              │  │  NAT   │  │   │
│  │  │  GW 1  │  │              │  │  GW 2  │  │   │
│  │  └───┬────┘  │              │  └───┬────┘  │   │
│  │      │       │              │      │       │   │
│  │  ┌───▼────┐  │              │  ┌───▼────┐  │   │
│  │  │Private │  │              │  │Private │  │   │
│  │  │Subnet 1│  │              │  │Subnet 2│  │   │
│  │  └────────┘  │              │  └────────┘  │   │
│  └──────────────┘              └──────────────┘   │
└─────────────────────────────────────────────────────┘
```

**Pros**:
- High availability - no single point of failure
- Each AZ has independent internet connectivity
- Better fault tolerance

**Cons**:
- Higher cost (~$65/month + data processing)
- More complex architecture

**Best For**: Production environments requiring high availability

---

### Scenario 2: Single NAT Gateway (Cost Optimized)

**Use Case**: Development, staging, or cost-sensitive environments

**Configuration**:
```hcl
enable_nat_gateway = true
single_nat_gateway = true
```

**Architecture**:
```
┌─────────────────────────────────────────────────────┐
│                      VPC                            │
│                                                     │
│  ┌──────────────┐              ┌──────────────┐   │
│  │   AZ-1       │              │   AZ-2       │   │
│  │              │              │              │   │
│  │  ┌────────┐  │              │  ┌────────┐  │   │
│  │  │ Public │  │              │  │ Public │  │   │
│  │  │Subnet 1│  │              │  │Subnet 2│  │   │
│  │  └───┬────┘  │              │  └────────┘  │   │
│  │      │       │              │              │   │
│  │  ┌───▼────┐  │              │              │   │
│  │  │  NAT   │  │              │              │   │
│  │  │  GW 1  │  │              │              │   │
│  │  └───┬────┘  │              │              │   │
│  │      │       │              │      │       │   │
│  │  ┌───▼────┐  │              │  ┌───▼────┐  │   │
│  │  │Private │  │              │  │Private │  │   │
│  │  │Subnet 1│  │              │  │Subnet 2│  │   │
│  │  └────────┘  │              │  └────────┘  │   │
│  │              │              │      ▲       │   │
│  │              │              │      │       │   │
│  │              └──────────────┼──────┘       │   │
│  │                             │              │   │
│  └──────────────┘              └──────────────┘   │
└─────────────────────────────────────────────────────┘
```

**Pros**:
- Lower cost (~$32.50/month + data processing)
- Simpler architecture
- ~50% cost savings on NAT gateway

**Cons**:
- Single point of failure
- If AZ-1 fails, both private subnets lose internet connectivity
- Cross-AZ data transfer charges for AZ-2 traffic

**Best For**: Development, staging, or non-critical environments

---

### Scenario 3: No NAT Gateway (Public Subnets)

**Use Case**: Development environments with public subnets

**Configuration**:
```hcl
enable_nat_gateway = false
eks_subnet_type = "public"
```

**Architecture**:
```
┌─────────────────────────────────────────────────────┐
│                      VPC                            │
│                                                     │
│  ┌──────────────┐              ┌──────────────┐   │
│  │   AZ-1       │              │   AZ-2       │   │
│  │              │              │              │   │
│  │  ┌────────┐  │              │  ┌────────┐  │   │
│  │  │ Public │  │              │  │ Public │  │   │
│  │  │Subnet 1│  │              │  │Subnet 2│  │   │
│  │  │        │  │              │  │        │  │   │
│  │  │  EKS   │  │              │  │  EKS   │  │   │
│  │  │ Nodes  │  │              │  │ Nodes  │  │   │
│  │  └────────┘  │              │  └────────┘  │   │
│  │      │       │              │      │       │   │
│  │      └───────┼──────────────┼──────┘       │   │
│  │              │              │              │   │
│  │              ▼              ▼              │   │
│  │         Internet Gateway                   │   │
│  └──────────────┘              └──────────────┘   │
└─────────────────────────────────────────────────────┘
```

**Pros**:
- Lowest cost (no NAT gateway charges)
- Direct internet connectivity
- Simpler architecture

**Cons**:
- EKS nodes have public IPs
- Less secure
- Not recommended for production

**Best For**: Development environments only

---

## Cost Comparison (us-west-2)

| Configuration | Monthly Cost | Data Processing | Use Case |
|--------------|--------------|-----------------|----------|
| Multi-AZ NAT | ~$65 | $0.045/GB × 2 | Production |
| Single NAT | ~$32.50 | $0.045/GB | Staging/Dev |
| No NAT | $0 | $0 | Dev only |

**Note**: Costs are approximate and based on us-west-2 pricing. Data processing charges apply to all data processed through NAT gateways.

## Environment Recommendations

### Development
```hcl
enable_nat_gateway = false
single_nat_gateway = true  # Not used
eks_subnet_type = "public"
```
**Rationale**: Minimize costs for development

### Staging
```hcl
enable_nat_gateway = true
single_nat_gateway = true
eks_subnet_type = "private"
```
**Rationale**: Balance cost and production-like environment

### Production
```hcl
enable_nat_gateway = true
single_nat_gateway = false
eks_subnet_type = "private"
```
**Rationale**: High availability and security

## Migration Examples

### From No NAT to Single NAT

**Before**:
```hcl
enable_nat_gateway = false
eks_subnet_type = "public"
```

**After**:
```hcl
enable_nat_gateway = true
single_nat_gateway = true
eks_subnet_type = "private"
```

**Impact**: 
- Adds ~$32.50/month
- Improves security (private subnets)
- Requires cluster recreation if changing subnet type

### From Single NAT to Multi-AZ NAT

**Before**:
```hcl
enable_nat_gateway = true
single_nat_gateway = true
```

**After**:
```hcl
enable_nat_gateway = true
single_nat_gateway = false
```

**Impact**:
- Adds ~$32.50/month
- Improves availability
- No cluster recreation needed
- Zero downtime migration

## Terraform Commands

### Plan Changes
```bash
terraform plan -var-file="prod.tfvars"
```

### Apply Changes
```bash
terraform apply -var-file="prod.tfvars"
```

### Verify NAT Gateway Configuration
```bash
# List NAT gateways
aws ec2 describe-nat-gateways --filter "Name=tag:Name,Values=webapp-prod-nat-gw-*"

# Check route tables
aws ec2 describe-route-tables --filters "Name=tag:Name,Values=webapp-prod-private-rt-*"
```

## Troubleshooting

### Issue: Private subnets can't reach internet

**Check**:
1. NAT gateway is created and available
2. Route table has route to NAT gateway
3. Security groups allow outbound traffic

**Commands**:
```bash
# Check NAT gateway status
aws ec2 describe-nat-gateways --nat-gateway-ids <nat-gw-id>

# Check route table
aws ec2 describe-route-tables --route-table-ids <rt-id>
```

### Issue: High NAT gateway costs

**Solution**: Consider switching to single NAT gateway for non-production:
```hcl
single_nat_gateway = true
```

### Issue: NAT gateway in wrong AZ

**Solution**: Destroy and recreate NAT gateways:
```bash
terraform destroy -target=module.vpc.aws_nat_gateway.nat_gw1
terraform destroy -target=module.vpc.aws_nat_gateway.nat_gw2
terraform apply -var-file="prod.tfvars"
```

## Best Practices

1. **Use Multi-AZ for Production**: Always use `single_nat_gateway = false` for production
2. **Cost Optimize Non-Prod**: Use `single_nat_gateway = true` for dev/staging
3. **Monitor Costs**: Set up AWS Cost Explorer alerts for NAT gateway costs
4. **Plan Maintenance**: Schedule NAT gateway changes during maintenance windows
5. **Test Failover**: Regularly test AZ failover scenarios in production

## Additional Resources

- [AWS NAT Gateway Pricing](https://aws.amazon.com/vpc/pricing/)
- [AWS NAT Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
- [VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
