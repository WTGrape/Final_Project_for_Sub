terraform { 
  required_providers { 
    aws = { 
      source = "hashicorp/aws" 
      version = "~> 5.48.0" 
    } 
  }
  backend "s3" {
    bucket = "nadri-tfstate"
    key = "networking/terraform.tfstate"
    region = "ap-northeast-2"
    encrypt = true
    dynamodb_table  = "TerraformStateLock"
    acl = "bucket-owner-full-control"
  }
  required_version = "~> 1.3" 
} 