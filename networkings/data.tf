###
# 1. amazon linux 2023 AMI
###
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

###
# 2. load balancer eni private ip
###
# develope dmz network loadbalancer
data "aws_network_interface" "dev_dmz_nlb" {
count = 2

  filter {
    name   = "description"
    values = ["ELB net/${aws_lb.dev_dmz_nlb.name}/*"]
  }
  filter {
    name   = "subnet-id"
    values = [ aws_subnet.dev_dmz_lb[count.index].id ]
  }
}
# shared internal loadbalancer
data "aws_network_interface" "shared_ext" {
count = 2

  filter {
    name   = "description"
    values = ["ELB net/${aws_lb.shared_ext.name}/*"]
  }
  filter {
    name   = "subnet-id"
    values = [ aws_subnet.shared_tgw[count.index].id ]
  }
}
### 
# 3. network firewall network interface
###
data "aws_network_interface" "user_nwf_endpoints" {
  count     = length(local.azs)
  filter {
    name    = "interface-type"
    values  = ["gateway_load_balancer_endpoint"]
  }

  filter {
    name    = "vpc-id"
    values  = [ aws_vpc.user_dmz.id ]
  }
  filter {
    name   = "subnet-id"
    values = [ aws_subnet.user_dmz_nwf[count.index].id ]
  }
  depends_on = [ 
    aws_networkfirewall_firewall.user_network_firewall
  ]  
}  

data "aws_network_interface" "dev_nwf_endpoints" {
  count     = length(local.azs)
  filter {
    name    = "interface-type"
    values  = ["gateway_load_balancer_endpoint"]
  }

  filter {
    name   = "vpc-id"
    values = [ aws_vpc.dev_dmz.id ]
  }  
  filter {
    name   = "subnet-id"
    values = [ aws_subnet.dev_dmz_nwf[count.index].id ]
  }
  depends_on = [ 
    aws_networkfirewall_firewall.dev_network_firewall
  ]  
}  