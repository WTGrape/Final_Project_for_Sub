###
# 1. node policy
###
resource "aws_iam_role_policy" "ECRFullAccess" {
  name = "node-ECR-FullAccess"
  role = aws_iam_role.was-node.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ecr:*"
        ],
        "Resource": "*"
      }
    ]
  })
}
###
# 2-1. EKS to Firehose (test_dev)
###
data "aws_iam_policy_document" "eks_test_dev_to_firehose_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.test_dev_was.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:logging:fluent-bit"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.test_dev_was.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.test_dev_was.arn]
      type        = "Federated"
    }
  }
}
###
# 2-2. EKS to Firehose (prod)
###
data "aws_iam_policy_document" "eks_prod_to_firehose_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.prod_was.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:logging:fluent-bit"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.prod_was.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.prod_was.arn]
      type        = "Federated"
    }
  }
}
###
# 3-1. Firehose to Openserch (Public)
###
data "aws_iam_policy_document" "firehose_to_opensearch_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_policy" "firehose-to-lambda" {
  name = "firehose-to-lambda"
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Action" : [
        "lambda:InvokeFunction",
        "lambda:GetFunctionConfiguration"
      ],
      "Resource" : "arn:aws:lambda:${local.region}:${data.aws_caller_identity.current.account_id}:function:*"
    }
  ]
})
}
###
# 3-2. policy for Opensearch (when VPC based, please add)
###
resource "aws_iam_policy" "firehose-to-vpc-opensearch" {
  name = "firehose-to-vpc-opensearch"
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeVpcs",
        "ec2:DescribeVpcAttribute",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface",
        "ec2:CreateNetworkInterfacePermission",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
})
}
###
# 4. policy for Cloudtrail to Cloudwatch
###
data "aws_iam_policy_document" "cloudtrail_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_policy" "cloudtrail-policy-1" {
  name = "cloudtrail-policy-1"
  policy = jsonencode(
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AWSCloudTrailCreateLogStream2014110",
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogStream"
        ],
        "Resource": [
          "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:${var.watch}:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_${local.region}"
        ]        
      },
      {            
        "Sid": "AWSCloudTrailPutLogEvents20141101",            
        "Effect": "Allow",            
        "Action": [                
          "logs:PutLogEvents"            
        ],            
        "Resource": [                
          "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:${var.watch}:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_${local.region}"
        ]
      }
    ]
}
)
}
###
# 5. Policy for Cloudwatch to Opensearch(Lambda)
###
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
###
# 6. policy for cloudwatch to firehose(rds)
###
data "aws_iam_policy_document" "cloudwatch_rds_logging-entity" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.${local.region}.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    condition {
      test = "StringLike"
      variable = "aws:SourceArn"
      values = [ "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:*" ]
    }
  }
}

resource "aws_iam_policy" "cloudwatch_rds_logging" {
  name = "cloudwatch-rds-logging"
  policy = jsonencode(
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "firehose:PutRecord",
                "firehose:PutRecordBatch"
            ],
            "Resource": [ 
              "arn:aws:firehose:${local.region}:${data.aws_caller_identity.current.account_id}:deliverystream/${aws_kinesis_firehose_delivery_stream.kinesis-firehose["test_dev_db"].name}",
              "arn:aws:firehose:${local.region}:${data.aws_caller_identity.current.account_id}:deliverystream/${aws_kinesis_firehose_delivery_stream.kinesis-firehose["prod_db"].name}"
            ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "*"
        }
    ]
  }  
)
  depends_on = [aws_kinesis_firehose_delivery_stream.kinesis-firehose ]
}
###
# 7. policy for lambda for firehose transformation
###
resource "aws_iam_policy" "lambda_to_firehose" {
  name = "lambda-to-firehose"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "firehose:PutRecord",
                "firehose:PutRecordBatch"
            ],
            "Resource": "arn:aws:firehose:${local.region}:${data.aws_caller_identity.current.account_id}:deliverystream/*"
        }
    ]
  })
}
resource "aws_iam_policy" "lambda_to_cloudwatch" {
  name = "lambda-to-cloudwatch"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "*"
      }
    ]
  })
}