###
# 1. test_dev_was
###
data "aws_vpc" "test_dev_vpc" {
    filter {
        name   = "tag:Name"
        values = ["test-dev"]
    }
}
data "aws_eks_cluster" "test_dev_was" {
    name = "test_dev_was"
}
data "aws_eks_cluster_auth" "test_dev_was" { 
    name = "test_dev_was" 
}
data "tls_certificate" "test_dev_was" { 
    url = data.aws_eks_cluster.test_dev_was.identity[0].oidc[0].issuer 
}
data "aws_iam_openid_connect_provider" "test_dev_was" {
    url = data.aws_eks_cluster.test_dev_was.identity[0].oidc[0].issuer 
}
###
# 2. role
###
data "http" "iam_policy" { 
    url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.1/docs/install/iam_policy.json"
}
###
# 3. RDS endpoint
###
data "aws_db_instance" "test_dev" {
  db_instance_identifier = "test-dev-db"
}
###
# security group
###
# pod security group 에서 사용하려 했었다.
# 현재 사용하는 node instance type 에서는 지원하지 않는다.
# data "aws_security_group" "test_dev_pod_security_group" {
#     filter {
#       name = "tag:Name"
#       values = ["test_dev_pod_db_sg"]
#     }
# }
# data "aws_security_group" "prod_pod_security_group" {
#     filter {
#       name = "tag:Name"
#       values = ["prod_pod_db_sg"]
#     }
# }