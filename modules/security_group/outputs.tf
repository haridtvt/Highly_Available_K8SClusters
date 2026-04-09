output "security_group_master" {
  value = aws_security_group.sg_control_plane.id
}

output "security_group_worker" {
  value = aws_security_group.sg_data_plane.id
}

output "security_group_etcd" {
  value = aws_security_group.sg_etcd_cluster.id
}

output "security_group_lb" {
  value = aws_security_group.sg_application_lb.id
}
