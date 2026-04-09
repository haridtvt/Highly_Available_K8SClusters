output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "subnet_private_zone1a" {
  value = aws_subnet.subnet_public_1a.cidr_block
}

output "subnet_private_zone1b" {
  value = aws_subnet.subnet_public_1b.cidr_block
}

output "subnet_private_zone1c" {
  value = aws_subnet.subnet_public_1c.cidr_block
}
