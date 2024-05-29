terraform { 
  required_providers { 
    aws = { 
      source = "hashicorp/aws" 
      version = "~> 5.48.0" 
    } 
    random = { 
      source = "hashicorp/random" 
      version = "~> 3.4.3" 
    } 
    tls = { 
      source = "hashicorp/tls" 
      version = "~> 4.0.4" 
    } 
    cloudinit = { 
      source = "hashicorp/cloudinit" 
      version = "~> 2.2.0" 
    } 
    kubernetes = { 
      source = "hashicorp/kubernetes" 
      version = "~> 2.16.1" 
    } 
  }
  backend "s3" {
    bucket = "nadri-tfstate"
    key = "eks/terraform.tfstate"
    region = "ap-northeast-2"
    encrypt = true
    dynamodb_table  = "TerraformStateLock"
    acl = "bucket-owner-full-control"
  }
  required_version = "~> 1.3" 
} 