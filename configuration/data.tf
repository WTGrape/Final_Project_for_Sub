###
# 1. loadbalancers
###
data "aws_lb" "dev_dmz_lb"{
    name  = "dev-dmz-nlb"
}
###
# 2. subnets
###
data "aws_subnets" "dev_dmz_proxy" {
    filter {
        name   = "tag:Identifier"
        values = ["dev-dmz-proxy"]
    }
    filter {
        name   = "state"
        values = ["available"]
    }
}
data "aws_subnets" "user_dmz_proxy" {
    filter {
        name   = "tag:Identifier"
        values = ["user-dmz-proxy"]
    }
    filter {
        name   = "state"
        values = ["available"]
    }
}
data "aws_subnets" "shared" {
    filter {
        name   = "tag:Identifier"
        values = ["subnet-nexus"]
    }
    filter {
        name   = "state"
        values = ["available"]
    }
}
###
# 3. proxy instances
###
data "aws_instances" "test_proxy"{
    filter {
      name = "subnet-id"
      values = data.aws_subnets.dev_dmz_proxy.ids
    }
    instance_tags = {
      Role = "proxy"
    }
}
data "aws_instances" "prod_proxy"{
    filter {
      name = "subnet-id"
      values = data.aws_subnets.user_dmz_proxy.ids
    }
    instance_tags = {
      Role = "proxy"
    }
}
###
# 4. Account ID
###
data "aws_caller_identity" "current" {}
###
# 6. vpc
###
data "aws_vpc" "shared" {
  filter {
    name   = "tag:Name"
    values = ["shared"]
  }
}
###
# 6. security group
###
data "aws_security_group" "shared_default" {
    vpc_id = data.aws_vpc.shared.id
    name = "default"
}
###
# 7. kms key
###
data "aws_kms_key" "by_alias" {
  key_id = "alias/nadri-kms-2"
}
###
# 8. eks cluster
###
data "aws_eks_cluster" "test_dev_was" {
  name = "test_dev_was"
}
data "aws_eks_cluster" "prod_was" {
  name = "prod_was"
}