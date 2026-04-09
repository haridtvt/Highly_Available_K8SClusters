output "master_template" {
  value = aws_launch_template.master_template.id
}

output "ectd_template" {
  value = aws_launch_template.etcd_template.id
}

output "worker_template" {
  value = aws_launch_template.worker_template.id
}