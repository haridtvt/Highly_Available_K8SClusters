module "network" {
  source     = "./modules/network"
  cidr_block_vpc = "10.220.0.0/16"
  private_cidr_block_subnet_1a = "10.220.1.0/24"
  private_cidr_block_subnet_1b = "10.220.2.0/24"
  private_cidr_block_subnet_1c = "10.220.3.0/24"
  public_cidr_block_1a = "10.220.11.0/24"
  public_cidr_block_1b = "10.220.12.0/24"
  public_cidr_block_1c = "10.220.13.0/24"
}

module "security_groups" {
  depends_on = [module.network]
  source     = "./modules/security_group"
  vpc_id = module.network.vpc_id
  vpc_cidr = module.network.vpc_cidr
}

module "iam_role" {
  source     = "./modules/IAM_role"
}

module "launch_template" {
  depends_on = [module.iam_role, module.security_groups, module.network]
  source     = "./modules/instance_template"
  scripts_etcdnode = "${file("scripts/base.sh")}\n${file("scripts/etcd.sh")}"
  scripts_masternode = "${file("scripts/base.sh")}\n${file("scripts/install_k8s.sh")}"
  scripts_workernode = "${file("scripts/base.sh")}\n${file("scripts/install_k8s.sh")}"
  sg_etcd_id = module.security_groups.security_group_etcd
  sg_master_id = module.security_groups.security_group_master
  sg_worker_id = module.security_groups.security_group_worker
  ami_id = var.ami_id
  iam_instance_profile_name = module.iam_role.iam_instance_profile_name
}

module "ec2" {
  depends_on = [module.launch_template]
  source     = "./modules/ec2"
  template_etcd = module.launch_template.ectd_template
  template_master = module.launch_template.master_template
  private_subnet_ids = [
    module.network.subnet_private_zone1a_id,
    module.network.subnet_private_zone1b_id,
    module.network.subnet_private_zone1c_id
  ]
}

module "load_balancer" {
  depends_on = [module.ec2]
  source = "./modules/load_balancer"
  vpc_id = module.network.vpc_id
  subnet_private_ids = [
    module.network.subnet_private_zone1a_id,
    module.network.subnet_private_zone1b_id,
    module.network.subnet_private_zone1c_id
  ]
  subnet_public_ids = [
    module.network.subnet_public_zone1a_id,
    module.network.subnet_public_zone1b_id,
    module.network.subnet_public_zone1c_id
  ]
  master_instance_ids = [
    module.ec2.master_ec2_id0,
    module.ec2.master_ec2_id1,
    module.ec2.master_ec2_id2
  ]
  etcd_instance_ids = [
    module.ec2.etcd_ec2_id0,
    module.ec2.etcd_ec2_id1,
    module.ec2.etcd_ec2_id2
  ]
  sg_application_lb = module.security_groups.security_group_lb
}

module "asg_worker" {
  depends_on = [module.load_balancer]
  source = "./modules/auto_scaling_group"
  public_subnet_ids = [
    module.network.subnet_public_zone1a_id,
    module.network.subnet_public_zone1b_id,
    module.network.subnet_public_zone1c_id
  ]
  target_group_arn = module.load_balancer.target_group_alb_worker_arn
  template_worker = module.launch_template.worker_template
}