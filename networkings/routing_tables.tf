########################################################
###################### 1. dev dmz ######################
########################################################
resource "aws_route_table" "dev_dmz_igw_rt" {
  vpc_id                  = aws_vpc.dev_dmz.id 
  
  route {
    cidr_block            = aws_subnet.dev_dmz_nat[0].cidr_block
    network_interface_id  = data.aws_network_interface.dev_nwf_endpoints[0].id
  }
  route {
    cidr_block            = aws_subnet.dev_dmz_nat[1].cidr_block
    network_interface_id  = data.aws_network_interface.dev_nwf_endpoints[1].id
  }
  route {
    cidr_block            = aws_subnet.dev_dmz_lb[0].cidr_block
    network_interface_id  = data.aws_network_interface.dev_nwf_endpoints[0].id
  }
  route {
    cidr_block            = aws_subnet.dev_dmz_lb[1].cidr_block
    network_interface_id  = data.aws_network_interface.dev_nwf_endpoints[1].id
  }

  tags = {
    Name                = "${local.dev_dmz_name}-igw-RT"
  }
  depends_on = [
    data.aws_network_interface.dev_nwf_endpoints,
    aws_internet_gateway.dev_dmz_igw,
    aws_ec2_transit_gateway.main,
    aws_ec2_transit_gateway_vpc_attachment.dev_dmz
  ]
}
resource "aws_route_table" "dev_dmz_nwf_rt" {
  count                 = length(local.azs)
  vpc_id                = aws_vpc.dev_dmz.id 
  
  route {
    cidr_block          = "0.0.0.0/0"
    gateway_id          = aws_internet_gateway.dev_dmz_igw.id
  }
  # route {
  #   cidr_block          = "10.0.0.0/8"
  #   transit_gateway_id  = aws_ec2_transit_gateway.main.id
  # }


  tags = {
    Name                = "${local.dev_dmz_name}-nwf-RT-${count.index}"
  }
  depends_on = [
    aws_internet_gateway.dev_dmz_igw,
    aws_ec2_transit_gateway.main,
    aws_ec2_transit_gateway_vpc_attachment.dev_dmz
  ]
}
resource "aws_route_table" "dev_dmz_public_rt" {
  count                 = length(local.azs)
  vpc_id                = aws_vpc.dev_dmz.id 
  
  route {
    cidr_block          = "0.0.0.0/0"
    network_interface_id  = data.aws_network_interface.dev_nwf_endpoints[count.index].id
  }
  route {
    cidr_block          = "10.0.0.0/8"
    transit_gateway_id  = aws_ec2_transit_gateway.main.id
  }


  tags = {
    Name                = "${local.dev_dmz_name}-public-RT-${count.index}"
  }
  depends_on = [
    data.aws_network_interface.dev_nwf_endpoints,
    aws_ec2_transit_gateway.main,
    aws_ec2_transit_gateway_vpc_attachment.dev_dmz
  ]
}
resource "aws_route_table" "dev_dmz_proxy_rt" {
  count                 = length(local.azs)
  vpc_id                = aws_vpc.dev_dmz.id 
  
  route {
    cidr_block          = "0.0.0.0/0"
    nat_gateway_id      = aws_nat_gateway.dev_dmz_ngw.id
  }
  route {
    cidr_block          = "10.0.0.0/8"
    transit_gateway_id  = aws_ec2_transit_gateway.main.id
  }

  tags = {
    Name                = "${local.dev_dmz_name}-proxy-RT-${count.index}"
  }
  depends_on = [
    aws_nat_gateway.dev_dmz_ngw,
    aws_ec2_transit_gateway.main,
    aws_ec2_transit_gateway_vpc_attachment.dev_dmz
  ]
}
resource "aws_route_table" "dev_dmz_tgw_rt" {
  count                 = length(local.azs)
  vpc_id                = aws_vpc.dev_dmz.id 
  
  route {
    cidr_block          = "0.0.0.0/0"
    nat_gateway_id      = aws_nat_gateway.dev_dmz_ngw.id
  }

  tags = {
    Name                = "${local.dev_dmz_name}-tgw-RT-${count.index}"
  }
  depends_on = [
    aws_nat_gateway.dev_dmz_ngw,
    aws_ec2_transit_gateway.main
  ]
}

