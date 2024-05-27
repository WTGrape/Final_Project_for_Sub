###
# 1. Key Variables 
###
variable "key_name" {
  description = "Name of the key pair"
  type        = string
  default     = "terraform-key"
  sensitive = true
}
variable "public_key_location" {
  description = "Location of the Public key"
  type        = string
  default     = "~/.ssh/terraform-key.pub"
  sensitive = true
}
variable "private_key_location" {
  description = "Location of the private key"
  type        = string
  default     = "~/.ssh/terraform-key"
  sensitive = true
}
###
# 2. file destination
###
variable "dest1" {
  description = "dest of key"
  type        = string
  default     = "/home/ec2-user/.ssh/terraform-key"
  sensitive   = true
}
variable "dest2" {
  description = "dest of aws"
  type        = string
  default     = "/home/ec2-user/.aws"
}
variable "dest3" {
  description = "dest of alb config"
  type        = string
  default     = "/home/ec2-user/alb"
}
###
# 3. firehose connection
###
variable "firehose_connection" {
  type = map(object({
    name        = string
    cloudwatch  = optional(bool)
    transname  = optional(string)
    lambda = optional(string)
    handler = optional(string)
  }))
  default = {
    "vpc_flow_shared" = {
      name = "vpc-flow-shared"
      lambda = "vpc_flow_shared"
      handler = "vpc-lambda"
    },
    "vpc_flow_test_dev" = {
      name = "vpc-flow-test-dev"
      lambda = "vpc_flow_test_dev"
      handler = "vpc-lambda"
    },
    "vpc_flow_prod" = {
      name = "vpc-flow-prod"
      lambda = "vpc_flow_prod"
      handler = "vpc-lambda"
    },
    "vpc_flow_user_dmz" = {
      name = "vpc-flow-user-dmz"
      lambda = "vpc_flow_user_dmz"
      handler = "vpc-lambda"
    },
    "vpc_flow_dev_dmz" = {
      name = "vpc-flow-dev-dmz"
      lambda = "vpc_flow_dev_dmz"
      handler = "vpc-lambda"
    },
    "vpc_flow_tgw" = {
      name = "vpc-flow-tgw"
      lambda = "vpc_flow_tgw"
      handler = "tgw-lambda"
    }
    "test_dev_eks" = {
      name = "test-dev-eks"
    }
    "prod_eks" = {
      name = "prod-eks"
    }
    "test_dev_db" = {
      name = "test-dev-db"
      cloudwatch = true
      transname = "trans-dev"
    }
    "prod_db" = {
      name = "prod-db"
      cloudwatch = true
      transname = "trans-prod"
    }
    "user_network_firewall" = {
      name = "user-nwf"
    }
    "dev_network_firewall" = {
      name = "dev-nwf"
    }
  }
}
variable "firehose_connection_wafs" {
  type = map(object({
    name = string
  }))
  default = {
    "alb-wacl" = {
      name = "alb-wacl"
    }
  }
}
###
# 4. names
###
variable "domain" {
  description = "name of opensearch"
  default = "nadri-opensearch"
}

variable "watch" {
  description = "name of cloudwatch Log group"
  default = "/aws/nadri-cloudtrail"
}

variable "trail" {
  description = "name of cloudtrail"
  default = "nadri-cloudtrail"
}
###
# 5. json transform
###
variable "transform" {
  type = map(object({
    name = string
  }))
  default = {
    "trans-dev" = {
      name = "trans-dev"  
    }
    "trans-prod" = {
      name = "trans-prod"
    }    
  }
}