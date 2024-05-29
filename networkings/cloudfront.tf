##############################################################################
################################# 1.create cloudfront ########################
##############################################################################

###################### a. cloudfront distribution ############################
resource "aws_cloudfront_distribution" "user_dmz_alb_cf" {
  enabled = true
  comment = "nadri-project-cf"
  #  domain_name = ["nadri-project.com", "www.nadri-project.com"]
  aliases = [local.domain_name[0], local.domain_name[1]]
  web_acl_id = aws_wafv2_web_acl.cf_wacl.arn
  provider     = aws.virginia
  origin {
    domain_name = aws_lb.user_dmz_alb[0].dns_name
    # cf_origin_name = ["user_dmz_lb_a", "user_dmz_lb_c", "user_dmz_group"]
    origin_id = aws_lb.user_dmz_alb[0].name
    origin_shield {
      origin_shield_region = local.region
      enabled               = true
    }
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }    
  }
  origin {
    domain_name = aws_lb.user_dmz_alb[1].dns_name
    origin_id = aws_lb.user_dmz_alb[1].name
    origin_shield {
      origin_shield_region = local.region
      enabled               = true
    }
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }    
  }
    
  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["KP", "CN"]
    }
  }
  origin_group {
    origin_id = local.cf_origin_name[0]
    # memeber 1이 메인 접속, member2가 1이 criteria 상태일 때 접속가능
    failover_criteria {
      status_codes = [403, 404, 500, 502, 500]
    }
    member {
      origin_id = aws_lb.user_dmz_alb[0].name
    }
    member {
      origin_id = aws_lb.user_dmz_alb[1].name
    }
  }
  
  default_cache_behavior {
    allowed_methods         = ["GET", "HEAD", "OPTIONS", "PUT", "POST","PATCH", "DELETE"]
    cached_methods          = ["GET", "HEAD"]
    target_origin_id        = aws_lb.user_dmz_alb[0].name
    viewer_protocol_policy  = "redirect-to-https"

    cache_policy_id         = aws_cloudfront_cache_policy.user_dmz_cache_policy.id
  }
  viewer_certificate {
    acm_certificate_arn         = aws_acm_certificate.nadri.arn
    ssl_support_method          = "sni-only"
    minimum_protocol_version    = "TLSv1.2_2021"
  }
  depends_on = [
    aws_lb.user_dmz_alb,
    aws_wafv2_web_acl.cf_wacl,
    aws_acm_certificate.nadri
  ]
}

###################### b. cloudfront cache_policy ############################
resource "aws_cloudfront_cache_policy" "user_dmz_cache_policy" {
  name        = "user-dmz-policy"
  comment     = "user-dmz-policy"
  default_ttl = 1800
  max_ttl     = 21600
  min_ttl     = 0
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "whitelist"
      cookies {
        items = ["token"]
      }
    }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Accept"]
      }
    }
    query_strings_config {
      query_string_behavior = "whitelist"
      query_strings {
        items = ["pageNo","contentID","rowCnt"]
      }
    }
  }
}
