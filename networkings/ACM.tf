######################### a. ACM create ################################
resource "aws_acm_certificate" "nadri" {
  domain_name                = local.domain_name[0]
  subject_alternative_names  = [local.domain_name[1]]
  validation_method          = "DNS"
  provider                   = aws.virginia
  tags = {
    Name = "nadri-crt"
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_acm_certificate" "click_cert" {
  domain_name                = local.click_name[0]
  subject_alternative_names  = [local.click_name[1],local.click_name[2]]
  validation_method          = "DNS"
  tags = {
    Name = "nadri-clicl-crt"
  }
  lifecycle {
    create_before_destroy = true
  }
}