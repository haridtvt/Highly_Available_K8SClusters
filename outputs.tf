output "VPC_ID" {
  value = module.VPC.VPC_ID
}

output "nlb_dns" {
  value = module.NLB.NLB_DNS
}

output "master_ids" {
  value = module.EC2.master_ids
}