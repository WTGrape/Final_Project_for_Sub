###
# 1. cluster role
###
resource "aws_iam_role" "was-cluster" { 
  name               = "eks-cluster-was"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role.json 
} 
resource "aws_iam_role_policy_attachment" "was-AmazonEKSClusterPolicy" { 
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" 
  role       = aws_iam_role.was-cluster.name 
} 
# Optionally, enable Security Groups for Pods 
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html 
resource "aws_iam_role_policy_attachment" "was-AmazonEKSVPCResourceController" { 
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController" 
  role       = aws_iam_role.was-cluster.name 
} 
###
# 2. node role
###
resource "aws_iam_role" "was-node" { 
  name = "eks-node-was" 
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
} 
resource "aws_iam_role_policy_attachment" "was-AmazonEKSWorkerNodePolicy" { 
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy" 
  role       = aws_iam_role.was-node.name 
} 
resource "aws_iam_role_policy_attachment" "was-AmazonEKS_CNI_Policy" { 
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy" 
  role       = aws_iam_role.was-node.name 
} 
resource "aws_iam_role_policy_attachment" "was-AmazonEC2ContainerRegistryReadOnly" { 
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" 
  role       = aws_iam_role.was-node.name 
} 
resource "aws_iam_role_policy_attachment" "was-CloudWatchAgentServerPolicy" { 
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy" 
  role       = aws_iam_role.was-node.name 
}
resource "aws_iam_role_policy_attachment" "was-AmazonS3FullAccess" { 
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess" 
  role       = aws_iam_role.was-node.name 
}
###
# 3-1. IAM for EKS to Firehose (test_dev)
###
resource "aws_iam_role" "role-eks-test-dev-to-firehose" {
  name = "role-eks-test-dev-to-firehose"
  
  assume_role_policy = data.aws_iam_policy_document.eks_test_dev_to_firehose_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "role-eks-to-firehose-policy-test-dev-1" {
  role      = aws_iam_role.role-eks-test-dev-to-firehose.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess"
}

###
# 3-2. IAM for EKS to Firehose (prod)
###

resource "aws_iam_role" "role-eks-prod-to-firehose" {
  name = "role-eks-prod-to-firehose"
  
  assume_role_policy = data.aws_iam_policy_document.eks_prod_to_firehose_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "role-eks-to-firehose-policy-prod-1" {
  role      = aws_iam_role.role-eks-prod-to-firehose.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess"
}
###
# 4-1. IAM for Firehose to Openserch (Public)
###
resource "aws_iam_role" "role-firehose-to-opensearch" {
  name = "role-firehose-to-opensearch"
  
  assume_role_policy = data.aws_iam_policy_document.firehose_to_opensearch_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "role-firehose-to-opensearch-policy-1" {
  role      = aws_iam_role.role-firehose-to-opensearch.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "role-firehose-to-opensearch-policy-2" {
  role      = aws_iam_role.role-firehose-to-opensearch.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonOpenSearchServiceFullAccess"
}

resource "aws_iam_role_policy_attachment" "role-firehose-to-opensearch-policy-4" {
  role      = aws_iam_role.role-firehose-to-opensearch.name
  policy_arn = aws_iam_policy.firehose-to-lambda.arn
}

###
# 4-2. IAM policy for Opensearch (when VPC based, please add)
###
resource "aws_iam_role_policy_attachment" "role-firehose-to-opensearch-policy-3" {
  role      = aws_iam_role.role-firehose-to-opensearch.name
  policy_arn = aws_iam_policy.firehose-to-vpc-opensearch.arn
}

###
# 5. IAM policy for Cloudtrail to Cloudwatch
###

resource "aws_iam_role" "role-cloudtrail-to-cloudwatch" {
  name = "role-cloudtrail-to-cloudwatch"
  
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "role-cloudtrail-policy-1" {
  role      = aws_iam_role.role-cloudtrail-to-cloudwatch.name
  policy_arn = aws_iam_policy.cloudtrail-policy-1.arn
}

###
# 6. IAM role for Cloudwatch to Opensearch(Lambda)
###
resource "aws_iam_role" "role-cloudwatch-to-opensearch" {
  name = "role-cloudwatch-to-opensearch"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "role-cloudwatch-to-opensearch-policy-1" {
  role      = aws_iam_role.role-cloudwatch-to-opensearch.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonOpenSearchServiceFullAccess"
}

resource "aws_iam_role_policy_attachment" "role-cloudwatch-to-opensearch-policy-2" {
  role      = aws_iam_role.role-cloudwatch-to-opensearch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
###
# 7. IAM role for cloudwatch to firehose(rds)
###
resource "aws_iam_role" "role-cloudwatch-to-firehose-db" {
  name = "role-cloudwatch-to-firehose-db"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_rds_logging-entity.json
}
resource "aws_iam_role_policy_attachment" "role-cloudwatch-to-firehose-db" {
  role      = aws_iam_role.role-cloudwatch-to-firehose-db.name
  policy_arn = aws_iam_policy.cloudwatch_rds_logging.arn
}
###
# 8. IAM role for lambda to firehose
###
resource "aws_iam_role" "role-lambda-to-firehose" {
  name = "role-lambda-to-firehose"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}
resource "aws_iam_role_policy_attachment" "role-lambda-to-firehose" {
  role      = aws_iam_role.role-lambda-to-firehose.name
  policy_arn = aws_iam_policy.lambda_to_firehose.arn
}
resource "aws_iam_role_policy_attachment" "role-lambda-to-firehose-2" {
  role      = aws_iam_role.role-lambda-to-firehose.name
  policy_arn = aws_iam_policy.firehose-to-vpc-opensearch.arn
}
resource "aws_iam_role_policy_attachment" "role-lambda-to-firehose-3" {
  role      = aws_iam_role.role-lambda-to-firehose.name
  policy_arn = aws_iam_policy.lambda_to_cloudwatch.arn
}