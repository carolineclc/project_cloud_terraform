output "alb_target_group_arn" {
  value = aws_alb_target_group.alb_tg.arn
}
output "alb_dns_name" {
  value = aws_alb.alb.dns_name
}