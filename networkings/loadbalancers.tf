#############################################
################ 1. dev dmz #################
#############################################
################ dev dmz nlb ################
resource "aws_lb" "dev_dmz_nlb" {
  name                = "dev-dmz-nlb"
  internal            = false
  load_balancer_type  = "network"
  subnets             = aws_subnet.dev_dmz_lb[*].id
  security_groups     = [ aws_security_group.dev_dmz_nlb.id ]

  tags = merge( var.dmz_tags,var.dev_tags,
    {
      Name = "dev-dmz-nlb"
    }
  )
  depends_on = [
    aws_acm_certificate.click_cert,
    aws_lb_target_group.dev_dmz_argo,
    aws_security_group.dev_dmz_nlb,
    aws_security_group_rule.dev_dmz-prom_grafa
  ]
}
resource "aws_lb_listener" "dev_dmz_nlb_nexus" {
  load_balancer_arn = aws_lb.dev_dmz_nlb.arn
  port              = "9999"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_dmz_nexus.arn
  }
}
resource "aws_lb_listener" "dev_dmz_nlb_argo" {
  load_balancer_arn = aws_lb.dev_dmz_nlb.arn
  port              = "443"
  protocol          = "TLS"
  certificate_arn   = aws_acm_certificate.click_cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_dmz_argo.arn
  }
  depends_on = [
    aws_lb.dev_dmz_nlb,
    aws_acm_certificate.click_cert,
    aws_lb_target_group.dev_dmz_argo
  ]
}
resource "aws_lb_listener" "dev_dmz_nlb_prom-grafa" {
  for_each          = { for k, v in var.shared_int : k => v if lookup(v, "dmz_listen", null) != null }
  load_balancer_arn = aws_lb.dev_dmz_nlb.arn
  port              = each.value.dmz_listen
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_dmz_prom-grafa[each.key].arn
  }
}
################ dev dmz nlb target group ################
resource "aws_lb_target_group" "dev_dmz_nexus" {
  name        = "dev-dmz-nexus-target-group"
  port        = 5000
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.dev_dmz.id
}
resource "aws_lb_target_group" "dev_dmz_argo" {
  name        = "dev-dmz-argo-target-group"
  port        = 443
  protocol    = "TLS"
  target_type = "ip"
  vpc_id      = aws_vpc.dev_dmz.id
}
resource "aws_lb_target_group" "dev_dmz_prom-grafa" {
  for_each    = { for k, v in var.shared_int : k => v if lookup(v, "listener", null) != null }
  name        = "dev-dmz-${each.value.svc_name}-target-group"
  port        = each.value.listener
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.dev_dmz.id
}
################ dev dmz alb ################
resource "aws_lb" "dev_dmz_alb" {
  count               = length(local.azs)
  name                = "dev-dmz-alb-${count.index}"
  internal            = false
  load_balancer_type  = "application"
  subnets             = aws_subnet.dev_dmz_lb[*].id
  security_groups     = [ aws_security_group.dev_dmz_alb.id ]

  tags = merge( var.dmz_tags,var.dev_tags,
    {
      Name = "dev-dmz-alb-${count.index}"
    }
  )
}
resource "aws_lb_listener" "dev_dmz_alb_proxy" {
  count               = length(local.azs)
  load_balancer_arn   = aws_lb.dev_dmz_alb[count.index].arn
  port                = "80"
  protocol            = "HTTP"

  default_action {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.dev_dmz_proxy[count.index].arn
  }
}
resource "aws_lb_listener" "dev_dmz_alb_https_proxy" {
  count               = length(local.azs)
  load_balancer_arn   = aws_lb.dev_dmz_alb[count.index].arn
  port                = "443"
  protocol            = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_dmz_https_proxy[count.index].arn
  }
}
################ dev dmz alb target group ################
resource "aws_lb_target_group" "dev_dmz_proxy" {
  count               = length(local.azs)
  name                = "dev-dmz-proxy-tg-${count.index}"
  port                = 80
  protocol            = "HTTP"
  vpc_id              = aws_vpc.dev_dmz.id
}
resource "aws_lb_target_group" "dev_dmz_https_proxy" {
  count               = length(local.azs)
  name                = "dev-dmz-https-proxy-tg-${count.index}"
  port                = 443
  protocol            = "HTTP"
  vpc_id              = aws_vpc.dev_dmz.id
}

