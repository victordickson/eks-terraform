# Staging Environment Configuration
cluster_name = "webapp-staging"
environment  = "staging"
aws_region   = "us-west-2"

# EC2 Key Pair
ec2_key_name = "my-staging-key"

# VPC Configuration
vpc_cidr                 = "10.2.0.0/16"
vpc_az1                  = "us-west-2a"
vpc_az2                  = "us-west-2b"
vpc_public_subnet1_cidr  = "10.2.1.0/24"
vpc_public_subnet2_cidr  = "10.2.2.0/24"
vpc_private_subnet1_cidr = "10.2.10.0/24"
vpc_private_subnet2_cidr = "10.2.20.0/24"

# EKS Configuration
eks_version            = "1.28"

# Database Configuration
db_engine                = "postgres"
db_engine_version        = "15.4"
db_instance_class        = "db.t3.small"
db_multi_az             = true
db_skip_final_snapshot  = false
db_storage_size_in_gb   = 50
db_backup_retention_period = 7
db_deletion_protection  = false

# Network Configuration
eks_subnet_type = "private"
enable_nat_gateway = false
single_nat_gateway = true  # Use single NAT gateway for cost optimization

# Optional Components
enable_database = false
enable_bastion = false
bastion_instance_type = "t3.small"

# Additional Tags
tags = {
  CostCenter = "staging"
  Owner      = "qa-team"
}