resource "aws_route_table_association" "dev_dmz_igw_asso" {
  gateway_id            = aws_internet_gateway.dev_dmz_igw.id
  route_table_id        = aws_route_table.dev_dmz_igw_rt.id

  depends_on = [
    aws_internet_gateway.dev_dmz_igw,
    aws_route_table.dev_dmz_igw_rt
  ]
}
resource "aws_route_table_association" "dev_dmz_nwf_subnet_asso" {
  count                 = length(local.azs)
  subnet_id             = element(aws_subnet.dev_dmz_nwf[*].id, count.index)
  route_table_id        = element(aws_route_table.dev_dmz_nwf_rt[*].id, count.index)

  depends_on = [
    aws_subnet.dev_dmz_nwf,
    aws_route_table.dev_dmz_nwf_rt
  ]
}
resource "aws_route_table_association" "dev_dmz_nat_subnet_asso" {
  count                 = length(local.azs)
  subnet_id             = element(aws_subnet.dev_dmz_nat[*].id, count.index)
  route_table_id        = element(aws_route_table.dev_dmz_public_rt[*].id, count.index)

  depends_on = [
    aws_subnet.dev_dmz_nat,
    aws_route_table.dev_dmz_public_rt
  ]
}
resource "aws_route_table_association" "dev_dmz_lb_subnet_asso" {
  count                 = length(local.azs)
  subnet_id             = element(aws_subnet.dev_dmz_lb[*].id, count.index)
  route_table_id        = element(aws_route_table.dev_dmz_public_rt[*].id, count.index)

  depends_on = [
    aws_subnet.dev_dmz_lb,
    aws_route_table.dev_dmz_public_rt
  ]
}
resource "aws_route_table_association" "dev_dmz_proxy_subnet_asso" {
  count                 = length(local.azs)
  subnet_id             = element(aws_subnet.dev_dmz_proxy[*].id, count.index)
  route_table_id        = element(aws_route_table.dev_dmz_proxy_rt[*].id, count.index)
  
  depends_on = [
    aws_route_table.dev_dmz_proxy_rt
  ]
}
resource "aws_route_table_association" "dev_dmz_tgw_subnet_asso" {
  count                 = length(local.azs)
  subnet_id             = element(aws_subnet.dev_dmz_tgw[*].id, count.index)
  route_table_id        = element(aws_route_table.dev_dmz_tgw_rt[*].id, count.index)
  
  depends_on = [
    aws_route_table.dev_dmz_tgw_rt
  ]
}
#######################################################
###################### 2. shared ######################
#######################################################
resource "aws_route_table" "nexus" {
  vpc_id = aws_vpc.shared.id 
  
  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.main.id
  }

  tags = {
    Name = "${local.shared_name}-nexus-RT"
  }
  depends_on = [
    aws_ec2_transit_gateway.main,
    aws_ec2_transit_gateway_vpc_attachment.shared
  ]
}
resource "aws_route_table_association" "nexus" {
  count = length(local.azs)
  subnet_id = element(aws_subnet.nexus[*].id, count.index)
  route_table_id = aws_route_table.nexus.id

  depends_on = [
    aws_route_table.nexus
  ]
}
resource "aws_route_table" "shared_int" {
  vpc_id = aws_vpc.shared.id 
  
  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.main.id
  }

  tags = {
    Name = "${local.shared_name}-int-RT"
  }
  depends_on = [
    aws_ec2_transit_gateway.main,
    aws_ec2_transit_gateway_vpc_attachment.shared
  ]
}
resource "aws_route_table_association" "shared_int" {
  count = length(local.azs)
  subnet_id = element(aws_subnet.shared_int[*].id, count.index)
  route_table_id = aws_route_table.shared_int.id

  depends_on = [
    aws_route_table.shared_int
    ]
}
resource "aws_route_table" "shared_tgw" {
  vpc_id = aws_vpc.shared.id 
  
  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.main.id
  }

  tags = {
    Name = "${local.shared_name}-subnet-tgw-RT"
  }
  depends_on = [
    aws_ec2_transit_gateway.main,
    aws_ec2_transit_gateway_vpc_attachment.shared
  ]
}
resource "aws_route_table_association" "shared_tgw" {
  count = length(local.azs)
  subnet_id = element(aws_subnet.shared_tgw[*].id, count.index)
  route_table_id = aws_route_table.shared_tgw.id

  depends_on = [
    aws_route_table.shared_tgw
  ]
}
#########################################################
###################### 3. test dev ######################
#########################################################
resource "aws_route_table" "test_dev" {
  vpc_id = aws_vpc.test_dev.id 
  
  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.main.id
  }

  tags = {
    Name = "${local.test_dev_name}-int-RT"
  }
  depends_on = [
    aws_ec2_transit_gateway.main,
    aws_ec2_transit_gateway_vpc_attachment.test_dev
  ]
}
resource "aws_route_table_association" "test_dev_subnet_asso" {
  count = length(local.azs)
  subnet_id = element(aws_subnet.test_dev_node[*].id, count.index)
  route_table_id = aws_route_table.test_dev.id

  depends_on = [
    aws_route_table.test_dev
    ]
}
resource "aws_route_table_association" "test_dev_db_subnet_asso" {
  count = length(local.azs)
  subnet_id = element(aws_subnet.test_dev_db[*].id, count.index)
  route_table_id = aws_route_table.test_dev.id

  depends_on = [
    aws_route_table.test_dev
    ]
}
resource "aws_route_table" "test_dev_tgw" {
  vpc_id = aws_vpc.test_dev.id 
  
  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.main.id
  }

  tags = {
    Name = "${local.test_dev_name}-subnet-tgw-RT"
  }
  depends_on = [
    aws_ec2_transit_gateway.main,
    aws_ec2_transit_gateway_vpc_attachment.test_dev
  ]
}
resource "aws_route_table_association" "test_dev_tgw" {
  count = length(local.azs)
  subnet_id = element(aws_subnet.test_dev_tgw[*].id, count.index)
  route_table_id = aws_route_table.test_dev_tgw.id

  depends_on = [
    aws_route_table.test_dev_tgw
    ]
}
###########################################################
###################### 4. production ######################
###########################################################
resource "aws_route_table" "prod" {
  vpc_id = aws_vpc.prod.id 
  
  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.main.id
  }

  tags = {
    Name = "${local.prod_name}-int-RT"
  }
  depends_on = [
    aws_ec2_transit_gateway.main,
    aws_ec2_transit_gateway_vpc_attachment.prod
  ]
}
resource "aws_route_table_association" "prod_subnet_asso" {
  count = length(local.azs)
  subnet_id = element(aws_subnet.prod_node[*].id, count.index)
  route_table_id = aws_route_table.prod.id

  depends_on = [
    aws_route_table.prod
  ]
}
resource "aws_route_table_association" "prod_db_subnet_asso" {
  count = length(local.azs)
  subnet_id = element(aws_subnet.prod_db[*].id, count.index)
  route_table_id = aws_route_table.prod.id

  depends_on = [
    aws_route_table.prod
  ]
}
resource "aws_route_table" "prod_tgw" {
  vpc_id = aws_vpc.prod.id 
  
  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.main.id
  }

  tags = {
    Name = "${local.prod_name}-subnet-tgw-RT"
  }
  depends_on = [
    aws_ec2_transit_gateway.main,
    aws_ec2_transit_gateway_vpc_attachment.prod
  ]
}
resource "aws_route_table_association" "prod_tgw" {
  count = length(local.azs)
  subnet_id = element(aws_subnet.prod_tgw[*].id, count.index)
  route_table_id = aws_route_table.prod_tgw.id

  depends_on = [
    aws_route_table.prod_tgw
    ]
}
#########################################################
###################### 5. user dmz ######################
#########################################################
resource "aws_route_table" "user_dmz_igw_rt" {
  vpc_id                = aws_vpc.user_dmz.id 
  
  route {
    cidr_block            = aws_subnet.user_dmz_nat[0].cidr_block
    network_interface_id  = data.aws_network_interface.user_nwf_endpoints[0].id
  }
  route {
    cidr_block            = aws_subnet.user_dmz_nat[1].cidr_block
    network_interface_id  = data.aws_network_interface.user_nwf_endpoints[1].id
  }
  route {
    cidr_block            = aws_subnet.user_dmz_lb[0].cidr_block
    network_interface_id  = data.aws_network_interface.user_nwf_endpoints[0].id
  }
  route {
    cidr_block            = aws_subnet.user_dmz_lb[1].cidr_block
    network_interface_id  = data.aws_network_interface.user_nwf_endpoints[1].id
  }


  tags = {
    Name                = "${local.user_dmz_name}-igw-RT"
  }
  depends_on = [
    data.aws_network_interface.user_nwf_endpoints,
    aws_internet_gateway.user_dmz_igw,
    aws_ec2_transit_gateway.main,
    aws_ec2_transit_gateway_vpc_attachment.user_dmz
  ]
}
resource "aws_route_table" "user_dmz_nwf_rt" {
  count                 = length(local.azs)
  vpc_id                = aws_vpc.user_dmz.id 
  
  route {
    cidr_block          = "0.0.0.0/0"
    gateway_id          = aws_internet_gateway.user_dmz_igw.id
  }
  # route {
  #   cidr_block          = "10.0.0.0/8"
  #   transit_gateway_id  = aws_ec2_transit_gateway.main.id
  # }


  tags = {
    Name                = "${local.user_dmz_name}-nwf-RT"
  }
  depends_on = [
    aws_internet_gateway.user_dmz_igw,
    aws_ec2_transit_gateway.main,
    aws_ec2_transit_gateway_vpc_attachment.user_dmz
  ]
}
resource "aws_route_table" "user_dmz_public_rt" {
  count                 = length(local.azs)
  vpc_id                = aws_vpc.user_dmz.id 
  
  route {
    cidr_block          = "0.0.0.0/0"
    network_interface_id  = data.aws_network_interface.user_nwf_endpoints[count.index].id
  }
  route {
    cidr_block          = "10.0.0.0/8"
    transit_gateway_id  = aws_ec2_transit_gateway.main.id
  }


  tags = {
    Name                = "${local.user_dmz_name}-public-RT-${count.index}"
  }
  depends_on = [
    #nwf endpoint 로 변경 예정
    data.aws_network_interface.dev_nwf_endpoints,
    aws_internet_gateway.user_dmz_igw,
    aws_ec2_transit_gateway.main,
    aws_ec2_transit_gateway_vpc_attachment.user_dmz
    ]
}
resource "aws_route_table" "user_dmz_proxy_rt" {
  count                 = length(local.azs)
  vpc_id                = aws_vpc.user_dmz.id 
  
  route {
    cidr_block          = "0.0.0.0/0"
    nat_gateway_id      = aws_nat_gateway.user_dmz_ngw.id
  }
  route {
    cidr_block          = "10.0.0.0/8"
    transit_gateway_id  = aws_ec2_transit_gateway.main.id
  }

  tags = {
    Name                = "${local.user_dmz_name}-proxy-RT-${count.index}"
  }
  depends_on = [
    aws_nat_gateway.user_dmz_ngw,
    aws_ec2_transit_gateway.main,
    aws_ec2_transit_gateway_vpc_attachment.user_dmz
    ]
}
resource "aws_route_table" "user_dmz_tgw_rt" {
  count                 = length(local.azs)
  vpc_id                = aws_vpc.user_dmz.id 
  
  route {
    cidr_block          = "0.0.0.0/0"
    nat_gateway_id      = aws_nat_gateway.user_dmz_ngw.id
  }

  tags = {
    Name                = "${local.user_dmz_name}-tgw-RT"
  }
  depends_on = [
    aws_nat_gateway.user_dmz_ngw,
    aws_ec2_transit_gateway.main,
    aws_ec2_transit_gateway_vpc_attachment.user_dmz
    ]
}

