###
# 1. test develope relem
###
resource "aws_eks_node_group" "test_dev_was" {
  cluster_name    = aws_eks_cluster.test_dev_was.name 
  node_group_name = "test_dev_was_node_Group" 
  node_role_arn   = aws_iam_role.was-node.arn 
  subnet_ids      = data.aws_subnets.test_dev_node.ids
  scaling_config { 
    desired_size = 2 
    max_size     = 6 
    min_size     = 2 
  }
  update_config { 
    max_unavailable = 1 
  } 
# Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling. 
# Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces. 
  depends_on = [ 
    aws_iam_role_policy_attachment.was-AmazonEKSWorkerNodePolicy, 
    aws_iam_role_policy_attachment.was-AmazonEKS_CNI_Policy, 
    aws_iam_role_policy_attachment.was-AmazonEC2ContainerRegistryReadOnly, 
    aws_iam_role_policy_attachment.was-CloudWatchAgentServerPolicy 
  ] 
}
###
# 2. production relem
###
resource "aws_eks_node_group" "prod_was" {
  cluster_name    = aws_eks_cluster.prod_was.name 
  node_group_name = "prod_was_node_Group" 
  node_role_arn   = aws_iam_role.was-node.arn 
  subnet_ids      = data.aws_subnets.prod_node.ids
  scaling_config { 
    desired_size = 2 
    max_size     = 6 
    min_size     = 2 
  } 
  update_config { 
    max_unavailable = 1 
  } 
 
# Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling. 
# Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces. 
  depends_on = [ 
    aws_iam_role_policy_attachment.was-AmazonEKSWorkerNodePolicy, 
    aws_iam_role_policy_attachment.was-AmazonEKS_CNI_Policy, 
    aws_iam_role_policy_attachment.was-AmazonEC2ContainerRegistryReadOnly, 
    aws_iam_role_policy_attachment.was-CloudWatchAgentServerPolicy 
  ] 
} 