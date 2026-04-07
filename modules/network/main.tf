resource "aws_vpc" "VPC" {
  tags = {
    Name = "cluster_k8s_vpc"
    terraform = "true"
  }
  cidr_block = var.cidr_block_vpc

}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "IGW_Cluster_k8s"
    terraform = "true"
  }
}

resource "aws_subnet" "SUBS1" {
  vpc_id = aws_vpc.VPC.id
  cidr_block = var.cidr_block_subnet
  availability_zone = var.zone
  map_public_ip_on_launch = true
  tags = {
    Name = "Master_subs"
    terraform = "true"
  }
}

resource "aws_route_table" "ROUTE" {
  vpc_id = aws_vpc.VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "Routing_internet"
    terraform = "true"
  }
}

resource "aws_route_table_association" "RTASSOC" {
  subnet_id      = aws_subnet.SUBS1.id
  route_table_id = aws_route_table.ROUTE.id
}

