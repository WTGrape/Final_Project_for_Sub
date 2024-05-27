###
# 1. test develope relem
###
resource "aws_eks_cluster" "test_dev_was" { 
  name     = "test_dev_was"
  role_arn = aws_iam_role.was-cluster.arn 
  vpc_config { 
    subnet_ids              = data.aws_subnets.test_dev_node.ids
    security_group_ids      = data.aws_security_groups.test_dev_cluster.ids
    endpoint_private_access = true
    endpoint_public_access  = false
  } 
 
# Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling. 
# Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups. 

  depends_on = [ 
    aws_iam_role_policy_attachment.was-AmazonEKSClusterPolicy, 
    aws_iam_role_policy_attachment.was-AmazonEKSVPCResourceController, 
    # aws_cloudwatch_log_group.test_dev_was 
  ] 
  enabled_cluster_log_types = ["api", "audit"] 
} 

data "tls_certificate" "test_dev_was" { 
  url = aws_eks_cluster.test_dev_was.identity[0].oidc[0].issuer 
}
resource "aws_iam_openid_connect_provider" "test_dev_was" { 
  client_id_list  = ["sts.amazonaws.com"] 
  thumbprint_list = [data.tls_certificate.test_dev_was.certificates[0].sha1_fingerprint] 
  url             = data.tls_certificate.test_dev_was.url 
}
resource "aws_security_group_rule" "dev-node-exporter" {
  security_group_id         = aws_eks_cluster.test_dev_was.vpc_config[0].cluster_security_group_id
  type                      = "ingress"
  cidr_blocks               = [for s in data.aws_subnet.shared_int : s.cidr_block]
  protocol                  = "tcp"
  from_port                 = 9100
  to_port                   = 9100
  depends_on = [ 
    aws_eks_cluster.test_dev_was,
    aws_eks_node_group.test_dev_was
  ]
}
resource "aws_security_group_rule" "dev-kube-state-metrics" {
  security_group_id         = aws_eks_cluster.test_dev_was.vpc_config[0].cluster_security_group_id
  type                      = "ingress"
  cidr_blocks               = [for s in data.aws_subnet.shared_int : s.cidr_block]
  protocol                  = "tcp"
  from_port                 = 31569
  to_port                   = 31569
  depends_on = [ 
    aws_eks_cluster.test_dev_was,
    aws_eks_node_group.test_dev_was
  ]
}
# 2. production relem
###
resource "aws_eks_cluster" "prod_was" { 
  name     = "prod_was"
  role_arn = aws_iam_role.was-cluster.arn 
  vpc_config { 
    subnet_ids              = data.aws_subnets.prod_node.ids
    security_group_ids      = data.aws_security_groups.prod_cluster.ids
    endpoint_private_access = true
    endpoint_public_access  = false
  } 
 
# Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling. 
# Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups. 

  depends_on = [ 
    aws_iam_role_policy_attachment.was-AmazonEKSClusterPolicy, 
    aws_iam_role_policy_attachment.was-AmazonEKSVPCResourceController, 
    # aws_cloudwatch_log_group.prod_was 
  ] 
  enabled_cluster_log_types = ["api", "audit"] 
} 
# resource "aws_cloudwatch_log_group" "prod_was" { 
#   name              = "/aws/eks/prod_was/cluster" 
#   retention_in_days = 7 
# } 
data "tls_certificate" "prod_was" { 
  url = aws_eks_cluster.prod_was.identity[0].oidc[0].issuer 
}
resource "aws_iam_openid_connect_provider" "prod_was" { 
  client_id_list  = ["sts.amazonaws.com"] 
  thumbprint_list = [data.tls_certificate.prod_was.certificates[0].sha1_fingerprint] 
  url             = data.tls_certificate.prod_was.url 
}
resource "aws_security_group_rule" "prod-node-exporter" {
  security_group_id         = aws_eks_cluster.prod_was.vpc_config[0].cluster_security_group_id
  type                      = "ingress"
  cidr_blocks               = [for s in data.aws_subnet.shared_int : s.cidr_block]
  protocol                  = "tcp"
  from_port                 = 9100
  to_port                   = 9100
  depends_on = [ 
    aws_eks_cluster.prod_was,
    aws_eks_node_group.prod_was
  ]
}
resource "aws_security_group_rule" "prod-kube-state-metrics" {
  security_group_id         = aws_eks_cluster.prod_was.vpc_config[0].cluster_security_group_id
  type                      = "ingress"
  cidr_blocks               = [for s in data.aws_subnet.shared_int : s.cidr_block]
  protocol                  = "tcp"
  from_port                 = 31569
  to_port                   = 31569
  depends_on = [ 
    aws_eks_cluster.prod_was,
    aws_eks_node_group.prod_was
  ]
}