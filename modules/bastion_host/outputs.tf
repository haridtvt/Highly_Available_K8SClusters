output "instance_public_ip" {
  value       = aws_instance.bastion_host.public_ip
}

output "sg_bastion_id" {
  value = aws_security_group.sg_bastion.id
}