output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "vpc_id" {
  description = "ID of the VPC where the cluster is deployed"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "database_endpoint" {
  description = "RDS instance endpoint"
  value       = var.enable_database ? module.database[0].db_endpoint : null
  sensitive   = true
}

output "database_port" {
  description = "RDS instance port"
  value       = var.enable_database ? module.database[0].db_port : null
}

output "bastion_public_ip" {
  description = "Public IP of bastion host"
  value       = var.enable_bastion ? module.bastion[0].public_ip : null
}

output "ecr_frontend_repository_url" {
  description = "URL of the ECR repository for frontend"
  value       = module.eks.ecr_frontend_repository_url
}

output "ecr_api_repository_url" {
  description = "URL of the ECR repository for API"
  value       = module.eks.ecr_api_repository_url
}

output "cert_manager_role_arn" {
  description = "ARN of the cert-manager IAM role"
  value       = module.eks.cert_manager_role_arn
}