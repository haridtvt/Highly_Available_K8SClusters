resource "aws_lb" "nbl_external" {
  name  = "nbl-external"
  internal = false
  load_balancer_type = "network"
  subnets = var.subnet_public_ids
  enable_cross_zone_load_balancing = true
  tags = {
    Name      = "nbl_external"
    terraform = "true"
    tier = "nlb_control_plan"
  }
}

resource "aws_lb_target_group" "nlb_external_target" {
  name  = "nlb-external-target"
  port  = 6443
  protocol = "TCP"
  vpc_id   = var.vpc_id
  health_check {
    protocol            = "TCP"
    port                = 6443
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = {
    Name = "nlb_external_target"
    terraform = "true"
  }
}

resource "aws_lb_target_group_attachment" "nlb_external_attachment" {
  count            = 3
  target_group_arn = aws_lb_target_group.nlb_external_target.arn
  target_id        = var.master_instance_ids[count.index]
  port             = 6443
}

resource "aws_lb_listener" "nbl_external_listener" {
  load_balancer_arn = aws_lb.nbl_external.arn
  port              = 6443
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_external_target.arn
  }
  tags = {
    Name = "nbl_external_listener"
  }
}

###

resource "aws_lb" "nbl_internal" {
  name  = "nbl-internal"
  internal = true
  load_balancer_type = "network"
  subnets = var.subnet_private_ids
  enable_cross_zone_load_balancing = true
  tags = {
    Name      = "nbl_internal"
    terraform = "true"
    tier = "nlb_ectd"
  }
}

resource "aws_lb_target_group" "nlb_internal_target" {
  name  = "nlb-internal-target"
  port  = 2379
  protocol = "TCP"
  vpc_id   = var.vpc_id
  health_check {
    protocol            = "TCP"
    port                = 2379
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = {
    Name = "nlb_internal_target"
    terraform = "true"
  }
}

resource "aws_lb_target_group_attachment" "nlb_internal_attachment" {
  count            = 3
  target_group_arn = aws_lb_target_group.nlb_internal_target.arn
  target_id        = var.etcd_instance_ids[count.index]
  port             = 2379
}

resource "aws_lb_listener" "nbl_internal_listener" {
  load_balancer_arn = aws_lb.nbl_internal.arn
  port              = 2379
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_internal_target.arn
  }
  tags = {
    Name = "nbl_internal_listener"
  }
}

###
resource "aws_lb" "application_lb" {
  name               = "application-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_application_lb]
  subnets            = var.subnet_public_ids
  enable_deletion_protection = false
  tags = {
    Name = "application_lb"
    terraform = "true"
  }
}

resource "aws_lb_target_group" "application_lb_target" {
  name  = "application-lb-target"
  port  = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    protocol            = "HTTP"
    port                = 80
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = {
    Name = "application_lb_target"
    terraform = "true"
  }
}

resource "aws_lb_listener" "application_lb_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application_lb_target.arn
  }
  tags = {
    Name = "nbl_internal_listener"
  }
}
