provider "aws" { 
  region = local.region 
}
provider "aws" {
  alias = "virginia"
  region = "us-east-1"
}