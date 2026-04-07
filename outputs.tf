output "VPC_ID" {
  value = module.VPC.VPC_ID
}

output "SUBNET_CLUSTER" {
  value = module.VPC.SUBNET1
}

output "master_ids" {
  value = module.EC2.master_ids
}