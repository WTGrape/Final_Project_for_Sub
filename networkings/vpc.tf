###
# 1. dev dmz
###
resource "aws_vpc" "dev_dmz" {
  cidr_block = local.dev_dmz_vpc_cidr
  tags = local.dev_dmz_tags
    
  enable_dns_hostnames      = true
  enable_dns_support        = true
}
###
# 2. shared
###
resource "aws_vpc" "shared" {
    cidr_block = local.shared_vpc_cidr
    tags = local.shared_tags
    
    enable_dns_hostnames      = true
    enable_dns_support        = true
}
###
# 3. test dev
###
resource "aws_vpc" "test_dev" {
  cidr_block = local.test_dev_vpc_cidr
  tags = local.test_dev_tags
    
  enable_dns_hostnames      = true
  enable_dns_support        = true
}
###
# 4. production
###
resource "aws_vpc" "prod" {
  cidr_block = local.prod_vpc_cidr
  tags = local.prod_tags
    
  enable_dns_hostnames      = true
  enable_dns_support        = true
}
###
# 5. user dmz
###
resource "aws_vpc" "user_dmz" {
    cidr_block = local.user_dmz_vpc_cidr
    tags = local.user_dmz_tags
    
    enable_dns_hostnames      = true
    enable_dns_support        = true
}