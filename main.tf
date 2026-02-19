module "vpc" {
  source = "./modules/vpc"

  cluster_name                = var.cluster_name
  vpc_cidr                   = var.vpc_cidr
  vpc_instance_tenancy       = var.vpc_instance_tenancy
  vpc_az1                    = var.vpc_az1
  vpc_az2                    = var.vpc_az2
  vpc_public_subnet1_cidr    = var.vpc_public_subnet1_cidr
  vpc_public_subnet2_cidr    = var.vpc_public_subnet2_cidr
  vpc_private_subnet1_cidr   = var.vpc_private_subnet1_cidr
  vpc_private_subnet2_cidr   = var.vpc_private_subnet2_cidr
  enable_nat_gateway         = var.enable_nat_gateway
  single_nat_gateway         = var.single_nat_gateway

  tags = local.tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name               = var.cluster_name
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = var.eks_subnet_type == "private" ? module.vpc.private_subnet_ids : module.vpc.public_subnet_ids
  ec2_key_name             = var.ec2_key_name
  eks_version              = var.eks_version
  ecr_image_tag_mutability = var.ecr_image_tag_mutability
  ecr_scan_on_push         = var.ecr_scan_on_push
  ecr_lifecycle_policy_count = var.ecr_lifecycle_policy_count

  tags = local.tags
}

module "database" {
  count  = var.enable_database ? 1 : 0
  source = "./modules/database"

  cluster_name                = var.cluster_name
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  vpc_private_subnet1_cidr   = var.vpc_private_subnet1_cidr
  vpc_private_subnet2_cidr   = var.vpc_private_subnet2_cidr
  db_engine                  = var.db_engine
  db_engine_version          = var.db_engine_version
  db_parameter_group_family  = var.db_parameter_group_family
  db_instance_class          = var.db_instance_class
  db_storage_type            = var.db_storage_type
  db_multi_az               = var.db_multi_az
  db_skip_final_snapshot    = var.db_skip_final_snapshot
  db_storage_size_in_gb     = var.db_storage_size_in_gb
  db_backup_retention_period = var.db_backup_retention_period
  db_backup_window          = var.db_backup_window
  db_maintenance_window     = var.db_maintenance_window
  db_monitoring_interval    = var.db_monitoring_interval
  db_deletion_protection    = var.db_deletion_protection

  tags = local.tags
}

module "bastion" {
  count  = var.enable_bastion ? 1 : 0
  source = "./modules/bastion"

  cluster_name         = var.cluster_name
  vpc_id              = module.vpc.vpc_id
  public_subnet_id    = module.vpc.public_subnet_ids[0]
  ec2_key_name        = var.ec2_key_name
  bastion_instance_type = var.bastion_instance_type

  tags = local.tags
}