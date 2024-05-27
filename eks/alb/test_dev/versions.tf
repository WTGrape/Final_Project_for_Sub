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
    key = "alb/test_dev/terraform.tfstate"
    region = "ap-northeast-2"
    encrypt = true
    dynamodb_table  = "TerraformStateLock"
    acl = "bucket-owner-full-control"
  }
  required_version = "~> 1.3" 
} 
provider "helm" { 
  kubernetes { 
    host                   = data.aws_eks_cluster.test_dev_was.endpoint 
    token                  = data.aws_eks_cluster_auth.test_dev_was.token 
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.test_dev_was.certificate_authority[0].data) 
  } 
}
provider "kubernetes" {
  config_path    = "~/.kube/config"
}
