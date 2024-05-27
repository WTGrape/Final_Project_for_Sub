###
# 1. file destination
###
variable "dest1" {
  description = "dest of key"
  type        = string
  default     = "/home/ec2-user/.ssh/terraform-key"
  sensitive   = true
}
variable "dest2" {
  description = "nexus nginx.conf"
  type        = string
  default     = "/home/ec2-user/test_nginx.conf"
  sensitive   = true
}
variable "dest3" {
  description = "proxy"
  type        = string
  default     = "/home/ec2-user/prod_nginx.conf"
  sensitive   = true
}
variable "dest4" {
  description = "proxy"
  type        = string
  default     = "/home/ec2-user/nginx.conf"
  sensitive   = true
}
variable "dest5" {
  description = "proxy nginx.conf"
  type        = string
  default     = "/etc/nginx/nginx.conf"
  sensitive   = true
}
###
# 2. lambda
###
variable "lambda" {
  type = map(object({
    name        = string
  }))
  default = {
    "dev" = {
      name        = "dev-dmz"
    },
    "user" = {
      name        = "user-dmz"
    },
  }
}