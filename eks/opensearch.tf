###
# 1. Amazon Opensearch Domain  (VPC based)
###
resource "aws_opensearch_domain" "log-opensearch" {
  domain_name    = var.domain
  engine_version = "OpenSearch_2.5"

  cluster_config {
    instance_type  = "c5.large.search"
    instance_count = 2
    zone_awareness_enabled = true
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = 10
  }

  vpc_options {
    subnet_ids = data.aws_subnets.shared_int.ids
    security_group_ids =  data.aws_security_groups.shared_opensearch.ids
  }

  encrypt_at_rest {
    enabled = true
  }
   
  node_to_node_encryption {
    enabled = true
  }
  
  domain_endpoint_options {
    enforce_https = true
    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
  }

  advanced_security_options {
    enabled = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name = "test"
      master_user_password = "Password@1234"
      }
  }

  access_policies = jsonencode(
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Principal": "*",
      "Effect": "Allow",
      "Resource": "arn:aws:es:${local.region}:${data.aws_caller_identity.current.account_id}:domain/${var.domain}/*"
    }
  ]
}
  )

  tags = {
    Name = "log-opensearch"
  }
}
###
# 2. opensearch vpc endpoint
###
resource "aws_opensearch_vpc_endpoint" "log-opensearch" {
  domain_arn = aws_opensearch_domain.log-opensearch.arn
  vpc_options {
    security_group_ids = data.aws_security_groups.shared_opensearch.ids
    subnet_ids         = data.aws_subnets.shared_int.ids
  }
}
# ###
# # Console Monitoring IAM policy attachment (On Public level)
# ###
# data "aws_iam_user" "sk108-team" {
#   user_name = "sk108-team"
# }

# resource "aws_iam_user_policy_attachment" "user-attach" {
#   user       = data.aws_iam_user.sk108-team.user_name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonOpenSearchServiceFullAccess"
# }