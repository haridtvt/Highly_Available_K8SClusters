resource "aws_launch_template" "master_template" {
  name_prefix   = "k8s-master-"
  image_id      = var.ami_id
  instance_type = "t3.medium"
  network_interfaces {
    associate_public_ip_address = false
    security_groups = [var.sg_master_id]
  }
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 30
      volume_type = "gp3"
      delete_on_termination = true
    }
  }
  user_data = base64encode(var.scripts_masternode)
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "k8s-master-template"
      terraform = "true"
    }
  }
}

resource "aws_launch_template" "worker_template" {
  name_prefix   = "k8s-worker-"
  image_id      = var.ami_id
  instance_type = "t3.small"
  network_interfaces {
    associate_public_ip_address = false
    security_groups = [var.sg_worker_id]
  }
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 50
      volume_type = "gp3"
      delete_on_termination = true
    }
  }
  user_data = base64encode(var.scripts_workernode)
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "k8s-worker-template"
      terraform = "true"
    }
  }
}

resource "aws_launch_template" "etcd_template" {
  name_prefix   = "k8s-etcd-"
  image_id      = var.ami_id
  instance_type = "t3.small"
  network_interfaces {
    associate_public_ip_address = false
    security_groups = [var.sg_etcd_id]
  }
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 50
      volume_type = "gp3"
      delete_on_termination = true
      iops = 3000
    }
  }
  user_data = base64encode(var.scripts_etcdnode)
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "k8s-etcd-template"
      terraform = "true"
    }
  }
}
