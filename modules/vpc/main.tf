resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = var.vpc_instance_tenancy
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = var.cluster_name
  })
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-igw"
  })
}

# Public Subnets
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_public_subnet1_cidr
  availability_zone       = var.vpc_az1
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                     = "${var.cluster_name}-public-1"
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_public_subnet2_cidr
  availability_zone       = var.vpc_az2
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                     = "${var.cluster_name}-public-2"
    "kubernetes.io/role/elb" = "1"
  })
}

# Private Subnets
resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc_private_subnet1_cidr
  availability_zone = var.vpc_az1

  tags = merge(var.tags, {
    Name                              = "${var.cluster_name}-private-1"
    "kubernetes.io/role/internal-elb" = "1"
  })
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc_private_subnet2_cidr
  availability_zone = var.vpc_az2

  tags = merge(var.tags, {
    Name                              = "${var.cluster_name}-private-2"
    "kubernetes.io/role/internal-elb" = "1"
  })
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat_gw1" {
  count      = var.enable_nat_gateway ? 1 : 0
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-nat-eip-1"
  })
}

resource "aws_eip" "nat_gw2" {
  count      = var.enable_nat_gateway && !var.single_nat_gateway ? 1 : 0
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-nat-eip-2"
  })
}

# NAT Gateways
resource "aws_nat_gateway" "nat_gw1" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat_gw1[0].id
  subnet_id     = aws_subnet.public_subnet1.id
  depends_on    = [aws_internet_gateway.gw]

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-nat-gw-1"
  })
}

resource "aws_nat_gateway" "nat_gw2" {
  count         = var.enable_nat_gateway && !var.single_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat_gw2[0].id
  subnet_id     = aws_subnet.public_subnet2.id
  depends_on    = [aws_internet_gateway.gw]

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-nat-gw-2"
  })
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-public-rt"
  })
}

resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat_gw1[0].id
    }
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-private-rt-1"
  })
}

resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.nat_gw1[0].id : aws_nat_gateway.nat_gw2[0].id
    }
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-private-rt-2"
  })
}

# Route Table Associations
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private2.id
}