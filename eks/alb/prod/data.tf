###
# 1. production was
###
data "aws_vpc" "prod_vpc" {
    filter {
        name   = "tag:Name"
        values = ["production"]
    }
}
data "aws_eks_cluster" "prod_was" {
    name = "prod_was"
}
data "aws_eks_cluster_auth" "prod_was" { 
    name = "prod_was" 
}
data "tls_certificate" "prod_was" { 
    url = data.aws_eks_cluster.prod_was.identity[0].oidc[0].issuer 
}
data "aws_iam_openid_connect_provider" "prod_was" {
    url = data.aws_eks_cluster.prod_was.identity[0].oidc[0].issuer 
}
###
# 2. role
###
data "http" "iam_policy" { 
    url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.1/docs/install/iam_policy.json"
}
###
# 3. argo acm arn
###
data "aws_acm_certificate" "click" {
  domain   = local.click_name[0]
  statuses = ["ISSUED"]
}