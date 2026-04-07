output "instance_public_ip" {
  value = aws_instance.WORKER.public_ip
}

output "master_ids" {
  value = aws_instance.MASTER[*].id
}