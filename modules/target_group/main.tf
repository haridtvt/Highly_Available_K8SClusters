resource "aws_lb_target_group" "k8s_api_tg" {
  name     = "k8s-api-target-group"
  port     = 6443
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
    Name = "k8s-api-tg"
  }
}

resource "aws_lb_target_group_attachment" "master_attachment" {
  count            = 3
  target_group_arn = aws_lb_target_group.k8s_api_tg.arn
  target_id        = var.master_instance_ids[count.index]
  port             = 6443
}

resource "aws_lb_listener" "k8s_api_listener" {
  load_balancer_arn = var.load_balancer_arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_api_tg.arn
  }
}