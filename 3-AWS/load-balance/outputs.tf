# load-balance/outputs.tf

output "lb_target_group_arn_out" {
  value = aws_lb_target_group.tf_tg.arn
}

// docs found in tf docs or tf state dashboard, or use <tf state show module.load-balance.aws_lb.tf_lb>
output "lb_endpoint" {
  value = aws_lb.tf_lb.dns_name
}