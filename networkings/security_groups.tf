###
# 1. dev dmz
###
resource "aws_security_group" "dev_dmz_nlb" {
  name = "dev_dmz_nlb_sg" 
  description = "Security Group for dev_dmz_nlb" 
  vpc_id = aws_vpc.dev_dmz.id

  ingress {
    from_port     = 9999
    to_port       = 9999
    protocol      = "tcp"
    cidr_blocks   = ["0.0.0.0/0"]
  }
  ingress {
    from_port     = 443
    to_port       = 443
    protocol      = "tcp"
    cidr_blocks   = ["0.0.0.0/0"]
  }

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = merge(var.dmz_tags,var.dev_tags,
    {
      Name = "dev_dmz_nlb"
    }
  )
}
resource "aws_security_group_rule" "dev_dmz-prom_grafa" {
  for_each                  = { for k, v in var.shared_int : k => v if lookup(v, "svc_port", null) != null }
  security_group_id         = aws_security_group.dev_dmz_nlb.id
  type                      = "ingress"
  cidr_blocks               = ["0.0.0.0/0"]
  protocol                  = "tcp"
  from_port                 = each.value.dmz_listen
  to_port                   = each.value.dmz_listen
  depends_on                = [ aws_security_group.dev_dmz_nlb ]
}
resource "aws_security_group" "dev_dmz_alb" {
  name = "dev_dmz_alb_sg" 
  description = "Security Group for dev_dmz_alb" 
  vpc_id = aws_vpc.dev_dmz.id

  ingress {
    from_port     = 80
    to_port       = 80
    protocol      = "tcp"
    cidr_blocks   = ["0.0.0.0/0"]
  }
  # ingress {
  #   from_port     = 443
  #   to_port       = 443
  #   protocol      = "tcp"
  #   cidr_blocks   = ["0.0.0.0/0"]
  # }

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = merge(var.dmz_tags,var.dev_tags,
    {
      Name = "dev_dmz_alb"
    }
  )
}
resource "aws_security_group" "dev_dmz_proxy" {
  name = "dev_dmz_proxy_sg" 
  description = "Security Group for dev_dmz_proxy" 
  vpc_id = aws_vpc.dev_dmz.id

  ingress {
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
    cidr_blocks = aws_subnet.nexus[*].cidr_block
  }
  ingress {
    from_port     = 80
    to_port       = 80
    protocol      = "tcp"
    security_groups = [aws_security_group.dev_dmz_alb.id]
  }
  # ingress {
  #   from_port     = 443
  #   to_port       = 443
  #   protocol      = "tcp"
  #   security_groups = [aws_security_group.dev_dmz_alb.id]
  # }

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = merge(var.dmz_tags,var.dev_tags,
    {
      Name = "dev_dmz_proxy-sg"
    }
  )
}
###
# 2. shared
###
resource "aws_security_group" "nexus" {
  name = "nexus_sg" 
  description = "Security Group for nexus" 
  vpc_id = aws_vpc.shared.id

  ingress {
  from_port     = 22
  to_port       = 22
  protocol      = "tcp"
  security_groups = [aws_security_group.shared_ext_lb.id]
  }

  egress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = merge(var.shared_tags,var.dev_tags,
    {
      Name = "nexus_sg"
    }
  )
}
resource "aws_security_group" "shared_ext_lb" {
  name = "shared_ext_lb_sg" 
  description = "Security Group for shared_ext_lb" 
  vpc_id = aws_vpc.shared.id

  ingress {
  from_port     = 5000
  to_port       = 5000
  protocol      = "tcp"
  cidr_blocks   = aws_subnet.dev_dmz_lb[*].cidr_block
  }

  egress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = merge(var.shared_tags,var.dev_tags,
    {
      Name = "shared_ext_lb_sg"
    }
  )
}
resource "aws_security_group_rule" "prom_grafa_listener" {
  for_each                  = { for k, v in var.shared_int : k => v if lookup(v, "listener", null) != null }
  security_group_id         = aws_security_group.shared_ext_lb.id
  type                      = "ingress"
  cidr_blocks               = aws_subnet.dev_dmz_lb[*].cidr_block
  protocol                  = "tcp"
  from_port                 = each.value.listener
  to_port                   = each.value.listener
  depends_on                = [ aws_security_group.shared_ext_lb ]
}
resource "aws_security_group" "shared_int_default" {
  name = "shared_shared_int_default_sg" 
  description = "Security Group for shared_int" 
  vpc_id = aws_vpc.shared.id
  ingress {
  from_port     = 22
  to_port       = 22
  protocol      = "tcp"
  security_groups = [aws_security_group.shared_int_lb.id]
  }
  egress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = merge(var.shared_tags,var.dev_tags,
    {
      Name = "shared_int_default_sg"
    }
  )
}
resource "aws_security_group" "shared_int_prom-grafa" {
  name                      = "shared_int_prom-grafa" 
  description               = "Security Group for shared_int_prom-grafa" 
  vpc_id                    = aws_vpc.shared.id
  tags = merge(var.shared_tags,var.dev_tags,
    {
      Name = "shared_int_prom-grafa_sg"
    }
  )
}
resource "aws_security_group_rule" "prom_grafa" {
  for_each                  = { for k, v in var.shared_int : k => v if lookup(v, "svc_port", null) != null }
  security_group_id         = aws_security_group.shared_int_prom-grafa.id
  type                      = "ingress"
  source_security_group_id  = aws_security_group.shared_ext_lb.id
  protocol                  = "tcp"
  from_port                 = each.value.svc_port
  to_port                   = each.value.svc_port
}
resource "aws_security_group" "shared_int_lb" {
  name = "shared_int_lb_sg" 
  description = "Security Group for shared_int_lb" 
  vpc_id = aws_vpc.shared.id

  egress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = merge(var.shared_tags,var.dev_tags,
    {
      Name = "shared_int_lb_sg"
    }
  )
}
resource "aws_security_group_rule" "shared_int_lb" {
  for_each                  = { for k, v in var.shared_int : k => v if lookup(v, "port", null) != null }
  security_group_id         = aws_security_group.shared_int_lb.id
  type                      = "ingress"
  source_security_group_id  = aws_security_group.nexus.id
  protocol                  = "tcp"
  from_port                 = each.value.port
  to_port                   = each.value.port
}
resource "aws_security_group" "shared_opensearch" {
  name = "shared_opensearch_sg" 
  description = "Security Group for opensearch" 
  vpc_id = aws_vpc.shared.id

  ingress {
  from_port     = 22
  to_port       = 22
  protocol      = "tcp"
  security_groups = [aws_security_group.nexus.id]
  }
 
  ingress {
  from_port     = 443
  to_port       = 443
  protocol      = "tcp"
  cidr_blocks   = ["0.0.0.0/0"]
  }  

  egress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = merge(var.shared_tags,var.dev_tags,
    {
      Name = "shared_opensearch_sg"
    }
  )
}
resource "aws_security_group" "shared_firehose" {
  name = "shared_firehose_sg"
  description = "Security Group for shared_firehose" 
  vpc_id = aws_vpc.shared.id
  
  ingress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = [ "10.0.0.0/8" ]
  }
  
  egress {
  from_port     = 443
  to_port       = 443
  protocol      = "TCP"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = {
    Name = "shared_firehose_sg"
  }
}
###
# 3. test dev
###
resource "aws_security_group" "test_dev_endpoint" {
  name = "test-dev-endpoint-sg"
  description = "Security Group for test_dev_endpoint" 
  vpc_id = aws_vpc.test_dev.id
  
  ingress {
  from_port     = 443
  to_port       = 443
  protocol      = "tcp"
  cidr_blocks   = [ "10.0.0.0/8" ]
  }
  
  egress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = {
    Name = "test_dev_endpoint_sg"
  }
}
resource "aws_security_group" "test_dev_cluster" {
  name = "test-dev-cluster-sg"
  description = "Security Group for test_dev_cluster" 
  vpc_id = aws_vpc.test_dev.id
  
  ingress {
  from_port     = 443
  to_port       = 443
  protocol      = "tcp"
  cidr_blocks   = [ "10.0.0.0/8" ]
  }
  
  egress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = {
    Name                                  = "test_dev_cluster_sg"
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/cluster/test_dev_was"  = "shared"
  }
}
resource "aws_security_group" "test_dev_monitor" {
  name = "test-dev-monitor-sg"
  description = "Security Group for test_dev_monitoring" 
  vpc_id = aws_vpc.test_dev.id
  
  ingress {
  from_port     = 9100
  to_port       = 9100
  protocol      = "tcp"
  cidr_blocks   = [ local.shared_vpc_cidr ]
  }
  
  egress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = {
    Name                                  = "test_dev_monitor_sg"
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/cluster/test_dev_was"  = "shared"
  }
}
resource "aws_security_group" "test_dev_pod_to_db" {
  name = "test-dev-pod-to-db-sg"
  description = "Security Group for test_dev pod using db" 
  vpc_id = aws_vpc.test_dev.id
  
  egress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = {
    Name                                  = "test_dev_pod_db_sg"
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/cluster/test_dev_was"  = "shared"
  }
}
resource "aws_security_group" "test_dev_db" {
  name = "project_db" 
  description = "Security Group for RDS DB" 
  vpc_id = aws_vpc.test_dev.id

  ingress {
  from_port     = 3306 
  to_port       = 3306
  protocol      = "tcp"
  cidr_blocks  = aws_subnet.shared_int[*].cidr_block 
  }
  ingress {
  from_port     = 3306 
  to_port       = 3306
  protocol      = "tcp"
  cidr_blocks  = aws_subnet.test_dev_node[*].cidr_block
  }
  
  egress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = {
    Name = "test_dev_db_sg"
  }
}
###
# 4. production
###
resource "aws_security_group" "prod_endpoint" {
  name = "prod-endpoint-sg"
  description = "Security Group for prod_endpoint" 
  vpc_id = aws_vpc.prod.id
  
  ingress {
  from_port     = 443
  to_port       = 443
  protocol      = "tcp"
  cidr_blocks   = [ "10.0.0.0/8" ]
  }
  
  egress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = {
    Name = "prod_endpoint_sg"
  }
}
resource "aws_security_group" "prod_cluster" {
  name = "prod-cluster-sg"
  description = "Security Group for prod_cluster" 
  vpc_id = aws_vpc.prod.id
  
  ingress {
  from_port     = 443
  to_port       = 443
  protocol      = "tcp"
  cidr_blocks   = [ "10.0.0.0/8" ]
  }
  
  egress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = {
    Name                              = "prod_cluster_sg"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/prod_was"  = "shared"
  }
}
resource "aws_security_group" "prod_monitor" {
  name = "prod-monitor-sg"
  description = "Security Group for prod_monitoring" 
  vpc_id = aws_vpc.prod.id
  
  ingress {
  from_port     = 9100
  to_port       = 9100
  protocol      = "tcp"
  cidr_blocks   = [ local.shared_vpc_cidr ]
  }
  
  egress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = {
    Name                                  = "prod_monitor_sg"
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/cluster/prod_was"  = "shared"
  }
}
resource "aws_security_group" "prod_pod_to_db" {
  name = "test-dev-pod-db-sg"
  description = "Security Group for prod pod using db" 
  vpc_id = aws_vpc.prod.id
  
  egress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = {
    Name                                  = "prod_pod_db_sg"
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/cluster/prod_was"  = "shared"
  }
}
resource "aws_security_group" "prod_db" {
  name = "project_db" 
  description = "Security Group for RDS DB" 
  vpc_id = aws_vpc.prod.id

  ingress {
  from_port     = 3306 
  to_port       = 3306
  protocol      = "tcp"
  cidr_blocks  = aws_subnet.shared_int[*].cidr_block 
  }
  ingress {
  from_port     = 3306 
  to_port       = 3306
  protocol      = "tcp"
  cidr_blocks  = aws_subnet.prod_node[*].cidr_block
  }
  
  egress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = {
    Name = "prod_db_sg"
  }
}
###
# 5. user dmz
###
resource "aws_security_group" "dmz_user_alb" {
  name = "dmz_user_alb_sg" 
  description = "Security Group for dmz_user_alb" 
  vpc_id = aws_vpc.user_dmz.id


  ingress {
  from_port     = 80
  to_port       = 80
  protocol      = "tcp"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  # ingress {
  # from_port     = 443
  # to_port       = 443
  # protocol      = "tcp"
  # cidr_blocks   = ["0.0.0.0/0"]
  # }

  egress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = merge(var.dmz_tags,var.user_tags,
    {
      Name = "dmz_user_alb"
    })
}
resource "aws_security_group" "user_dmz_proxy" {
  name = "user_dmz_proxy_sg" 
  description = "Security Group for user_dmz_proxy" 
  vpc_id = aws_vpc.user_dmz.id

  ingress {
  from_port     = 22
  to_port       = 22
  protocol      = "tcp"
  cidr_blocks = aws_subnet.nexus[*].cidr_block
  }
  ingress {
  from_port     = 80
  to_port       = 80
  protocol      = "tcp"
  security_groups = [aws_security_group.dmz_user_alb.id]
  }
  # ingress {
  # from_port     = 443
  # to_port       = 443
  # protocol      = "tcp"
  # security_groups = [aws_security_group.dmz_user_alb.id]
  # }

  egress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = merge(var.dmz_tags,var.user_tags,
    {
      Name = "user-dmz-proxy"
    }
  )
}