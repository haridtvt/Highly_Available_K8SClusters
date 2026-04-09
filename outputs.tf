output "bastion_public_ip" {
  value = module.bastion_host.instance_public_ip
}

output "master_ips" {
  value = module.ec2.master_ip
}

output "etcd_ip" {
  value = module.ec2.etcd_ip
}

output "external_dns_nlb" {
  value = module.load_balancer.alb_external_dns
}

output "internal_dns_nlb" {
  value = module.load_balancer.nlb_internal_dns
}

output "alb_dns" {
  value = module.load_balancer.alb_external_dns
}