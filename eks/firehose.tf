###
# 1. Firehose
###
resource "aws_kinesis_firehose_delivery_stream" "kinesis-firehose" {
  for_each    = var.firehose_connection
  name        = "kinesis-firehose-${each.value.name}"
  destination = "opensearch"
  depends_on = [
   aws_iam_role.role-firehose-to-opensearch,
   aws_s3_bucket.s3-kinesis-firehose,
   aws_lambda_function.lambda_to_firehose,
   aws_lambda_function.lambda_to_firehose_vpc_flow
  ]  

  opensearch_configuration {
    domain_arn = aws_opensearch_domain.log-opensearch.arn
    role_arn   = aws_iam_role.role-firehose-to-opensearch.arn
    index_name = "${each.value.name}"
    index_rotation_period = "OneDay"
    buffering_size = 10
    buffering_interval = 400
    retry_duration = 300
    s3_backup_mode     = "AllDocuments"
    
    s3_configuration {
      role_arn           = aws_iam_role.role-firehose-to-opensearch.arn
      bucket_arn         = aws_s3_bucket.s3-kinesis-firehose[each.key].arn
      buffering_size     = 10
      buffering_interval = 400
      compression_format = "GZIP"
      prefix = "${each.value.name}"
      error_output_prefix = "err-${each.value.name}"
    }

    vpc_config {
      subnet_ids = data.aws_subnets.shared_int.ids
      security_group_ids = data.aws_security_groups.shared_firehose.ids
      role_arn = aws_iam_role.role-firehose-to-opensearch.arn
    }

    dynamic "processing_configuration" {
      for_each = each.value.lambda != null ? [1] :[]
      content{
        enabled = true
        processors {
          type = "Lambda"
          parameters {
            parameter_name = "LambdaArn"
            parameter_value = "${aws_lambda_function.lambda_to_firehose_vpc_flow[each.value.lambda].arn}:$LATEST"
          }
        }
      }
    }
    dynamic "processing_configuration" {
      for_each = each.value.transname != null ? [1] :[]
      content{
        enabled = true
        processors {
          type = "Lambda"
          parameters {
            parameter_name = "LambdaArn"
            parameter_value = "${aws_lambda_function.lambda_to_firehose[each.value.transname].arn}:$LATEST"
          }
        }
      }
    }
  }
}
resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_log_filter" {
  for_each        = { for k, v in var.firehose_connection : k => v if lookup(v, "cloudwatch", false) != null }
  name            = "rds_to_opensearch-${each.value.name}"
  role_arn        = aws_iam_role.role-cloudwatch-to-firehose-db.arn
  log_group_name  = "/aws/rds/instance/${each.value.name}/error"
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.kinesis-firehose[each.key].arn
  depends_on = [aws_kinesis_firehose_delivery_stream.kinesis-firehose ]
}
###
# 2. Firehose for WAFs
###
resource "aws_kinesis_firehose_delivery_stream" "wafs-kinesis-firehose" {
  for_each    = var.firehose_connection_wafs
  name        = "aws-waf-logs-${each.value.name}-kinesis-firehose"
  destination = "opensearch"
  depends_on = [
   aws_iam_role.role-firehose-to-opensearch,
   aws_s3_bucket.s3-kinesis-firehose-wafs
  ]  

  opensearch_configuration {
    domain_arn = aws_opensearch_domain.log-opensearch.arn
    role_arn   = aws_iam_role.role-firehose-to-opensearch.arn
    index_name = "aws-waf-logs-${each.value.name}"
    index_rotation_period = "OneDay"
    buffering_size = 10
    buffering_interval = 400
    retry_duration = 300
    s3_backup_mode     = "AllDocuments"
    
    s3_configuration {
      role_arn           = aws_iam_role.role-firehose-to-opensearch.arn
      bucket_arn         = aws_s3_bucket.s3-kinesis-firehose-wafs[each.key].arn
      buffering_size     = 10
      buffering_interval = 400
      compression_format = "GZIP"
      prefix = "${each.value.name}"
      error_output_prefix = "err-${each.value.name}"
    }

    vpc_config {
      subnet_ids = data.aws_subnets.shared_int.ids
      security_group_ids = data.aws_security_groups.shared_firehose.ids
      role_arn = aws_iam_role.role-firehose-to-opensearch.arn
    }
    processing_configuration {
        enabled = true
        processors {
          type = "Lambda"
          parameters {
            parameter_name = "LambdaArn"
            parameter_value = "${aws_lambda_function.lambda_to_firehose_waf.arn}:$LATEST"
          }
        }
    }
  }
}
###
# 3. Wafs to firehose connection
###
# resource "aws_wafv2_web_acl_logging_configuration" "cf-wacl" {
#   depends_on = [aws_kinesis_firehose_delivery_stream.wafs-kinesis-firehose["cf-wacl"]]
#   log_destination_configs = [aws_kinesis_firehose_delivery_stream.wafs-kinesis-firehose["cf-wacl"].arn]
#   resource_arn            = data.aws_wafv2_web_acl.cf_wacl.arn
# }

resource "aws_wafv2_web_acl_logging_configuration" "alb-wacl" {
  depends_on = [aws_kinesis_firehose_delivery_stream.wafs-kinesis-firehose["alb-wacl"]]
  log_destination_configs = [aws_kinesis_firehose_delivery_stream.wafs-kinesis-firehose["alb-wacl"].arn]
  resource_arn            = data.aws_wafv2_web_acl.alb_wacl.arn
}
###
# 4. NWF to firehose connection
###

resource "aws_networkfirewall_logging_configuration" "user_nwf_flow" {
  depends_on = [aws_kinesis_firehose_delivery_stream.kinesis-firehose["user_network_firewall"]]
  firewall_arn = data.aws_networkfirewall_firewall.user_network_firewall.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        deliveryStream = aws_kinesis_firehose_delivery_stream.kinesis-firehose["user_network_firewall"].name
      }
      log_destination_type = "KinesisDataFirehose"
      log_type             = "FLOW"
    }
    log_destination_config {
      log_destination = {
        deliveryStream = aws_kinesis_firehose_delivery_stream.kinesis-firehose["user_network_firewall"].name
      }
      log_destination_type = "KinesisDataFirehose"
      log_type             = "ALERT"
    }
  }
}

resource "aws_networkfirewall_logging_configuration" "dev_nwf_flow" {
  depends_on = [aws_kinesis_firehose_delivery_stream.kinesis-firehose["dev_network_firewall"]]
  firewall_arn = data.aws_networkfirewall_firewall.dev_network_firewall.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        deliveryStream = aws_kinesis_firehose_delivery_stream.kinesis-firehose["dev_network_firewall"].name
      }
      log_destination_type = "KinesisDataFirehose"
      log_type             = "FLOW"
    }
    log_destination_config {
      log_destination = {
        deliveryStream = aws_kinesis_firehose_delivery_stream.kinesis-firehose["dev_network_firewall"].name
      }
      log_destination_type = "KinesisDataFirehose"
      log_type             = "ALERT"
    }
  }
}