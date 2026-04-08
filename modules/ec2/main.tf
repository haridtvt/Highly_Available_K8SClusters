resource "aws_instance" "MASTER" {
  count = 3
  launch_template {
    id      = var.template
    version = "$Latest"
  }
  key_name = "K8s"
  tags = {
    Name = "k8s-master-${count.index + 1}"
  }
}

resource "aws_instance" "WORKER" {
  ami           = var.ami_id
  instance_type = "t3.medium"
  subnet_id     = var.subnet_id
  key_name = "K8s"
  vpc_security_group_ids = [var.sg_worker]
  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }
  user_data = filebase64(var.user-data-worker)
  tags = {
    Name = "Worker_node",
    terraform = "true"
  }
}