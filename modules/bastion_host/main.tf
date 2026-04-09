resource "aws_security_group" "sg_bastion" {
  name   = "bastion-host"
  vpc_id = var.vpc_id
  tags   = {
    Name = "bastion",
    terraform = "true"
  }
}

resource "aws_security_group_rule" "tcp_22" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.sg_bastion.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow port 22 SSH"
}

resource "aws_security_group_rule" "icmp" {
  from_port         = -1
  protocol          = "icmp"
  security_group_id = aws_security_group.sg_bastion.id
  to_port           = -1
  type              = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow ICMP"
}

resource "aws_security_group_rule" "ec2_egress_internet" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_bastion.id
}

resource "aws_instance" "bastion_host" {
  ami = var.ami_id
  instance_type = "t2.micro"
  subnet_id = var.public_subnet
  key_name = "Bastion_host"
  vpc_security_group_ids = [aws_security_group.sg_bastion.id]
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  tags = {
    Name = "Bastion_Server",
    terraform = "true"
  }
}
resource "aws_eip" "eip" {
  domain = "vpc"
  tags = {
    Name = "EIP_bastion_host"
  }
}
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.bastion_host.id
  allocation_id = aws_eip.eip.id
}

