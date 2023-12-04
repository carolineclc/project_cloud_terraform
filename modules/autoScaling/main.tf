resource "aws_autoscaling_group" "asg" {
  name                 = "my-asg"
  desired_capacity     = 2
  min_size             = 2
  max_size             = 6
  vpc_zone_identifier  = var.vpc_public_subnets
  target_group_arns    = var.target_group_arn

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "my-scale-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300 
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "my-scale-down-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300 
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  lb_target_group_arn   = var.lb_target_group_arn
}
