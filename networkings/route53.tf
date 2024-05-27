##############################################################################
#################################### 1.route53 record ########################
##############################################################################
############################# 1.route53 for nadir ############################
##############################################################################

######################### a. route53 ###############################
resource "aws_route53_zone" "nadri" {
    name         =  local.domain_name[0]
}
resource "aws_route53domains_registered_domain" "nadri" {
  domain_name = local.domain_name[0]
    
  dynamic "name_server" {
    for_each = aws_route53_zone.nadri.name_servers
    content{
        name = name_server.value
    }
  }

  tags = {
    Environment = "project"
  }
  depends_on = [ 
    aws_route53_zone.nadri
  ]
}
######################### b. cloudfront attach ###############################

resource "aws_route53_record" "nadri" {
  zone_id        = aws_route53_zone.nadri.zone_id
  name           = local.domain_name[0]
  type           = "A"
  alias {
    name                   = aws_cloudfront_distribution.user_dmz_alb_cf.domain_name
    zone_id                = aws_cloudfront_distribution.user_dmz_alb_cf.hosted_zone_id
    evaluate_target_health = true
  }
  depends_on = [ 
    aws_route53_zone.nadri
  ]
}

resource "aws_route53_record" "www_nadri" {
  zone_id        = aws_route53_zone.nadri.zone_id
  name           = local.domain_name[1]
  type           = "A"
  alias {
    name                   = aws_cloudfront_distribution.user_dmz_alb_cf.domain_name
    zone_id                = aws_cloudfront_distribution.user_dmz_alb_cf.hosted_zone_id
    evaluate_target_health = true
  }
  depends_on = [ 
    aws_route53_zone.nadri
  ]
}
######################### c. ACM to route53 record ###########################
resource "aws_route53_record" "no_acm_record" {
  for_each = {
    for dvo in aws_acm_certificate.nadri.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  # route 53의 hosting zone은 고정으로 되어있음.
  zone_id         = aws_route53_zone.nadri.zone_id
  depends_on = [
    aws_acm_certificate.nadri,
    aws_route53_zone.nadri
    ]
}
##############################################################################
############################# 2.route53 for arogcd ###########################
##############################################################################

######################### a. route53 ###############################
resource "aws_route53_zone" "nadri_click" {
    name         =  local.click_name[0]
}
resource "aws_route53domains_registered_domain" "nadri_click" {
  domain_name = local.click_name[0]
    
  dynamic "name_server" {
    for_each = aws_route53_zone.nadri_click.name_servers
    content{
        name = name_server.value
    }
    # name = aws_route53_zone.nadri_click.name_servers[*]
  }

  tags = {
    Environment = "test"
  }
  depends_on = [ 
    aws_route53_zone.nadri_click
  ]
}

######################### b. ACM to route53 record ###########################
resource "aws_route53_record" "no_acm_click_record" {
  for_each = {
    for dvo in aws_acm_certificate.click_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  # route 53의 hosting zone은 고정으로 되어있음.
  zone_id         = aws_route53_zone.nadri_click.zone_id
  depends_on = [
    aws_acm_certificate.click_cert,
    aws_route53_zone.nadri_click
  ]
}