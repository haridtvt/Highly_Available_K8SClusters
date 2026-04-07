resource "aws_launch_template" "k8s_template" {
  name_prefix   = "k8s-master-"
  image_id      = var.ami_id
  instance_type = "t3.medium"
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 50
      volume_type = "gp3"
      delete_on_termination = true
    }
  }
  network_interfaces {
    associate_public_ip_address = true
    subnet_id = var.subnet_id
    security_groups             = [var.sg_master]
  }
  user_data = filebase64(var.scripts)
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "k8s-master"
      terraform = "true"
    }
  }
}