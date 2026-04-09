output "target_group_alb_worker_arn" {
  value = aws_lb_target_group.application_lb_target.arn
}

output "nlb_external_dns" {
  value = aws_lb.nbl_external.dns_name
}

output "nlb_internal_dns" {
  value = aws_lb.nbl_internal.dns_name
}

output "alb_external_dns" {
  value = aws_lb.application_lb.dns_name
}