resource "aws_route_table_association" "user_dmz_igw_asso" {
  gateway_id            = aws_internet_gateway.user_dmz_igw.id
  route_table_id        = aws_route_table.user_dmz_igw_rt.id

  depends_on = [
    aws_internet_gateway.user_dmz_igw,
    aws_route_table.user_dmz_igw_rt
  ]
}
resource "aws_route_table_association" "user_dmz_nwf_subnet_asso" {
  count                 = length(local.azs)
  subnet_id             = element(aws_subnet.user_dmz_nwf[*].id, count.index)
  route_table_id        = element(aws_route_table.user_dmz_nwf_rt[*].id, count.index)

  depends_on = [
    aws_subnet.user_dmz_nwf,
    aws_route_table.user_dmz_nwf_rt
  ]
}
resource "aws_route_table_association" "user_dmz_nat_subnet_asso" {
  count                 = length(local.azs)
  subnet_id             = element(aws_subnet.user_dmz_nat[*].id, count.index)
  route_table_id        = element(aws_route_table.user_dmz_public_rt[*].id, count.index)

  depends_on = [
    aws_subnet.user_dmz_nat,
    aws_route_table.user_dmz_public_rt
    ]
}
resource "aws_route_table_association" "user_dmz_lb_subnet_asso" {
  count                 = length(local.azs)
  subnet_id             = element(aws_subnet.user_dmz_lb[*].id, count.index)
  route_table_id        = element(aws_route_table.user_dmz_public_rt[*].id, count.index)

  depends_on = [
    aws_subnet.user_dmz_lb,
    aws_route_table.user_dmz_public_rt
    ]
}
resource "aws_route_table_association" "user_dmz_proxy_subnet_asso" {
  count                 = length(local.azs)
  subnet_id             = element(aws_subnet.user_dmz_proxy[*].id, count.index)
  route_table_id        = element(aws_route_table.user_dmz_proxy_rt[*].id, count.index)
  
  depends_on = [
    aws_route_table.user_dmz_proxy_rt
    ]
}
resource "aws_route_table_association" "user_dmz_tgw_subnet_asso" {
  count                 = length(local.azs)
  subnet_id             = element(aws_subnet.user_dmz_tgw[*].id, count.index)
  route_table_id        = element(aws_route_table.user_dmz_tgw_rt[*].id, count.index)
  
  depends_on = [
    aws_route_table.user_dmz_tgw_rt
    ]
}