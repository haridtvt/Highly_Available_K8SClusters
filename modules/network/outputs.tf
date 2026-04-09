output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "subnet_private_zone1a" {
  value = aws_subnet.subnet_private_1a.cidr_block
}

output "subnet_private_zone1b" {
  value = aws_subnet.subnet_private_1b.cidr_block
}

output "subnet_private_zone1c" {
  value = aws_subnet.subnet_private_1c.cidr_block
}

output "subnet_private_zone1a_id" {
  value = aws_subnet.subnet_private_1a.id
}

output "subnet_private_zone1b_id" {
  value = aws_subnet.subnet_private_1b.id
}

output "subnet_private_zone1c_id" {
  value = aws_subnet.subnet_private_1c.id
}

output "subnet_public_zone1a_id" {
  value = aws_subnet.subnet_public_1a.id
}

output "subnet_public_zone1b_id" {
  value = aws_subnet.subnet_public_1b.id
}

output "subnet_public_zone1c_id" {
  value = aws_subnet.subnet_public_1c.id
}
