output "bastion_public_ip" {
  value = module.bastion_host.instance_public_ip
}

output "master_ips" {
  value = module.ec2.master_ip
}

output "etcd_ip" {
  value = module.ec2.etcd_ip
}