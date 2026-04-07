output "VPC_ID" {
  value = aws_vpc.VPC.id
}

output "SUBNET1" {
  value = aws_subnet.SUBS1.cidr_block
}

output "SUBNET1_ID" {
  value = aws_subnet.SUBS1.id
}