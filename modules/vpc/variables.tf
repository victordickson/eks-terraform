variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "vpc_instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "vpc_az1" {
  description = "Availability Zone 1"
  type        = string
}

variable "vpc_az2" {
  description = "Availability Zone 2"
  type        = string
}

variable "vpc_public_subnet1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
}

variable "vpc_public_subnet2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
}

variable "vpc_private_subnet1_cidr" {
  description = "CIDR block for private subnet 1"
  type        = string
}

variable "vpc_private_subnet2_cidr" {
  description = "CIDR block for private subnet 2"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT gateways"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway for all private subnets (cost optimization)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
