###
# 1. KMS
###

resource "aws_kms_key" "sk108_kms" {
    description = "KMS key for sk108-team"
    is_enabled = true
    key_usage = "ENCRYPT_DECRYPT"
    customer_master_key_spec = "SYMMETRIC_DEFAULT"
    policy = jsonencode(   
{
    "Version": "2012-10-17",
    "Id": "Key policy created by CloudTrail",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/sk108-team"
                ]    
            },
            "Action": "kms:*",            
            "Resource": "*"
        },
        {
            "Sid": "Allow CloudTrail to encrypt logs",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "kms:GenerateDataKey*",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:SourceArn": "arn:aws:cloudtrail:${local.region}:${data.aws_caller_identity.current.account_id}:trail/${var.trail}"
                },
                "StringLike": {
                    "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
                }
            }
        },
        {
            "Sid": "Allow CloudTrail to describe key",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "kms:DescribeKey",
            "Resource": "*"
        },
        {
            "Sid": "Allow principals in the account to decrypt log files",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "kms:Decrypt",
                "kms:ReEncryptFrom"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}"
                },
                "StringLike": {
                    "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
                }
            }
        },
        {
            "Sid": "Allow alias creation during setup",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "kms:CreateAlias",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}",
                    "kms:ViaService": "ec2.${local.region}.amazonaws.com"
                }
            }
        },
        {
            "Sid": "Enable cross account log decryption",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [              
                "kms:Decrypt",
                "kms:ReEncryptFrom"        
            ],            
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}"
                },
                "StringLike": {
                    "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
                }    
            }
        },
        {
            "Sid": "Allow Cloudwatch log access",
            "Effect": "Allow",                              
            "Principal": {
                "Service": "logs.${local.region}.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt",                
                "kms:Decrypt",
                "kms:ReEncrypt",                
                "kms:GenerateDataKey",
                "kms:Describe"            
            ],            
            "Resource": "*",
            "Condition": {
                "ArnEquals": {
                    "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:*"
                }
            }
        }        
    ]
}
    )
}

resource "aws_kms_alias" "sk108_kms" {
    name = "alias/nadri-kms"
    target_key_id = aws_kms_key.sk108_kms.key_id
}

###
# 2. Cloudwatch log group
###

resource "aws_cloudwatch_log_group" "log_cloudtrail" {
  name = var.watch
  retention_in_days = 30
}
resource "aws_cloudwatch_log_group" "log_lambda" {
  depends_on = [ aws_cloudwatch_log_subscription_filter.cloudwatch_lambdafunction_logfilter ]
  name = "/aws/lambda/${aws_lambda_function.cloudwatch_to_opensearch.function_name}"
  retention_in_days = 30
}

###
# 3. Cloudtrail
###

resource "aws_cloudtrail" "cloudtrail" {
  depends_on = [
    aws_cloudwatch_log_group.log_cloudtrail,
    aws_s3_bucket.s3-cloudtrail  
  ]

  name                          = var.trail
  s3_bucket_name                = aws_s3_bucket.s3-cloudtrail.id
  include_global_service_events = false
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.log_cloudtrail.arn}:*"
  cloud_watch_logs_role_arn = aws_iam_role.role-cloudtrail-to-cloudwatch.arn
  kms_key_id = aws_kms_key.sk108_kms.arn

  event_selector {
    exclude_management_event_sources = [ "kms.amazonaws.com", "rdsdata.amazonaws.com" ]
    read_write_type = "All"
  }
}
