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
# ###
# # 3. nexus
# ###
# resource "aws_autoscaling_group" "nexus" {
#   name = "${aws_launch_configuration.nexus.name}-asg" 
#   min_size             = 1 
#   desired_capacity     = 1
#   max_size             = 2
#   target_group_arns = [ aws_lb_target_group.nexus.arn ]

#   health_check_type    = "EC2"
#   launch_configuration = aws_launch_configuration.nexus.name
#   enabled_metrics = [
#     "GroupMinSize",
#     "GroupMaxSize",
#     "GroupDesiredCapacity",
#     "GroupInServiceInstances",
#     "GroupTotalInstances"
#   ]
#   metrics_granularity = "1Minute"
#   vpc_zone_identifier  = aws_subnet.nexus[*].id

#   lifecycle {
#     create_before_destroy = true
#   }

#   tag {
#     key = "Name"
#     value = "nexus"
#     propagate_at_launch = true
#   }

#   depends_on = [ 
#     aws_lb.shared_ext,
#     aws_subnet.nexus,
#     aws_security_group.nexus,
#     aws_launch_configuration.nexus,
#    ]
# }
# ###
# # 4. shared_int
# ###
# resource "aws_autoscaling_group" "shared_int" {
#   for_each             = { for k, v in var.shared_int : k => v if lookup(v, "instance", true) != false }
#   name                 = "${aws_launch_configuration.shared_int[each.key].name}-asg" 
#   min_size             = 1 
#   desired_capacity     = 1
#   max_size             = 2
#   # target_group_arns = concat(
#   #   [aws_lb_target_group.shared_int[each.key].arn],
#   #   [for k, v in var.shared_int : aws_lb_target_group.ext_prom-grafa[each.key].arn if lookup(v, "svc_port", null) !=null ]
#   # )

#   health_check_type    = "EC2"
#   launch_configuration = aws_launch_configuration.shared_int[each.key].name
#   enabled_metrics = [
#     "GroupMinSize",
#     "GroupMaxSize",
#     "GroupDesiredCapacity",
#     "GroupInServiceInstances",
#     "GroupTotalInstances"
#   ]
#   metrics_granularity = "1Minute"
#   vpc_zone_identifier  = aws_subnet.shared_int[*].id
#   lifecycle {
#     create_before_destroy = true
#   }

#   tag {
#     key = "Name"
#     value = "shared_int-${each.value.name}" 
#     propagate_at_launch = true
#   }

#   depends_on = [ 
#     aws_lb.shared_ext,
#     aws_lb.shared_int,
#     aws_subnet.shared_int,
#     aws_security_group.shared_int_default,
#     aws_launch_configuration.shared_int
#    ]
# }
# resource "aws_autoscaling_attachment" "shared_int_lb" {
#   for_each               = { for k, v in var.shared_int : k => v if lookup(v, "instance", true) != false }
#   autoscaling_group_name = aws_autoscaling_group.shared_int[each.key].id
#   lb_target_group_arn    = aws_lb_target_group.shared_int[each.key].arn
# }
# resource "aws_autoscaling_attachment" "prom_grafa_ext_lb" {
#   for_each          = { for k, v in var.shared_int : k => v if lookup(v, "svc_port", null) != null }
#   autoscaling_group_name = aws_autoscaling_group.shared_int["prom-grafa"].id
#   lb_target_group_arn    = aws_lb_target_group.ext_prom-grafa[each.key].arn
# }