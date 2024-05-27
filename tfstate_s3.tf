provider "aws" { 
  region = "ap-northeast-2"
}
terraform { 
  required_providers { 
    aws = { 
      source = "hashicorp/aws" 
      version = "~> 5.48.0" 
    } 
  } 
  required_version = "~> 1.3" 
} 
resource "aws_dynamodb_table" "terraform_state_lock" {
  name = "TerraformStateLock"
  read_capacity = 5
  write_capacity = 5
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
// 로그 저장용 버킷
resource "aws_s3_bucket" "logs" {
  bucket = "nadri-tfstate-logs"
  tags =  {
    Name = "nadri-tfstate-logs"
  }
}
resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_acl" "logs" {
  bucket  = aws_s3_bucket.logs.id
  acl     = "log-delivery-write"
  depends_on = [ aws_s3_bucket_ownership_controls.logs ]
}
// Terraform state 저장용 S3 버킷
resource "aws_s3_bucket" "terraform-state" {
  bucket = "nadri-tfstate"
  tags =  {
    Name = "nadri-tfstate"
  }
  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_s3_bucket_logging" "terraform-state" {
  bucket = aws_s3_bucket.terraform-state.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "log/"
}
resource "aws_s3_bucket_versioning" "terraform-state" {
  bucket = aws_s3_bucket.terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }
}