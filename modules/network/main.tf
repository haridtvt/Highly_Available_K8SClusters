resource "aws_vpc" "vpc" {
  tags = {
    Name = "cluster_k8s_vpc"
    terraform = "true"
  }
  cidr_block = var.cidr_block_vpc
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "IGW_Cluster_k8s"
    terraform = "true"
  }
}

resource "aws_subnet" "subnet_private_1a" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private_cidr_block_subnet_1a
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "subnet_private_zone1a"
    terraform = "true"
  }
}

resource "aws_subnet" "subnet_private_1b" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private_cidr_block_subnet_1b
  availability_zone = "ap-southeast-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "subnet_private_zone1b"
    terraform = "true"
  }
}

resource "aws_subnet" "subnet_private_1c" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private_cidr_block_subnet_1c
  availability_zone = "ap-southeast-1c"
  map_public_ip_on_launch = false
  tags = {
    Name = "subnet_private_zone1c"
    terraform = "true"
  }
}

resource "aws_subnet" "subnet_public_1a" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.public_cidr_block_1a
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet_public_zone1a"
    terraform = "true"
  }
}

resource "aws_subnet" "subnet_public_1b" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.public_cidr_block_1b
  availability_zone = "ap-southeast-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet_public_zone1b"
    terraform = "true"
  }
}

resource "aws_subnet" "subnet_public_1c" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.public_cidr_block_1c
  availability_zone = "ap-southeast-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet_public_zone1c"
    terraform = "true"
  }
}

resource "aws_eip" "ip_nat" {
  domain = "vpc"
  tags = {
    Name = "Public IP NAT gateway"
    terraform = "true"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  subnet_id = aws_subnet.subnet_public_1a.id
  allocation_id = aws_eip.ip_nat.id
  depends_on = [aws_internet_gateway.internet_gw]
  tags = {
    Name = "NAT gateway"
    terraform = "true"
  }
}

resource "aws_route_table" "nat_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "Route NAT table"
    terraform = "true"
  }
}

resource "aws_route_table" "default_gateway_route" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
  tags = {
    Name = "Default route table"
    terraform = "true"
  }
}

resource "aws_route_table_association" "rta_private1a" {
  subnet_id = aws_subnet.subnet_private_1a.id
  route_table_id = aws_route_table.nat_route_table.id
}

resource "aws_route_table_association" "rta_private1b" {
  subnet_id = aws_subnet.subnet_private_1b.id
  route_table_id = aws_route_table.nat_route_table.id
}

resource "aws_route_table_association" "rta_private1c" {
  subnet_id = aws_subnet.subnet_private_1c.id
  route_table_id = aws_route_table.nat_route_table.id
}

resource "aws_route_table_association" "rta_public_1a" {
  subnet_id = aws_subnet.subnet_public_1a.id
  route_table_id = aws_route_table.default_gateway_route.id
}

resource "aws_route_table_association" "rta_public_1b" {
  subnet_id = aws_subnet.subnet_public_1b.id
  route_table_id = aws_route_table.default_gateway_route.id
}

resource "aws_route_table_association" "rta_public_1c" {
  subnet_id = aws_subnet.subnet_public_1c.id
  route_table_id = aws_route_table.default_gateway_route.id
}


