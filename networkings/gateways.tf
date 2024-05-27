###
# 1. dev dmz
###
resource "aws_eip" "dev_dmz_eip" {
  # count   = length(local.azs)
  vpc     = true

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_internet_gateway" "dev_dmz_igw" {
  vpc_id = aws_vpc.dev_dmz.id 
  
  tags = {
    Name = "${local.dev_dmz_name}-igw"
 }
}
resource "aws_nat_gateway" "dev_dmz_ngw" {
  # count               = length(local.azs)
  # allocation_id       = element(aws_eip.dev_dmz_eip[*].id,count.index)
  # subnet_id           = element(aws_subnet.dev_dmz_nat[*].id, count.index)
  allocation_id = aws_eip.dev_dmz_eip.id
  subnet_id = aws_subnet.dev_dmz_nat[0].id
  tags = {
    # Name = "${local.dev_dmz_name}-ngw-${count.index+1}"
    Name = "${local.dev_dmz_name}-ngw"
  }
 depends_on = [
    aws_internet_gateway.dev_dmz_igw,
    aws_eip.dev_dmz_eip
  ]
}
###
# 2. user dmz
###
resource "aws_eip" "user_dmz_eip" {
    # count   = length(local.azs)
    vpc     = true

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_internet_gateway" "user_dmz_igw" {
  vpc_id = aws_vpc.user_dmz.id 
  
  tags = {
    Name = "${local.user_dmz_name}-igw"
 }
}
resource "aws_nat_gateway" "user_dmz_ngw" {
    # count               = length(local.azs)
    # allocation_id       = element(aws_eip.user_dmz_eip[*].id,count.index)
    # subnet_id           = element(aws_subnet.user_dmz_nat[*].id, count.index)
    allocation_id = aws_eip.user_dmz_eip.id
    subnet_id = aws_subnet.user_dmz_nat[0].id
    tags = {
        # Name = "${local.user_dmz_name}-ngw-${count.index+1}"
        Name = "${local.user_dmz_name}-ngw"
    }
 depends_on = [
    aws_internet_gateway.user_dmz_igw,
    aws_eip.user_dmz_eip
    ]
}