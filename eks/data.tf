###
# 1. subnets
###
data "aws_subnets" "test_dev_node" {
  filter {
    name   = "tag:Identifier"
    values = ["test-dev-subnet-node"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_subnets" "prod_node" {
  filter {
    name   = "tag:Identifier"
    values = ["production-subnet-node"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_subnets" "shared_int" {
  filter {
    name   = "tag:Identifier"
    values = ["subnet-shared-int"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
data "aws_subnet" "shared_int" {
  for_each = toset(data.aws_subnets.shared_int.ids)
  id       = each.value
}
###
# 2. security group
###
data "aws_security_groups" "test_dev_cluster" {
  filter {
    name   = "tag:Name"
    values = ["test_dev_cluster_sg"]
  }
}
data "aws_security_groups" "prod_cluster" {
  filter {
    name   = "tag:Name"
    values = ["prod_cluster_sg"]
  }
}
data "aws_security_groups" "test_dev_monitor" {
  filter {
    name   = "tag:Name"
    values = ["test-dev-monitor-sg"]
  }
}
data "aws_security_groups" "prod_monitor" {
  filter {
    name   = "tag:Name"
    values = ["prod_monitor_sg"]
  }
}
data "aws_security_groups" "shared_opensearch" {
  filter {
    name   = "tag:Name"
    values = ["shared_opensearch_sg"]
  }
}
data "aws_security_groups" "shared_firehose" {
  filter {
    name   = "tag:Name"
    values = ["shared_firehose_sg"]
  }
}
###
# 3. assume_role
###
data "aws_iam_policy_document" "cluster_assume_role" { 
  statement { 
    effect = "Allow" 
    principals { 
      type        = "Service" 
      identifiers = ["eks.amazonaws.com"] 
    } 
    actions = ["sts:AssumeRole"] 
  } 
}
data "aws_iam_policy_document" "node_assume_role" { 
  statement { 
    effect = "Allow" 
    principals { 
      type        = "Service" 
      identifiers = ["ec2.amazonaws.com"] 
    } 
    actions = ["sts:AssumeRole"] 
  } 
}
###
# 4. dns name
###
data "aws_lb" "dev_dmz_lb"{
  name  = "dev-dmz-nlb"
}
data "aws_lb" "shared_int_lb"{
  name  = "shared-int-lb"
}
###
# 5. key pair
###
data "aws_key_pair" "example" {
  key_name           = "terraform-key"
  include_public_key = true
}
###
# 6. Account ID
###
data "aws_caller_identity" "current" {}
###
# 7. vpc
###
data "aws_vpc" "dev_dmz" {
  filter {
    name   = "tag:Name"
    values = ["dev-dmz"]
  }
}
data "aws_vpc" "shared" {
  filter {
    name   = "tag:Name"
    values = ["shared"]
  }
}
data "aws_vpc" "test_dev" {
  filter {
    name   = "tag:Name"
    values = ["test-dev"]
  }
}
data "aws_vpc" "prod" {
  filter {
    name   = "tag:Name"
    values = ["production"]
  }
}
data "aws_vpc" "user_dmz" {
  filter {
    name   = "tag:Name"
    values = ["user-dmz"]
  }
}
###
# 8. transit gateway
###
data "aws_ec2_transit_gateway" "main" {
  filter {
    name   = "tag:Name"
    values = ["final-vpc-tgw"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }  
}
###
# 9. RDS
###
data "aws_cloudwatch_log_group" "test-dev-db" {
  name = "/aws/rds/instance/test-dev-db/error"
}
data "aws_cloudwatch_log_group" "prod-db" {
  name = "/aws/rds/instance/prod-db/error"
}
data "aws_cloudwatch_log_groups" "test" {
  log_group_name_prefix = "/aws/rds/instance/"
}
###
# 10. Lambda
###
data "template_file" "index_js" {
  template = file("../files/index.js.j2")
  vars = {
    opensearch_endpoint = aws_opensearch_domain.log-opensearch.endpoint
  }
  depends_on = [ aws_opensearch_domain.log-opensearch ]
}
resource "local_file" "index_js" {
  content  = data.template_file.index_js.rendered
  filename = "../files/index.js"
  depends_on = [ data.template_file.index_js ]
}
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "../files/index.js"
  output_path = "../files/lambda.zip"
  depends_on = [ 
    aws_opensearch_domain.log-opensearch,
    local_file.index_js
  ]
}
data "archive_file" "transform" {
  for_each    = var.transform
  type        = "zip"
  source_file = "../files/${each.value.name}.py"
  output_path = "../files${each.value.name}.zip"
  depends_on = [ 
    aws_opensearch_domain.log-opensearch
  ]
}
data "archive_file" "vpc_transform" {
  for_each      = { for k, v in var.firehose_connection : k => v if lookup(v, "lambda", false) != null }
  type        = "zip"
  source_file = "../files/${each.value.handler}.py"
  output_path = "../files/${each.value.handler}.zip"
  depends_on = [ 
    aws_opensearch_domain.log-opensearch
  ]
}

data "archive_file" "waf_transform" {
  type        = "zip"
  source_file = "../files/waf-lambda.py"
  output_path = "../files/waf-lambda.zip"
  depends_on = [
    aws_opensearch_domain.log-opensearch
  ]
}
###
# 10. Wafs
###
data "aws_wafv2_web_acl" "alb_wacl" {
  name = "alb-wacl"
  scope = "REGIONAL"
}
###
# 12. NWF
###
data "aws_networkfirewall_firewall" "user_network_firewall" {
  name = "user-dmz-nwf"
}
data "aws_networkfirewall_firewall" "dev_network_firewall" {
  name = "dev-dmz-nwf"
}