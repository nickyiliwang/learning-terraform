# load-balance/outputs.tf

output "lb_target_group_arn_out" {
    value = aws_lb_target_group.tf_tg.arn
}