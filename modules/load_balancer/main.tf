resource "aws_lb" "NLB" {
  name                             = "k8s-api-nlb"
  internal                         = false
  load_balancer_type               = "network"
  subnets = [var.subnet_id]
  enable_cross_zone_load_balancing = true
  tags = {
    Name      = "k8s-api-nlb"
    terraform = "true"
  }
}