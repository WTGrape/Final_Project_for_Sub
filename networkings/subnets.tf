###
# 1. dev dmz
###
resource "aws_subnet" "dev_dmz_nwf" {
  count               = length(local.azs)
  vpc_id              = aws_vpc.dev_dmz.id
  cidr_block          = cidrsubnet(local.dev_dmz_vpc_cidr, 8, count.index+0)
  availability_zone   = element(local.azs, count.index)

  tags = {
    Name = "${local.dev_dmz_name}-subnet-nwf-0${count.index+1}"
  }
  map_public_ip_on_launch = true
}
resource "aws_subnet" "dev_dmz_nat" {
  count               = length(local.azs)
  vpc_id              = aws_vpc.dev_dmz.id
  cidr_block          = cidrsubnet(local.dev_dmz_vpc_cidr, 8, count.index+50)
  availability_zone   = element(local.azs, count.index)

  tags = {
    Name = "${local.dev_dmz_name}-subnet-nat-0${count.index+1}"
  }
  map_public_ip_on_launch = true
}
resource "aws_subnet" "dev_dmz_lb" {
  count               = length(local.azs)
  vpc_id              = aws_vpc.dev_dmz.id
  cidr_block          = cidrsubnet(local.dev_dmz_vpc_cidr, 8, count.index+100)
  availability_zone   = element(local.azs, count.index)

  tags = {
    Name = "${local.dev_dmz_name}-subnet-lb-0${count.index+1}"
  }
  map_public_ip_on_launch = true
}
resource "aws_subnet" "dev_dmz_proxy" {
  count               = length(local.azs)
  vpc_id              = aws_vpc.dev_dmz.id
  cidr_block          = cidrsubnet(local.dev_dmz_vpc_cidr, 8, count.index+150)
  availability_zone   = element(local.azs, count.index)

  tags = {
    Name              = "${local.dev_dmz_name}-subnet-proxy-0${count.index+1}"
    Identifier        = "dev-dmz-proxy"
  }
}
resource "aws_subnet" "dev_dmz_tgw" {
  count               = length(local.azs)
  vpc_id              = aws_vpc.dev_dmz.id
  cidr_block          = cidrsubnet(local.dev_dmz_vpc_cidr, 8, count.index+200)
  availability_zone   = element(local.azs, count.index)

  tags = {
    Name = "${local.dev_dmz_name}-subnet-tgw-0${count.index+1}"
  }
}
###
# 2. shared
###
resource "aws_subnet" "nexus" {
    count               = length(local.azs)
    vpc_id              = aws_vpc.shared.id
    cidr_block          = cidrsubnet(local.shared_vpc_cidr, 8, count.index+10)
    availability_zone   = element(local.azs, count.index)

    tags = {
        Name            = "${local.shared_name}-subnet-nexus-0${count.index+1}"
        Identifier      = "subnet-nexus"
    }
}
resource "aws_subnet" "shared_int" {
    count               = length(local.azs)
    vpc_id              = aws_vpc.shared.id
    cidr_block          = cidrsubnet(local.shared_vpc_cidr, 8, count.index+100)
    availability_zone   = element(local.azs, count.index)

    tags = {
        Name = "${local.shared_name}-subnet-int-0${count.index+1}"
        Identifier      = "subnet-shared-int"
    }
}
resource "aws_subnet" "shared_tgw" {
    count               = length(local.azs)
    vpc_id              = aws_vpc.shared.id
    cidr_block          = cidrsubnet(local.shared_vpc_cidr, 8, count.index+200)
    availability_zone   = element(local.azs, count.index)

    tags = {
        Name = "${local.shared_name}-subnet-tgw-0${count.index+1}"
    }
}
###
# 3. test dev
###
resource "aws_subnet" "test_dev_node" {
  count               = length(local.azs)
  vpc_id              = aws_vpc.test_dev.id
  cidr_block          = cidrsubnet(local.test_dev_vpc_cidr, 8, count.index+10)
  availability_zone   = element(local.azs, count.index)

  tags = {
    Name                                  = "${local.test_dev_name}-subnet-node-0${count.index+1}"
    Identifier                            = "${local.test_dev_name}-subnet-node"
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/cluster/test_dev_was"  = "shared"
  }
}
resource "aws_subnet" "test_dev_db" {
  count               = length(local.azs)
  vpc_id              = aws_vpc.test_dev.id
  cidr_block          = cidrsubnet(local.test_dev_vpc_cidr, 8, count.index+100)
  availability_zone   = element(local.azs, count.index)

    tags = {
      Name = "${local.test_dev_name}-subnet-db-0${count.index+1}"
    }
}
resource "aws_subnet" "test_dev_tgw" {
  count               = length(local.azs)
  vpc_id              = aws_vpc.test_dev.id
  cidr_block          = cidrsubnet(local.test_dev_vpc_cidr, 8, count.index+200)
  availability_zone   = element(local.azs, count.index)

    tags = {
      Name = "${local.test_dev_name}-subnet-tgw-0${count.index+1}"
    }
}
###
# 4. production
###
resource "aws_subnet" "prod_node" {
  count               = length(local.azs)
  vpc_id              = aws_vpc.prod.id
  cidr_block          = cidrsubnet(local.prod_vpc_cidr, 8, count.index+10)
  availability_zone   = element(local.azs, count.index)

  tags = {
    Name                              = "${local.prod_name}-subnet-node-0${count.index+1}"
    Identifier                        = "${local.prod_name}-subnet-node"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/prod_was"  = "shared"
  }
}
resource "aws_subnet" "prod_db" {
  count               = length(local.azs)
  vpc_id              = aws_vpc.prod.id
  cidr_block          = cidrsubnet(local.prod_vpc_cidr, 8, count.index+100)
  availability_zone   = element(local.azs, count.index)

    tags = {
      Name = "${local.prod_name}-subnet-db-0${count.index+1}"
    }
}
resource "aws_subnet" "prod_tgw" {
  count               = length(local.azs)
  vpc_id              = aws_vpc.prod.id
  cidr_block          = cidrsubnet(local.prod_vpc_cidr, 8, count.index+200)
  availability_zone   = element(local.azs, count.index)

    tags = {
      Name = "${local.prod_name}-subnet-tgw-0${count.index+1}"
    }
}
###
# 5. user dmz
###
resource "aws_subnet" "user_dmz_nwf" {
  count               = length(local.azs)
  vpc_id              = aws_vpc.user_dmz.id
  cidr_block          = cidrsubnet(local.user_dmz_vpc_cidr, 8, count.index+0)
  availability_zone   = element(local.azs, count.index)

  tags = {
    Name = "${local.user_dmz_name}-subnet-nwf-0${count.index+1}"
  }
  map_public_ip_on_launch = true
}
resource "aws_subnet" "user_dmz_nat" {
  count               = length(local.azs)
  vpc_id              = aws_vpc.user_dmz.id
  cidr_block          = cidrsubnet(local.user_dmz_vpc_cidr, 8, count.index+50)
  availability_zone   = element(local.azs, count.index)

  tags = {
    Name = "${local.user_dmz_name}-subnet-nat-0${count.index+1}"
  }
  map_public_ip_on_launch = true
}
resource "aws_subnet" "user_dmz_lb" {
  count               = length(local.azs)
  vpc_id              = aws_vpc.user_dmz.id
  cidr_block          = cidrsubnet(local.user_dmz_vpc_cidr, 8, count.index+100)
  availability_zone   = element(local.azs, count.index)

  tags = {
    Name = "${local.user_dmz_name}-subnet-lb-0${count.index+1}"
  }
  map_public_ip_on_launch = true
}
resource "aws_subnet" "user_dmz_proxy" {
    count               = length(local.azs)
    vpc_id              = aws_vpc.user_dmz.id
    cidr_block          = cidrsubnet(local.user_dmz_vpc_cidr, 8, count.index+150)
    availability_zone   = element(local.azs, count.index)

    tags = {
        Name              = "${local.user_dmz_name}-subnet-proxy-0${count.index+1}"
        Identifier        = "user-dmz-proxy"
    }
}
resource "aws_subnet" "user_dmz_tgw" {
    count               = length(local.azs)
    vpc_id              = aws_vpc.user_dmz.id
    cidr_block          = cidrsubnet(local.user_dmz_vpc_cidr, 8, count.index+200)
    availability_zone   = element(local.azs, count.index)

    tags = {
        Name = "${local.user_dmz_name}-subnet-tgw-0${count.index+1}"
    }
}