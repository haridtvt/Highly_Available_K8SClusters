module "VPC" {
  source = "./modules/network"
  zone = "ap-southeast-1a"
  cidr_block_vpc = "10.220.0.0/16"
  cidr_block_subnet = "10.220.1.0/24"
}

module "SG" {
  source = "./modules/security_group"
  vpc_id = module.VPC.VPC_ID
  cidr_ipv4 = module.VPC.SUBNET1
}

module "TEMPLATE" {
  source = "./modules/instance_template"
  sg_master = module.SG.security_group_master
  ami_id = var.ami_id
  scripts = "./scripts/user-data.sh"
  subnet_id = module.VPC.SUBNET1_ID
}

module "EC2" {
  source = "./modules/ec2"
  template = module.TEMPLATE.template_id
  ami_id = var.ami_id
  subnet_id = module.VPC.SUBNET1_ID
  sg_worker = module.SG.security_group_worker
  user-data-worker = "./scripts/user-data.sh"
}

module "NLB" {
  source = "./modules/load_balancer"
  subnet_id = module.VPC.SUBNET1_ID
}

module "TARGET" {
  source = "./modules/target_group"
  vpc_id = module.VPC.VPC_ID
  load_balancer_arn = module.NLB.NLB_ARN
  master_instance_ids = module.EC2.master_ids
}