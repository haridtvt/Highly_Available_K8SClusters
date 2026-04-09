resource "aws_instance" "ec2_master" {
  count = 3
  launch_template {
    id      = var.template_master
    version = "$Latest"
  }
  subnet_id = var.private_subnet_ids[count.index]
  key_name = "K8s"
  tags = {
    Name = "k8s-master-${count.index + 1}"
  }
}

resource "aws_instance" "ec2_etcd" {
  count = 3
  launch_template {
    id      = var.template_etcd
    version = "$Latest"
  }
  subnet_id = var.private_subnet_ids[count.index]
  key_name = "K8s"
  tags = {
    Name = "k8s-etcd-${count.index + 1}"
  }
}