output "auto_scale_up_policy_arn" {
  value = aws_autoscaling_policy.scale_up_policy.arn
}
output "auto_scale_down_policy_arn" {
  value = aws_autoscaling_policy.scale_down_policy.arn
}
output "auto_scale_group_name" {
  value = aws_autoscaling_group.asg.name
}