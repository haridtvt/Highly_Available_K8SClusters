resource "aws_autoscaling_group" "worker_asg" {
  name                = "worker-asg"
  desired_capacity    = 3
  max_size            = 6
  min_size            = 3
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id = var.template_worker
    version = "$Latest"
  }
  target_group_arns = [var.target_group_arn]
  health_check_type         = "EC2"
  health_check_grace_period = 300
  tag {
    key                 = "true"
    propagate_at_launch = false
    value               = "terraform"
  }
}