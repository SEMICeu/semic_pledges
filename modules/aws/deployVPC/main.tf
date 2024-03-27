
# Create a vpc
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = local.vpc_name
  }
}

# Change default sg, allow nothing
resource "aws_default_security_group" "sg-default" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = local.sg_default_name
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = local.igw_name
  }
}

# Create NAT gateway
resource "aws_eip" "this" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]
  tags = {
    Name = local.nat_gw_name
  }
}

resource "aws_nat_gateway" "this" {
  subnet_id     = aws_subnet.public[0].id
  allocation_id = aws_eip.this.allocation_id
  tags = {
    Name = local.nat_gw_name
  }
}

# Public subnets
resource "aws_subnet" "public" {
  count             = local.num_public_subnets
  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.public_cidrs[count.index]
  tags = {
    Name                                       = "${local.subnet_name}-public-${count.index}"
    "kubernetes.io/cluster/${var.global_name}" = "shared"
    "kubernetes.io/role/elb"                   = "1"
  }
}

# Private subnets
resource "aws_subnet" "private" {
  count             = local.num_private_subnets
  vpc_id            = aws_vpc.this.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.private_cidrs[count.index]
  tags = {
    Name                                       = "${local.subnet_name}-private-${count.index}"
    "kubernetes.io/cluster/${var.global_name}" = "shared"
    "kubernetes.io/role/internal-elb"          = "1"
  }
}

# Public Routes
resource "aws_route_table" "public" {
  count  = local.num_public_subnets
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.subnet_name}-public"
  }
}

resource "aws_route_table_association" "public" {
  count          = local.num_public_subnets
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.*.id[count.index]
}

resource "aws_route" "public_internet_gateway" {
  count                  = local.num_public_subnets
  route_table_id         = aws_route_table.public.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

# Private Routes
resource "aws_route_table" "private" {
  count  = local.num_private_subnets
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.subnet_name}-private"
  }
}

resource "aws_route_table_association" "private" {
  count          = local.num_private_subnets
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.*.id[count.index]
}

resource "aws_route" "private_nat_gateway" {
  count                  = local.num_private_subnets
  route_table_id         = aws_route_table.private.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id

  timeouts {
    create = "5m"
  }
}
