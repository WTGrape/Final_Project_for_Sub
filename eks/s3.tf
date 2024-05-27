###
# 1. Log storage for firehose
###

resource "aws_s3_bucket" "s3-kinesis-firehose" {
  for_each = var.firehose_connection
  force_destroy = true
  bucket = "s3-kinesis-firehose-${each.value.name}"
}
resource "aws_s3_bucket_lifecycle_configuration" "s3-lifecycle" {
  for_each = var.firehose_connection
  bucket = aws_s3_bucket.s3-kinesis-firehose[each.key].id
  rule {
    id      = "log"
    status  = "Enabled"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 1095
    }
  }
}
###
# 1-2. Log storage for firehose (aws-waf)
###

resource "aws_s3_bucket" "s3-kinesis-firehose-wafs" {
  for_each = var.firehose_connection_wafs
  force_destroy = true
  bucket = "aws-waf-logs-nadri-${each.value.name}"
}
resource "aws_s3_bucket_lifecycle_configuration" "s3-kinesis-firehose-wafs-lifecycle" {
  for_each = var.firehose_connection_wafs
  bucket = aws_s3_bucket.s3-kinesis-firehose-wafs[each.key].id
  rule {
    id      = "log"
    status  = "Enabled"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 1095
    }
  }
}
###
# 2. Log storage for cloudtrail
###

resource "aws_s3_bucket" "s3-cloudtrail" {
  bucket = "s3-nadri-cloudtrail"
  force_destroy = true
}
resource "aws_s3_bucket_lifecycle_configuration" "s3-lifecycle-cloudtrail" {
  bucket = aws_s3_bucket.s3-cloudtrail.id
  rule {
    id      = "log"
    status  = "Enabled"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 1095
    }
  }
}

resource "aws_s3_bucket_policy" "s3_cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.s3-cloudtrail.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AWSCloudTrailAclCheck",
        "Effect": "Allow",
        "Principal": {
          "Service": "cloudtrail.amazonaws.com"
        },
        "Action": "s3:GetBucketAcl",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.s3-cloudtrail.id}",
        "Condition": {
            "StringEquals": {
                "AWS:SourceArn": "arn:aws:cloudtrail:${local.region}:${data.aws_caller_identity.current.account_id}:trail/${var.trail}"
                }
                    }
      },
      {
        "Sid": "AWSCloudTrailWrite20150319",
        "Effect": "Allow",
        "Principal": {
          "Service": "cloudtrail.amazonaws.com"
        },
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.s3-cloudtrail.id}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        "Condition": {
          "StringEquals": {
            "s3:x-amz-acl": "bucket-owner-full-control",
            "AWS:SourceArn": "arn:aws:cloudtrail:${local.region}:${data.aws_caller_identity.current.account_id}:trail/${var.trail}"
          }
        }
      }
    ]
  })
  depends_on = [ aws_s3_bucket.s3-cloudtrail ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-cloudtrail" {
  bucket = aws_s3_bucket.s3-cloudtrail.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.sk108_kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
  depends_on = [ aws_s3_bucket.s3-cloudtrail ]
}