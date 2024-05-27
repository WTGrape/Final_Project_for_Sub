locals {
  region      = "ap-northeast-2"
}
provider "aws" { 
  region      = local.region 
}
terraform { 
  required_providers { 
    aws = { 
      source  = "hashicorp/aws" 
      version = "~> 5.48.0" 
    } 
  }
  backend "s3" {
    bucket          = "nadri-tfstate"
    key             = "configuration/terraform.tfstate"
    region          = "ap-northeast-2"
    encrypt         = true
    dynamodb_table  = "TerraformStateLock"
    acl             = "bucket-owner-full-control"
  }
  required_version = "~> 1.3" 
}

###
# 1. monitoring
###
resource "null_resource" "install_monitoring" {
  triggers = {
    always_recreate = "${timestamp()}"
  }
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "ansible-inventory -i aws_lb_inventory.py --graph"
  }
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook playbook.yaml"
  }
}