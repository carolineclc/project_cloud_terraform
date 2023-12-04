resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "my-high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2" 
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "This metric monitors ec2 high cpu utilization"
  alarm_actions       = var.auto_scale_up_policy_arn
  dimensions = {
    AutoScalingGroupName = var.auto_scale_group_name
  }
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name          = "my-low-cpu-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2" 
  period              = 60
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "This metric monitors ec2 low cpu utilization"
  alarm_actions       = var.auto_scale_down_policy_arn
  dimensions = {
    AutoScalingGroupName = var.auto_scale_group_name
  }
}