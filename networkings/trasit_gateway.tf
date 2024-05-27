###
# 1. create transit gateway
###
resource "aws_ec2_transit_gateway" "main" {
  description = "connect various vpcs"

  auto_accept_shared_attachments = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = local.tgw_name
  }
}

###
# 2. transit gateway attachment
###
resource "aws_ec2_transit_gateway_vpc_attachment" "dev_dmz" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id = aws_vpc.dev_dmz.id
  subnet_ids = aws_subnet.dev_dmz_tgw[*].id

  tags = {
    Name = "dev_dmz_vpc_tgw_attache"
  }
  depends_on = [ aws_ec2_transit_gateway.main ]
}
resource "aws_ec2_transit_gateway_vpc_attachment" "shared" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id = aws_vpc.shared.id
  subnet_ids = aws_subnet.shared_tgw[*].id

  tags = {
    Name = "shared_vpc_tgw_attach"
  }
  depends_on = [ aws_ec2_transit_gateway.main ]
}
resource "aws_ec2_transit_gateway_vpc_attachment" "test_dev" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id = aws_vpc.test_dev.id
  subnet_ids = aws_subnet.test_dev_tgw[*].id

  tags = {
    Name = "test_dev_vpc_tgw_attach"
  }
  depends_on = [ aws_ec2_transit_gateway.main ]
}
resource "aws_ec2_transit_gateway_vpc_attachment" "prod" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id = aws_vpc.prod.id
  subnet_ids = aws_subnet.prod_tgw[*].id

  tags = {
    Name = "prod_vpc_tgw_attach"
  }
  depends_on = [ aws_ec2_transit_gateway.main ]
}
resource "aws_ec2_transit_gateway_vpc_attachment" "user_dmz" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id = aws_vpc.user_dmz.id
  subnet_ids = aws_subnet.user_dmz_tgw[*].id

  tags = {
    Name = "user_dmz_vpc_tgw_attach"
  }
  depends_on = [ aws_ec2_transit_gateway.main ]
}
###
# 3. transit gateway routing table
###
resource "aws_ec2_transit_gateway_route_table" "dev" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags      = {
    Name    = "dev-tgw-rt"
  }
  depends_on = [ aws_ec2_transit_gateway.main ]
}
resource "aws_ec2_transit_gateway_route_table" "shared" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags      = {
    Name    = "shared-tgw-rt"
  }
  depends_on = [ aws_ec2_transit_gateway.main ]
}
resource "aws_ec2_transit_gateway_route_table" "prod" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags      = {
    Name    = "prod-tgw-rt"
  }
  depends_on = [ aws_ec2_transit_gateway.main ]
}
###
# 4. routing table associations
# This is the link between a VPC (already symbolized with its attachment to the Transit Gateway)
#  and the Route Table the VPC's packet will hit when they arrive into the Transit Gateway.
# The Route Tables Associations do not represent the actual routes the packets are routed to.
# These are defined in the Route Tables Propagations section below.
###
resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-dev_dmz-assoc" {
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.dev_dmz.id
  transit_gateway_route_table_id  = aws_ec2_transit_gateway_route_table.dev.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.dev_dmz,
    aws_ec2_transit_gateway_route_table.dev
  ]
}
resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-shared-assoc" {
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.shared.id
  transit_gateway_route_table_id  = aws_ec2_transit_gateway_route_table.shared.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.shared,
    aws_ec2_transit_gateway_route_table.shared
  ]
}
resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-test_dev-assoc" {
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.test_dev.id
  transit_gateway_route_table_id  = aws_ec2_transit_gateway_route_table.dev.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.test_dev,
    aws_ec2_transit_gateway_route_table.dev
  ]
}
resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-prod-assoc" {
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.prod.id
  transit_gateway_route_table_id  = aws_ec2_transit_gateway_route_table.prod.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.prod,
    aws_ec2_transit_gateway_route_table.prod
  ]
}
resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-user_dmz-assoc" {
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.user_dmz.id
  transit_gateway_route_table_id  = aws_ec2_transit_gateway_route_table.prod.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.user_dmz,
    aws_ec2_transit_gateway_route_table.prod
  ]
}
###
# 5. routing table propagations
# This section defines which VPCs will be routed from each Route Table created in the Transit Gateway
###
# tgw-rt-dev
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-dev-to-dev_dmz_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_dmz.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dev.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.dev_dmz,
    aws_ec2_transit_gateway_route_table.dev
  ]
}
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-dev-to-shared_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dev.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.shared,
    aws_ec2_transit_gateway_route_table.dev
  ]
}
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-dev-to-test_dev_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.test_dev.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dev.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.test_dev,
    aws_ec2_transit_gateway_route_table.dev
  ]
}
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-dev-to-prod_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prod.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dev.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.user_dmz,
    aws_ec2_transit_gateway_route_table.dev
  ]
}
# tgw-rt-shared
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-shared-to-dev_dmz_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_dmz.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.dev_dmz,
    aws_ec2_transit_gateway_route_table.shared
  ]
}
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-shared-to-test_dev_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.test_dev.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.test_dev,
    aws_ec2_transit_gateway_route_table.shared
  ]
}
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-shared-to-prod_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prod.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-shared-to-user_dmz_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.user_dmz.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.user_dmz,
    aws_ec2_transit_gateway_route_table.shared
  ]
}
# tgw-rt-prod
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-prod-to-user_dmz_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.user_dmz.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.user_dmz,
    aws_ec2_transit_gateway_route_table.prod
  ]
}
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-prod-to-prod_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prod.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.prod,
    aws_ec2_transit_gateway_route_table.prod
  ]
}
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-prod-to-shared_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.shared,
    aws_ec2_transit_gateway_route_table.prod
  ]
}
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-prod-to-dev_dmz_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_dmz.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.dev_dmz,
    aws_ec2_transit_gateway_route_table.prod
  ]
}
###
# 6. transit gateway static route
###
resource "aws_ec2_transit_gateway_route" "dev" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_dmz.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dev.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.dev_dmz,
    aws_ec2_transit_gateway_route_table.dev
  ]
}
resource "aws_ec2_transit_gateway_route" "shared" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_dmz.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.dev_dmz,
    aws_ec2_transit_gateway_route_table.shared
  ]
}
resource "aws_ec2_transit_gateway_route" "prod" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.user_dmz.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod.id
  depends_on = [ 
    aws_ec2_transit_gateway_vpc_attachment.user_dmz,
    aws_ec2_transit_gateway_route_table.prod
  ]
}