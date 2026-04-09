resource "aws_security_group" "sg_control_plane" {
  vpc_id = var.vpc_id
  tags = {
    Name = "sg_control_plane"
    terraform = "true"
  }
}

resource "aws_security_group" "sg_data_plane" {
  vpc_id = var.vpc_id
  tags = {
    Name = "sg_data_plane"
    terraform = "true"
  }
}

resource "aws_security_group" "sg_etcd_cluster" {
  vpc_id = var.vpc_id
  tags = {
    Name = "sg_etcd_cluster"
    terraform = "true"
  }
}

resource "aws_security_group" "sg_application_lb" {
  vpc_id = var.vpc_id
  tags = {
    Name = "sg_application_lb"
    terraform = "true"
  }
}

locals {
  all_target_id = {
    master = aws_security_group.sg_control_plane.id
    worker = aws_security_group.sg_data_plane.id
    etcd = aws_security_group.sg_etcd_cluster.id
    lb = aws_security_group.sg_application_lb.id
  }
}


resource "aws_security_group_rule" "ec2_egress_internet" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  for_each = local.all_target_id
  security_group_id = each.value
}

resource "aws_vpc_security_group_ingress_rule" "tcp_22" {
  ip_protocol       = "tcp"
  for_each = local.all_target_id
  security_group_id = each.value
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
  description       = "allow SSH port"
}

resource "aws_vpc_security_group_ingress_rule" "icmp" {
  ip_protocol       = "icmp"
  for_each = local.all_target_id
  security_group_id = each.value
  cidr_ipv4         = "0.0.0.0/0"
  from_port   = -1
  to_port     = -1
  description       = "Allow ICMP traffic"
}

resource "aws_vpc_security_group_ingress_rule" "tcp_4789" {
  ip_protocol       = "udp"
  for_each = local.all_target_id
  security_group_id = each.value
  from_port         = 4789
  to_port           = 4789
  cidr_ipv4         = var.vpc_cidr
  description       = "Allow vxlan traffic"
}

resource "aws_vpc_security_group_ingress_rule" "udp_53" {
  ip_protocol       = "udp"
  for_each = local.all_target_id
  security_group_id = each.value
  cidr_ipv4         = var.vpc_cidr
  from_port   = 53
  to_port     = 53
  description       = "Allow DNS UDP traffic"
}

resource "aws_vpc_security_group_ingress_rule" "tcp_53" {
  ip_protocol       = "tcp"
  for_each = local.all_target_id
  security_group_id = each.value
  cidr_ipv4         = var.vpc_cidr
  from_port   = 53
  to_port     = 53
  description       = "Allow DNS TCP traffic"
}

resource "aws_vpc_security_group_ingress_rule" "tcp_6443_control" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.sg_control_plane.id
  from_port = 6443
  to_port = 6443
  cidr_ipv4 = "0.0.0.0/0"
  description = "allow 6443 port k8s API servers"
}

resource "aws_vpc_security_group_ingress_rule" "tcp_6443_lb" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.sg_application_lb.id
  from_port = 6443
  to_port = 6443
  cidr_ipv4 = "0.0.0.0/0"
  description = "allow 6443 port k8s API servers"
}

resource "aws_vpc_security_group_ingress_rule" "tcp_10250_control" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.sg_control_plane.id
  from_port         = 10250
  to_port           = 10250
  cidr_ipv4         = var.vpc_cidr
  description       = "Kubelet API (Self, Control Plane)"
}

resource "aws_vpc_security_group_ingress_rule" "tcp_10250_data" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.sg_data_plane.id
  from_port         = 10250
  to_port           = 10250
  cidr_ipv4         = var.vpc_cidr
  description       = "Kubelet API (Self, Control Plane)"
}

resource "aws_vpc_security_group_ingress_rule" "tcp_10259" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.sg_control_plane.id
  from_port = 10259
  to_port = 10259
  cidr_ipv4 = var.vpc_cidr
  description = "kube-scheduler"
}

resource "aws_vpc_security_group_ingress_rule" "tcp_10257" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.sg_control_plane.id
  from_port = 10257
  to_port = 10257
  cidr_ipv4 = var.vpc_cidr
  description = "kube-controller-manager"
}

resource "aws_vpc_security_group_ingress_rule" "tcp_30000_32767" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.sg_data_plane.id
  from_port         = 30000
  to_port           = 32767
  cidr_ipv4         = "0.0.0.0/0"
  description       = "NodePort Services "
}

resource "aws_vpc_security_group_ingress_rule" "udp_30000_32767" {
  ip_protocol       = "udp"
  security_group_id = aws_security_group.sg_data_plane.id
  from_port         = 30000
  to_port           = 32767
  cidr_ipv4         = "0.0.0.0/0"
  description       = "NodePort Services "
}

resource "aws_vpc_security_group_ingress_rule" "tcp_2379_etcd" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.sg_etcd_cluster.id
  from_port = 2379
  to_port = 2379
  cidr_ipv4 = var.vpc_cidr
  description = "allow ectd server port port"
}

resource "aws_vpc_security_group_ingress_rule" "tcp_2379_lb" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.sg_application_lb.id
  from_port = 2379
  to_port = 2379
  cidr_ipv4 = var.vpc_cidr
  description = "allow ectd server port port"
}

resource "aws_vpc_security_group_ingress_rule" "tcp_2380" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.sg_etcd_cluster.id
  from_port = 2380
  to_port = 2380
  cidr_ipv4 = var.vpc_cidr
  description = "allow ectd server port port"
}

resource "aws_vpc_security_group_ingress_rule" "tcp_443" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.sg_application_lb.id
  from_port = 443
  to_port = 443
  cidr_ipv4 = "0.0.0.0/0"
  description = "allow 443 port for application load balancer"
}

resource "aws_vpc_security_group_ingress_rule" "tcp_80" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.sg_application_lb.id
  from_port = 80
  to_port = 80
  cidr_ipv4 = "0.0.0.0/0"
  description = "allow 80 port for application load balancer"
}

