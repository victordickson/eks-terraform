# Production Environment Configuration
cluster_name = "webapp-prod"
environment  = "prod"
aws_region   = "us-west-2"

# EC2 Key Pair
ec2_key_name = "my-prod-key"

# VPC Configuration
vpc_cidr                 = "10.3.0.0/16"
vpc_az1                  = "us-west-2a"
vpc_az2                  = "us-west-2b"
vpc_public_subnet1_cidr  = "10.3.1.0/24"
vpc_public_subnet2_cidr  = "10.3.2.0/24"
vpc_private_subnet1_cidr = "10.3.10.0/24"
vpc_private_subnet2_cidr = "10.3.20.0/24"

# EKS Configuration
eks_version            = "1.28"
ecr_image_tag_mutability = "IMMUTABLE"
ecr_lifecycle_policy_count = 50

# Database Configuration
db_engine                = "postgres"
db_engine_version        = "15.4"
db_instance_class        = "db.r6g.large"
db_multi_az             = true
db_skip_final_snapshot  = false
db_storage_size_in_gb   = 100
db_backup_retention_period = 30
db_deletion_protection  = true

# Network Configuration
eks_subnet_type = "private"
enable_nat_gateway = true
single_nat_gateway = false  # Set to true for single NAT gateway (cost optimization)

# Optional Components
enable_database = true
enable_bastion = true
bastion_instance_type = "t3.small"

# Additional Tags
tags = {
  CostCenter = "production"
  Owner      = "ops-team"
  Backup     = "required"
}