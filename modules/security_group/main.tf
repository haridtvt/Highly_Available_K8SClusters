resource "aws_security_group" "SG1" {
  vpc_id = var.vpc_id
  tags = {
    Name = "master_node_sg"
    terraform = "true"
  }
}

resource "aws_security_group" "SG2" {
  vpc_id = var.vpc_id
  tags = {
    Name = "worker_node_sg"
    terraform = "true"
  }
}

locals {
  target_sg_ids = {
    master = aws_security_group.SG1.id
    worker = aws_security_group.SG2.id
  }
}

resource "aws_security_group_rule" "ec2_egress_internet" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  for_each = local.target_sg_ids
  security_group_id = each.value
}

resource "aws_vpc_security_group_ingress_rule" "P22" {
  ip_protocol       = "tcp"
  for_each = local.target_sg_ids
  security_group_id = each.value
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
  description       = "SSH port"
}

resource "aws_vpc_security_group_ingress_rule" "P4789" {
  ip_protocol       = "udp"
  for_each = local.target_sg_ids
  security_group_id = each.value
  from_port         = 4789
  to_port           = 4789
  cidr_ipv4         = var.cidr_ipv4
  description       = "Allow VXLAN traffic"
}

resource "aws_vpc_security_group_ingress_rule" "ICMP" {
  ip_protocol       = "icmp"
  for_each = local.target_sg_ids
  security_group_id = each.value
  cidr_ipv4         = var.cidr_ipv4
  from_port   = -1
  to_port     = -1
  description       = "Allow ICMP traffic"
}

resource "aws_vpc_security_group_ingress_rule" "DNST" {
  ip_protocol       = "tcp"
  for_each = local.target_sg_ids
  security_group_id = each.value
  cidr_ipv4         = var.cidr_ipv4
  from_port   = 53
  to_port     = 53
  description       = "Allow DNS TCP traffic"
}

resource "aws_vpc_security_group_ingress_rule" "DNSU" {
  ip_protocol       = "udp"
  for_each = local.target_sg_ids
  security_group_id = each.value
  cidr_ipv4         = var.cidr_ipv4
  from_port   = 53
  to_port     = 53
  description       = "Allow DNS UDP traffic"
}

resource "aws_vpc_security_group_ingress_rule" "P2379" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.SG1.id
  from_port = 2379
  to_port = 2380
  cidr_ipv4 = var.cidr_ipv4
  description = "allow ectd server port port"
}

resource "aws_vpc_security_group_ingress_rule" "P6443" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.SG1.id
  from_port = 6443
  to_port = 6443
  cidr_ipv4 = "0.0.0.0/0"
  description = "allow 6443 port k8s API servers"
}
resource "aws_vpc_security_group_ingress_rule" "P10250" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.SG1.id
  from_port         = 12050
  to_port           = 12050
  cidr_ipv4         = var.cidr_ipv4
  description       = "Kubelet API (Self, Control Plane)"
}

resource "aws_vpc_security_group_ingress_rule" "P10259" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.SG1.id
  from_port = 10259
  to_port = 10259
  cidr_ipv4 = var.cidr_ipv4
  description = "kube-scheduler"
}

resource "aws_vpc_security_group_ingress_rule" "P10257" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.SG1.id
  from_port = 10257
  to_port = 10257
  cidr_ipv4 = var.cidr_ipv4
  description = "kube-controller-manager"
}

resource "aws_vpc_security_group_ingress_rule" "P10250N" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.SG2.id
  from_port         = 10250
  to_port           = 10250
  cidr_ipv4         = var.cidr_ipv4
  description       = "Kubelet API (Self, Control Plane)"
}

resource "aws_vpc_security_group_ingress_rule" "P10256N" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.SG2.id
  from_port         = 10256
  to_port           = 10256
  cidr_ipv4         = var.cidr_ipv4
  description       = "kube-proxy"
}

resource "aws_vpc_security_group_ingress_rule" "P30000T" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.SG2.id
  from_port         = 30000
  to_port           = 32767
  cidr_ipv4         = var.cidr_ipv4
  description       = "NodePort Services "
}

resource "aws_vpc_security_group_ingress_rule" "P30000U" {
  ip_protocol       = "udp"
  security_group_id = aws_security_group.SG2.id
  from_port         = 30000
  to_port           = 32767
  cidr_ipv4         = "0.0.0.0/0"
  description       = "NodePort Services "
}
