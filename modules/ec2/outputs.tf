output "master_ec2_id0" {
  value = aws_instance.ec2_master[0].id
}

output "master_ec2_id1" {
  value = aws_instance.ec2_master[1].id
}

output "master_ec2_id2" {
  value = aws_instance.ec2_master[2].id
}

output "etcd_ec2_id0" {
  value = aws_instance.ec2_etcd[0].id
}

output "etcd_ec2_id1" {
  value = aws_instance.ec2_etcd[1].id
}

output "etcd_ec2_id2" {
  value = aws_instance.ec2_etcd[2].id
}