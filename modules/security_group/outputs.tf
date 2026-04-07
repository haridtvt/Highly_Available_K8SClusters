output "security_group_master" {
  value = aws_security_group.SG1.id
}

output "security_group_worker" {
  value = aws_security_group.SG2.id
}