###########################################
################ 2. shared ################
###########################################
resource "aws_lb_target_group" "nexus" {
  name        = "shared-ext-lb-tg"
  port        = 22
  protocol    = "TCP"
  vpc_id      = aws_vpc.shared.id
}
resource "aws_lb_target_group_attachment" "nexus" {
  target_group_arn = aws_lb_target_group.nexus.arn
  target_id        = aws_instance.nexus.id
  port             = 22
}
resource "aws_lb_target_group" "ext_prom-grafa" {
  for_each         = { for k, v in var.shared_int : k => v if lookup(v, "svc_port", null) != null }
  name             = "shared-ext-${each.value.svc_name}"
  port             = each.value.svc_port
  protocol         = "TCP"
  vpc_id           = aws_vpc.shared.id
}
resource "aws_lb_target_group_attachment" "ext_prom-grafa" {
  for_each          = { for k, v in var.shared_int : k => v if lookup(v, "svc_port", null) != null }
  target_group_arn  = aws_lb_target_group.ext_prom-grafa[each.key].arn
  target_id         = aws_instance.shared_int["prom-grafa"].id
  port              = each.value.svc_port
}
resource "aws_lb" "shared_ext" {
  name                = "shared-ext-lb"
  internal            = true
  load_balancer_type  = "network"
  subnets             = aws_subnet.shared_tgw[*].id
  security_groups     = [ aws_security_group.shared_ext_lb.id ]

  tags = merge( var.shared_tags, var.dev_tags,
    {
      Name = "shared-ext-lb"
    }
  )
  depends_on = [ aws_security_group_rule.prom_grafa_listener ]
}
resource "aws_lb_listener" "nexus" {
  load_balancer_arn = aws_lb.shared_ext.arn
  port              = "5000"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nexus.arn
  }
}
resource "aws_lb_listener" "prom-grafa" {
  for_each           = { for k, v in var.shared_int : k => v if lookup(v, "listener", null) != null }
  load_balancer_arn  = aws_lb.shared_ext.arn
  port               = each.value.listener
  protocol           = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ext_prom-grafa[each.key].arn
  }
}
resource "aws_lb_target_group" "shared_int" {
  for_each          = { for k, v in var.shared_int : k => v if lookup(v, "instance", true) != false }
  name              = each.value.name
  port              = 22
  protocol          = "TCP"
  vpc_id            = aws_vpc.shared.id
}
resource "aws_lb_target_group_attachment" "shared_int" {
    for_each         = { for k, v in var.shared_int : k => v if lookup(v, "instance", true) != false }
    target_group_arn = aws_lb_target_group.shared_int[each.key].arn
    target_id = aws_instance.shared_int[each.key].id
    port = 22
}
resource "aws_lb" "shared_int" {
  name                = "shared-int-lb"
  internal            = true
  load_balancer_type  = "network"
  subnets             = aws_subnet.nexus[*].id
  security_groups     = [ aws_security_group.shared_int_lb.id ]

  tags = merge( var.shared_tags,var.dev_tags,
    {
      Name = "shared-int-lb"
    }
  )
}
resource "aws_lb_listener" "shared_int" {
  for_each         = { for k, v in var.shared_int : k => v if lookup(v, "instance", true) != false }
  load_balancer_arn = aws_lb.shared_int.arn
  port              = each.value.port
  protocol          = "TCP"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  # alpn_policy       = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.shared_int[each.key].arn
  }
}
###############################################
################# 3. user dmz #################
###############################################
################ user dmz alb #################
resource "aws_lb" "user_dmz_alb" {
  count               = length(local.azs)
  name                = "user-dmz-alb-${count.index}"
  internal            = false
  load_balancer_type  = "application"
  subnets             = aws_subnet.user_dmz_lb[*].id
  security_groups     = [ aws_security_group.dmz_user_alb.id ]

  tags = merge( var.dmz_tags,var.user_tags,
    {
      Name = "user-dmz-alb-${count.index}"
    }
  )
}
resource "aws_lb_listener" "user_dmz_alb_proxy" {
  count               = length(local.azs)
  load_balancer_arn   = aws_lb.user_dmz_alb[count.index].arn
  port                = "80"
  protocol            = "HTTP"

  default_action {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.user_dmz_proxy[count.index].arn
  }
}
resource "aws_lb_listener" "user_dmz_alb_https_proxy" {
  count               = length(local.azs)
  load_balancer_arn   = aws_lb.user_dmz_alb[count.index].arn
  port                = "443"
  protocol            = "HTTP"

  default_action {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.user_dmz_proxy[count.index].arn
  }
}
################ user dmz alb target group ################
resource "aws_lb_target_group" "user_dmz_proxy" {
  count               = length(local.azs)
  name                = "user-dmz-proxy-tg-${count.index}"
  port                = 80
  protocol            = "HTTP"
  vpc_id              = aws_vpc.user_dmz.id
}
resource "aws_lb_target_group" "user_dmz_https_proxy" {
  count               = length(local.azs)
  name                = "user-dmz-https-proxy-tg-${count.index}"
  port                = 443
  protocol            = "HTTP"
  vpc_id              = aws_vpc.user_dmz.id
}