# Development Environment Configuration
cluster_name = "webapp-dev"
environment  = "dev"
aws_region   = "us-west-2"

# EC2 Key Pair
ec2_key_name = "my-dev-key"

# VPC Configuration
vpc_cidr                 = "10.1.0.0/16"
vpc_az1                  = "us-west-2a"
vpc_az2                  = "us-west-2b"
vpc_public_subnet1_cidr  = "10.1.1.0/24"
vpc_public_subnet2_cidr  = "10.1.2.0/24"
vpc_private_subnet1_cidr = "10.1.10.0/24"
vpc_private_subnet2_cidr = "10.1.20.0/24"

# EKS Configuration
eks_version            = "1.28"

# Database Configuration
db_engine                = "postgres"
db_engine_version        = "15.4"
db_instance_class        = "db.t3.micro"
db_multi_az             = false
db_skip_final_snapshot  = true
db_storage_size_in_gb   = 20
db_backup_retention_period = 1
db_deletion_protection  = false

# Network Configuration
eks_subnet_type = "public"
enable_nat_gateway = false
single_nat_gateway = true  # Not applicable when NAT gateway is disabled

# Optional Components
enable_database = false
enable_bastion = false

# Additional Tags
tags = {
  CostCenter = "development"
  Owner      = "dev-team"
}