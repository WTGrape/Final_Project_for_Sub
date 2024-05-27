###
# 1. test dev
###
resource "aws_vpc_endpoint" "test_dev_interface_endpoint" {
  for_each = var.interface_endpoints
  vpc_id              = aws_vpc.test_dev.id
  service_name        = each.value.service_name
  vpc_endpoint_type   = each.value.type
  subnet_ids = aws_subnet.test_dev_node[*].id
  security_group_ids  = [
    aws_security_group.test_dev_endpoint.id,
  ]
  tags = {
    Name              = "test_dev-endpoint-${each.value.name}"
  }
  private_dns_enabled = each.value.name == "s3" ? false : true
}
###
# 2. production
###
resource "aws_vpc_endpoint" "prod_interface_endpoint" {
  for_each = var.interface_endpoints
  vpc_id              = aws_vpc.prod.id
  service_name        = each.value.service_name
  vpc_endpoint_type   = each.value.type
  subnet_ids = aws_subnet.prod_node[*].id
  security_group_ids  = [
    aws_security_group.prod_endpoint.id,
  ]
  tags = {
    Name              = "prod-endpoint-${each.value.name}"
  }
  private_dns_enabled = each.value.name == "s3" ? false : true
}