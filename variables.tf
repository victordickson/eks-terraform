variable "cluster_name" {
  description = "The name to give to this environment. Will be used for naming various resources."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region to use"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "ec2_key_name" {
  description = "The name of the public key to inject to instances launched in the VPC"
  type        = string
}

variable "vpc_instance_tenancy" {
  description = "How are instances distributed across the underlying physical hardware"
  type        = string
  default     = "default"
}

variable "vpc_az1" {
  description = "The AZ where *-subnet1 will reside"
  type        = string
}

variable "vpc_az2" {
  description = "The AZ where *-subnet2 will reside"
  type        = string
}

variable "vpc_public_subnet1_cidr" {
  description = "The cidr block to use for public-subnet1"
  type        = string
}

variable "vpc_public_subnet2_cidr" {
  description = "The cidr block to use for public-subnet2"
  type        = string
}

variable "vpc_private_subnet1_cidr" {
  description = "The cidr block to use for private-subnet1"
  type        = string
}

variable "vpc_private_subnet2_cidr" {
  description = "The cidr block to use for private-subnet2"
  type        = string
}

variable "db_engine" {
  description = "The underlying database engine to use"
  type        = string
  default     = "postgres"
}

variable "db_instance_class" {
  description = "The instance type to use for the database instances"
  type        = string
  default     = "db.t3.micro"
}

variable "db_multi_az" {
  description = "Should the database be multi AZ or not?"
  type        = bool
  default     = true
}

variable "db_skip_final_snapshot" {
  description = "Should we skip snapshot creation just before deleting the DB?"
  type        = bool
  default     = false
}

variable "db_storage_size_in_gb" {
  description = "Size of the database in GB"
  type        = number
  default     = 20
}

variable "eks_subnet_type" {
  description = "Whether to deploy EKS in public or private subnets (public|private)"
  type        = string
  default     = "private"
  validation {
    condition     = contains(["public", "private"], var.eks_subnet_type)
    error_message = "eks_subnet_type must be either 'public' or 'private'."
  }
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT gateways (required for private subnets)"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway for all private subnets (cost optimization)"
  type        = bool
  default     = false
}

variable "enable_database" {
  description = "Whether to create RDS database"
  type        = bool
  default     = true
}

variable "enable_bastion" {
  description = "Whether to create a bastion host"
  type        = bool
  default     = true
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

# EKS Configuration
variable "eks_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "ecr_image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "ecr_lifecycle_policy_count" {
  description = "Number of images to keep in ECR repositories"
  type        = number
  default     = 30
}

# Database Configuration
variable "db_engine_version" {
  description = "The engine version to use"
  type        = string
  default     = "15.4"
}

variable "db_parameter_group_family" {
  description = "The DB parameter group family"
  type        = string
  default     = "postgres15"
}

variable "db_storage_type" {
  description = "One of standard (magnetic), gp2 (general purpose SSD), or io1 (provisioned IOPS SSD)"
  type        = string
  default     = "gp3"
}

variable "db_backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 7
}

variable "db_backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created"
  type        = string
  default     = "03:00-04:00"
}

variable "db_maintenance_window" {
  description = "The window to perform maintenance in"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "db_monitoring_interval" {
  description = "The interval for collecting enhanced monitoring metrics"
  type        = number
  default     = 60
}

variable "db_deletion_protection" {
  description = "If the DB instance should have deletion protection enabled"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}