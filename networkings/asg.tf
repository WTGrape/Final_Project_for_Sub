###
# 1. dev_dmz_proxy
###
resource "aws_autoscaling_group" "dev_dmz_proxy" {
  count                = length(local.azs)
  name                 = "${aws_launch_configuration.dev_dmz_proxy.name}-asg-${count.index}" 
  min_size             = 1 
  desired_capacity     = 1
  max_size             = 2
  target_group_arns    = [ aws_lb_target_group.dev_dmz_proxy[count.index].arn ]

  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.dev_dmz_proxy.name
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
  metrics_granularity  = "1Minute"
  vpc_zone_identifier  = [ aws_subnet.dev_dmz_proxy[count.index].id ]

  tag {
    key = "Name"
    value = "dev_dmz_proxy-${count.index}"
    propagate_at_launch = true
  }
  tag {
    key = "Role"
    value = "proxy"
    propagate_at_launch = true
  }

  depends_on = [ 
    aws_lb.dev_dmz_alb,
    aws_security_group.dev_dmz_proxy,
    aws_launch_configuration.dev_dmz_proxy,
    aws_route_table.dev_dmz_igw_rt,
    aws_route_table.dev_dmz_public_rt
  ]
}
resource "aws_autoscaling_attachment" "dev_dmz_https_proxy" {
  count                   = length(local.azs)
  autoscaling_group_name  = element(aws_autoscaling_group.dev_dmz_proxy[*].id, count.index)
  lb_target_group_arn     = element(aws_lb_target_group.dev_dmz_https_proxy[*].arn, count.index)
}
###
# 2. user_dmz_proxy
###
resource "aws_autoscaling_group" "user_dmz_proxy" {
  count                 = length(local.azs)
  name                  = "${aws_launch_configuration.user_dmz_proxy.name}-asg-${count.index}" 
  min_size              = 1 
  desired_capacity      = 1
  max_size              = 2
  target_group_arns     = [ aws_lb_target_group.user_dmz_proxy[count.index].arn ]

  health_check_type     = "EC2"
  launch_configuration  = aws_launch_configuration.user_dmz_proxy.name
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
  metrics_granularity   = "1Minute"
  vpc_zone_identifier   =[ aws_subnet.user_dmz_proxy[count.index].id ]

  tag {
    key = "Name"
    value = "user_dmz_proxy-${count.index}"
    propagate_at_launch = true
  }
  tag {
    key = "Role"
    value = "proxy"
    propagate_at_launch = true
  }

  depends_on = [ 
    aws_lb.user_dmz_alb,
    aws_security_group.user_dmz_proxy,
    aws_launch_configuration.user_dmz_proxy,
    aws_route_table.user_dmz_igw_rt,
    aws_route_table.user_dmz_public_rt
   ]
}
resource "aws_autoscaling_attachment" "user_dmz_https_proxy" {
  count                   = length(local.azs)
  autoscaling_group_name  = element(aws_autoscaling_group.user_dmz_proxy[*].id, count.index)
  lb_target_group_arn     = element(aws_lb_target_group.user_dmz_https_proxy[*].arn, count.index)
}