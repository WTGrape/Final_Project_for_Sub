locals {
    tgw_name                = "final-vpc-tgw"
    dev_dmz_name            = "dev-dmz"
    shared_name             = "shared"
    test_dev_name           = "test-dev"
    prod_name               = "production"
    user_dmz_name           = "user-dmz"
    region                  = "ap-northeast-2"

    dev_dmz_vpc_cidr        = "10.10.0.0/16"
    shared_vpc_cidr         = "10.20.0.0/16"
    test_dev_vpc_cidr       = "10.30.0.0/16"
    prod_vpc_cidr           = "10.40.0.0/16"
    user_dmz_vpc_cidr       = "10.50.0.0/16"
    azs                     = ["ap-northeast-2a", "ap-northeast-2c"]

    dev_dmz_tags = {
        Name        = local.dev_dmz_name
        environment = "dmz"
    }
    shared_tags = {
        Name        = local.shared_name
        environment = "shared"
    }
    test_dev_tags = {
        Name        = local.test_dev_name
        environment = "stage"
    }
    prod_tags = {
        Name        = local.prod_name
        environment = "stage"
    }
    user_dmz_tags = {
        Name        = local.user_dmz_name
        environment = "dmz"
    }
    cf_origin_name          = ["user_dmz_group", "dev_dmz_group"]
    domain_name             = ["nadri-project.com", "www.nadri-project.com"]
    click_name              = ["nadri-project.click","www.nadri-project.click","argo.nadri-project.click"]
    
    wacl_name               = ["cf-wacl", "alb-wacl"]
    wacl_scope              = ["CLOUDFRONT", "REGIONAL"]
}